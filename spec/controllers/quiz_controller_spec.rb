# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuizController do
  describe '#join' do
    let(:code) { 'abcABC' }

    subject(:join) { post :join, params: { code: code } }

    let!(:quiz) { create(:quiz, code: 'ABCABC') }

    before { sign_in create(:user) }

    it 'redirects to quiz_url(quiz.id)' do
      expect(join).to redirect_to(quiz_url(quiz.id))
    end

    context 'when the quiz cannot be found' do
      let(:code) { 'bleurgh' }

      it 'redirects to root_url' do
        expect(join).to redirect_to(root_url)
      end

      it 'sets the flash message' do
        join
        expect(controller).to set_flash[:error].to('Quiz not found')
      end
    end
  end

  describe '#show' do
    include_context 'with existing quiz'

    subject(:show) { get :show, params: { id: quiz.id } }

    before { sign_in quiz.user }

    it 'renders the waiting template' do
      expect(show).to render_template(:waiting)
    end

    context 'when a question is active' do
      let(:question) { quiz.questions.first }

      before do
        quiz.cursor = question.id
        quiz.save!
      end

      it 'redirects to the question' do
        expect(show).to redirect_to(
          quiz_question_url(quiz_id: quiz.id, id: question.id)
        )
      end
    end
  end

  describe '#new' do
    before do
      sign_in create(:user)
      get :new
    end

    it 'renders the new quiz page' do
      is_expected.to render_template(:new)
    end
  end

  describe '#create' do
    subject(:create_action) do
      post :create, params: { quiz: { name: name, code: code } }
    end

    let(:name) { 'Jimbaliquiz' }
    let(:code) { 'JIMBLES' }
    let(:user) { create(:user) }
    let(:quiz) { Quiz.find_by(name: name, code: code, user: user) }

    before { sign_in user }

    it 'creates the quiz' do
      create_action
      expect(quiz).to be_truthy
    end

    it 'redirects to edit_quiz_url(id: quiz.id)' do
      expect(create_action).to redirect_to edit_quiz_url(id: quiz.id)
    end
  end

  describe '#add_guest' do
    include_context 'with existing quiz'

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
