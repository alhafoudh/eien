# frozen_string_literal: true

require "eien/config/list_task"
require "eien/config/update_task"
require "eien/config/export_task"

module Eien
  module CLI
    class Config < CLI
      desc "list", "lists config values"
      option :context, aliases: %i[c]
      option :app, aliases: %i[a]
      option :name, aliases: %i[n]

      def list
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_app!(app)

          ::Eien::Config::ListTask.new(
            context,
            app,
            options[:name] || "default"
          ).run!
        end
      end

      desc "export", "exports config values"
      option :context, aliases: %i[c]
      option :app, aliases: %i[a]
      option :name, aliases: %i[n]

      def export
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_app!(app)

          ::Eien::Config::ExportTask.new(
            context,
            app,
            options[:name] || "default"
          ).run!
        end
      end

      desc "set KEY=VALUE [...]", "sets config values"
      option :context, aliases: %i[c]
      option :app, aliases: %i[a]
      option :name, aliases: %i[n]

      def set(*raw_key_pairs)
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_app!(app)

          key_pairs = raw_key_pairs.each_with_object({}) do |raw_key_pair, key_pairs|
            key, value = raw_key_pair.split("=")
            key_pairs[key] = value
          end

          ::Eien::Config::UpdateTask.new(
            context,
            app,
            options[:name] || "default",
            **key_pairs
          ).run!
        end
      end

      desc "unset KEY [...]", "unsets config values"
      option :context, aliases: %i[c]
      option :app, aliases: %i[a]
      option :name, aliases: %i[n]

      def unset(*keys)
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_app!(app)

          key_pairs = keys.each_with_object({}) do |key, key_pairs|
            key_pairs[key] = nil
          end

          ::Eien::Config::UpdateTask.new(
            context,
            app,
            options[:name] || "default",
            **key_pairs
          ).run!
        end
      end
    end
  end
end