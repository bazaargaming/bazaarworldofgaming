require 'nokogiri'
require 'open-uri'
require 'timeout'
require 'restclient'



module DailyParseHelper

	def self.parse_all
		GameSale.delete_all
		SteamHelper.parse_steam_site
		GmgHelper.parse_gmg_site
		AmazonHelper.parse_amazon_site
		GamersGateHelper.parse_ggate_site
	end
end