# frozen_string_literal: true

class CreateQuizzes < ActiveRecord::Migration[6.0]
  def change
    create_table :quizzes do |t|
      t.string :name
      t.string :code, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
