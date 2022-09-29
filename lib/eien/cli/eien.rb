# frozen_string_literal: true

require "thor"
require "tty-table"
require "colorized_string"
require "action_view"
require "action_view/helpers"
require "irb"

require "eien"
require "eien/init_task"

require "eien/cli/cli"
require "eien/cli/apps"
require "eien/cli/processes"
require "eien/cli/config"
require "eien/cli/secrets"
require "eien/cli/deploy"

module Eien
  module CLI
    class Eien < CLI
      package_name "Eien"

      desc "version", "print Eien version"

      def version
        rescue_and_exit do
          puts ::Eien::VERSION
        end
      end

      desc "init CONTEXT", "initialize Eien dependencies inside cluster context"

      def init(context)
        rescue_and_exit do
          InitTask.new(context).run!
        end
      end

      desc "console", "start interactive console"

      def console
        binding.irb
      end

      desc "apps", "manage apps"
      subcommand :apps, Apps

      desc "ps", "manage processes"
      subcommand :ps, Processes

      desc "config", "manage config"
      subcommand :config, Config

      desc "secrets", "manage secrets"
      subcommand :secrets, Secrets

      desc "deploy", "manage deployment"
      subcommand :deploy, Deploy
    end
  end
end
