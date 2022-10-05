# frozen_string_literal: true

module Eien
  module CLI
    class Routes < CLI
      class_option :context, aliases: [:c]
      class_option :app, aliases: [:a]

      def self.route_options
        option(:enabled, type: :boolean)
        option(:domains, type: :array)
        option(:path)
        option(:process)
        option(:port)
      end

      desc "list", "lists routes"
      map ls: :list

      def list
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_app!(app)

          ::Eien::Routes::ListTask.new(
            context,
            app,
          ).run!
        end
      end

      desc "enable ROUTE", "enables route"

      def enable(route)
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_app!(app)

          ::Eien::Routes::UpdateTask.new(
            context,
            app,
            route,
            enabled: true,
          ).run!
        end
      end

      desc "disable ROUTE", "disables route"

      def disable(route)
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_app!(app)

          ::Eien::Routes::UpdateTask.new(
            context,
            app,
            route,
            enabled: false,
          ).run!
        end
      end

      desc "create NAME", "creates route"

      route_options

      def create(name)
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_app!(app)

          default_attributes = { enabled: true }
          attributes = default_attributes.merge(options.slice(*::Eien::Routes::UpdateTask::ALLOWED_ATTRIBUTES.map(&:to_s)).symbolize_keys)

          ::Eien::Routes::CreateTask.new(
            context,
            app,
            name,
            **attributes,
          ).run!
        end
      end

      desc "update NAME", "updates route"

      route_options

      def update(name)
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_app!(app)

          attributes = options.slice(*::Eien::Routes::UpdateTask::ALLOWED_ATTRIBUTES.map(&:to_s)).symbolize_keys

          ::Eien::Routes::UpdateTask.new(
            context,
            app,
            name,
            **attributes,
          ).run!
        end
      end

      desc "delete NAME", "deletes route"

      def delete(name)
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_app!(app)

          ::Eien::Routes::DeleteTask.new(
            context,
            app,
            name,
          ).run!
        end
      end
    end
  end
end
