module Api
  module V1
    class AuthController < ApplicationController
      # Skip CSRF protection for API actions

      # POST /api/v1/auth/login
      def login
        # Find user by username
        user = User.find_by(username: params[:username])

        if user
          # If user exists, generate a token and return success response
          token = JsonWebToken.encode({ user_id: user.id })
          render json: { token: token, message: 'Login successful' }, status: :ok
        else
          # If user doesn't exist, create a new user
          user = User.create(username: params[:username])

          if user.persisted?
            # Generate a token for the new user
            token = JsonWebToken.encode({ user_id: user.id })
            render json: { token: token, message: 'User created and login successful' }, status: :ok
          else
            # Handle any errors during user creation
            render json: { error: 'Failed to create user' }, status: :unprocessable_entity
          end
        end
      end

      # DELETE /api/v1/auth/logout
      def logout
        # Since JWT is stateless, logout is client-side.
        render json: { message: 'Logout successful (token deleted client-side)' }, status: :ok
      end
    end
  end
end
