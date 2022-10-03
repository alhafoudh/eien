# frozen_string_literal: true

module Eien
  class InitTask < Task
    def run!
      logger.reset

      logger.heading("Deploying CustomResourceDefinitions")

      Krane::CLI::GlobalDeployCommand.from_options(
        task_config.context,
        Eien.prepare_krane_options(Krane::CLI::GlobalDeployCommand::OPTIONS).merge(
          filenames: [Eien.crd_dir],
          selector: "owner=#{Eien::CRD_OWNER_SELECTOR_VALUE}",
        ),
      )

      Eien.config.context = context
      Eien.config.save!
    end
  end
end
