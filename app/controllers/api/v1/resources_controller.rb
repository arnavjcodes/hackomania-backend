module Api
  module V1
    class ResourcesController < ApplicationController
      before_action :authenticate_user!  # Ensure user is logged in
      before_action :set_resource, only: [ :show, :update, :destroy, :upvote, :downvote, :comments, :add_comment ]

      # GET /api/v1/resources
      # Supports filtering by resource_type, tag, search query, and ordering by rating or views.
      def index
        resources = Resource.includes(:user, :tags)
                              .published
                              .search(params[:q])
                              .by_type(params[:resource_type])
                              .with_tag(params[:tag])
        # Ordering: default order by creation, or override with "rating" or "views"
        if params[:order] == "rating"
          resources = resources.ordered_by_rating
        elsif params[:order] == "views"
          resources = resources.ordered_by_views
        else
          resources = resources.order(created_at: :desc)
        end

        render json: resources.as_json(
          include: {
            user: { only: [ :id, :username, :name ] },
            tags: { only: [ :id, :name ] }
          }
        )
      end

      # GET /api/v1/resources/:id
      def show
        # Increase view count on every show call.
        @resource.increment_view!
        render json: @resource.as_json(
          include: {
            user: { only: [ :id, :username, :name ] },
            tags: { only: [ :id, :name ] },
            resource_comments: { include: { user: { only: [ :id, :username, :name ] } } }
          }
        )
      end

      # POST /api/v1/resources
      def create
        @resource = current_user.resources.new(resource_params)
        if @resource.save
          render json: { message: "Resource created successfully.", resource: @resource }, status: :created
        else
          render json: { errors: @resource.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/resources/:id
      def update
        if @resource.user == current_user && @resource.update(resource_params)
          render json: { message: "Resource updated successfully.", resource: @resource }, status: :ok
        else
          render json: { errors: @resource.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/resources/:id
      def destroy
        if @resource.user == current_user && @resource.destroy
          render json: { message: "Resource deleted successfully." }, status: :ok
        else
          render json: { error: "Unable to delete resource." }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/resources/:id/upvote
      def upvote
        if @resource.upvote!
          render json: { message: "Resource upvoted.", rating: @resource.rating }, status: :ok
        else
          render json: { errors: "Failed to upvote resource." }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/resources/:id/downvote
      def downvote
        if @resource.downvote!
          render json: { message: "Resource downvoted.", rating: @resource.rating }, status: :ok
        else
          render json: { errors: "Failed to downvote resource." }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/resources/:id/comments
      def comments
        comments = @resource.resource_comments.includes(:user).order(created_at: :asc)
        render json: comments.as_json(
          include: { user: { only: [ :id, :username, :name ] } }
        )
      end

      # POST /api/v1/resources/:id/comments
      def add_comment
        comment = @resource.resource_comments.new(resource_comment_params)
        comment.user = current_user
        if comment.save
          render json: { message: "Comment added.", comment: comment }, status: :created
        else
          render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_resource
        @resource = Resource.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Resource not found." }, status: :not_found
      end

      def resource_params
        params.require(:resource).permit(
          :title, :description, :content, :resource_type, :url, :published, :approved,
          tag_ids: []  # Accept an array of tag IDs for association
        )
      end

      def resource_comment_params
        params.require(:resource_comment).permit(:content)
      end
    end
  end
end
