# frozen_string_literal: true

class QuestionUser < ApplicationRecord
  belongs_to :question
  belongs_to :user
end
