# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'quiz/edit' do
  let(:quiz) { create(:quiz, name: 'My Quiz') }

  before do
    sign_in quiz.user
    controller.extra_params = { id: quiz.id }
  end

  it 'renders the quiz name' do
    expect(rendered).to match /My Quiz/
  end
end
