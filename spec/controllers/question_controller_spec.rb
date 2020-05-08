# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/matchers/exceed_query_limit'

RSpec.describe QuestionController do
  let!(:quiz) { create(:quiz) }
  let!(:questions) { create_list(:question, 3, quiz: quiz) }
  let!(:players) { create_list(:user, 3) }

  before do
    questions.each do |question|
      players.each do |player|
        create(:question_user, question: question, user: player)
      end
    end
  end

  describe '#show' do
    subject(:show) do
      get :show, params: { id: questions.first.id, quiz_id: quiz.id }
    end

    before do
      sign_in create(:user)
      quiz.cursor = questions.first.id
      quiz.save
    end

    it 'does not hit the DB too crazily' do
      expect { show }.not_to exceed_query_limit(5)
    end
  end
end
