class UiController < ApplicationController
  # before_filter do
  #   redirect_to :root if Rails.env.production?
  # end
  layout 'application'

  def index
  end

  def sign_in
    render :layout => false
  end

  def sign_up
    render :layout => 'front_end'
  end
end