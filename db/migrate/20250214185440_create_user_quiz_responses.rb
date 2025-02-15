class CreateUserQuizResponses < ActiveRecord::Migration[7.2]
  def change
    create_table :user_quiz_responses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :quiz, null: false, foreign_key: true
      t.references :quiz_question, null: false, foreign_key: true
      t.references :quiz_answer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
