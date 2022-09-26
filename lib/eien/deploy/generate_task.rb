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
        app_name = the_app.metadata.name

        processes = client.get_processes(namespace: target_namespace)

        # default_secret = get_secret('default')
        processes.each_with_object([]) do |process, resources|
          next unless process.spec.enabled

          process_name = process.metadata.name

          resources << generate_deployment(app_name, process, process_name, target_namespace)

          next unless process.spec.ports.to_h.any?

          resources << generate_service(app_name, process, process_name, target_namespace)
        end
      end

      private

      def generate_deployment(app_name, process, process_name, target_namespace)
        Kubeclient::Resource.new(
          apiVersion: "apps/v1",
          kind: "Deployment",
          metadata: {
            name: process_name,
            namespace: target_namespace,
            labels: {
              "#{::Eien::LABEL_PREFIX}/app": app_name,
              "#{::Eien::LABEL_PREFIX}/process": process_name
            }
          },
          spec: {
            replicas: process.spec.replicas,
            selector: {
              matchLabels: {
                "#{::Eien::LABEL_PREFIX}/app": app_name,
                "#{::Eien::LABEL_PREFIX}/process": process_name
              }
            },
            template: {
              metadata: {
                labels: {
                  "#{::Eien::LABEL_PREFIX}/app": app_name,
                  "#{::Eien::LABEL_PREFIX}/process": process_name
                  # "#{::Eien::LABEL_PREFIX}/secretsHash": Digest::SHA1.hexdigest(default_secret.to_h.to_yaml)
                }
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
                        containerPort: port.to_i
                      }
                    end
                    # env: default_secret.data.to_h.map do |key, value|
                    #   {
                    #     name: key.to_s,
                    #     valueFrom: {
                    #       secretKeyRef: {
                    #         name: default_secret.metadata.name,
                    #         key: key.to_s,
                    #       }
                    #     }
                    #   }
                    # end,
                  }.compact
                ]
              }
            }
          }
        )
      end

      def generate_service(app_name, process, process_name, target_namespace)
        Kubeclient::Resource.new(
          apiVersion: "v1",
          kind: "Service",
          metadata: {
            name: process_name,
            namespace: target_namespace,
            labels: {
              "#{::Eien::LABEL_PREFIX}/app": app_name,
              "#{::Eien::LABEL_PREFIX}/process": process_name
            }
          },
          spec: {
            selector: {
              "#{::Eien::LABEL_PREFIX}/app": app_name,
              "#{::Eien::LABEL_PREFIX}/process": process_name
            },
            type: "NodePort",
            ports: process.spec.ports.to_h.map do |name, port|
              {
                name: name.to_s,
                port: port.to_i,
                targetPort: port.to_i
              }
            end
          }
        )
      end

    end
  end
end
