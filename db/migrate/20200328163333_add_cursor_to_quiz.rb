# frozen_string_literal: true

class AddCursorToQuiz < ActiveRecord::Migration[6.0]
  def change
    add_column :quizzes, :cursor, :integer, default: 0
  end
end
