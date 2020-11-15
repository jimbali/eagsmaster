# frozen_string_literal: true

class Series < ApplicationRecord
  belongs_to :user
  has_many :quizzes

  validates_uniqueness_of :name
end
