RSpec.describe 'button_to_form / nested forms', js: false do
  it 'main form' do
    visit '/test/button_to_form'
    click_button 'Save User'
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
    expect(json_response).to match({
      form: "delete_form",
      # button's name is 'button' by default
      button: "",
      # hidden fields within this other form
      delete_form_something: "something",
    })
  end
end

RSpec.describe ButtonToForm do
  it "has a version number" do
    expect(ButtonToForm::Version).not_to be nil
  end
end
