class SessionsController < ApplicationController
  def create
    user = User.find_by(user_name: user_params[:user_name])
    if user&.authenticate(user_params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: "Logged in successfully!"
    else
      @user= User.new
      flash.now[:alert] = "Invalid username or password."
      render :new, status: :unprocessable_entity
    end
  end

  def new
    @user = User.new
  end

  def destroy
    if session[:user_id] != nil
      session[:user_id] = nil
      redirect_to root_path, notice: "Logout successfully! "
    end
  end
  

  private

  def user_params
    params.require(:user).permit(:user_name, :password)
  end

end
