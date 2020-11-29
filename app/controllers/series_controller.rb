# frozen_string_literal: true

class SeriesController < ApplicationController
  def show
    @series = Series.find(params[:id])
    @leaderboard_json = @series.leaderboard.to_json
  end

  def new
    @series = Series.new
    @redirect_to = params[:redirect_to]
  end

  def create
    series = Series.new(params.require(:series).permit(:name))
    series.user = current_user
    return redirect_to(params[:redirect_to] || root_url) if series.save

    flash[:error] = series.errors.full_messages.first
    redirect_to new_series_url(redirect_to: params[:redirect_to])
  end
end
