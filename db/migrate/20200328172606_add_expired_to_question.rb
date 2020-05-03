# frozen_string_literal: true

class AddExpiredToQuestion < ActiveRecord::Migration[6.0]
  def change
    add_column :questions, :expired, :boolean, nil: false, default: false
  end
end
