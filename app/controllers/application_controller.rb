class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def authenticate_user!
    return if current_user

    session[:return_to] = request.fullpath if request.get? || request.head?
    redirect_to login_path, alert: "Please sign in to continue."
  end

  def require_admin!
    return if current_user&.admin?

    redirect_to root_path, alert: "Administrator access is required."
  end
end
