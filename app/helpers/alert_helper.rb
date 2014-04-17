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

			lowest_sale = nil
			game_sales = game.game_sales
			game_sales.each do |sale|
				saleamt = sale.saleamt.to_f
				if lowest_sale == nil or lowest_sale.saleamt.to_f > saleamt.to_f
					lowest_sale = sale
				end
			end


			if lowest_sale != nil
				if lowest_sale.saleamt <= alert.threshold
					Alerter.alert_message(user,lowest_sale).deliver
				end
			end
		end
	end


end
