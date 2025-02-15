module Api
  module V1
    class UsersController < ApplicationController
      # GET /api/v1/user
      before_action :authenticate_user!

      def show
        user = params[:id] ? User.find(params[:id]) : User.find(current_user.id)

        render json: user.as_json(
          only: [:id, :name, :username, :email, :bio, :created_a, :preferences],
          methods: [:followers_count, :following_count],
          include: {
            forum_threads: { 
              only: [:id, :title, :content, :created_at],
              methods: [:likes_count, :chill_votes_count]
            },
            comments: {
              only: [:id, :content, :created_at, :thread_id],
              include: {
                forum_thread: { only: [:title] }
              }
            }
          }
        ).merge(
          is_following: current_user_same?(user) ? nil : current_user.following?(user),
          comments: user.comments.map { |c| 
            c.as_json.merge(thread_title: c.forum_thread.title) 
          }
        )
      end

      # PATCH/PUT /api/v1/user
      def update
        if @current_user.update(user_params)
          render json: @current_user
        else
          render json: { errors: @current_user.errors.full_messages }, 
                 status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/user
      def destroy
        @current_user.destroy
        head :no_content
      end

      # GET /api/v1/users/:id/followers
      def followers
        user = User.find(params[:id])
        render json: user.followers
      end

      # GET /api/v1/users/:id/following
      def following
        user = User.find(params[:id])
        render json: user.following
      end

      # POST /api/v1/users/:id/follow
      def follow
        user_to_follow = User.find(params[:id])
        
        if current_user.following << user_to_follow
          render json: { message: "Successfully followed #{user_to_follow.username}" }
        else
          render json: { error: "Unable to follow user" }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/users/:id/unfollow
      def unfollow
        follow_relationship = current_user.follows_as_follower.find_by(followed_user_id: params[:id])
        
        if follow_relationship&.destroy
          render json: { message: "Successfully unfollowed" }
        else
          render json: { error: "Unable to unfollow user" }, status: :unprocessable_entity
        end
      end
      

      private

      def current_user_same?(user)
        current_user == user
      end

      def user_params
        params.require(:user).permit(
          :name,
          :email,
          :bio,
          :language,
          :timezone,
          :dark_mode,
          preferences: {
            categories: [],
            tags: [],
            notifications: [:push]
          }
        )
      end
    end
  end
end