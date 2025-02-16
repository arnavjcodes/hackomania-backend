# app/controllers/chat_controller.rb
class Api::V1::ChatController < ApplicationController
  require "httparty"

  # System prompt to define the chatbot's personality
  SYSTEM_PROMPT = <<~PROMPT
    You are CodeNerd, a witty and geeky chatbot designed to assist with coding, answer trivia, and crack jokes. Your personality is a mix of a tech-savvy nerd and a sci-fi fan. You love making references to pop culture, memes, and programming humor. Always respond in a friendly, humorous, and slightly sarcastic tone. Use emojis occasionally to spice up your responses.
  PROMPT

  # Joke API URL
  JOKE_API_URL = "https://v2.jokeapi.dev/joke/Programming?blacklistFlags=nsfw,religious"

  # Endpoint to handle chat requests
  def create
    message = params[:message]

    # Easter eggs
    if message.downcase.include?("answer to life")
      return render json: { response: "42" }
    end

    # Geeky jokes
    if message.downcase.include?("tell me a joke")
      joke = get_geeky_joke
      return render json: { response: joke }
    end

    # Geek trivia and coding help
    begin
      response = call_gemini_api(message)
      render json: { response: response }
    rescue StandardError => e
      render json: { response: "Oops! Something went wrong." }, status: :internal_server_error
    end
  end

  private

  # Fetch a random geeky joke
  def get_geeky_joke
    response = HTTParty.get(JOKE_API_URL)
    if response["joke"]
      response["joke"]
    else
      "#{response['setup']} #{response['delivery']}"
    end
  rescue StandardError => e
    "Why did the programmer quit their job? Because they didn’t get arrays! 😄"
  end

  # Call the Gemini API
  def call_gemini_api(message)
    payload = {
      contents: [
        {
          parts: [
            {
              text: "#{SYSTEM_PROMPT}\n\nUser: #{message}\nCodeNerd:"
            }
          ]
        }
      ]
    }

    headers = {
      "Content-Type" => "application/json"
    }

    response = HTTParty.post(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyAJDwmW1X5eyBZ0isYvb2NYQMKAITlHaC4",
      body: payload.to_json,
      headers: headers
    )

    response["candidates"][0]["content"]["parts"][0]["text"]
  end
end
