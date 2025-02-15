class CreateQuizzes < ActiveRecord::Migration[7.2]
  def change
    create_table :quizzes do |t|
      t.string :title
      t.text :description
      t.boolean :active

      t.timestamps
    end
  end
end
