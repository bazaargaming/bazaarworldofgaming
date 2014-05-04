class SessionsController < ApplicationController
  #Action to start a new session.
	def new
	end

  #Action that creates a new session given a username and password.
  #Displays messages on success and error
	def create
		user = User.find_by(username: params[:session][:username])
  		if user && user.authenticate(params[:session][:password])
    		sign_in user #Helper function that creates a cookie for the session
    		flash.now[:success] = 'Login Successful'
    		redirect_to root_path
  		else
    		flash.now[:error] = 'Invalid username or password'
      		render 'new'
  		end
	end

  #destroy the current session i.e. sign out.
	def destroy
    sign_out
    redirect_to root_url
	end
end
