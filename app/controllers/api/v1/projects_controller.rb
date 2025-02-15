module Api
  module V1
    class ProjectsController < ApplicationController
      before_action :authenticate_user!, except: [ :index, :show ]
      before_action :set_project, only: [ :show, :update, :destroy ]

      # GET /api/v1/projects
      def index
        # Load all projects, optionally including associated user
        projects = Project.includes(:user).order(created_at: :desc)

        render json: projects.map { |project| project_data(project) }
      end

      # POST /api/v1/projects
      def create
        # Build a new project for the current_user
        @project = current_user.projects.build(project_params)

        if @project.save
          render json: {
            message: "Project created successfully.",
            project: project_data(@project)
          }, status: :created
        else
          render json: { error: @project.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/projects/:id
      def show
        render json: {
          project: project_data(@project),
          comments: format_comments(@project.comments.where(parent_id: nil))
        }
      end

      # PATCH/PUT /api/v1/projects/:id
      def update
        # Optional: Ensure only the project owner can update
        unless @project.user == current_user
          return render json: { error: "Not authorized to update this project." }, status: :forbidden
        end

        if @project.update(project_params)
          render json: {
            message: "Project updated successfully.",
            project: project_data(@project)
          }, status: :ok
        else
          render json: { error: @project.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/projects/:id
      def destroy
        # Optional: Ensure only the project owner can destroy
        unless @project.user == current_user
          return render json: { error: "Not authorized to delete this project." }, status: :forbidden
        end

        if @project.destroy
          render json: { message: "Project deleted successfully." }, status: :ok
        else
          render json: { error: "Failed to delete project." }, status: :unprocessable_entity
        end
      end

      private

      def set_project
        @project = Project.find(params[:id])
      end

      def project_params
        # Permit the fields your Project model has
        params.require(:project).permit(:title, :description, :repo_link, :live_site_link)
      end

      # This returns a single project's data in a consistent JSON structure
      def project_data(project)
        {
          id: project.id,
          title: project.title,
          description: project.description,
          repo_link: project.repo_link,
          live_site_link: project.live_site_link,
          created_at: project.created_at,
          user: {
            id: project.user.id,
            username: project.user.username,
            name: project.user.name
          },
          # If you want the total number of comments:
          comments_count: project.comments.count
        }
      end

      # Format top-level comments + nested replies (similar to ForumThreads)
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
            replies: format_comments(comment.replies)
          }
        end
      end
    end
  end
end
