require 'spec_helper'

RSpec.describe ButtonToFormHelper do
  before do
    @orig_content_for_name = ButtonToFormHelper.content_for_name
    ButtonToFormHelper.content_for_name = :footer
  end
  after do
    ButtonToFormHelper.content_for_name = @orig_content_for_name
  end

  it 'simplest case' do
    html = button_to_form('Make happy', '/make_happy')
    expect(html).to match(%r(<button name="button" type="submit" form="(form-[\w-]+)">Make happy</button>))
    expect(footer).to eq %(<form id="#{@form_id}" action="/make_happy" accept-charset="UTF-8" method="post"><input name="utf8" type="hidden" value="&#x2713;" /></form>)
  end
  it 'passing same form id as a previous call' do
    html_1 = button_to_form('Make happy 1', '/make_happy')
    html_2 = button_to_form('Make happy 2', '/make_happy', {}, {id: @form_id})
    expect(html_1).to match(%r(<button name="button" type="submit" form="(form-[\w-]+)">Make happy 1</button>))
    expect(html_2).to match(%r(<button name="button" type="submit" form="(form-[\w-]+)">Make happy 2</button>))
    expect(footer).to eq %(<form id="#{@form_id}" action="/make_happy" accept-charset="UTF-8" method="post"><input name="utf8" type="hidden" value="&#x2713;" /></form>)
  end
  context 'passing a block with hidden_field_tags' do
    it do
      html = button_to_form('Make happy', '/make_happy') do
        hidden_field_tag(:how_happy, 'ecstatic!')
      end
      expect(html).to match(%r(<button name="button" type="submit" form="(form-[\w-]+)">Make happy</button>))
      expect(footer).to eq(
        %(<form id="#{@form_id}" action="/make_happy" accept-charset="UTF-8" method="post"><input name="utf8" type="hidden" value="&#x2713;" />) +
          %(<input type=\"hidden\" name=\"how_happy\" id=\"how_happy\" value=\"ecstatic!\" />) +
        %(</form>)
      )
    end
  end

  # Helpers

  delegate :hidden_field_tag, :text_field_tag, to: :helper

  def button_to_form(*args, &block)
    helper.button_to_form(*args, &block).tap do |html|
      html.match(%r(form="(form-[\w-]+)")m)
      @form_id = $1
    end
  end

  def footer
    helper.content_for(:footer)
  end
end

