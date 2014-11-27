class GroupNotificationsController < ApplicationController
  before_filter :authenticate_user!

  def create
    redirect_to notifications_path
  end
end