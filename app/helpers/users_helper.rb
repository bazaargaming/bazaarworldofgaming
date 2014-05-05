#This module is used to format a user's data so that it can easily be displayed on the user's profile page
module UsersHelper

	# This fuction, upon recieving a user, will use the user's email address to
	# find the gravatar image associated with that email address.
	# Returns the url of the user's gravatar image.
	def gravatar_for(user)
    	gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    	gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}"
	end

	# This function takes the list of games that a user has added to their profile
	# and returns them in a list of arrays of length 6 so that they can be easily formated
	# and represented on the user's page.
	def self.get_games_in_groups(user)

		# Determine the number of arrays of length 6 needed
		size = user.games.size
		num_of_arrays = size/6
		num_of_arrays = size % 6 == 0 ? num_of_arrays : num_of_arrays + 1
		
		# Initialialize the double array that will be returned
		arrays = Array.new
		for n in 0..num_of_arrays
			arrays[n] = Array.new
		end

		# Fill in the arrays with the games
		user.games.each_with_index do |game, i|
			array = arrays[i/6]
			array.push(game)
		end

		return arrays
	end

	# This function takes the list of price alerts that a user has created
	# and returns them in a list of arrays of length 6 so that they can be
	# easily formated and represented on the user's page.
	def self.get_alerts_in_groups(user)

		# Determine the number of arrays of length 6 needed
		size = user.alerts.size
		num_of_arrays = size/6
		num_of_arrays = size % 6 == 0 ? num_of_arrays : num_of_arrays + 1
		
		# Initialialize the double array that will be returned
		arrays = Array.new
		for n in 0..num_of_arrays
			arrays[n] = Array.new
		end

		# Fill in the arrays with the price alerts
		user.alerts.each_with_index do |alert, i|
			array = arrays[i/6]
			array.push(alert)
		end

		return arrays
	end
end
