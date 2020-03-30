class CreateQuestionUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :question_users do |t|
      t.integer :question_id, null: false
      t.integer :user_id, null: false
      t.string :answer

      t.timestamps
    end
  end
end
