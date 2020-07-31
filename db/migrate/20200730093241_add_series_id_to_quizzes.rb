# frozen_string_literal: true

class AddSeriesIdToQuizzes < ActiveRecord::Migration[6.0]
  def change
    add_column :quizzes, :series_id, :integer
  end
end
