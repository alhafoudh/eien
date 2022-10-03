# frozen_string_literal: true

require "dotiw"

module Eien
  module Helpers
    module TimeHelpers
      include DOTIW::Methods

      def summarize_age(time)
        time_ago_in_words(time, include_seconds: true, highest_measures: 2)
      end
    end
  end
end
