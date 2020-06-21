# frozen_string_literal: true

class ChangePointsToDecimal < ActiveRecord::Migration[6.0]
  def up
    change_column :question_users, :points, :decimal, precision: 7, scale: 3
  end

  def down
    change_column :question_users, :points, :integer
  end
end
