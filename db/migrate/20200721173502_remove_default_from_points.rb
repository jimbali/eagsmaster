# frozen_string_literal: true

class RemoveDefaultFromPoints < ActiveRecord::Migration[6.0]
  def change
    change_column_default(:question_users, :points, from: 0, to: nil)
  end
end
