class AccountSettingsController < ApplicationController

  def index
    # binding.pry
    if current_business_owner.account_setting
      @account_settings = current_business_owner.account_setting
    else
      @account_settings = AccountSetting.new
    end 
  end

  def create
    @account_settings  = AccountSetting.new(account_settings_params)

    if @account_settings.save
      flash[:success] = "your settings have been updated"
      redirect_to account_settings_path
    else
      render :index
    end
  end

  def update
    @account_settings = current_business_owner.account_setting


    if @account_settings.update(account_settings_params)
      flash[:success] = "your settings have been updated"
      redirect_to account_settings_path
    else
      render :index
    end


  end

  private

  def account_settings_params
    params.require(:account_setting).permit([:default_send_now_message, :default_add_to_queue_message, :default_send_from_queue_message, :default_message_subject, :timezone ]).merge(business_owner_id: current_business_owner.id)


  end
end