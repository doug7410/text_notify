class QueueItemController < ApplicationController
  def destroy
    QueueItem.find(params[:id]).destroy
    redirect_to notifications_path
  end
end