# This common code has been extracted to ensure that both config.ru and spec/spec_helper.rb
# configure Combustion/Rails in exactly the same way.

require "rubygems"
require "bundler"

Bundler.require :default, :development

Combustion.initialize! :action_controller, :action_view

ButtonToFormHelper.content_for_name = :forms
