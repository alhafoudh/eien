# frozen_string_literal: true

require "thor"
require "tty-table"
require "colorized_string"

module Eien
  module CLI
    class CLI < Thor
      def self.exit_on_failure?
        true
      end

      private

      def rescue_and_exit
        yield
      rescue ::Eien::Errors::UserInputError => e
        warn(colorize_error(e.message))
        exit(1)
      rescue Krane::KubeclientBuilder::ContextMissingError => e
        warn(colorize_error(e.message))
        exit(1)
      end

      def require_context!(context)
        require_option!(
          context,
          "#{colorize_error("No context selected.")}\n\n" \
            "Initialize Eien using #{colorize_command("eien init CONTEXT")}" \
            " or context using #{colorize_command("-c CONTEXT")} argument.",
        )
      end

      def require_app!(app)
        require_option!(
          app,
          "#{colorize_error("No app selected.")}\n\n" \
            "Select app using #{colorize_command("eien apps select APP")}" \
            " or supply app name using #{colorize_command("-a APP")} argument.",
        )
      end

      def require_option!(value, message)
        return unless value.nil?

        warn(message)
        exit(1)
      end

      def require_options(allowed_options, default_options = {})
        symbolized_allowed_options = allowed_options.map(&:to_sym)
        symbolized_default_options = default_options.symbolize_keys
        symbolized_options = options.to_h.symbolize_keys

        symbolized_default_options.merge(symbolized_options.slice(*symbolized_allowed_options))
      end

      def colorize_error(error)
        ColorizedString.new(error).light_red
      end

      def colorize_command(command)
        ColorizedString.new(command).yellow
      end

      def confirm!(message, value)
        require "tty-prompt"

        instructions = "To confirm, please type '#{value}'"
        prompt = TTY::Prompt.new
        result = prompt.ask("#{message} #{instructions}:") do |question|
          question.required(true)
          question.validate(/\A#{value}\z/, "#{instructions}.")
        end

        result == value
      end
    end
  end
end
