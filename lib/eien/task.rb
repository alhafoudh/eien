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

    def warn!(message)
      puts ColorizedString.new(message).light_yellow
    end

    def error!(message)
      puts ColorizedString.new(message).light_red
    end
  end
end
