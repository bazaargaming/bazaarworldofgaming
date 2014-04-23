require 'nokogiri'
require 'open-uri'
require 'timeout'
require 'restclient'



module AlertHelper
	def self.sendAlerts
		alerts = Alert.all

		alerts.each do |alert|
			user = alert.user
			game = alert.game

			lowest_sale = GameHelper.best_price(game)


			if lowest_sale != nil
				if lowest_sale.saleamt <= alert.threshold
					Alerter.alert_message(user,lowest_sale).deliver
				end
			end
		end
	end


end
