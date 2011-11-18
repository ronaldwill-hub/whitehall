class SessionsController < ApplicationController
  layout 'admin'
  before_filter :skip_slimmer

  def new
  end

  def create
    user = User.find_or_create_by_name(params[:name])
    user.update_attributes(params.slice('departmental_editor', 'organisation_id'))
    if user.valid?
      session[:user_id] = user.id
      redirect_back admin_root_path
    else
      flash.now[:alert] = "Name can't be blank"
      render :new
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "You've been logged out"
  end
end