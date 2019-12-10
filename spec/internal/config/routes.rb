# frozen_string_literal: true

Rails.application.routes.draw do
  (TestController.public_instance_methods - ApplicationController.public_instance_methods).sort.each do |action|
    get   "test/#{action}", to: "test##{action}"
    post  "test/#{action}", to: "test##{action}"
    patch "test/#{action}", to: "test##{action}"
  end
end
