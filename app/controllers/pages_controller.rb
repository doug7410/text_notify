class PagesController < ApplicationController
  
  before_filter :go_to_ui_pages

  def front
    render :layout => 'front_end'
  end

  private
  
  def go_to_ui_pages
    redirect_to new_notification_path if user_signed_in?
  end
end