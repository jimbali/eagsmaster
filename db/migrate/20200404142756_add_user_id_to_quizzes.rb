# frozen_string_literal: true

class AddUserIdToQuizzes < ActiveRecord::Migration[6.0]
  def change
    add_column :quizzes, :user_id, :integer
  end
end
