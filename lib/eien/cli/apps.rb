# frozen_string_literal: true

require "eien"
require "thor"

require "eien/apps/list_task"
require "eien/apps/create_task"

module Eien
  module CLI
    class Apps < CLI
      desc "list", "lists apps"
      option :context, aliases: %i[c]

      def list
        rescue_and_exit do
          ::Eien::Apps::ListTask.new(::Eien.context_or_default(options[:context])).run!
        end
      end

      desc "create NAME", "creates app"
      option :context, aliases: %i[c]
      option :namespace, aliases: %i[n]

      def create(name)
        rescue_and_exit do
          ::Eien::Apps::CreateTask.new(
            name,
            options[:namespace] || name,
            ::Eien.context_or_default(options[:context])
          ).run!
        end
      end
    end
  end
end
