# frozen_string_literal: true

class Question < ApplicationRecord
  belongs_to :quiz
  has_many :question_users

  delegate :answer_formatter, to: :quiz
end
