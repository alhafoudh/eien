# frozen_string_literal: true

require "eien/renderers/deployment_renderer"
require "eien/renderers/service_renderer"

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

        render_status(app, deployments, processes, services)
      end

      private

      def render_status(app, deployments, processes, services)
        puts colorize(app.metadata.name).yellow

        processes.map do |process|
          deployment = deployments[process.metadata.name]
          service = services[process.metadata.name]

          puts
          puts colorize(process.metadata.name).light_cyan

          unless deployment
            warn!("Process #{process.metadata.name} is not deployed yet.")
            next
          end

          puts
          puts TTY::Table.new(
            [
              "  Deployment",
              service ? "  Service" : "",
            ],
            [
              [
                ::Eien::Renderers::DeploymentRenderer.new(deployment).render,
                service ? ::Eien::Renderers::ServiceRenderer.new(service).render : "",
              ],
            ],
          ).render(:basic, multiline: true, padding: [0, 1])
          puts
        end
      end
    end
  end
end
