# frozen_string_literal: true

class AddPointsToQuestionUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :question_users, :points, :integer, nil: false, default: 0
  end
end
