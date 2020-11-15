# frozen_string_literal: true

FactoryBot.define do
  factory :series do
    name { Faker::Game.title }
    user
  end
end
