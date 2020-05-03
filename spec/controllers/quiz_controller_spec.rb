# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuizController do
  describe '#join' do
    subject(:join) { post :join, params: { code: 'abcABC' } }

    let!(:quiz) { create(:quiz, code: 'ABCABC') }

    before { sign_in create(:user) }

    it 'redirects to quiz_url(quiz.id)' do
      expect(join).to redirect_to(quiz_url(quiz.id))
    end
  end
end
