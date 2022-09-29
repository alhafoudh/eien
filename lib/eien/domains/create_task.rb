# frozen_string_literal: true

module Eien
  module Domains
    class CreateTask < Task
      attr_reader :app, :domain, :attributes

      def initialize(context, app, domain, **attributes)
        @app = Eien.app_from_name(context, app)
        @domain = domain
        @attributes = attributes
        super(context)
      end

      def run!
        client = kubeclient_builder.build_eien_kubeclient(context)

        domain = Kubeclient::Resource.new(
          metadata: {
            name: attributes[:name] || name_from_domain,
            namespace: app.spec.namespace,
            labels: {
              "#{::Eien::LABEL_PREFIX}/app": app.metadata.domain,
            },
          },
          spec: prepare_attributes,
        )

        client.create_domain(domain)
      end

      private

      def name_from_domain
        if domain.start_with?("*")
          "#{domain.parameterize}-wildcard"
        else
          domain.parameterize
        end
      end

      def prepare_attributes
        attributes.except(:domain).merge(domain: domain)
      end
    end
  end
end
