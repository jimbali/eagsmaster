# frozen_string_literal: true

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
