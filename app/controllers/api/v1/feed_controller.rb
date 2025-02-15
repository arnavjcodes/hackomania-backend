module Api
    module V1
      class FeedController < ApplicationController
        before_action :authenticate_user!
  
        # GET /api/v1/feed
        def index
          # Step 1: Get user’s preferred categories
          preferred = current_user.preferences["categories"] || []
  
          # Step 2: Discovery logic for random categories
          all_cats = Category.pluck(:id)
          unsubscribed = all_cats - preferred
          random_picks = unsubscribed.sample([3, unsubscribed.size].min)
          category_ids_for_feed = (preferred + random_picks).uniq
  
          # Step 3: Fetch all threads for those categories
          feed_threads = ForumThread
                           .where(category_id: category_ids_for_feed)
                           .includes(:user, :comments, :reactions)
                           .order(created_at: :desc)
  
          # Step 4: Serialize feed with necessary attributes
          render json: feed_threads.map { |thread| format_thread(thread) }
        end
  
        private
  
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
    end
  end
  