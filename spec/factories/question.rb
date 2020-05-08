# frozen_string_literal: true

FactoryBot.define do
  factory :question do
    title { Faker::Lorem.question }
    quiz
  end
end
