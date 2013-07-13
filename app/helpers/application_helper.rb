module ApplicationHelper
  def logged_in?
    !current_user.nil?
  end
  
  def current_user
    session[:user].nil? ? nil : User.find(session[:user])
  end
end
