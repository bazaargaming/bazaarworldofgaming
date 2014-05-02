module UsersHelper

	def gravatar_for(user)
    	gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    	gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}"
	end

	def self.get_games_in_groups(user)
		size = user.games.size
		num_of_arrays = size/6
		num_of_arrays = size % 6 == 0 ? num_of_arrays : num_of_arrays + 1
		arrays = Array.new

		for n in 0..num_of_arrays
			arrays[n] = Array.new
		end

		user.games.each_with_index do |game, i|
			array = arrays[i/6]
			array.push(game)
		end

		return arrays
	end
	def self.get_alerts_in_groups(user)
		size = user.alerts.size
		num_of_arrays = size/6
		num_of_arrays = size % 6 == 0 ? num_of_arrays : num_of_arrays + 1
		arrays = Array.new

		for n in 0..num_of_arrays
			arrays[n] = Array.new
		end

		user.alerts.each_with_index do |alert, i|
			array = arrays[i/6]
			array.push(alert)
		end

		return arrays
	end
end
