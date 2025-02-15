class Api::V1::CategoriesController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_category, only: [:show]

  # GET /categories
  def index
    @categories = Category.all
    render json: @categories
  end

  # GET /categories/:id
  def show
    @forum_threads = @category.forum_threads.recent
    render json: {
      category: @category,
      forum_threads: @forum_threads.map { |thread| format_thread(thread) }
    }
  end

    # POST /categories
  def create
    @category = Category.new(category_params)
    if @category.save
      # 1) Get or initialize the array of categories in the user's preferences
      user_prefs = current_user.preferences
      user_prefs["categories"] ||= []
  
      # 2) Append the new category ID if it's not already included
      unless user_prefs["categories"].include?(@category.id)
        user_prefs["categories"] << @category.id
      end
  
      # 3) Save the updated user preferences
      current_user.update(preferences: user_prefs)
  
      # 4) Respond with the newly created category
      render json: @category, status: :created
    else
      render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :description)
  end


  
  def format_thread(thread)
    {
      id: thread.id,
      title: thread.title,
      content: thread.content,
      mood: thread.mood,
      created_at: thread.created_at,
      updated_at: thread.updated_at,
      likes_count: thread.reactions.where(reaction_type: 'like').count,
      chill_votes_count: thread.reactions.where(reaction_type: 'chill').count,
      comments_count: thread.comments.count,
      user: {
        id: thread.user.id,
        username: thread.user.username,
        name: thread.user.name
      },
      user_liked: thread.reactions.exists?(user: current_user, reaction_type: 'like'),
      user_chilled: thread.reactions.exists?(user: current_user, reaction_type: 'chill')
    }
  end
end