class Api::V1::ForumThreadsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_forum_thread, only: [:update, :show, :destroy, :toggle_like, :toggle_chill]
  
  def all_threads
    threads = ForumThread.includes(:user, :category, :reactions).order(created_at: :desc)

    render json: threads.map { |thread| forum_thread_data(thread) }
  end
  # GET /forum_threads
  def index
    category = Category.find(params[:category_id])
    forum_threads = category.forum_threads.recent.includes(:user, :reactions, :category)
  
    render json: forum_threads.map { |thread| forum_thread_data(thread) }
  end

  # POST /forum_threads
  def create
    @forum_thread = ForumThread.new(forum_thread_params)
    @forum_thread.user = current_user

    if @forum_thread.save
      render json: { message: "Thread created successfully.", forum_thread: forum_thread_data(@forum_thread) }, status: :created
    else
      render json: { error: @forum_thread.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /forum_threads/:id
  def show
    render json: {
      forum_thread: forum_thread_data(@forum_thread),
      comments: format_comments(@forum_thread.comments.where(parent_id: nil))
    }
  end

  # PATCH /forum_threads/:id
  def update
    if @forum_thread.update(forum_thread_params)
      render json: { message: "Thread updated successfully.", forum_thread: forum_thread_data(@forum_thread) }, status: :ok
    else
      render json: { error: @forum_thread.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /forum_threads/:id
  def destroy
    if @forum_thread.destroy
      render json: { message: "Thread deleted successfully." }, status: :ok
    else
      render json: { error: "Failed to delete thread." }, status: :unprocessable_entity
    end
  end

  # PATCH /forum_threads/:id/like
  # PATCH /forum_threads/:id/toggle_like
  def toggle_like
    reaction = @forum_thread.reactions.find_by(
      user: current_user,
      reaction_type: "like"
    )

    if reaction
      # user already liked => remove the like
      reaction.destroy
    else
      # create a new like
      @forum_thread.reactions.create!(
        user: current_user,
        reaction_type: "like"
      )
    end

    render json: forum_thread_data(@forum_thread), status: :ok
  end

  # PATCH /forum_threads/:id/toggle_chill
  def toggle_chill
    reaction = @forum_thread.reactions.find_by(
      user: current_user,
      reaction_type: "chill"
    )

    if reaction
      # user already chilled => remove
      reaction.destroy
    else
      # create new chill
      @forum_thread.reactions.create!(
        user: current_user,
        reaction_type: "chill"
      )
    end

    render json: forum_thread_data(@forum_thread), status: :ok
  end

  private

  def set_forum_thread
    @forum_thread = ForumThread.find(params[:id])
  end

  # Return all needed data, including whether current_user has liked/chilled
  def forum_thread_data(thread)
    likes_count = thread.reactions.where(reaction_type: "like").count
    chill_count = thread.reactions.where(reaction_type: "chill").count
    user_liked = thread.reactions.exists?(user: current_user, reaction_type: "like")
    user_chilled = thread.reactions.exists?(reaction_type: "chill", user: current_user)
    category = Category.find(thread.category_id)

    thread.as_json(
      include: { 
        user: { only: [:id, :username, :name] },
  
      }
    ).merge({
      "likes_count" => likes_count,
      "chill_votes_count" => chill_count,
      "user_liked" => user_liked,
      "user_chilled" => user_chilled,
      "comments_count" => thread.comments.count,
      "category" => thread.category.as_json(only: [:id, :name, :description]),
      "mood" => thread.mood,
      "tags" => thread.tags.map { |tag| { id: tag.id, name: tag.name } }
    })
  end

  def forum_thread_params
    params.require(:forum_thread).permit(:title, :content, :mood, :category_id, :tag_list)
  end

  def format_comments(comments)
    comments.map do |comment|
      {
        id: comment.id,
        content: comment.content,
        user: {
          id: comment.user.id,
          username: comment.user.username,
          name: comment.user.name
        },
        mood: comment.mood,
        created_at: comment.created_at,
        replies: format_comments(comment.replies) # Recursive call for nested replies
      }
    end
  end

end
