class ConferencesController < ApplicationController
  def show
    @conference = Conference.find(params[:id])
  end
end
