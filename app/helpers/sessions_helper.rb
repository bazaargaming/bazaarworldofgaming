module SessionsHelper

	# This function creates a cookie for the current user session and sets the variable current_user
	def sign_in(user)
		remember_token = User.new_remember_token
		cookies.permanent[:remember_token] = remember_token
		user.update_attribute(:remember_token, User.hash(remember_token))
		self.current_user = user
	end

	# Overrides = method for current_user
	def current_user=(user)
		@current_user = user
	end

	#  Functions that allows @current_user to be used as just current_user
	def current_user
    	remember_token = User.hash(cookies[:remember_token])
    	@current_user ||= User.find_by(remember_token: remember_token)
  	end

  	# Checks if the user passed in matches the user signed in
  	def current_user?(user)
    	user == current_user
 	end

 	# Checks if user is signed in
	def signed_in?
		!current_user.nil?
	end

	# Deletes current session cookie and sets current_user to nil
	def sign_out
    	current_user.update_attribute(:remember_token,
                                  User.hash(User.new_remember_token))
    	cookies.delete(:remember_token)
    	self.current_user = nil
  	end
end
