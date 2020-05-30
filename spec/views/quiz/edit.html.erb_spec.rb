# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'quiz/edit.html.erb' do
  let(:quiz) { create(:quiz, name: 'My Quiz') }

  it 'renders the quiz name' do
    assign :quiz, quiz
    render
    expect(rendered).to match /My Quiz/
  end
end
