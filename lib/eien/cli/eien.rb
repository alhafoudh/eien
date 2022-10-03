# frozen_string_literal: true

require "thor"
require "colorized_string"
require "irb"

require "eien"

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
        require "irb"
        IRB.start
      end

      desc "apps", "manage apps"
      subcommand :apps, Apps

      desc "ps", "manage processes"
      subcommand :ps, Processes

      desc "config", "manage config"
      subcommand :config, Config

      desc "secrets", "manage secrets"
      subcommand :secrets, Secrets

      desc "domains", "manage domains"
      subcommand :domains, Domains

      desc "routes", "manage routes"
      subcommand :routes, Routes

      desc "deploy", "manage deployment"
      subcommand :deploy, Deploy
    end
  end
end
