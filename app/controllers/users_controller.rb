class UsersController < ApplicationController
  # These two lines call two functions that check that a user is signed in
  # and that the user that is signed in matches the user whose information
  # is being changed/deleted
  before_action :signed_in_user, only: [:edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update, :destroy]

  #Create a blank user
  def new
    @user = User.new
  end

  #Create a user given parameters
  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "Registration was successful!"
      sign_in @user
      redirect_to root_path
    else
      render 'new'
    end
  end

  #Show a users profile page. Routes to HTML file
  def show
  end

  #Edit a user in the database. Routes to an HTML file
  def edit
  end

  #Update a user given parameters.
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  #Delete a user.
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted."
    redirect_to root_path
  end

  private
    # This function authenticates the parameters
    def user_params
      params.require(:user).permit(:name, :email, :username, :password,
                                   :password_confirmation)
    end

    # This function redirects a user to the sign in page if they aren't signed in
    def signed_in_user
      redirect_to signin_url, notice: "Please sign in." unless signed_in?
    end

    # This function enforces that no one can access a user's info but that user
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
end
