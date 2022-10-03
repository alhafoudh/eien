# frozen_string_literal: true

require "pry"

if ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start do
    add_filter 'spec/'
  end
end

require "fakefs/spec_helpers"

require "eien"

if ENV["COVERAGE"]
  Zeitwerk::Loader.eager_load_all
end

require 'stringio'

class StringIO
  def ioctl(*)
    0
  end
end

Object.send(:remove_const, :ColorizedString)

class ColorizedString < String
  def respond_to_missing?
    true
  end

  def method_missing(symbol, *args)
    to_s
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    Eien.clear_config!
  end
end
