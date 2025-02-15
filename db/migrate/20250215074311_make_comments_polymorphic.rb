class MakeCommentsPolymorphic < ActiveRecord::Migration[7.2]
  def up
    # 1) Add polymorphic references
    add_reference :comments, :commentable, polymorphic: true, index: true

    # 2) Migrate existing data from forum_thread_id to (commentable_id, commentable_type = 'ForumThread')
    #    Only do this if you have existing comment records to preserve.
    execute <<-SQL.squish
      UPDATE comments
      SET commentable_id = forum_thread_id,
          commentable_type = 'ForumThread'
    SQL

    # 3) Remove the old forum_thread_id column
    remove_column :comments, :forum_thread_id
  end

  def down
    # Bring back forum_thread_id (in case of rollback)
    add_reference :comments, :forum_thread, foreign_key: true

    # Move data back for forum_thread comments
    execute <<-SQL.squish
      UPDATE comments
      SET forum_thread_id = commentable_id
      WHERE commentable_type = 'ForumThread'
    SQL

    # Remove the polymorphic columns
    remove_column :comments, :commentable_type
    remove_column :comments, :commentable_id
  end
end
