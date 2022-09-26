# frozen_string_literal: true

require "thor"
require "tty-table"
require "colorized_string"
require "action_view"
require "action_view/helpers"

require "eien"
require "eien/init_task"

require "eien/cli/cli"
require "eien/cli/apps"
require "eien/cli/processes"

module Eien
  module CLI
    class Eien < CLI
      package_name "Eien"

      desc "init", "initialize Eien dependencies inside cluster"
      option :context, aliases: %i[c]

      def init
        rescue_and_exit do
          InitTask.new(::Eien.context_or_default(options[:context])).run!
        end
      end

      desc "apps", "manage apps"
      subcommand :apps, Apps

      desc "ps", "manage processes"
      subcommand :ps, Processes
    end
  end
end
