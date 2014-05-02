require 'nokogiri'
require 'open-uri'
require 'timeout'
require 'restclient'


##
# This module contains and functions that can be called in scheduled daily jobs
#
module DailyParseHelper

	##
	# Parses sales from all our vendors, and then runs the alert checker
	#
	def self.parse_all
		GameSale.delete_all
		SteamHelper.parse_steam_site
		GmgHelper.parse_gmg_site
		AmazonHelper.parse_amazon_site
		GamersGateHelper.parse_ggate_site
		AlertHelper.send_alerts
	end
	
end