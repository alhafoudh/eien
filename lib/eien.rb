# frozen_string_literal: true

require "active_support/core_ext/module/delegation"
require "active_support/hash_with_indifferent_access"
require "krane/formatted_logger"

require "eien/version"
require "eien/oj"
require "eien/local_config"
require "eien/task_config"
require "eien/kubeclient_builder"
require "eien/errors"
require "eien/task"

module Eien
  LABEL_PREFIX = "eien.freevision.sk"
  CRD_OWNER_SELECTOR_VALUE = "eien.freevision.sk"

  class Error < StandardError; end

  def self.root
    File.expand_path(File.join(__dir__, ".."))
  end

  def self.crd_dir
    File.join(root, "crds")
  end

  def self.config
    @config ||= LocalConfig.build
  end

  def self.prepare_krane_options(krane_options)
    krane_options
      .each_with_object(HashWithIndifferentAccess.new) do |(key, option), options|
      options[key] = option[:default]
    end
  end

  def self.context_or_default(context)
    context.nil? ? config.context : context
  end

  def self.app_or_default(app)
    app.nil? ? config.app : app
  end

  def self.build_eien_kubeclient(context)
    task_config = TaskConfig.new(context, nil)
    task_config.kubeclient_builder.build_eien_kubeclient(context)
  end

  def self.app_from_name(context, name)
    kubeclient = build_eien_kubeclient(context)
    kubeclient.get_app(name)
  rescue Kubeclient::ResourceNotFoundError
    raise UserInputError, "App #{name} does not exist."
  end
end
