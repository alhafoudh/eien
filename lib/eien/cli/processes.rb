# frozen_string_literal: true

require "eien"
require "thor"

require "eien/processes/list_task"
require "eien/processes/update_task"

module Eien
  module CLI
    class Processes < CLI
      desc "list", "lists processes"
      option :context, aliases: %i[c]
      option :app, aliases: %i[a]

      def list
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_app!(app)

          ::Eien::Processes::ListTask.new(
            context,
            app
          ).run!
        end
      end

      desc "enable PROCESS", "enables process"
      option :context, aliases: %i[c]
      option :app, aliases: %i[a]

      def enable(process)
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_app!(app)

          ::Eien::Processes::UpdateTask.new(
            context,
            app,
            process,
            enabled: true
          ).run!
        end
      end

      desc "disable PROCESS", "disables process"
      option :context, aliases: %i[c]
      option :app, aliases: %i[a]

      def disable(process)
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_app!(app)

          ::Eien::Processes::UpdateTask.new(
            context,
            app,
            process,
            enabled: false
          ).run!
        end
      end

      # desc "create NAME", "creates app"
      # option :context, aliases: %i[c]
      # option :namespace, aliases: %i[n]
      #
      # def create(name)
      #   ::Eien::Apps::CreateTask.new(
      #     name,
      #     options[:namespace] || name,
      #     ::Eien.context_or_default(options[:context])
      #   ).run!
      # end
    end
  end
end
