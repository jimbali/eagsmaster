# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate_user!

  def progress_data
    rank = 1
    points_memo = nil
    results = @quiz.results
    questions = @quiz.questions.includes(:question_users)

    results.map.with_index(1) do |result, i|
      rank = i if points_memo && result.total_points < points_memo
      points_memo = result.total_points

      result_fields(result, rank, questions)
    end
  end

  def result_fields(result, rank, questions)
    static_fields(result, rank).tap do |data|
      add_question_fields(questions, result, data)
    end
  end

  def static_fields(result, rank)
    {
      'playerId' => result.user_id,
      'rank' => rank,
      'team' => result.team,
      'totalPoints' => format('%<total>g', total: result.total_points)
    }
  end

  def add_question_fields(questions, result, data)
    questions.each do |question|
      question_user = question.question_users.find do |r|
        r.user_id == result.user_id
      end
      tag = "question#{question.id}"
      data["#{tag}Answer"] = question_user&.answer
      points = question_user&.points
      data["#{tag}Points"] = points && format('%<points>g', points: points)
    end
  end
end
