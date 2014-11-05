class UiController < ApplicationController
  # before_filter do
  #   redirect_to :root if Rails.env.production?
  # end
  before_action :front_end_layout, only: [:front, :sign_up]

  layout 'application'

  def index
  end

  def sign_in
    render :layout => false
  end

  private

  def front_end_layout
    render :layout => 'front_end'
  end
end