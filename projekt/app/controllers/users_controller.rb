class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to new_session_path, notice: "Account created successfully!"
    else
      flash.now[:alert] = "There was a problem creating your account."
      render :new, status: :unprocessable_entity
    end
  end

  def new
    @user = User.new
  end

  def update
  end

  def edit
  end

  private

  def user_params
    params.require(:user).permit(:user_name, :password, :password_confirmation)
  end
end
