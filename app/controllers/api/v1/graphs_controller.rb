# app/controllers/api/v1/graphs_controller.rb
module Api
  module V1
    class GraphsController < ApplicationController
      before_action :authenticate_user!

      def show
        # Get current user's followers and following
        followers = current_user.followers.to_a
        following = current_user.following.to_a

        # Create the union of nodes (include self for context)
        graph_users = (followers + following + [ current_user ]).uniq
        user_ids = graph_users.map(&:id)

        # Build nodes for the graph
        nodes = graph_users.map do |user|
          {
            id: user.id,
            username: user.username,
            name: user.name
            # Add any other user attributes you need on the frontend
          }
        end

        # Build edges (follow relationships) among these nodes
        edges = []
        graph_users.each do |user|
          # Determine if we can reveal this user's outgoing follow edges:
          # Allowed if the user is current_user OR if the user follows current_user.
          if user == current_user || current_user.followers.include?(user)
            # For each follow relation from the user, include the edge if the target is in our graph
            user.follows_as_follower.each do |follow|
              if user_ids.include?(follow.followed_user_id)
                edges << {
                  source: follow.follower_id,
                  target: follow.followed_user_id,
                  created_at: follow.created_at # optional, if needed
                }
              end
            end
          end
        end

        render json: { nodes: nodes, edges: edges }
      end
    end
  end
end
