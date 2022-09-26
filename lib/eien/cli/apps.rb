# frozen_string_literal: true

require "eien/apps/list_task"
require "eien/apps/create_task"
require "eien/apps/select_task"
require "eien/apps/delete_task"
require "eien/apps/status_task"

module Eien
  module CLI
    class Apps < CLI
      class_option :context, aliases: %i[c]

      desc "list", "lists apps"

      def list
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])

          require_context!(context)

          ::Eien::Apps::ListTask.new(context).run!
        end
      end

      desc "create NAME", "creates app"
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

      desc "delete APP", "deletes app"

      def delete(app)
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])

          require_context!(context)

          if confirm!("You are about to delete #{app} app.", app)
            ::Eien::Apps::DeleteTask.new(
              context,
              app
            ).run!
          end
        end
      end

      desc "status", "shows app status"
      option :app, aliases: %i[a]

      def status
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_context!(app)

          ::Eien::Apps::StatusTask.new(
            context,
            app
          ).run!
        end
      end
    end
  end
end
