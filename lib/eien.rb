# frozen_string_literal: true

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/eien/oj.rb")
loader.inflector.inflect(
  "cli" => "CLI",
)
loader.setup

require "fileutils"
require "active_support/core_ext/module/delegation"
require "active_support/hash_with_indifferent_access"
require "krane"
require "krane/cli/global_deploy_command"
require "krane/cli/deploy_command"

require "eien/oj"

module Eien
  LABEL_PREFIX = "eien.freevision.sk"
  CRD_OWNER_SELECTOR_VALUE = "eien.freevision.sk"

  def self.root
    File.expand_path(File.join(__dir__, ".."))
  end

  def self.crd_dir
    File.join(root, "crds")
  end

  def self.clear_config!
    @config = nil
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
    raise Errors::UserInputError, "App #{name} does not exist."
  end

  def self.secret_name(name)
    "#{name}-secret"
  end

  def self.config_map_name(name)
    "#{name}-config"
  end
end
