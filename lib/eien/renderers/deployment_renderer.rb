# frozen_string_literal: true

module Eien
  module Renderers
    class DeploymentRenderer < Renderer
      attr_reader :deployment

      def initialize(deployment)
        @deployment = deployment
        super()
      end

      def render
        created_time_ago = time_ago_in_words(created_at, include_seconds: true)

        status = deployment.status

        condition_message = status.conditions.map do |condition|
          condition_update_time_ago = time_ago_in_words(Time.parse(condition.lastTransitionTime), include_seconds: true)
          "#{colorize_condition_type(condition.type)}\n#{condition.message}\n#{condition_update_time_ago} ago\n"
        end.join("\n")

        rows = [
          ["name", ColorizedString.new(name).light_magenta],
          ["", ""],
          ["created", "#{created_time_ago} ago"],
          ["", ""],
          ["replicas", [
            "#{status.replicas} desired",
            "#{status.updatedReplicas} updated",
            "#{status.readyReplicas} ready",
            "#{status.availableReplicas} available",
          ].join("\n"),],
          ["", ""],
          ["condition", condition_message],
        ]
        TTY::Table.new(rows).render(:unicode, multiline: true, padding: [0, 1])
      end

      private

      def name
        deployment.metadata.name
      end

      def created_at
        Time.parse(deployment.metadata.creationTimestamp)
      end

      def colorize_condition_type(type)
        color = case type
        when "Available" then :light_green
        when "Progressing" then :yellow
        else
          :white
        end

        ColorizedString.new(type).public_send(color)
      end
    end
  end
end
