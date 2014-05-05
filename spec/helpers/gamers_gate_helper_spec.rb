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

	it "should accurately parse original price data for 'The Last Federation'" do
		# The Last Federation on GamersGate
		game_url = "http://www.gamersgate.com/DD-TLF/the-last-federation"
		game_src = RestClient.get(game_url)
		game_doc = Nokogiri::HTML(game_src)
		expect(GamersGateHelper.parse_orig_price(game_doc)).to eq(19.99)
	end

	it "should accurately parse publisher data for 'The Last Federation'" do
		# The Last Federation on GamersGate
		game_url = "http://www.gamersgate.com/DD-TLF/the-last-federation"
		game_src = RestClient.get(game_url)
		game_doc = Nokogiri::HTML(game_src)
		expect(GamersGateHelper.parse_publisher(game_doc)).to eq("Arcen Games")
	end

	it "should accurately parse developer data for 'The Last Federation'" do
		# The Last Federation on GamersGate
		game_url = "http://www.gamersgate.com/DD-TLF/the-last-federation"
		game_src = RestClient.get(game_url)
		game_doc = Nokogiri::HTML(game_src)
		expect(GamersGateHelper.parse_developer(game_doc)).to eq(nil)
	end

	it "should accurately parse boxart data for 'The Last Federation'" do
		# The Last Federation on GamersGate
		game_url = "http://www.gamersgate.com/DD-TLF/the-last-federation"
		game_src = RestClient.get(game_url)
		game_doc = Nokogiri::HTML(game_src)
		expect(GamersGateHelper.parse_boxart(game_doc)).to eq("http://www.gamersgate.com/img/boximgs/big/DD-TLF.jpg")
	end

	it "should accurately parse genres data for 'The Last Federation'" do
		# The Last Federation on GamersGate
		game_url = "http://www.gamersgate.com/DD-TLF/the-last-federation"
		game_src = RestClient.get(game_url)
		game_doc = Nokogiri::HTML(game_src)
		genres = ["Strategy", "Simulator", "Turn-based Strategy", "Mac", "Indie", "Linux"]
		expect(GamersGateHelper.parse_genres(game_doc)).to eq(genres)
	end

	it "should accurately parse description data for 'The Last Federation'" do
		# The Last Federation on GamersGate
		game_url = "http://www.gamersgate.com/DD-TLF/the-last-federation"
		game_src = RestClient.get(game_url)
		game_doc = Nokogiri::HTML(game_src)
		description = "From the creators of AI War: Fleet Command comes an all-new grand strategy title with turn-based tactical combat, set in a deep simulation of an entire solar system and its billions of inhabitants. You are the last of a murdered race, determined to unify or destroy the 8 others."
		expect(GamersGateHelper.parse_description(game_doc)).to eq(description)
	end

end

