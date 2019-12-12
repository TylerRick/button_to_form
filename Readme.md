# `button_to_form`

[![Gem Version](https://badge.fury.io/rb/button_to_form.svg)](https://badge.fury.io/rb/button_to_form)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](https://rdoc.info/github/TylerRick/button_to_form/)

## Motivation

The [button_to](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to)
provided by rails _doesn't work_ when used inside of a `<form>` tag, because it adds a new `<form>`
(at your current nesting level) and HTML doesn't allow a `form` to be nested within another `form`.

## How does it work?

The HTML spec _does_, however, allow a button/input/etc. to be
associated with a different form than the one it is nested within.

The [HTML spec says](https://html.spec.whatwg.org/#association-of-controls-and-forms):

> A form-associated element is, by default, associated with its nearest ancestor form element
> (as described below), but, if it is listed, may have a form attribute specified to override
> this.

This helper takes advantage of that, rendering a separate, empty `<form>` in the footer, and then
associating this `button` with it, so that it submits to *that* `form`'s action _rather_ than to the
action of the `form` it is a descendant of.

So — assuming you have added `<%= content_for(:footer) %>` somewhere in your layout — this source:

```ruby
= form_tag '/main_form' do
  = hidden_field_tag :main_form_param_1, 'main_form'
  = text_field_tag   :main_form_param_2, ''

  = button_to_form 'Make happy', '/make_happy' do
    = hidden_field_tag :how_happy, 'ecstatic!'
```

will get rendered to HTML that looks something like this:
```html
  <form action="/main_form" accept-charset="UTF-8" method="post">
    <input type="hidden" name="main_form_param_1" id="main_form_param_1" value="main_form">
    <input type="text" name="main_form_param_2" id="main_form_param_2" value="">
    <button name="button" type="submit" form="form-1e7dc01b-46d0-4a44-908e-77fbe2a7ec98">Make happy</button>
  </form>
  …
  <div id="footer">
    <form id="form-1e7dc01b-46d0-4a44-908e-77fbe2a7ec98" action="/make_happy" accept-charset="UTF-8" method="post">
      <input type="hidden" name="how_happy" id="how_happy" value="ecstatic!">
    </form>
  </div>
```

As you can see, there are 2 `<form>` tags that get rendered, but neither of them is nested within
the other, so it is allowed — and works well! Now you can include `button_to` calls inside of
other forms as much as your heart desires.


## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'button_to_form'
```

For this helper to work, you *must* also include this somewhere in your layout:
```ruby
  <%= content_for(:footer) %>
```

If you want these forms to be added to a different `content_for` key, say `:forms`, you can
configure it like so:
```ruby
ButtonToFormHelper.content_for_name = :forms
```

## Usage

By default, it will generate a unique id for the form. In its simplest form, it can be used as a
drop-in replacement for Rails's `button_to`. Example:

```ruby
  = button_to_form 'Make happy', [:make_happy, user]
```
(These examples use HAML, but you could just as easily use ERB.)

Unless you have a use case where the default generated id doesn't work, it is recommended to use
that approach, as it ensures that each `button_to_form` call has its own corresponding unique
`<form>`.

If, however, you need to reference this form in other places, you can specify a well-known id as the
form's id. You can also pass other `form_options`, such as `method`.

```ruby
  = button_to_form 'Delete', thing,
    {data: {confirm: 'Are you sure?'}},
    {method: 'delete', id: 'delete_thing_form'}
  = hidden_field_tag :some_id, some_id, {form: 'delete_thing_form'}
```

You may pass along additional data to the endpoint via `hidden_field_tag`s by passing them inside a
block. You don't need to specify the `form` in this case because, as descendants, they are already
associated with this new form.

```ruby
  = button_to_form 'Delete', thing,
    {data: {confirm: 'Are you sure?'}},
    {method: 'delete'} do
    = hidden_field_tag :some_id, some_id
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To start up a development web server with the same internal Rails app that is used for tests, run `rackup`.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/TylerRick/button_to_form.
