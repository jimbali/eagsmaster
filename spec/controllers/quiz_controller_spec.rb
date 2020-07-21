# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuizController do
  describe '#join' do
    subject(:join) { post :join, params: { code: code } }

    let(:code) { 'abcABC' }

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

    it { is_expected.to render_template(:new) }
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

  describe '#edit' do
    include_context 'with existing quiz'

    before do
      sign_in quiz.user
      get :edit, params: { id: quiz.id }
    end

    it { is_expected.to render_template(:edit) }

    it 'assigns the column headers' do
      expect(assigns(:column_headers)).to eq(
        [
          'Rank', 'Team', 'Total Points', questions.first.title, 'Points',
          questions.second.title, 'Points', questions.third.title, 'Points',
          'Total Points'
        ]
      )
    end

    it 'assigns the column data' do
      expect(assigns(:column_data)).to eq(
        [
          'rank', 'team', 'totalPoints', "question#{questions.first.id}Answer",
          "question#{questions.first.id}Points",
          "question#{questions.second.id}Answer",
          "question#{questions.second.id}Points",
          "question#{questions.third.id}Answer",
          "question#{questions.third.id}Points", 'totalPoints'
        ].map { |key| { data: key } }
      )
    end

    it 'assigns the progress data' do
      expect(assigns(:progress_data)).to eq(progress_data)
    end
  end

  describe '#update' do
    include_context 'with existing quiz'

    subject(:update) { patch :update, params: { id: quiz.id, quiz: row } }

    let(:name) { 'NewName' }
    let(:code) { 'NEWCODE' }
    let(:cursor) { 2 }
    let(:row) { { name: name, code: code, cursor: cursor } }

    before { sign_in quiz.user }

    it 'updates the name' do
      update
      expect(quiz.reload.name).to eq(name)
    end

    it 'updates the code' do
      update
      expect(quiz.reload.code).to eq(code)
    end

    it 'updates the cursor' do
      update
      expect(quiz.reload.cursor).to eq(cursor)
    end

    it 'redirects to edit_quiz_url(id: quiz.id)' do
      expect(update).to redirect_to(edit_quiz_url(id: quiz.id))
    end
  end

  describe '#update_progress' do
    include_context 'with existing quiz'

    let(:player) { players.first }

    before { sign_in quiz.user }

    context 'with a valid points update' do
      let(:patch) do
        {
          playerId: player.id,
          field: "question#{questions.first.id}Points",
          oldValue: '0',
          newValue: '8.2'
        }
      end

      let(:updated_progress_data) do
        progress_data.dup.tap do |data|
          data.third["question#{questions.first.id}Points"] = '8.2'
          data.third['totalPoints'] = '11.2'
        end
      end

      before do
        post :update_progress, params: { quiz_id: quiz.id, patch: patch }
      end

      it 'updates the points for the first answer' do
        expect(player.question_users.first.points).to eq(BigDecimal('8.2'))
      end

      it 'returns the updated progress data' do
        expect(response.parsed_body).to eq(updated_progress_data)
      end
    end

    context 'with the initial points update' do
      let(:patch) do
        {
          playerId: player.id,
          field: "question#{questions.first.id}Points",
          oldValue: nil,
          newValue: '4.5'
        }
      end

      let(:updated_progress_data) do
        progress_data.dup.tap do |data|
          data.third["question#{questions.first.id}Points"] = '4.5'
          data.third['totalPoints'] = '7.5'
        end
      end

      before do
        questions.first.question_users.find_by(user: player).update(points: nil)
        post :update_progress, params: { quiz_id: quiz.id, patch: patch }
      end

      it 'updates the points for the first answer' do
        expect(player.question_users.first.points).to eq(BigDecimal('4.5'))
      end

      it 'returns the updated progress data' do
        expect(response.parsed_body).to eq(updated_progress_data)
      end

      it 'has status code 200 OK' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with a conflicted points update' do
      let(:patch) do
        {
          playerId: player.id,
          field: "question#{questions.first.id}Points",
          oldValue: '1.23',
          newValue: '8.2'
        }
      end

      before do
        post :update_progress, params: { quiz_id: quiz.id, patch: patch }
      end

      it 'does not update the points for the first answer' do
        expect(player.question_users.first.points).to eq(BigDecimal('0'))
      end

      it 'returns the current progress data' do
        expect(response.parsed_body).to eq(progress_data)
      end

      it 'has status code 409 Conflict' do
        expect(response).to have_http_status(:conflict)
      end
    end

    context 'with a valid answer update' do
      let(:patch) do
        {
          playerId: player.id,
          field: "question#{questions.first.id}Answer",
          oldValue: answers.first,
          newValue: 'Ronald McDonald'
        }
      end

      let(:updated_progress_data) do
        progress_data.dup.tap do |data|
          data.third["question#{questions.first.id}Answer"] = 'Ronald McDonald'
        end
      end

      before do
        post :update_progress, params: { quiz_id: quiz.id, patch: patch }
      end

      it 'updates the answer for the first answer' do
        expect(player.question_users.first.answer).to eq('Ronald McDonald')
      end

      it 'returns the updated progress data' do
        expect(response.parsed_body).to eq(updated_progress_data)
      end
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
        "question#{questions.first.id}Points" => nil,
        "question#{questions.second.id}Answer" => nil,
        "question#{questions.second.id}Points" => nil,
        "question#{questions.third.id}Answer" => nil,
        "question#{questions.third.id}Points" => nil,
        'rank' => 4,
        'team' => name,
        'totalPoints' => '0'
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
