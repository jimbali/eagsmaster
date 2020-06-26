# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a quiz', type: :system do
  let(:user) { create(:user) }
  let(:name) { 'The Chase' }
  let(:code) { 'CHASE' }

  before do
    sign_in user

    visit '/'
    click_on 'Create a quiz'
    fill_in 'Name', with: name
    fill_in 'quiz_code', with: 'CHASE'
    click_on 'Create Quiz'
  end

  it 'has the correct page title' do
    expect(page).to have_text 'Edit quiz'
  end

  it 'the quiz has the correct title' do
    expect(page).to have_field 'Name', with: name
  end

  it 'the quiz has the correct code' do
    expect(page).to have_field('quiz_code', with: code)
  end
end
