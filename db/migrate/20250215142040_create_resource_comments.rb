class CreateResourceComments < ActiveRecord::Migration[7.0]
  def change
    create_table :resource_comments do |t|
      t.text :content, null: false
      t.references :user,     null: false, foreign_key: true
      t.references :resource, null: false, foreign_key: true

      t.timestamps
    end
  end
end
