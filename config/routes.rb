Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :admin do
        post "/cluster", to: "clustering#create"
      end

      post "/chat", to: "chat#create"

      get "graph", to: "graphs#show"

      resources :external_events, only: [ :index ]

      resources :projects, only: [ :index, :create, :show, :update, :destroy ] do
        resources :comments, only: [ :create, :destroy ]

        member do
          post   :add_collaborator      # Expects params[:collaborator_id]
          delete :remove_collaborator   # Expects params[:collaborator_id]
        end
      end

      resources :meetups, controller: "events", only: [ :index, :show, :create, :update, :destroy ] do
        member do
          post :attend     # Join the meetup
          delete :attend, action: :cancel_attendance  # Leave the meetup
        end
      end


      resources :resources, only: [ :index, :show, :create, :update, :destroy ] do
        member do
          post :upvote
          post :downvote
          get  :comments
          post :comments, action: :add_comment
        end
      end

      # Authentication routes
      post "auth/login", to: "auth#login"
      delete "auth/logout", to: "auth#logout"

      get "forum_threads", to: "forum_threads#all_threads"

      resources :quizzes, only: [ :index ] do
        post :responses, to: "quiz_responses#create"
      end

      namespace :api do
        namespace :v1 do
          resources :events, only: [ :index, :show, :create, :update, :destroy ]
        end
      end

      resources :resources, only: [ :index, :show, :create, :update, :destroy ] do
        member do
          post :upvote
          post :downvote
          get  :comments         # GET comments for a resource
          post :comments, action: :add_comment  # Post a new comment
        end
      end




      # Categories
      resources :categories, only: [ :index, :show, :create ] do
        # Nested routes for threads under categories
        resources :forum_threads, only: [ :index, :create ] # Index for threads in a category
      end

      # Forum Threads
      resources :forum_threads, only: [ :show, :update, :destroy ] do
        # Nested routes for comments under threads
        resources :comments, only: [ :create, :destroy ]

        # Routes for likes and chill votes
        member do
          patch :toggle_reaction  # Pass reaction_type in params
        end
      end

      # Tags
      resources :tags, only: [ :index, :show, :create ]

      # Feed
      get "feed", to: "feed#index"

      # User profile
      get "user", to: "users#show"
      put "user", to: "users#update"
      patch "user", to: "users#update"

      delete "user", to: "users#destroy"

      resources :users, only: [ :show ] do
        member do
          get :followers
          get :following
          post :follow
          delete :unfollow
        end
      end
    end
  end

  # Root and Frontend Routes
  root "homepage#index"
  get "/*path" => "homepage#index"

  # Health Check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA Files
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
