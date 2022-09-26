# frozen_string_literal: true

require "thor"
require "tty-table"
require "colorized_string"
require "action_view"
require "action_view/helpers"

require "eien"

module Eien
  module CLI
    class CLI < Thor
      private

      def rescue_and_exit
        yield
      rescue ::Eien::UserInputError => e
        $stderr.puts(e.message)
        exit(1)
      end
    end
  end
end
