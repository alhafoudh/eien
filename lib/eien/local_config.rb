# frozen_string_literal: true

module Eien
  class LocalConfig
    attr_accessor :context, :app

    def self.build
      new.tap(&:load!)
    end

    def load!
      return unless File.exist?(config_path)

      config = YAML.load_file(config_path).deep_symbolize_keys
      @context = config[:context]
      @app = config[:app]
    end

    def save!
      config = {
        context: context,
        app: app,
      }.compact.deep_stringify_keys

      FileUtils.mkdir_p(config_dir)
      File.write(config_path, config.to_yaml)
    end

    private

    def config_dir
      File.join(Dir.pwd, ".eien")
    end

    def config_path
      File.join(config_dir, "config")
    end
  end
end
