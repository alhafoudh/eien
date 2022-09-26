# frozen_string_literal: true

require "eien/deploy/generate_task"

module Eien
  module Deploy
    class ApplyTask < Task
      attr_reader :app

      def initialize(context, app)
        @app = app
        super(context)
      end

      def run!
        the_app = Eien.app_from_name(context, app)
        app_name = the_app.metadata.name

        resources = ::Eien::Deploy::GenerateTask.new(context, app_name).run!

        temp_file = Tempfile.new(%w[eien_generated_resources .yaml])
        begin
          resources.map do |resource|
            temp_file.write(resource.to_h.deep_stringify_keys.to_yaml)
          end

          temp_file.close

          deploy_options = Krane::CLI::DeployCommand::OPTIONS.each_with_object(HashWithIndifferentAccess.new) do |(key, option), options|
            options[key] = option[:default]
          end

          deploy_options[:filenames] << temp_file.path
          deploy_options[:selector] = "#{::Eien::LABEL_PREFIX}/app=#{app_name}"

          Krane::CLI::DeployCommand.from_options(
            the_app.spec.namespace,
            context,
            deploy_options
          )
        ensure
          temp_file.close
          temp_file.unlink
        end
      end
    end
  end
end
