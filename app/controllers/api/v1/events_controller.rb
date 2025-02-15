module Api
  module V1
    class EventsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_event, only: [ :show, :update, :destroy, :attend, :cancel_attendance ]

      # GET /api/v1/meetups (or /api/v1/events)
      def index
        # You might separate official events and user meetups on the frontend
        events = Event.upcoming.includes(:user, :attendees)
        render json: events.as_json(
          include: {
            user: { only: [ :id, :username, :name ] },
            attendees: { only: [ :id, :username, :name ] }
          }
        )
      end

      # GET /api/v1/meetups/:id
      def show
        render json: @event.as_json(
          include: {
            user: { only: [ :id, :username, :name ] },
            attendees: { only: [ :id, :username, :name ] }
          }
        )
      end

      # POST /api/v1/meetups
      def create
        @event = current_user.events.new(event_params)
        if @event.save
          render json: { message: "Meetup created successfully.", meetup: @event }, status: :created
        else
          render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/meetups/:id
      def update
        if @event.user == current_user && @event.update(event_params)
          render json: { message: "Meetup updated successfully.", meetup: @event }, status: :ok
        else
          render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/meetups/:id
      def destroy
        if @event.user == current_user && @event.destroy
          render json: { message: "Meetup deleted successfully." }, status: :ok
        else
          render json: { error: "Unable to delete meetup." }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/meetups/:id/attend
      def attend
        # Check if user is already attending
        unless @event.attendees.include?(current_user)
          @event.attendees << current_user
          render json: { message: "You have joined the meetup.", attendees: @event.attendees.as_json(only: [ :id, :username, :name ]) }, status: :ok
        else
          render json: { message: "You are already attending this meetup." }, status: :ok
        end
      end

      # DELETE /api/v1/meetups/:id/attend
      def cancel_attendance
        attendance = @event.meetup_attendances.find_by(user: current_user)
        if attendance
          attendance.destroy
          render json: { message: "You have left the meetup.", attendees: @event.attendees.as_json(only: [ :id, :username, :name ]) }, status: :ok
        else
          render json: { message: "You are not attending this meetup." }, status: :unprocessable_entity
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
