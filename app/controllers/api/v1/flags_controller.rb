class Api::V1::FlagsController < ApplicationController
  def index
    flags = Flag.all
    render json: flags, include: [:flaggable, :user]
  end

  def create
    flag = Flag.new(flag_params)
    if flag.save
      render json: flag, status: :created
    else
      render json: { error: flag.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def flag_params
    params.require(:flag).permit(:reason, :user_id, :flaggable_id, :flaggable_type)
  end
end
