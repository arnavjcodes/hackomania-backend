class CreateResourceTags < ActiveRecord::Migration[7.0]
  def change
    create_table :resource_tags do |t|
      t.references :resource, null: false, foreign_key: true
      t.references :tag,      null: false, foreign_key: true

      t.timestamps
    end

    add_index :resource_tags, [ :resource_id, :tag_id ], unique: true
  end
end
