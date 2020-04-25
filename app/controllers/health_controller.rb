# frozen_string_literal: true

class HealthController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    render json: [{ health: 'ok' }]
  end
end
