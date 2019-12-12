# `button_to_form`

[![Gem Version](https://badge.fury.io/rb/button_to_form.svg)](https://badge.fury.io/rb/button_to_form)

## Motivation

The [button_to](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to)
provided by rails doesn't work when used inside of a form tag, because it adds a new <form> and
HTML doesn't allow a form within a form.

## How does it work?

The HTML spec does, however, allow a button/input/etc. to be
associated with a different form than the one it is nested within.

The [HTML spec says](https://html.spec.whatwg.org/#association-of-controls-and-forms):

> A form-associated element is, by default, associated with its nearest ancestor form element
> (as described below), but, if it is listed, may have a form attribute specified to override
> this.

This helper takes advantage of that, rendering a separate, empty form in the footer, and then
associating this button with it, so that it submits with *that* form's action rather than the
action of the form it is a descendant of.


## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'button_to_form'
```

For this helper to work, you *must* also include this somewhere in your layout:
```ruby
  <%= content_for(:footer) %>
```

ButtonToFormHelper.content_for_name = :forms

## Usage

By default, it will generate a unique id for the form. In its simplest form, it can be used as a
drop-in replacement for Rails's `button_to`. Example:

  = button_to_form 'Make happy', [:make_happy, user]

If you need to reference this form in other places, you should specify the form's id. You can
also pass other `form_options`, such as `method`.

  = button_to_form 'Delete', thing,
    {data: {confirm: 'Are you sure?'}},
    {method: 'delete', id: 'delete_thing_form'}
  = hidden_field_tag :some_id, some_id, {form: 'delete_thing_form'}

You may pass along additional data to the endpoint via hidden_field_tags by passing them as a
block. You don't need to specify the form in this case because, as descendants, they are already
associated with this form.

  = button_to_form 'Delete', thing,
    {data: {confirm: 'Are you sure?'}},
    {method: 'delete'}
    = hidden_field_tag :some_id, some_id


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/TylerRick/button_to_form.
