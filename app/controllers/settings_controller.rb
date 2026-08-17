class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def show
  end
end
