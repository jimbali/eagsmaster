# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create(email: 'test_user@eagsmaster.com', password: 'Password123#')

quiz = Quiz.create(code: 'jimbles', name: 'Jimblequiz')

Question.create(
  title: 'Most listened to radio stations in the UK',
  quiz_id: quiz.id
)
Question.create(
  title: 'Largest countries by land mass',
  quiz_id: quiz.id
)
