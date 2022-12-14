# frozen_string_literal: true

module Eien
  module CLI
    class Secrets < CLI
      class_option :context, aliases: [:c]
      class_option :app, aliases: [:a]
      class_option :name, aliases: [:n]

      desc "list", "lists secrets"
      map ls: :list

      def list
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_app!(app)

          ::Eien::Secrets::ListTask.new(
            context,
            app,
            options[:name] || "default",
          ).run!
        end
      end

      desc "export", "exports secrets"

      def export
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_app!(app)

          ::Eien::Secrets::ExportTask.new(
            context,
            app,
            options[:name] || "default",
          ).run!
        end
      end

      desc "set KEY=VALUE [...]", "sets secrets"

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

          ::Eien::Secrets::UpdateTask.new(
            context,
            app,
            options[:name] || "default",
            **key_pairs,
          ).run!
        end
      end

      desc "unset KEY [...]", "unsets secrets"

      def unset(*keys)
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_app!(app)

          key_pairs = keys.each_with_object({}) do |key, key_pairs|
            key_pairs[key] = nil
          end

          ::Eien::Secrets::UpdateTask.new(
            context,
            app,
            options[:name] || "default",
            **key_pairs,
          ).run!
        end
      end
    end
  end
end
