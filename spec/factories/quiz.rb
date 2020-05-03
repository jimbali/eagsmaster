# frozen_string_literal: true

FactoryBot.define do
  factory :quiz do
    name { Faker::Game.title }
    code { Quiz.unique_code }
    user
  end
end
