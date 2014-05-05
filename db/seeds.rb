
require 'nokogiri'
require 'open-uri'
require 'timeout'
require 'restclient'


# # TODO: First wipe out the sales database, then run steam, then run gmg, then run amazon


require 'nokogiri'
require 'open-uri'
require 'timeout'




	VIABLE_CONSOLE_LIST = ["PC"]


	@client = Gamesdb::Client.new
 	platforms = @client.platforms.all

 	id_list = [936, 2511, 902, 16252, 19934]


	platforms.each do |platform| unless !(VIABLE_CONSOLE_LIST.include?(platform.name))
		puts(platform.name)
		puts("in it")
		platform_games_wrapper = @client.get_platform_games(platform.id)
		platform_games = platform_games_wrapper["Game"]
		if (!(platform_games.nil?) && platform.id != "4914")
			id_list.each do |id|
				gameinfo = GamesdbHelper.fetch_game_info(id,@client)
				if GamesdbHelper.game_exists_in_db?(gameinfo[:title],gameinfo[:platform])
					puts "have it"
					next
				end

				
        		metacritic_url = GamesdbHelper.build_metacritic_url(gameinfo[:title], gameinfo[:platform])
				if metacritic_url.nil?
					next
				end


			  puts(metacritic_url)

				score = GamesdbHelper.retrieve_metacritic_score(metacritic_url)

				puts score

			  gameinfo[:search_title] = StringHelper.create_search_title(gameinfo[:title])

				g = Game.create!(gameinfo)
			
				puts(g.title)

			end
		end
	end
end


	SteamHelper.extract_page_info("http://store.steampowered.com/app/8870/")
	SteamHelper.extract_page_info("http://store.steampowered.com/app/72850/")
	SteamHelper.extract_page_info("http://store.steampowered.com/app/8930/")
	SteamHelper.extract_page_info("http://store.steampowered.com/app/242050/")
	SteamHelper.extract_page_info("http://store.steampowered.com/app/265930/")

	GmgHelper.get_sale_page_info("http://www.greenmangaming.com/s/us/en/pc/games/shooter/bioshock-infinite-na/")
	GmgHelper.get_sale_page_info("http://www.greenmangaming.com/s/us/en/pc/games/rpgs/elder-scrolls-v-skyrim/")
	GmgHelper.get_sale_page_info("http://www.greenmangaming.com/s/us/en/pc/games/strategy/sid-meiers-civilization-v/")
	GmgHelper.get_sale_page_info("http://www.greenmangaming.com/s/us/en/pc/games/simulation/goat-simulator/")
	GmgHelper.get_sale_page_info("http://www.greenmangaming.com/s/us/en/pc/games/action/assassins-creed-iv-black-flag-na/")


	AmazonHelper.parse_amazon_site
	GamersGateHelper.parse_ggate_site
