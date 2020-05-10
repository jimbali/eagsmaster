# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { 'Password123#' }
    nickname { Faker::Games::Pokemon.name }
  end
end
