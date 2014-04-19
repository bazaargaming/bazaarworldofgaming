require 'spec_helper'

describe GamersGateHelper do

	it "should return false because url is not a game list page" do
		url = "http://www.gamersgate.com/DD-CIV5BNW/sid-meiers-civilization-v-brave-new-world"
		expect(GamersGateHelper.parse_menu_page(url)).to eq(false)
	end

	it "should return true because url is a proper game list page" do
		url = "http://www.gamersgate.com/games?state=available&pg=1"
		expect(GamersGateHelper.parse_menu_page(url)).to eq(true)
	end

	it "should return correct information for the game The Last Federation shown in the first page" do
		url = "http://www.gamersgate.com/games?state=available&pg=1"
		f = RestClient.get(url)
		doc = Nokogiri::HTML(f)
		games = doc.css('div.product_display')
		game = games[0]
		expect(GamersGateHelper.parse_name(game)).to eq("The Last Federation")
		expect(GamersGateHelper.parse_current_price(game)).to eq(14.99)
		
		game_url = GamersGateHelper.parse_game_url(game)
		expect(game_url).to eq("http://www.gamersgate.com/DD-TLF/the-last-federation")
		
		expect(GamersGateHelper.is_on_sale(game)).to eq(true)
		game_src = RestClient.get(game_url)
		game_doc = Nokogiri::HTML(game_src)
		expect(GamersGateHelper.parse_orig_price(game_doc)).to eq(19.99)
	end

	it "should return correct information for the game Wargame: Red Dragon shown in the first page" do
		url = "http://www.gamersgate.com/games?state=available&pg=1"
		f = RestClient.get(url)
		doc = Nokogiri::HTML(f)
		games = doc.css('div.product_display')
		game = games[1]
		expect(GamersGateHelper.parse_name(game)).to eq("Wargame: Red Dragon")
		expect(GamersGateHelper.parse_current_price(game)).to eq(39.99)
		expect(GamersGateHelper.parse_game_url(game)).to eq("http://www.gamersgate.com/DD-WGRD/wargame-red-dragon")
		expect(GamersGateHelper.is_on_sale(game)).to eq(false)
	end

	it "should return correct information for the game Port Royale 2 in the last page" do
		url = "http://www.gamersgate.com/games?state=available&pg=202"
		f = RestClient.get(url)
		doc = Nokogiri::HTML(f)
		games = doc.css('div.product_display')
		game = games[0]
		expect(GamersGateHelper.parse_name(game)).to eq("Port Royale 2")
		expect(GamersGateHelper.parse_current_price(game)).to eq(9.99)
		expect(GamersGateHelper.parse_game_url(game)).to eq("http://www.gamersgate.com/DD-PR2/port-royale-2")
		expect(GamersGateHelper.is_on_sale(game)).to eq(false)
	end

end

