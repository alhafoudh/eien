# frozen_string_literal: true

module Eien
  module Domains
    class UpdateTask < Task
      ALLOWED_ATTRIBUTES = %i[enabled name].freeze

      attr_reader :app, :domain, :attributes

      def initialize(context, app, name, **attributes)
        @app = Eien.app_from_name(context, app)
        @name = name
        @attributes = attributes
        super(context)
      end

      def run!
        client = kubeclient_builder.build_eien_kubeclient(context)
        domains = client.get_domains(namespace: app.spec.namespace)
        domains.map do |domain_resource|
          domain_resource.spec = (domain_resource.spec&.to_h || {}).merge(attributes)

          client.update_domain(domain_resource)
        end
      end

      private

      def prepare_attributes
        attributes.except(:domain).merge(domain: domain)
      end
    end
  end
end
