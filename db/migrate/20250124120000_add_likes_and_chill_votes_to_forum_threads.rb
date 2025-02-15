class AddLikesAndChillVotesToForumThreads < ActiveRecord::Migration[7.0]
    def change
      add_column :forum_threads, :likes_count, :integer, default: 0, null: false
      add_column :forum_threads, :chill_votes_count, :integer, default: 0, null: false
    end
  end