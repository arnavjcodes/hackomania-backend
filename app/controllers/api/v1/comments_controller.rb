class Api::V1::CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_commentable, only: [ :create, :destroy ]

  def create
    @comment = @commentable.comments.new(comment_params)
    @comment.user = current_user

    if @comment.save
      render json: { message: "Comment created successfully.", comment: @comment }, status: :created
    else
      render json: { error: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @comment = @commentable.comments.find(params[:id])
    if @comment.destroy
      render json: { message: "Comment deleted successfully." }, status: :ok
    else
      render json: { error: "Failed to delete comment." }, status: :unprocessable_entity
    end
  end

  private

  def set_commentable
    if params[:forum_thread_id]
      @commentable = ForumThread.find(params[:forum_thread_id])
    elsif params[:project_id]
      @commentable = Project.find(params[:project_id])
    else
      render json: { error: "No valid parent resource for comment." }, status: :unprocessable_entity
    end
  end

  def comment_params
    params.permit(:content, :mood, :parent_id)
  end
end
