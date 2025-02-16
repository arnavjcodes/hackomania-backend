# app/controllers/api/v1/projects_controller.rb
module Api
  module V1
    class ProjectsController < ApplicationController
      before_action :authenticate_user!, except: [ :index, :show ]
      before_action :set_project, only: [ :show, :update, :destroy, :add_collaborator, :remove_collaborator ]

      # GET /api/v1/projects
      def index
        projects = Project.includes(:user).order(created_at: :desc)
        render json: projects.map { |project| project_data(project) }
      end

      # POST /api/v1/projects
      def create
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
        # Ensure only the project owner can update
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
        # Ensure only the project owner can destroy
        unless @project.user == current_user
          return render json: { error: "Not authorized to delete this project." }, status: :forbidden
        end

        if @project.destroy
          render json: { message: "Project deleted successfully." }, status: :ok
        else
          render json: { error: "Failed to delete project." }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/projects/:id/add_collaborator
      def add_collaborator
        # Only the owner can add collaborators
        unless @project.user == current_user
          return render json: { error: "Not authorized to add collaborators." }, status: :forbidden
        end

        collaborator = User.find_by(id: params[:collaborator_id])
        unless collaborator
          return render json: { error: "Collaborator not found." }, status: :not_found
        end

        if @project.collaborators.include?(collaborator)
          return render json: { error: "Collaborator already added." }, status: :unprocessable_entity
        end

        @project.collaborators << collaborator
        render json: { message: "Collaborator added.", project: project_data(@project) }, status: :ok
      end

      # DELETE /api/v1/projects/:id/remove_collaborator
      def remove_collaborator
        # Only the owner can remove collaborators
        unless @project.user == current_user
          return render json: { error: "Not authorized to remove collaborators." }, status: :forbidden
        end

        collaborator = User.find_by(id: params[:collaborator_id])
        unless collaborator && @project.collaborators.include?(collaborator)
          return render json: { error: "Collaborator not found on this project." }, status: :not_found
        end

        @project.collaborators.delete(collaborator)
        render json: { message: "Collaborator removed.", project: project_data(@project) }, status: :ok
      end

      private

      def set_project
        @project = Project.find(params[:id])
      end

      def project_params
        params.require(:project).permit(
          :title, :description, :repo_link, :live_site_link,
          :tech_stack, :schema_url, :flowchart_url
        )
      end

      def project_data(project)
        {
          id: project.id,
          title: project.title,
          description: project.description,
          repo_link: project.repo_link,
          live_site_link: project.live_site_link,
          tech_stack: project.tech_stack,
          schema_url: project.schema_url,
          flowchart_url: project.flowchart_url,
          created_at: project.created_at,
          user: {
            id: project.user.id,
            username: project.user.username,
            name: project.user.name
          },
          collaborators: project.collaborators.as_json(only: [ :id, :username, :name ]),
          comments_count: project.comments.count
        }
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
            replies: format_comments(comment.replies)
          }
        end
      end
    end
  end
end
