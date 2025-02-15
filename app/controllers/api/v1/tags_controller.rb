class Api::V1::TagsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  # GET /tags
  def index
    @tags = Tag.all
    render json: @tags
  end

  # GET /tags/:id
  def show
    @tag = Tag.find(params[:id])
    @forum_threads = @tag.forum_threads.recent
    render json: {
      tag: @tag,
      forum_threads: @forum_threads
    }
  end

  # POST /tags
  def create
    @tag = Tag.new(tag_params)
    if @tag.save
      render json: @tag, status: :created
    else
      render json: { error: @tag.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def tag_params
    params.require(:tag).permit(:name)
  end
end
