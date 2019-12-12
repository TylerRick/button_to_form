require 'rails/engine'
require 'active_support'

module ButtonToForm
  class Engine < ::Rails::Engine
    ActiveSupport.on_load(:action_controller) do
      include ButtonToForm::ControllerMethods
    end
  end

  module ControllerMethods
    extend ActiveSupport::Concern
    included do
      before_action \
        def ensure_button_to_form_rendered
          puts 'ensure_button_to_form_rendered'
        end
    end
  end
end
