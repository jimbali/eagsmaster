# frozen_string_literal: true

class Series < ApplicationRecord
  belongs_to :user
  has_many :quizzes

  validates_uniqueness_of :name

  def questions
    Question.where(quiz: quizzes)
  end

  def results
    QuestionUser
      .joins(:user)
      .where(question: [questions])
      .group(:user_id)
      .select(
        'question_users.*, users.nickname AS team, ' \
        'IFNULL(SUM(points), 0) AS total_points, ' \
        'COUNT(points) AS questions_answered, ' \
        'COUNT(' \
          'CASE WHEN question_users.points=10 THEN 1 ELSE NULL END' \
        ') AS ten_point_answers'
      )
      .order(total_points: :desc)
  end

  def leaderboard
    rank = 1
    points_memo = nil

    results.map.with_index(1) do |result, i|
      rank = i if points_memo && result.total_points < points_memo
      points_memo = result.total_points

      static_fields(result, rank)
    end
  end

  def static_fields(result, rank)
    {
      'playerId' => result.user_id,
      'rank' => rank,
      'team' => result.team,
      'totalPoints' => format('%<total>g', total: result.total_points),
      'questionsAnswered' => result.questions_answered,
      'averageQuestionScore' => result.total_points / result.questions_answered,
      'tenPointAnswers' => result.ten_point_answers,
      'tenPointAnswerProbablility' =>
        "#{result.ten_point_answers.to_f / result.questions_answered * 100}%"
    }
  end
end
