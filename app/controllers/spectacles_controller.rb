class SpectaclesController < ApplicationController
  def index
    render json: { spectacles: Spectacle.ordered }, status: :ok
  end

  def create
    service = Spectacles::CreateSpectacleService.new
    if service.perform(params[:name], params[:start_date], params[:finish_date])
      render json: { spectacle: service.spectacle }, status: :ok
    else
      render json: { errors: service.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    spectacle = Spectacle.find_by_id(params[:id])
    render json: { }, status: :not_found and return unless spectacle

    spectacle.destroy
    render json: { id: spectacle.id }, status: :ok
  end
end
