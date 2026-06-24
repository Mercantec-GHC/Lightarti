class ApplicationController < ActionController::Base
  # allow_browser versions: :modern
  before_action :redirect_to_root_on_first_visit, unless: -> { Rails.env.test? }
  helper_method :current_user
  before_action :current_user

  
  private

  def redirect_to_root_on_first_visit
    return if request.path == root_path
    return if session[:has_seen_root]
    session[:has_seen_root] = true
    redirect_to root_path
  end

  def current_user
    @current_user = User.find_by(id: session[:user_id])
  end
end
