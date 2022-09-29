# frozen_string_literal: true

module Eien
  module Deploy
    class GenerateTask < Task
      attr_reader :app

      def initialize(context, app)
        @app = app
        super(context)
      end

      def run!
        the_app = Eien.app_from_name(context, app)
        client = kubeclient_builder.build_eien_kubeclient(context)
        target_namespace = the_app.spec.namespace

        resources = []

        processes = client.get_processes(namespace: target_namespace)
        routes = client.get_routes(namespace: target_namespace)

        resources += generate_for_processes(processes, the_app)
        resources += generate_for_routes(routes, the_app)

        resources
      end

      private

      def generate_for_processes(processes, app)
        target_namespace = app.spec.namespace

        v1_client = kubeclient_builder.build_v1_kubeclient(context)

        processes.each_with_object([]) do |process, resources|
          config = begin
            v1_client.get_config_map(::Eien.config_map_name(process.spec.config), target_namespace)
          rescue Kubeclient::ResourceNotFoundError
            Kubeclient::Resource.new(data: {})
          end
          secret = begin
            v1_client.get_secret(::Eien.secret_name(process.spec.secret), target_namespace)
          rescue Kubeclient::ResourceNotFoundError
            Kubeclient::Resource.new(data: {})
          end

          next unless process.spec.enabled

          resources << generate_deployment(app, process, config, secret)

          next unless process.spec.ports.to_h.any?

          resources << generate_service(app, process)
        end
      end

      def generate_for_routes(routes, app)
        app_name = app.metadata.name
        target_namespace = app.spec.namespace

        domain_routes = routes.each_with_object({}) do |route, map|
          next unless route.spec.enabled

          route.spec.domains.map do |domain|
            map[domain] ||= []
            map[domain] << route
          end
        end

        [
          Kubeclient::Resource.new(
            apiVersion: "networking.k8s.io/v1",
            kind: "Ingress",
            metadata: {
              name: app_name,
              namespace: target_namespace,
              labels: {
                "#{::Eien::LABEL_PREFIX}/app": app_name,
              },
            },
            spec: {
              rules: domain_routes.map do |domain, routes|
                {
                  host: domain,
                  http: {
                    paths: routes.map do |route|
                      {
                        path: route.spec.path,
                        pathType: "Prefix",
                        backend: {
                          service: {
                            name: route.spec.process,
                            port: {
                              name: route.spec.port,
                            },
                          },
                        },
                      }
                    end,
                  },
                }
              end,
            },
          )
        ]
      end

      def generate_deployment(app, process, config_map, secret)
        app_name = app.metadata.name
        target_namespace = app.spec.namespace
        process_name = process.metadata.name

        Kubeclient::Resource.new(
          apiVersion: "apps/v1",
          kind: "Deployment",
          metadata: {
            name: process_name,
            namespace: target_namespace,
            labels: {
              "#{::Eien::LABEL_PREFIX}/app": app_name,
              "#{::Eien::LABEL_PREFIX}/process": process_name,
            },
          },
          spec: {
            replicas: process.spec.replicas,
            selector: {
              matchLabels: {
                "#{::Eien::LABEL_PREFIX}/app": app_name,
                "#{::Eien::LABEL_PREFIX}/process": process_name,
              },
            },
            template: {
              metadata: {
                labels: {
                  "#{::Eien::LABEL_PREFIX}/app": app_name,
                  "#{::Eien::LABEL_PREFIX}/process": process_name,
                  "#{::Eien::LABEL_PREFIX}/secretHash": Digest::SHA1.hexdigest(secret.to_h.to_yaml),
                  "#{::Eien::LABEL_PREFIX}/configMapHash": Digest::SHA1.hexdigest(config_map.to_h.to_yaml),
                },
              },
              spec: {
                containers: [
                  {
                    name: process_name,
                    image: process.spec.image,
                    args: process.spec.command,
                    ports: process.spec.ports.to_h.map do |name, port|
                      {
                        name: name.to_s,
                        containerPort: port.to_i,
                      }
                    end,
                    env: env_from_config_map(config_map).merge(env_from_secret(secret)).values,
                  }.compact,
                ],
              },
            },
          },
        )
      end

      def generate_service(app, process)
        app_name = app.metadata.name
        target_namespace = app.spec.namespace
        process_name = process.metadata.name

        Kubeclient::Resource.new(
          apiVersion: "v1",
          kind: "Service",
          metadata: {
            name: process_name,
            namespace: target_namespace,
            labels: {
              "#{::Eien::LABEL_PREFIX}/app": app_name,
              "#{::Eien::LABEL_PREFIX}/process": process_name,
            },
          },
          spec: {
            selector: {
              "#{::Eien::LABEL_PREFIX}/app": app_name,
              "#{::Eien::LABEL_PREFIX}/process": process_name,
            },
            type: "ClusterIP",
            ports: process.spec.ports.to_h.map do |name, port|
              {
                name: name.to_s,
                port: port.to_i,
                targetPort: port.to_i,
              }
            end,
          },
        )
      end

      def env_from_config_map(config_map)
        config_map.data.to_h.keys.each_with_object({}) do |key, env|
          env[key] = {
            name: key.to_s,
            valueFrom: {
              configMapKeyRef: {
                name: config_map.metadata.name,
                key: key.to_s,
              },
            },
          }
        end
      end

      def env_from_secret(secret)
        secret.data.to_h.keys.each_with_object({}) do |key, env|
          env[key] = {
            name: key.to_s,
            valueFrom: {
              secretKeyRef: {
                name: secret.metadata.name,
                key: key.to_s,
              },
            },
          }
        end
      end
    end
  end
end
