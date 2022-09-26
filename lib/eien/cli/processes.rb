# frozen_string_literal: true

require "eien"
require "thor"

require "eien/processes/list_task"
require "eien/processes/set_enable_task"

module Eien
  module CLI
    class Processes < CLI
      desc "list APP", "lists processes"
      option :context, aliases: %i[c]

      def list(app)
        rescue_and_exit do
          ::Eien::Processes::ListTask.new(
            ::Eien.context_or_default(options[:context]),
            app
          ).run!
        end
      end

      desc "enable APP PROCESS", "enables process"
      option :context, aliases: %i[c]

      def enable(app, process)
        rescue_and_exit do
          ::Eien::Processes::SetEnableTask.new(
            ::Eien.context_or_default(options[:context]),
            app,
            process,
            true
          ).run!
        end
      end

      desc "disable APP PROCESS", "disables process"
      option :context, aliases: %i[c]

      def disable(app, process)
        rescue_and_exit do
          ::Eien::Processes::SetEnableTask.new(
            ::Eien.context_or_default(options[:context]),
            app,
            process,
            false
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
