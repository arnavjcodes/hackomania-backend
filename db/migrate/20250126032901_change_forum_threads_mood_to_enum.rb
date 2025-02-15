class ChangeForumThreadsMoodToEnum < ActiveRecord::Migration[7.2]
    def up
      add_column :forum_threads, :new_mood, :string, default: "Chill", null: false
  
      ForumThread.reset_column_information
  
      ForumThread.find_each do |thread|
        new_mood_value = case thread.mood
                         when 0 then "Chill"
                         when 1 then "Excited"
                         when 2 then "Curious"
                         when 3 then "Supportive"
                         else "Chill"         
                         end
  
        thread.update_columns(new_mood: new_mood_value)
      end
  
      remove_column :forum_threads, :mood, :integer
      rename_column :forum_threads, :new_mood, :mood
    end
  
    def down
      add_column :forum_threads, :old_mood, :integer, default: 0, null: false
  
      ForumThread.reset_column_information
  
      ForumThread.find_each do |thread|
        old_mood_value = case thread.mood
                         when "Chill"       then 0
                         when "Excited"     then 1
                         when "Curious"     then 2
                         when "Supportive"  then 3
                         else 0
                         end
  
        thread.update_columns(old_mood: old_mood_value)
      end
  
      remove_column :forum_threads, :mood, :string
      rename_column :forum_threads, :old_mood, :mood
    end
end
