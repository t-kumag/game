class MaintenanceController < ApplicationController

  def info
    render json: { latest_commit: Settings.latest_commit }
  end

end
