# frozen_string_literal: true

require "krane/task_config"

module Eien
  class TaskConfig < Krane::TaskConfig
    def kubeclient_builder
      @kubeclient_builder ||= KubeclientBuilder.new(kubeconfig: kubeconfig)
    end
  end
end
