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
    # TODO: Raise error if content_for :footer was never called in layout. But how do we even detect
    # that?
=begin disabled
    included do
      after_action \
        def ensure_button_to_form_rendered
          puts %(@button_to_form_needs_to_render_layout_section=#{(@button_to_form_needs_to_render_layout_section).inspect})
          puts %(=>@button_to_form_rendered_layout_section=#{(@button_to_form_rendered_layout_section).inspect})
          if @button_to_form_needs_to_render_layout_section && !@button_to_form_rendered_layout_section
            raise "button_to_form requires that you include content_for(:footer) somewhere in your layout"
          end
        end
    end
=end
  end
end
