# frozen_string_literal: true

require "eien"
require "thor"

require "eien/apps/list_task"
require "eien/apps/create_task"
require "eien/apps/select_task"

module Eien
  module CLI
    class Apps < CLI
      desc "list", "lists apps"
      option :context, aliases: %i[c]

      def list
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])

          require_context!(context)

          ::Eien::Apps::ListTask.new(context).run!
        end
      end

      desc "create NAME", "creates app"
      option :context, aliases: %i[c]
      option :namespace, aliases: %i[n]

      def create(name)
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])

          require_context!(context)

          ::Eien::Apps::CreateTask.new(
            context,
            name,
            options[:namespace] || name
          ).run!
        end
      end

      desc "select APP", "selects app"

      def select(app)
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])

          require_context!(context)

          ::Eien::Apps::SelectTask.new(
            context,
            app
          ).run!
        end
      end
    end
  end
end
