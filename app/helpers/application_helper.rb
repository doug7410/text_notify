module ApplicationHelper
  def active_link?(controller, action=nil)
    (params[:controller] == controller or params[:action] == action)?  'active' : '' 
  end
  
  def format_datetime(dt)
    business_owner_timezone = current_business_owner.account_setting.timezone
    if business_owner_signed_in?&& !business_owner_timezone.blank?
      dt = dt.in_time_zone(business_owner_timezone)
    end

    dt.strftime("%_m/%d/%Y - %l:%M%p") if dt
  
  end
end



