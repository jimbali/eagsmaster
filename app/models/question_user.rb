# frozen_string_literal: true

class QuestionUser < ApplicationRecord
  belongs_to :question
  belongs_to :user

  def answer=(value)
    write_attribute(:answer, question.answer_formatter.format(value))
  end
end
