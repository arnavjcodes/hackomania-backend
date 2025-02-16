# app/controllers/api/v1/external_events_controller.rb
module Api
  module V1
    class ExternalEventsController < ApplicationController
      before_action :authenticate_user!

      # GET /api/v1/external_events?location=San+Francisco&search=geek
      def index
        location = params[:location]
        search = params[:search]
        service = PerplexityMeetupSearchService.new(location: location, search_term: search)
        events = service.search_geek_meetups
        render json: { events: events }, status: :ok
      end
    end
  end
end
