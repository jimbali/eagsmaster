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

  describe '#add_guest' do
    include_context 'existing quiz'

    let(:name) { 'Bob' }
    let(:created_user) { User.find_by(nickname: name) }

    let(:guest_player) do
      {
        'playerId' => created_user.id,
        "question#{questions.first.id}Answer" => nil,
        "question#{questions.first.id}Points" => 0,
        "question#{questions.second.id}Answer" => nil,
        "question#{questions.second.id}Points" => nil,
        "question#{questions.third.id}Answer" => nil,
        "question#{questions.third.id}Points" => nil,
        'rank' => 4,
        'team' => name,
        'totalPoints' => 0
      }
    end

    before do
      sign_in quiz.user
      post :add_guest, params: { quiz_id: quiz.id, user: { nickname: name } }
    end

    it 'adds the user' do
      expect(created_user.attributes).to match hash_including(
        'nickname' => name,
        'email' => /guestuser\d+@example.com/,
        'guest' => true
      )
    end

    it 'returns the data with the guest player' do
      expect(response.parsed_body).to eq(progress_data + [guest_player])
    end
  end
end
