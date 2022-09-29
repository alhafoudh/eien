# frozen_string_literal: true

module Eien
  class Task
    attr_reader :context, :namespace, :task_config

    delegate :logger, to: :task_config
    delegate :kubeclient_builder, to: :task_config

    def initialize(context, namespace = nil)
      @context = context
      @namespace = namespace
      @task_config = TaskConfig.new(context, namespace)
    end

    def run!; end

    private

    def summarize_enabled(enabled)
      colorize(enabled.to_s).public_send(enabled ? :light_green : :light_red)
    end

    def colorize(message)
      ColorizedString.new(message)
    end

    def warn!(message)
      puts colorize(message).light_yellow
    end

    def error!(message)
      puts colorize(message).light_red
    end

    def none_string
      colorize("<none>").light_black
    end
  end
end
