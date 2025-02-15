# config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      # Replace with your frontend's origin
      origins 'https://web-forum-frontend.vercel.app', 'http://localhost:3001'
  
      resource '*',
        headers: :any,
        methods: [:get, :post, :put, :patch, :delete, :options, :head],
        credentials: true # If you need to send cookies or authorization headers
    end
  end
  
