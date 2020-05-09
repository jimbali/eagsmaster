# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/matchers/exceed_query_limit'

RSpec.describe QuestionController do
  let!(:quiz) { create(:quiz) }
  let!(:questions) { create_list(:question, 3, quiz: quiz) }
  let!(:players) { create_list(:user, 3) }
  let!(:answers) { Array.new(9) { |_i| Faker::Books::Dune.character } }

  before do
    i = 0
    players.each do |player|
      questions.each do |question|
        create(:question_user, question: question, user: player, points: i,
                               answer: answers[i])
        i += 1
      end
    end
  end

  describe '#show' do
    subject(:show) do
      get :show, params: { id: questions.first.id, quiz_id: quiz.id }
    end

    before do
      sign_in players.first
      quiz.cursor = questions.first.id
      quiz.save
    end

    it 'does not hit the DB too crazily' do
      expect { show }.not_to exceed_query_limit(7)
    end
  end

  describe '#progress_data' do
    before { controller.instance_variable_set(:@quiz, quiz) }

    it 'returns the data' do
      expect(controller.progress_data).to eq(
        [
          {
            playerId: players.third.id,
            "question#{questions.first.id}Answer" => answers[6],
            "question#{questions.first.id}Points" => 6,
            "question#{questions.second.id}Answer" => answers[7],
            "question#{questions.second.id}Points" => 7,
            "question#{questions.third.id}Answer" => answers[8],
            "question#{questions.third.id}Points" => 8,
            rank: 1,
            team: players.third.nickname,
            totalPoints: 21
          },
          {
            playerId: players.second.id,
            "question#{questions.first.id}Answer" => answers[3],
            "question#{questions.first.id}Points" => 3,
            "question#{questions.second.id}Answer" => answers[4],
            "question#{questions.second.id}Points" => 4,
            "question#{questions.third.id}Answer" => answers[5],
            "question#{questions.third.id}Points" => 5,
            rank: 2,
            team: players.second.nickname,
            totalPoints: 12
          },
          {
            playerId: players.first.id,
            "question#{questions.first.id}Answer" => answers[0],
            "question#{questions.first.id}Points" => 0,
            "question#{questions.second.id}Answer" => answers[1],
            "question#{questions.second.id}Points" => 1,
            "question#{questions.third.id}Answer" => answers[2],
            "question#{questions.third.id}Points" => 2,
            rank: 3,
            team: players.first.nickname,
            totalPoints: 3
          }
        ]
      )
    end
  end
end
