# frozen_string_literal: true

FactoryBot.define do
  factory :question_user do
    question
    user
  end
end
