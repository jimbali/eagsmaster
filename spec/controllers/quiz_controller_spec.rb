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

    let(:row) do
      {
        playerId: player.id,
        rank: 987,
        team: 'Jiminy Jillikers',
        totalPoints: 0,
        "question#{questions.first.id}Answer" => 'Yekaterinburg',
        "question#{questions.first.id}Points" => 8.2,
        "question#{questions.second.id}Answer" => 'Novgorod',
        "question#{questions.second.id}Points" => nil,
        "question#{questions.third.id}Answer" => 'St. Petersburg',
        "question#{questions.third.id}Points" => 0
      }
    end

    let(:updated_progress_data) do
      progress_data.dup.tap do |data|
        data.third["question#{questions.first.id}Answer"] = 'Yekaterinburg'
        data.third["question#{questions.first.id}Points"] = '8.2'
        data.third["question#{questions.second.id}Answer"] = 'Novgorod'
        data.third["question#{questions.second.id}Points"] = nil
        data.third["question#{questions.third.id}Answer"] = 'St. Petersburg'
        data.third["question#{questions.third.id}Points"] = '0'
        data.third['totalPoints'] = '8.2'
      end
    end

    before do
      sign_in quiz.user
      post :update_progress, params: { quiz_id: quiz.id, row: row }
    end

    it 'updates the first answer' do
      expect(player.question_users.first.answer).to eq('Yekaterinburg')
    end

    it 'updates the points for the first answer' do
      expect(player.question_users.first.points).to eq(BigDecimal('8.2'))
    end

    it 'updates the second answer' do
      expect(player.question_users.second.answer).to eq('Novgorod')
    end

    it 'updates the points for the second answer' do
      expect(player.question_users.second.points).to eq(nil)
    end

    it 'updates the third answer' do
      expect(player.question_users.third.answer).to eq('St. Petersburg')
    end

    it 'updates the points for the third answer' do
      expect(player.question_users.third.points).to eq(0)
    end

    it 'returns the updated progress data' do
      expect(response.parsed_body).to eq(updated_progress_data)
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
        "question#{questions.first.id}Points" => '0',
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
