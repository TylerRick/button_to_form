module ButtonToFormHelper
  class << self
    attr_accessor :content_for_name
  end
  self.content_for_name = :footer

  # The [button_to](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to)
  # provided by rails doesn't work when used inside of a form tag, because it adds a new <form> and
  # HTML doesn't allow a form within a form. It does, however, allow a button/input/etc. to be
  # associated with a different form than the one it is nested within.
  #
  # The [HTML spec says](https://html.spec.whatwg.org/#association-of-controls-and-forms):
  #
  # > A form-associated element is, by default, associated with its nearest ancestor form element
  # > (as described below), but, if it is listed, may have a form attribute specified to override
  # > this.
  #
  # This helper takes advantage of that, rendering a separate, empty form in the footer, and then
  # associating this button with it, so that it submits with *that* form's action rather than the
  # action of the form it is a descendant of.
  #
  # By default, it will generate a unique id for the form. In its simplest form, it can be used as a
  # drop-in replacement for Rails's `button_to`. Example:
  #
  #   = button_to_form 'Make happy', [:make_happy, user]
  #
  # If you need to reference this form in other places, you should specify the form's id. You can
  # also pass other `form_options`, such as `method`.
  #
  #   = button_to_form 'Delete', thing,
  #     {data: {confirm: 'Are you sure?'}},
  #     {method: 'delete', id: 'delete_thing_form'}
  #   = hidden_field_tag :some_id, some_id, {form: 'delete_thing_form'}
  #
  # You may pass along additional data to the endpoint via hidden_field_tags by passing them as a
  # block. You don't need to specify the form in this case because, as descendants, they are already
  # associated with this form.
  #
  #   = button_to_form 'Delete', thing,
  #     {data: {confirm: 'Are you sure?'}},
  #     {method: 'delete'}
  #     = hidden_field_tag :some_id, some_id
  #
  def button_to_form(button_text, url, button_options, form_options = {}, &block)
    form_options[:id] ||= "form-#{SecureRandom.uuid}"
    content_for(ButtonToFormHelper.content_for_name) do
      # @button_to_form_rendered_content_for_name = true
      # controller.instance_variable_set '@button_to_form_rendered_content_for_name', true
      form_tag(url, **form_options) do
        block.call if block
      end
    end
    # @button_to_form_needs_to_render_content_for_name = true
    # controller.instance_variable_set '@button_to_form_needs_to_render_content_for_name', true

    button_tag(button_text, **button_options, type: 'submit', form: form_options[:id])
  end

end
