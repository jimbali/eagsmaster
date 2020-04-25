class Quiz < ApplicationRecord
  belongs_to :user
  has_many :questions

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

  def players
    QuestionUser.where(question: [questions]).map(&:user)
  end

  def points_for(user)
    QuestionUser.where(question: [questions], user: user).sum(:points)
  end

  def player_rank(user)
    players.map do |player|
      player.question_users.map(&:points)
    end
  end
end
