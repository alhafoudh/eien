# frozen_string_literal: true

require "eien"
require "thor"

require "eien/processes/list_task"
require "eien/processes/update_task"
require "eien/processes/create_task"
require "eien/processes/delete_task"

module Eien
  module CLI
    class Processes < CLI
      def self.process_options
        option :enabled, type: :boolean
        option :image
        option :command, type: :array
        option :replicas, type: :numeric
        option :ports, type: :hash
        option :"no-ports", type: :boolean
      end

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

      desc "create NAME", "creates process"
      option :context, aliases: %i[c]
      option :app, aliases: %i[a]

      process_options

      def create(name)
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_app!(app)

          attributes = options.slice(*%w[enabled image command replicas ports]).symbolize_keys

          ::Eien::Processes::CreateTask.new(
            context,
            app,
            name,
            **attributes
          ).run!
        end
      end

      desc "update NAME", "updates process"
      option :context, aliases: %i[c]
      option :app, aliases: %i[a]

      process_options

      def update(name)
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_app!(app)

          attributes = options.slice(*::Eien::Processes::UpdateTask::ALLOWED_ATTRIBUTES.map(&:to_s)).symbolize_keys
          attributes[:ports] = {} if options[:"no-ports"]

          ::Eien::Processes::UpdateTask.new(
            context,
            app,
            name,
            **attributes
          ).run!
        end
      end

      desc "delete NAME", "deletes process"
      option :context, aliases: %i[c]
      option :app, aliases: %i[a]

      def delete(name)
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_app!(app)

          ::Eien::Processes::DeleteTask.new(
            context,
            app,
            name
          ).run!
        end
      end
    end
  end
end
