# frozen_string_literal: true

module Eien
  module CLI
    class Domains < CLI
      class_option :context, aliases: [:c]
      class_option :app, aliases: [:a]

      def self.domain_options
        option(:enabled, type: :boolean)
      end

      desc "list", "lists domains"
      map ls: :list

      def list
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_app!(app)

          ::Eien::Domains::ListTask.new(
            context,
            app,
          ).run!
        end
      end

      desc "enable DOMAIN", "enables domain"

      def enable(domain)
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_app!(app)

          ::Eien::Domains::UpdateTask.new(
            context,
            app,
            domain,
            enabled: true,
          ).run!
        end
      end

      desc "disable DOMAIN", "disables domain"

      def disable(domain)
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_app!(app)

          ::Eien::Domains::UpdateTask.new(
            context,
            app,
            domain,
            enabled: false,
          ).run!
        end
      end

      desc "create DOMAIN", "creates domain"
      option :domain
      option :enabled, type: :boolean
      option :name
      domain_options

      def create(domain)
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_app!(app)

          default_attributes = { enabled: true }
          attributes = default_attributes
            .merge(options.slice(*::Eien::Domains::UpdateTask::ALLOWED_ATTRIBUTES.map(&:to_s)).symbolize_keys)

          ::Eien::Domains::CreateTask.new(
            context,
            app,
            domain,
            **attributes,
          ).run!
        end
      end

      # desc "update DOMAIN", "updates domain"
      #
      # domain_options
      #
      # def update(domain)
      #   rescue_and_exit do
      #     context = ::Eien.context_or_default(options[:context])
      #     app = ::Eien.app_or_default(options[:app])
      #
      #     require_context!(context)
      #     require_app!(app)
      #
      #     attributes = options.slice(*::Eien::Domains::UpdateTask::ALLOWED_ATTRIBUTES.map(&:to_s)).symbolize_keys
      #
      #     ::Eien::Domains::UpdateTask.new(
      #       context,
      #       app,
      #       domain,
      #       **attributes
      #     ).run!
      #   end
      # end

      desc "delete DOMAIN", "deletes domain"

      def delete(domain)
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_app!(app)

          ::Eien::Domains::DeleteTask.new(
            context,
            app,
            domain,
          ).run!
        end
      end
    end
  end
end
