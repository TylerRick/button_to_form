class TestController < ApplicationController
  def button_to_form
    unless request.get?
      render json: params.to_unsafe_h.except(:controller, :action, :authenticity_token, :utf8)
    end
  end
end
