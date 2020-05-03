# frozen_string_literal: true

class AddUniquenessConstraintToQuestionUsers < ActiveRecord::Migration[6.0]
  def change
    add_index :question_users, %i[user_id question_id], unique: true
  end
end
