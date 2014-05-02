require 'nokogiri'
require 'open-uri'
require 'timeout'
require 'restclient'


##
# This helper is used to manage sending alerts to users
#

module AlertHelper

	##
	# Go through all the alerts in the back-end, check if the alert's game is on sale for equal to or less than the specified threshold
	# If it is, send out an alert
	#

	def self.send_alerts
		alerts = Alert.all

		alerts.each do |alert|
			user = alert.user
			game = alert.game

			lowest_sale = GameHelper.best_price(game)


			if lowest_sale != nil

				#the best sale available meets or beats the alert threshold, so send an alert
				if lowest_sale.saleamt <= alert.threshold
					Alerter.alert_message(user,lowest_sale).deliver
				end
			end
		end
	end

end
