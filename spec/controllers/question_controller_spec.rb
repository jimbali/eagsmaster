# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/matchers/exceed_query_limit'

RSpec.describe QuestionController do
  include_context 'with existing quiz'

  let(:question) { questions.first }

  describe '#show' do
    subject(:show) do
      get :show, params: { id: question.id, quiz_id: quiz.id }
    end

    let(:question_user) do
      QuestionUser.find_by(question_id: question.id, user_id: players.first)
    end

    let(:player) { players.first }

    before do
      sign_in player
      quiz.cursor = question.id
      quiz.save
    end

    it 'does not hit the DB too crazily' do
      expect { show }.not_to exceed_query_limit(7)
    end

    it 'renders the waiting template' do
      expect(show).to render_template(:waiting)
    end

    context 'when the question has expired' do
      before { question.update_attribute(:expired, true) }

      it 'renders the answer_summary template' do
        expect(show).to render_template(:answer_summary)
      end
    end

    context 'when the question has not yet been answered' do
      before { question_user.update_attribute(:answer, nil) }

      it 'renders the enter_answer template' do
        expect(show).to render_template(:enter_answer)
      end
    end

    context 'when the QuestionUser does not yet exist' do
      let(:player) { create(:user) }

      it 'renders the enter_answer template' do
        expect(show).to render_template(:enter_answer)
      end
    end

    context 'when the cursor is zero' do
      before { quiz.update_attribute(:cursor, 0) }

      it 'redirects to the quiz URL' do
        expect(show).to redirect_to(quiz_url(quiz.id))
      end
    end

    context 'when the cursor is on another question' do
      before { quiz.update_attribute(:cursor, questions.second.id) }

      it 'redirects to the question URL' do
        expect(show).to redirect_to(
          quiz_question_url(id: questions.second.id, quiz_id: quiz.id)
        )
      end
    end
  end

  describe '#submit_answer' do
    let(:answer) { 'Las Vegas' }

    let(:params) do
      { quiz_id: quiz.id, question_id: question.id, answer: answer }
    end

    let(:question_user) do
      QuestionUser.find_by(
        user_id: player.id, question_id: question.id
      )
    end

    before do
      sign_in player
    end

    context 'when the QuestionUser already exists' do
      subject(:submit_answer) { post :submit_answer, params: params }

      let(:player) { players.first }

      it 'sets the answer' do
        submit_answer
        expect(question_user.answer).to eq(answer)
      end

      it 'redirects to the current question' do
        expect(submit_answer).to redirect_to(
          quiz_question_url(id: question.id, quiz_id: quiz.id)
        )
      end

      context 'when the question has expired' do
        before do
          question.update_attribute(:expired, true)
          post :submit_answer, params: params
        end

        it 'has bad_request status' do
          expect(response).to have_http_status :bad_request
        end

        it 'does not save the answer' do
          expect(question_user.answer).not_to eq(answer)
        end
      end
    end

    context 'when the QuestionUser does not yet exist' do
      let(:player) { create(:user) }

      it 'creates the QuestionUser and sets the answer' do
        post :submit_answer, params: params
        expect(question_user.answer).to eq(answer)
      end
    end
  end

  describe '#create' do
    subject(:create_action) do
      post :create, params: {
        quiz_id: quiz.id,
        question: { title: title }
      }
    end

    let(:title) { 'Fastest trains in the world' }

    before { sign_in quiz.user }

    it 'creates the question' do
      create_action
      expect(quiz.questions.find_by(title: title)).to be_truthy
    end

    it 'redirects to the edit page' do
      expect(create_action).to redirect_to(edit_quiz_url(id: quiz.id))
    end
  end

  describe '#update' do
    let(:title) { 'Fastest aeroplanes in the world' }

    before do
      sign_in quiz.user
      patch :update, params: {
        id: question.id,
        quiz_id: quiz.id,
        question: { title: title, expired: true }
      }
      question.reload
    end

    it 'updates the title' do
      expect(question.title).to eq title
    end

    it 'sets expired to true' do
      expect(question.expired).to be true
    end

    it 'returns the updated question' do
      expect(response.parsed_body.except('created_at', 'updated_at'))
        .to eq(question.attributes.except('created_at', 'updated_at'))
    end
  end

  describe '#destroy' do
    before { sign_in quiz.user }

    it 'destroys the question' do
      delete :destroy, params: { id: question.id, quiz_id: quiz.id }
      expect { question.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe '#progress_data' do
    before { controller.instance_variable_set(:@quiz, quiz) }

    it 'returns the data' do
      expect(controller.progress_data).to eq(progress_data)
    end
  end
end
