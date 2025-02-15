class CreateQuizAnswers < ActiveRecord::Migration[7.2]
  def change
    create_table :quiz_answers do |t|
      t.references :quiz_question, null: false, foreign_key: true
      t.text :content
      t.jsonb :impact

      t.timestamps
    end
  end
end
