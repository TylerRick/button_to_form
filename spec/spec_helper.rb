require "bundler/setup"
require "button_to_form"

Bundler.require :default, :development
require 'capybara/dsl'
require_relative '../config/rails_environment'
require 'rspec/rails'
require 'capybara/rails'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Combustion is supposed to include these for us but Capybara::RSpecMatchers isn't defined when it checks for it
  config.include Capybara::RSpecMatchers
  config.include Capybara::DSL
end

Capybara.server = :webrick