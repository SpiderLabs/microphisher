class ApplicationController < ActionController::Base
  include ApplicationHelper
  
  protect_from_forgery
  
  # Restrict access to authenticated users
  before_filter :require_login
  
  def require_login
    redirect_to home_url unless logged_in?
  end
end
