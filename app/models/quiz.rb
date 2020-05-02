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
      Array.new(5).map { |e| [*'A'..'Z'].sample }.join
    end
  end

  def responses
    QuestionUser.where(question: [questions])
  end

  def results
    results = QuestionUser
      .joins(:user)
      .where(question: [questions])
      .group(:user_id)
      .select(
        'question_users.*, users.nickname as team, SUM(points) as total_points'
      )
      .order(total_points: :desc)
  end

  def players
    results.map(&:user)
  end

  def points_for(user)
    responses.where(user: user).sum(:points)
  end

  private

  def upcase_code
    code.upcase!
  end
end
