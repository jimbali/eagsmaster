require 'rails_helper'

RSpec.describe QuizController do
  describe '#join' do
    let!(:quiz) { create(:quiz, code: 'ABCABC' ) }

    subject { post :join, params: { code: 'abcABC' } }

    before { sign_in create(:user) }

    it 'redirects to quiz_url(quiz.id)' do
      expect(subject).to redirect_to(quiz_url(quiz.id))
    end
  end
end
