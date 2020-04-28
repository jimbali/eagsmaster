# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    if user.present?
      can :manage, Quiz, user_id: user.id

      can :manage, Question, quiz: { user_id: user.id }

      can :manage, QuestionUser, user_id: user.id
      can :manage, QuestionUser, question: { quiz: { user_id: user.id } }
    end
  end
end
