# frozen_string_literal: true

class CreateSeries < ActiveRecord::Migration[6.0]
  def change
    create_table :series do |t|
      t.integer :user_id
      t.string :name, index: { unique: true }
    end
  end
end
