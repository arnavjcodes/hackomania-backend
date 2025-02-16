# app/services/perplexity_meetup_search_service.rb
require "net/http"
require "uri"
require "json"

class PerplexityMeetupSearchService
  API_ENDPOINT = "https://api.perplexity.ai/chat/completions"
  API_KEY = "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" # Ensure this is set in your environment

  def initialize(location: nil, search_term: nil)
    @location = location
    @search_term = search_term
  end

  def search_geek_meetups
    messages = [
      {
        "role"    => "system",
        "content" => "You are a helpful AI assistant. Provide only the final answer without intermediate steps."
      },
      {
        "role"    => "user",
        "content" => generate_user_prompt
      }
    ]

    uri = URI(API_ENDPOINT)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path, {
      "Accept"        => "application/json",
      "Content-Type"  => "application/json",
      "Authorization" => "Bearer #{API_KEY}"
    })

    body = {
      model: "sonar",
      messages: messages
    }
    request.body = body.to_json

    response = http.request(request)

    if response.code.to_i == 200
      parsed = JSON.parse(response.body)
      raw_content = parsed["choices"][0]["message"]["content"]

      # Remove markdown formatting if present.
      if raw_content.strip.start_with?("```json")
        raw_content = raw_content.strip.sub(/^```json\s*/, "").sub(/\s*```$/, "")
      end

      begin
        events = JSON.parse(raw_content)
        events
      rescue JSON::ParserError => e
        Rails.logger.error "Failed to parse event listings from Perplexity API: #{e.message}"
        []
      end
    else
      Rails.logger.error "Perplexity API error: #{response.body}"
      []
    end
  rescue StandardError => e
    Rails.logger.error "Error calling Perplexity API: #{e.message}"
    []
  end

  private

  def generate_user_prompt
    prompt = "Search the web for the latest geek events and online meetups. " \
             "Return a JSON array where each object has exactly the following keys: " \
             "title (string), description (string), start_time (ISO8601 datetime string), " \
             "end_time (ISO8601 datetime string or null), location (string), " \
             "event_type (physical, online, or hybrid), and url (string representing the organizing website). " \
             "Ensure the descriptions have a fun, geeky vibe. " \
             "Focus on both physical meetups and online events."
    prompt += " Include events related to: #{@search_term}." if @search_term.present?
    prompt += " Location: #{@location}." if @location.present?
    prompt
  end
end
