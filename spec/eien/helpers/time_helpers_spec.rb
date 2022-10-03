# frozen_string_literal: true

RSpec.describe Eien::Helpers::TimeHelpers do
  include Eien::Helpers::TimeHelpers

  it "#summarize_age" do
    formatted_value = instance_double(String)
    time = Time.now

    expect(self).to receive(:time_ago_in_words).with(time, anything).and_return(formatted_value)
    expect(summarize_age(time)).to eq formatted_value
  end
end
