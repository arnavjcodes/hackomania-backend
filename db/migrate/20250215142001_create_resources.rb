class CreateResources < ActiveRecord::Migration[7.0]
  def change
    create_table :resources do |t|
      t.string  :title,         null: false
      t.text    :description
      t.text    :content
      t.string  :resource_type, null: false
      t.string  :url
      t.boolean :published,     default: false
      t.boolean :approved,      default: false
      t.integer :view_count,    default: 0
      t.float   :rating,        default: 0.0
      t.references :user,       null: false, foreign_key: true

      t.timestamps
    end
  end
end
