# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate_user!

  def progress_data
    rank = 1
    points_memo = nil

    @quiz.results.map.with_index(1) do |result, i|
      rank = i if points_memo && result.total_points < points_memo
      points_memo = result.total_points

      {
        playerId: result.user_id,
        rank: rank,
        team: result.team,
        totalPoints: result.total_points
      }.tap do |data|
        @quiz.questions.each do |question|
          question_user = QuestionUser.find_by(
            question: question, user: result.user
          )
          tag = "question#{question.id}"
          data["#{tag}Answer"] = question_user&.answer
          data["#{tag}Points"] = question_user&.points
        end
      end
    end
  end
end
