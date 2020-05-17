# frozen_string_literal: true

class Quiz < ApplicationRecord
  belongs_to :user
  has_many :questions

  validates_uniqueness_of :code, case_sensitive: false

  before_save :upcase_code

  class << self
    def unique_code
      code = nil
      loop do
        code = random_code
        break if Quiz.find_by(code: code).nil?
      end
      code
    end

    def random_code
      Array.new(5).map { |_e| [*'A'..'Z'].sample }.join
    end
  end

  def results
    QuestionUser
      .joins(:user)
      .where(question: [questions])
      .group(:user_id)
      .select(
        'question_users.*, users.nickname as team, SUM(points) as total_points'
      )
      .order(total_points: :desc)
  end

  def answer_formatter
    @answer_formatter ||= AnswerFormatter.new(:upcase_first)
  end

  private

  def upcase_code
    code.upcase!
  end
end
