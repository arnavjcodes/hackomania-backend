class CreateClusterAssignments < ActiveRecord::Migration[7.2]
  def change
    create_table :cluster_assignments do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :cluster_id
      t.integer :version

      t.timestamps
    end
  end
end
