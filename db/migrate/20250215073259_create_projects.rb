class CreateProjects < ActiveRecord::Migration[7.2]
  def change
    create_table :projects do |t|
      t.string :title, null: false
      t.text :description
      t.string :repo_link
      t.string :live_site_link
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
