class TestController < ApplicationController
  layout \
    def get_layout
      params[:layout] || 'application'
    end

  def button_to_form
  end

  def dump_params
    render json: params.to_unsafe_h.except(:controller, :action, :authenticity_token, :utf8)
  end
end
