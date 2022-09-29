# frozen_string_literal: true

module Eien
  module Domains
    class DeleteTask < Task
      attr_reader :app, :domain

      def initialize(context, app, name)
        @app = Eien.app_from_name(context, app)
        @domain = name
        super(context)
      end

      def run!
        client = kubeclient_builder.build_eien_kubeclient(context)
        domains = client.get_domains(namespace: app.spec.namespace)
        domains.map do |domain_resource|
          next unless domain_resource.spec.domain == domain

          client.delete_domain(domain_resource.metadata.name, app.spec.namespace)
        end
      end
    end
  end
end
