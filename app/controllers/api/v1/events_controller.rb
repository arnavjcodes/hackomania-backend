module Api
  module V1
    class EventsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_event, only: [ :show, :update, :destroy ]

      # GET /api/v1/events
      def index
        events = Event.upcoming.includes(:user)
        render json: events.as_json(include: { user: { only: [ :id, :username, :name ] } })
      end

      # GET /api/v1/events/:id
      def show
        render json: @event.as_json(include: { user: { only: [ :id, :username, :name ] } })
      end

      # POST /api/v1/events
      def create
        @event = current_user.events.new(event_params)
        if @event.save
          render json: { message: "Event created successfully.", event: @event }, status: :created
        else
          render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/events/:id
      def update
        if @event.user == current_user && @event.update(event_params)
          render json: { message: "Event updated successfully.", event: @event }, status: :ok
        else
          render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/events/:id
      def destroy
        if @event.user == current_user && @event.destroy
          render json: { message: "Event deleted successfully." }, status: :ok
        else
          render json: { error: "Unable to delete event." }, status: :unprocessable_entity
        end
      end

      private

      def set_event
        @event = Event.find(params[:id])
      end

      def event_params
        params.require(:event).permit(:title, :description, :start_time, :end_time, :location, :event_type)
      end
    end
  end
end
