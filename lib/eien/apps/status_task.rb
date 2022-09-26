# frozen_string_literal: true

module Eien
  module Apps
    class StatusTask < Task
      include ActionView::Helpers::DateHelper

      attr_reader :name

      def initialize(context, name)
        @name = name
        super(context, nil)
      end

      def run!
        v1_client = kubeclient_builder.build_v1_kubeclient(context)
        apps_client = kubeclient_builder.build_apps_v1_kubeclient(context)
        eien_client = kubeclient_builder.build_eien_kubeclient(context)

        app = eien_client.get_app(name)
        app_name = app.metadata.name

        target_namespace = app.spec.namespace
        processes = eien_client.get_processes(namespace: target_namespace)

        all_deployments = apps_client.get_deployments(namespace: target_namespace)
        all_services = v1_client.get_services(namespace: target_namespace)

        deployments = all_deployments.each_with_object({}) do |deployment, deployments|
          deployments[deployment.metadata.labels["#{::Eien::LABEL_PREFIX}/process"]] = deployment
        end

        services = all_services.each_with_object({}) do |service, services|
          services[service.metadata.labels["#{::Eien::LABEL_PREFIX}/process"]] = service
        end

        puts ColorizedString.new(app_name).yellow

        processes.map do |process|
          process_name = process.metadata.name

          puts
          puts ColorizedString.new(process_name).light_cyan
          puts

          deployment = deployments[process.metadata.name]
          service = services[process.metadata.name]

          puts TTY::Table.new(
            [
              "  Deployment",
              service ? "  Service" : ""
            ],
            [
              [
                generate_deployment_panel(deployment),
                service ? generate_service_panel(service) : ""
              ]
            ]
          ).render(:basic, multiline: true, padding: [0, 1])
          puts
        end
      end

      private

      def generate_deployment_panel(deployment)
        created_time_ago = time_ago_in_words(Time.parse(deployment.metadata.creationTimestamp), include_seconds: true)

        status = deployment.status

        condition_message = status.conditions.map do |condition|
          condition_update_time_ago = time_ago_in_words(Time.parse(condition.lastTransitionTime), include_seconds: true)
          "#{colorize_condition_type(condition.type)}\n#{condition.message}\n#{condition_update_time_ago} ago\n"
        end.join("\n")

        rows = [
          ["name", ColorizedString.new(deployment.metadata.name).light_magenta],
          ["", ""],
          ["created", "#{created_time_ago} ago"],
          ["", ""],
          ["replicas", [
            "#{status.replicas} desired",
            "#{status.updatedReplicas} updated",
            "#{status.readyReplicas} ready",
            "#{status.availableReplicas} available"
          ].join("\n")],
          ["", ""],
          ["condition", condition_message]
        ]
        TTY::Table.new(rows).render(:unicode, multiline: true, padding: [0, 1])
      end

      def generate_service_panel(service)
        created_time_ago = time_ago_in_words(Time.parse(service.metadata.creationTimestamp), include_seconds: true)

        status = service.status

        ports_message = service.spec.ports.each_with_object([]) do |port, lines|
          lines << "#{port.nodePort} -> #{port.port}/#{port.name} -> #{port.targetPort}"
        end.join("\n")

        external_ip_message = status.loadBalancer.ingress.map(&:ip).join("\n")

        rows = [
          ["name", ColorizedString.new(service.metadata.name).light_magenta],
          ["", ""],
          ["created", "#{created_time_ago} ago"],
          ["", ""],
          ["cluster IP", service.spec.clusterIP],
          ["", ""],
          ["ports", ports_message],
          ["", ""],
          ["external IP", external_ip_message]
        ]
        TTY::Table.new(rows).render(:unicode, multiline: true, padding: [0, 1])
      end

      def colorize_condition_type(type)
        color = case type
        when "Available" then :light_green
        when "Progressing" then :yellow
        else
          :white
        end

        ColorizedString.new(type).public_send(color)
      end
    end
  end
end
