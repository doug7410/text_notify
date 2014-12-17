module ApplicationHelper
  def active_link?(controller, action=nil)
    (params[:controller] == controller or params[:action] == action)?  'active' : '' 
  end
end
