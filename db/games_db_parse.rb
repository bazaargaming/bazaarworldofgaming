# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)


require 'nokogiri'
require 'open-uri'
require 'timeout'


# Game.delete_all


	VIABLE_CONSOLE_LIST = ["PC"]


	@client = Gamesdb::Client.new
 	platforms = @client.platforms.all


	platforms.each do |platform| unless !(VIABLE_CONSOLE_LIST.include?(platform.name))
		puts(platform.name)
		puts("in it")
		platform_games_wrapper = @client.get_platform_games(platform.id)
		platform_games = platform_games_wrapper["Game"]
		if (!(platform_games.nil?) && platform.id != "4914")
			platform_games.each do |platform_game|
				gameinfo = GamesdbHelper.fetch_game_info(platform_game["id"],@client)
				if GamesdbHelper.game_exists_in_db?(gameinfo[:title],gameinfo[:platform])
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

	SteamHelper.extract_page_info("http://store.steampowered.com/app/8870/")
	SteamHelper.extract_page_info("http://store.steampowered.com/app/72850/")
	SteamHelper.extract_page_info("http://store.steampowered.com/app/8930/")
	SteamHelper.extract_page_info("http://store.steampowered.com/app/242050/")
	SteamHelper.extract_page_info("http://store.steampowered.com/app/265930/")

	GmgHelper.getSalePageInfo("http://www.greenmangaming.com/s/us/en/pc/games/shooter/bioshock-infinite-na/")
	GmgHelper.getSalePageInfo("http://www.greenmangaming.com/s/us/en/pc/games/rpgs/elder-scrolls-v-skyrim/")
	GmgHelper.getSalePageInfo("http://www.greenmangaming.com/s/us/en/pc/games/strategy/sid-meiers-civilization-v/")
	GmgHelper.getSalePageInfo("http://www.greenmangaming.com/s/us/en/pc/games/simulation/goat-simulator/")
	GmgHelper.getSalePageInfo("http://www.greenmangaming.com/s/us/en/pc/games/action/assassins-creed-iv-black-flag-na/")


	



end




