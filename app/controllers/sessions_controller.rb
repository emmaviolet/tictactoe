class SessionsController < ApplicationController
  
  def new
  end

  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      logging_in
      redirect_to root_url, notice: "Logged in!"
    else 
      flash.now.alert = "Invalid email or password"
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    guest_user
    redirect_to root_url, notice: "Logged out!"
  end
  
end