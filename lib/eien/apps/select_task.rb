# frozen_string_literal: true

module Eien
  module Apps
    class SelectTask < Task
      attr_reader :app

      def initialize(context, app)
        @app = app

        super(context)
      end

      def run!
        the_app = Eien.app_from_name(context, app)

        ::Eien.config.app = the_app.metadata.name
        ::Eien.config.save!
      end
    end
  end
end
