module Api::V1::Admin
    class ClusteringController < ApplicationController
      before_action :authenticate_admin!
  
      def create
        version = params[:version] || ClusterAssignment.maximum(:version).to_i + 1
        ClusteringJob.perform_later(version)
        render json: { 
          message: "Clustering job enqueued for version #{version}",
          job_id: ClusteringJob.provider_job_id
        }
      end
  
      private
  
      def authenticate_admin!
        head :forbidden unless current_user.admin?
      end
    end
  end