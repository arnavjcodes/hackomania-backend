
class CreateReactions < ActiveRecord::Migration[7.0]
    def change
      create_table :reactions do |t|
        t.references :user, null: false, foreign_key: true
        t.references :forum_thread, null: false, foreign_key: true
        t.string :reaction_type, null: false # "like" or "chill"
  
        t.timestamps
      end
  
      # Ensure a user can only have one reaction_type per thread
      add_index :reactions,
              [:user_id, :forum_thread_id, :reaction_type],
              unique: true,
              name: "index_reactions_on_user_forum_thread_type"
    end
  end
  