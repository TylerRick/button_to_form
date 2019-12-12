RSpec.describe 'button_to_form / nested forms', js: false do
  it 'main form' do
    visit '/test/button_to_form'
    click_button 'Save User'
    expect(page).to have_current_path('/test/dump_params')
    expect(json_response).to match({
      form: "main_form",
      # Text fields
      main_form_something: "",
      user: {name: ""},
      # submit input's name is 'commit'
      commit: "Save User",
    })
  end

  it 'move button' do
    visit '/test/button_to_form'
    fill_in 'destination', with: 'Destination'
    click_button 'Move'
    expect(page).to have_current_path('/test/dump_params')
    expect(json_response).to match({
      form: "move_form",
      # Text fields
      destination: "Destination",
      # button's name is 'move_button'
      move_button: "",
    })
  end

  it 'delete button' do
    visit '/test/button_to_form'
    click_button 'Delete'
    expect(page).to have_current_path('/test/dump_params')
    expect(json_response).to match({
      form: "delete_form",
      # button's name is 'button' by default
      button: "",
      # hidden fields within this other form
    })
  end

  it 'failing to include content_for :footer in layout' do
    visit '/test/button_to_form?layout=bad'
    click_button 'Delete'
    expect(page).to have_current_path('/test/button_to_form?layout=bad')
    expect(page).to have_content 'error'
  end

  def json_response
    ActiveSupport::JSON.decode(response_body).with_indifferent_access
  end

  def response_body
    if page.driver.is_a? Capybara::RackTest::Driver
      page.driver.response.body
    else
      page.text
    end
  end
end
