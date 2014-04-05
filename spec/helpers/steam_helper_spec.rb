require 'spec_helper'

describe SteamHelper do

	it "should update databases with sales info for 'FM2014'" do
		# Football Manager 2014 (not on sale march 19)
		url1 = "http://store.steampowered.com/app/231670/" 
		SteamHelper.extract_page_info(url1)

		game_title = "Football Manager 2014"
		result_lis = GameSearchHelper.find_game(game_title)
		result = result_lis[0]
		expect(result[:title]).to eq("Football Manager 2014")
		# expect(result[:release_date]).to eq("Wed, 30 Oct 2013")
		expect(result[:description]).to eq("\r\n\t\t\t\t\t\t\t\t- Play it whenever, wherever, however Play on Linux for the first time, plus the inclusion of ‘cloud-save’ technology which means that managers can now pursue a single career from any computer, anywhere in the world.\t\t\t\t\t\t\t")
		expect(result[:publisher]).to eq("SEGA")
		expect(result[:developer]).to eq("Sports Interactive")
		expect(result[:genres]).to eq([])
		expect(result[:search_title]).to eq("football manager 2014")
		expect(result[:metacritic_rating]).to eq("85")
	
		result_lis = GameSale.where("url LIKE ?", url1)
		expect(result_lis.size).to eq(1)

		result = result_lis[0]
		expect(result[:store]).to eq("Steam")
		expect(result[:origamt]).to eq(49.99)
		expect(result[:saleamt]).to eq(49.99)
	end
	
end

