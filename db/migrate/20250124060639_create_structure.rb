class CreateStructure < ActiveRecord::Migration[7.2]
  def change
    create_table "categories", force: :cascade do |t|
      t.string "name", null: false
      t.text "description"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["name"], name: "index_categories_on_name", unique: true
    end
  
    create_table "comments", force: :cascade do |t|
      t.text "content", null: false
      t.integer "mood", default: 0
      t.bigint "parent_id"
      t.bigint "user_id", null: false
      t.bigint "forum_thread_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["forum_thread_id"], name: "index_comments_on_forum_thread_id"
      t.index ["parent_id"], name: "index_comments_on_parent_id"
      t.index ["user_id"], name: "index_comments_on_user_id"
    end
  
    create_table "forum_threads", force: :cascade do |t|
      t.string "title", null: false
      t.text "content", null: false
      t.integer "mood", default: 0
      t.bigint "user_id", null: false
      t.bigint "category_id", null: false
      t.text "tag_list" # Added tag_list column to store tags as a comma-separated string
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["category_id"], name: "index_forum_threads_on_category_id"
      t.index ["user_id"], name: "index_forum_threads_on_user_id"
    end
  
  
    create_table "tags", force: :cascade do |t|
      t.string "name", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["name"], name: "index_tags_on_name", unique: true # Updated to remove category association
    end
  
    create_table "users", force: :cascade do |t|
      t.string "username", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.jsonb "preferences", default: {}, null: false
      t.string "name"
      t.string "email"
      t.text "bio"
      t.string "language", default: "en"
      t.string "timezone", default: "UTC"
      t.boolean "dark_mode", default: false
      t.index ["email"], name: "index_users_on_email", unique: true, where: "(email IS NOT NULL)"
      t.index ["username"], name: "index_users_on_username", unique: true
    end

    create_table "forum_threads_tags", id: false do |t|
      t.bigint "forum_thread_id", null: false
      t.bigint "tag_id", null: false
      t.index ["forum_thread_id", "tag_id"], name: "index_forum_threads_tags_on_forum_thread_id_and_tag_id", unique: true
      t.index ["tag_id", "forum_thread_id"], name: "index_forum_threads_tags_on_tag_id_and_forum_thread_id"
    end

    add_foreign_key "comments", "comments", column: "parent_id"
    add_foreign_key "comments", "forum_threads"
    add_foreign_key "comments", "users"
    add_foreign_key "forum_threads", "categories"
    add_foreign_key "forum_threads", "users"
  end
end
