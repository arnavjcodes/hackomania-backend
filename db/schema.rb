# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_02_15_092157) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "cluster_assignments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "cluster_id"
    t.integer "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_cluster_assignments_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "content", null: false
    t.integer "mood", default: 0
    t.bigint "parent_id"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "commentable_type"
    t.bigint "commentable_id"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable"
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string "location"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "event_type", default: "physical", null: false
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "follows", force: :cascade do |t|
    t.bigint "follower_id"
    t.bigint "followed_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followed_user_id"], name: "index_follows_on_followed_user_id"
    t.index ["follower_id", "followed_user_id"], name: "index_follows_on_follower_id_and_followed_user_id", unique: true
    t.index ["follower_id"], name: "index_follows_on_follower_id"
  end

  create_table "forum_threads", force: :cascade do |t|
    t.string "title", null: false
    t.text "content", null: false
    t.bigint "user_id", null: false
    t.bigint "category_id", null: false
    t.text "tag_list"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "likes_count", default: 0, null: false
    t.integer "chill_votes_count", default: 0, null: false
    t.string "mood", default: "Chill", null: false
    t.index ["category_id"], name: "index_forum_threads_on_category_id"
    t.index ["user_id"], name: "index_forum_threads_on_user_id"
  end

  create_table "forum_threads_tags", id: false, force: :cascade do |t|
    t.bigint "forum_thread_id", null: false
    t.bigint "tag_id", null: false
    t.index ["forum_thread_id", "tag_id"], name: "index_forum_threads_tags_on_forum_thread_id_and_tag_id", unique: true
    t.index ["tag_id", "forum_thread_id"], name: "index_forum_threads_tags_on_tag_id_and_forum_thread_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.string "repo_link"
    t.string "live_site_link"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "quiz_answers", force: :cascade do |t|
    t.bigint "quiz_question_id", null: false
    t.text "content"
    t.jsonb "impact"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_question_id"], name: "index_quiz_answers_on_quiz_question_id"
  end

  create_table "quiz_questions", force: :cascade do |t|
    t.bigint "quiz_id", null: false
    t.text "content"
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id"], name: "index_quiz_questions_on_quiz_id"
  end

  create_table "quizzes", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reactions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "forum_thread_id", null: false
    t.string "reaction_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["forum_thread_id"], name: "index_reactions_on_forum_thread_id"
    t.index ["user_id", "forum_thread_id", "reaction_type"], name: "index_reactions_on_user_forum_thread_type", unique: true
    t.index ["user_id"], name: "index_reactions_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "user_quiz_responses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "quiz_id", null: false
    t.bigint "quiz_question_id", null: false
    t.bigint "quiz_answer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_answer_id"], name: "index_user_quiz_responses_on_quiz_answer_id"
    t.index ["quiz_id"], name: "index_user_quiz_responses_on_quiz_id"
    t.index ["quiz_question_id"], name: "index_user_quiz_responses_on_quiz_question_id"
    t.index ["user_id"], name: "index_user_quiz_responses_on_user_id"
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
    t.jsonb "interests"
    t.index ["email"], name: "index_users_on_email", unique: true, where: "(email IS NOT NULL)"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "cluster_assignments", "users"
  add_foreign_key "comments", "comments", column: "parent_id"
  add_foreign_key "comments", "users"
  add_foreign_key "events", "users"
  add_foreign_key "follows", "users", column: "followed_user_id"
  add_foreign_key "follows", "users", column: "follower_id"
  add_foreign_key "forum_threads", "categories"
  add_foreign_key "forum_threads", "users"
  add_foreign_key "projects", "users"
  add_foreign_key "quiz_answers", "quiz_questions"
  add_foreign_key "quiz_questions", "quizzes"
  add_foreign_key "reactions", "forum_threads"
  add_foreign_key "reactions", "users"
  add_foreign_key "user_quiz_responses", "quiz_answers"
  add_foreign_key "user_quiz_responses", "quiz_questions"
  add_foreign_key "user_quiz_responses", "quizzes"
  add_foreign_key "user_quiz_responses", "users"
end
