module ApplicationHelper
  # This is the "page title" (div#title)
  #
  # Usually we want the page title and the window <title> to be the same. This is fine as long as
  # you use plain text. But sometimes you may want to format the page title with HTML. Then we can
  # no longer use the same text in <title>.
  #
  # If you want to supply an HTML version of the the title, supply it as :title_html. It will only
  # be used for the on-page page title. <title> will still use the contents of :title or the last
  # breadcrumb, as always.
  #
  # See also: ApplicationController#page_title
  def page_title
    content_for(:title_html) || window_title
  end

  # This is the "window title" (<title> tag)
  def window_title
    content_for(:title) || breadcrumbs.last&.name
  end

  # TODO: Surely there's a more direct way of checking this. But what is it?
  def rendering_from_mailer?
    (attachments rescue nil).nonnil?
  end

  def image_tag_with_host(*args)
    html = image_tag(*args)
    html.
      gsub(/src="\/(.*)"/,
        %{src="#{root_url}\\1"}
      ).
      html_safe
  end

  def asset_must_exist!(file_name)
    ApplicationController.helpers.asset_path(file_name) or
      raise "#{file_name} does not exist"
  end

  # Used in: app/views/layouts/_header.html.haml
  def logo_image(scale = 1.0)
    image_tag('logo_300.png', alt: 'Simple Church Logo', width: (300 * scale).to_i, height: (142 * scale).to_i)
  end

  # Used in: app/views/layouts/_header.html.haml
  def show_google_translate?
    !Rails.env.test?
  end

  def editing_record?(record_type)
    controller_name == record_type.pluralize && ['edit', 'update'].include?(action_name)
  end

  def append_br(text)
    if text.present?
      text.html_safe + '<br/>'.html_safe
    end
  end

  def list(tag, objects)
    capture_haml do
      haml_tag tag do
        objects.each do |object|
          haml_tag :li, object
        end
      end
    end
  end

  def list_of_links_to_objects(objects)
    objects.map {|_| link_to(h(_), _)}.
      to_sentence.html_safe
  end

  def button_link(text, options = {}, &block)
    options.reverse_merge!(
      role: 'button',
      tabindex: 0,
    )
    content_tag :a, text, options, &block
  end

  # Used to add style to keywords such as 'false'.
  # Example:
  #   span_with_value_for_class(false)
  #   content_tag :span, false, class: 'false'
  def span_with_value_for_class(value)
    content_tag :span, value, class: value.to_s
  end


  # Creates a rel=popover "link" that shows a popover when hovered over but does nothing when clicked.
  # Captures the HTML content that is yielded to this method and sets that as the value of the 'data-content' attribute.
  # Uses popover() method from bootstrap (see bootstrapped.js.coffee).
  # See also the click_to_trigger_popover option.
  #
  # Usage:
  # = popover_link_to('hover here to see popover', 'Title') do
  #   Content
  def popover_link_to(link_text, title, options = {})
    content = options[:content] || capture_haml { yield }
    capture_haml do
      haml_tag :a, {
        role: 'button',
        rel: "popover",
        class: "dont_look_like_link",
        data: {
          title: title,
          content: content.gsub("'", "\'")
        }.merge(options)
      } do
        haml_concat link_text
      end
    end.gsub(%r{\s+</a>}, '</a>').html_safe
  end

  def info_icon(options = {})
    image_tag('i_circle.png', {:class => 'info_icon vertical_middle'}.merge(options))
  end

  # mail_to_with_icon to: simple_church.all_active_members.map(&:email), cc: simple_church.coach.email
  def mail_to_with_icon(options = {})
    recipients = [options[:to], options[:cc]]
    return unless recipients.any?
    recipient_list = recipients.select(&:present?).flatten.compact.to_sentence
    link_target =           Array(options.delete(:to)).select(&:present?).join(',')
    html_options = {
      class: 'link_with_icon no_tooltip',
      title: "Compose an e-mail to #{recipient_list}",
      cc: (Array(options.delete(:cc)).select(&:present?).join(',') if options[:cc])
    }.compact.merge(options)
    text = image_tag('email.png') + options[:link_text].to_s
    mail_to link_target, text, html_options
  end

  # Like link_to but adds 'current' class if you are already on the page represented by this nav
  # item
  def menu_link_to(text, url_options, options = {}, &block)
    url = main_app.url_for(url_options)
    route = Rails.application.routes.recognize_path(url, options)
    unless matching_actions = options.delete(:matching_actions)
      matching_actions = [route[:action]]
      matching_actions = ['new',  'create'] if route[:action] == 'new'
      matching_actions = ['edit', 'update'] if route[:action] == 'edit'
    end
    #Rails.logger.debug %(... route=#{(route).inspect})
    #Rails.logger.debug %(... #{matching_actions}.include? #{params[:action]}=#{(matching_actions.include? params[:action]).inspect})
    if (
      route[:controller] == params[:controller] and
      matching_actions.include? params[:action] and
      (route[:id].blank? || route[:id] == params[:id]) and
      (options[:conditions].nil? || options[:conditions].call)
    )
      (options[:class] ||= '') << ' current'
    end
    if block_given?
      link_to url, options, &block
    else
      link_to text, url, options
    end
  end

  def required_field_indicator(*args)
    options = args.extract_options!
    object, attr_name = args.shift, args.shift
    (options[:alt] ||= '*')
    (options[:class] ||= '') << ' required_field'
    if object && attr_name
      required = object.attr_required?(attr_name)
    else
      required = true
    end
    image_tag 'asterisk.png', options if required
  end

  def loading_indicator_id(suffix, id_or_record = nil)
    id = (id_or_record.is_a?(String) || id_or_record.nil?) ?
          id_or_record.to_s :
          dom_id(id_or_record)
    'loading_indicator_' + id + '_' + suffix
  end
  def loading_indicator(suffix, options = {})
    image_tag 'loading_indicator.gif', {
      :id => loading_indicator_id(suffix, options.delete(:object)),
      :class => "loading_indicator #{options.delete(:class)}",
    }.merge(options)
  end

  def hidden_link_to(*args)
    options = args.extract_options!
    (options[:class] ||= '') << ' dont_look_like_link'
    args << options
    link_to *args
  end

  def hidden_link_to_if(*args)
    options = args.extract_options!
    (options[:class] ||= '') << ' dont_look_like_link'
    args << options
    link_to_if *args
  end

  # Keeping all other params the same, toggle the param with key param_to_toggle from present to
  # not present (deletes the key from the params hash), or from not present to 'true'.
  #
  # If the specified param is already set to true, then change the word 'Show' to 'Hide'.
  #
  def toggle_link_to(text, param_to_toggle, words_to_change = {'Show' => 'Hide', 'Enable' => 'Disable'})
    params = params().to_unsafe_h.dup
    if params[param_to_toggle].present?
      words_to_change.each do |from, to|
        text = text.gsub(from, to)
      end
      params.delete param_to_toggle
    else
      params[param_to_toggle] = 'true'
    end
    link_to text, params
  end

  def link_to_top
    '<a href="#">^</a>'.html_safe
  end

  # Try to link to a record. If record is nil, avoid linking to ''. If no route exists for this type
  # of record, avoid raising a routing error.
  def try_link_to(label, record)
    link_to_if(record, label, record).html_safe rescue label
  end

  def phase_1_training_url
    'https://www.simplechurchathome.com/core4-online-training/'
  end

  def record_path(*prefix, record)
    case record
    when Event, Role
      polymorphic_path([*prefix, :admin, record])
    when Invitation
      if current_user&.is?(:admin)
        polymorphic_path([*prefix, :admin, record])
      else
        polymorphic_path([*prefix, record])
      end
    when ContactRequest
      house_church_contact_request_path(record.house_church, record)
    when WeeklyIndividualContribution
      weekly_report_individual_contribution_path(record.weekly_report)
    when HouseChurchRegistration
      house_church_registrations_path
    when NotificationSettings::Setting
      polymorphic_path([record.object_user, :notification_preferences])
    else
      polymorphic_path([*prefix, record])
    end
  rescue
    if Rails.env.production?
      ExceptionNotifier.notify_exception($!)
      '/'
    else
      raise
    end
  end

  # Link to a record. Uses record_path to compute the href.
  #
  # Example:
  #   link_to_record user
  def link_to_record(text_or_record, record = nil, options = {})
    text     = text_or_record
    record ||= text_or_record
    return '' unless can?(:read, record)
    link_to text,
      record_path(record),
      options.except(:text)
  end

  # Like link_to_record but when you just have a record ID and don't want to look up the record just
  # to create a link to it.
  #
  # If it can't find a model for the given key, it will fallback to just returning the given text.
  #
  # Example:
  #   link_to_record_by_id :user_id, 1
  def link_to_record_by_id(key, text_or_id, id = nil, options = {})
    text     = text_or_id
    id     ||= text_or_id
    return text unless key.to_s.ends_with?('_id')
    return text unless id.present?
    key = key.to_s.sub(/actor_id|acting_root_user_id|sender_id|recipient_id|address_same_as_user_id/, 'user_id')
    model = key.sub(/_id/, '').camelize.safe_constantize
    model = nil unless model.is_a?(ActiveRecord::Base)
    return text unless model

    record = model.pretend_find(id)
    link_to text,
      record_path(record),
      options.except(:text)
  end
end

#═════════════════════════════════════════════════════════════════════════════════════════════════
# PDF-related

module ApplicationHelper
  def download_as_pdf_link(text = 'Download as PDF', url = nil, options = {})
    url ||= params.to_unsafe_h.merge(format: 'pdf')
    link_to url do
      # Original size: 48x48
      image_tag('pdf_icon.png', alt: 'Download', height: 14, width: 14) +
      " #{text}"
    end
  end

  def download_as_pdf_button(text = 'Download as PDF', url = nil, options = {})
    url ||= params.to_unsafe_h.merge(format: 'pdf')
    link_to url, class: "btn #{options.delete(:class)}" do
      # Original size: 48x48
      image_tag('pdf_icon.png', alt: 'Download', height: 14, width: 14) +
      " #{text}"
    end
  end

  def rendering_as_pdf?
    # request.format.pdf? doesn't work if you render a template from a mailer rather than in a
    # normal controller action. As long as we're consistent and always render a pdf template using
    # render_pdf(), then this method should be able to detect that. I couldn't figure out a better
    # way to detect this. Even though it will be converted into a pdf, all other clues indicate that
    # an .html format template is being rendered!
    caller.grep(/render_with_phantomjs/).any? or
      request&.env._try['PhantomJS'] == 'Shrimp::InlineMiddleware'
  end

  def image_tag(source, options = {})
    if rendering_as_pdf? && !source.start_with?('file:')
      # wicked_pdf_image_tag will call image_tag with the path translated to a 'file:'-schema URL
      wicked_pdf_image_tag(source, options)
    else
      super
    end
  end

  def stylesheet_link_tag(source, *args)
    if rendering_as_pdf? && !source.start_with?('file:')
      wicked_pdf_stylesheet_link_tag source, *args
    else
      super
    end
  end

  def javascript_include_tag(sources, **options)
    # I don't understand why we have to specifically pass nonce: true to every single
    # javascript_include_tag. Of course I want them all to have the nonce! Why wouldn't I? It's too
    # easy to forget to add it, so let's make it the default.
    options[:nonce] = true unless options.key?(:nonce)

    # FIXME: wicked_pdf_javascript_include_tag automatically adds .js to the end even if the filename already has it!
    if rendering_as_pdf? && !sources[0].start_with?('file:')
      # Don't pass **options because  wicked_pdf_javascript_include_tag doesn't accept options and
      # it would interpret {:nonce=>true} as a source and end up causing this error:
      #   The asset "{:nonce=>true}.js" is not present in the asset pipeline.
      wicked_pdf_javascript_include_tag *sources
    else
      super *sources, **options
    end
  end
end

#═════════════════════════════════════════════════════════════════════════════════════════════════
# Form-related helpers

module ApplicationHelper

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
  #
  def button_to_form(button_text, url, button_options, form_options = {}, &block)
    form_options[:id] ||= "form-#{SecureRandom.uuid}"
    content_for(:footer) do
      form_tag(url, **form_options) do
        block.call if block
      end
    end

    button_tag(button_text, **button_options, type: 'submit', form: form_options[:id])
  end

  # If you have some params that you require to provided to the page both on the new and create (or
  # edit and update) pages, you can easily pass through those params as hidden inputs on the form
  # using this helper.
  def pass_through_params(*param_keys)
    param_keys.map {|key|
      hidden_field_tag key, params[key]
    }.join("\n").html_safe
  end

  def remove_hidden_input(input)
    #input.match(/<input[^>]*type="hidden"[^>]*>/) && Rails.logger.debug("... $&=#{$&.inspect}")
    input.gsub(/<input[^>]*type="hidden"[^>]*>/, '').html_safe
  end

  # TODO (old):
  # * make this box look like the flash[:error] box
  # * use same (JS) code as jQuery validator uses to display errors so they look identical
  def display_errors_for(*records)
    options = records.extract_options!
    exclude = Array(options[:exclude])

    exclude_proc = ->(errors) {
      errors.select {|attr_name, message| true unless exclude && (
        exclude.include?(attr_name) ||
        exclude.any? {|_| _.to_s.end_with?('.') && attr_name.to_s.start_with?(_.to_s) }
      ) }
    }
    if records.any? {|record| record&.errors && exclude_proc[record&.errors]&.any? }
      haml_tag :div, :id => 'error_explanation' do
        haml_tag :h2, 'Please correct these errors and try again:'
        haml_tag :ul do
          records.each do |record|
            next unless record
            # Log which error messages are shown to the user so that we can see if any are frequently encountered and need to be fixed.
            Rails.logger.warn "... #{record.class}.errors.full_messages=#{record.errors.full_messages.inspect}" if record&.errors&.any?
            exclude_proc[record.errors].each do |attr_name, message|
              if message.starts_with_uppercase?
                haml_tag :li, message
              else
                haml_tag :li, record.errors.full_message(attr_name, message)
              end
            end
          end
        end
      end
    end
  end

#  def field_container(record, method, options = {}, &block)
#    unless error_message_on(record, method).blank?
#      css_class = 'withError'
#    end
#    content_tag('p', capture { block.call method }, :class => css_class)
#  end

  # TODO: patch simple_form to include the attribute name like this method does.
  # Currently it shows <div class="help-block error_message_on">is required</div>
  # but doesn't add an attribute/class to indicate which model attribute the error message is for.
  def error_message_on(object_name, attr_name, options = {})
    object = options[:object]
    if object&.errors[attr_name].present?
      errors = object.errors[attr_name].map {|_| h(_)}
      errors = errors.join('<br/>').html_safe
      content_tag(options[:tag] || :div, errors,
                  class: ['help-block', 'error_message_on', attr_name].join(' '),
                  data: {for: attr_name}
      )
    else
      nil
    end
  end

  # Useful since the key may be present but the value blank.
  def skip_validations?
    params[:skip_validations].present?
  end

  def milton_mobile_phone
    User.milton_admin.phone
  end
  def milton_email
    #mail_to 'miltonadams@adamsonline.org'
    mail_to User.milton_admin.email
  end
end

#═════════════════════════════════════════════════════════════════════════════════════════════════

module ActionView
  module Helpers
    TextHelper.class_eval do
     #def pluralize(count, singular, plural = nil)
     #  "#{count || 0} " + ((count == 1 || count =~ /^1(\.0+)?$/) ? singular : (plural || singular.pluralize))
     #end

      def pluralize_without_count(count, singular, plural = nil)
        ((count == 1 || count =~ /^1(\.0+)?$/) ? singular : (plural || singular.pluralize))
      end
    end
  end
end

module ActionView
  module Helpers
    FormBuilder.class_eval do
     #def field_container(method, options = {}, &block)
     #  @template.field_container(@object_name,method,options,&block)
     #end

    end
  end
end

# See also: lib/action_view/helpers/form_helper_extensions.rb
