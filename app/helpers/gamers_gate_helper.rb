require 'nokogiri'
require 'open-uri'
require 'timeout'
require 'restclient'


module GamersGateHelper
	

	
	#function that parse the title of a game from a html row
	def self.parse_name(row)
		return row.css('a[class = ttl]')[0]["title"]
	end

	#function that parse the current price of a game from a html row
	def self.parse_current_price(row)
		price = row.css('span.prtag').text
		return price.delete("$").to_f		
	end

	#function that parse the url of a game page from the game's html row
	def self.parse_game_url(row)
		return row.css('a[class = ttl]')[0]['href']
	end

	##given a html row of a game, determins whether the game is on sale
	# by checking whether the price tag is painted red in it
	def self.is_on_sale(row)
		return row.css('span.redbg')[0] != nil
	end

	##parse the original price of a game from the html doc of its game page
	# only called when a game is on sale
	def self.parse_orig_price(doc)
		price_tag = doc.css('div.price_list').css('span.prtag')
		return price_tag.text.delete("$").to_f

	end


	#parse the description of a game from the html doc of its game page
	def self.parse_description(doc)
		return doc.css('meta[name = description]')[0]['content']
	end

	##parse the genres of a game from the html doc of its game page
	# returns a list of strings
	def self.parse_genres(doc)
		genres_list = []
		genres_row = doc.search"[text()*='Categories:']"
		if (genres_row.first == nil)
			return nil
		end
		genres_tags = genres_row.first.parent.css('a')
		genres_tags.each do |tag|
			genres_list.push(tag.text)
		end
		return genres_list
		
	end

	##parse the developer of a game from the html doc of its game page
	# returns nil if there's no developer info on the page
	def self.parse_developer(doc)
		developer_row = doc.search"[text()*='Developer:']"
		if (developer_row.first == nil)
			return nil
		end
		developer_tag = developer_row.first.parent.css('a')
		return developer_tag.first.text
		
	end

	##parse the publisher of a game from the html doc of its game page
	# returns nil if there's no publisher info on the page
	def self.parse_publisher(doc)
		publisher_row = doc.search"[text()*='Publisher:']"
		if (publisher_row.first == nil)
			return nil
		end
		publisher_tag = publisher_row.first.parent.css('a')
		return publisher_tag.first.text
		
	end

	##use the orginal price, sale price and the sale link
	# creates game sale and game sale history for corresponded game
  	def self.storeSalesData(original_price, sale_price, game, sale_link)
  		
    		gamers_gate_sales = game.game_sales.where(["store = ?", "GamersGate"])

    		if gamers_gate_sales == nil or gamers_gate_sales.length == 0

          		game_sale = game.game_sales.create!(store: "GamersGate", 
                                             		    url: sale_link, 
                                                	    origamt: original_price, 
                                              		    saleamt: sale_price,
                                                            occurrence: DateTime.now)


          		game_sale_history = game.game_sale_histories.create!(store: "GamersGate",
                                                               		     price: sale_price,
                                                               		     occurred: DateTime.now)
    		end
  	end

  	#parse the url of the boxart from the html doc of a game page
	def self.parse_boxart(doc)
		return doc.css('meta[itemprop = image]')[0]['content']
	
	end

	
	##use the url of a menu page, parse all the games on this page
	# first extract all the rows of game infos
	# then for each row, parse its title, price and game link
	# if the game is on sale, use the game page to parse its original price
	# creates new games if couldn't find the game in database (not using now)
	# create and add game sale and game sale histrory to the database
	# returns false if there's no games on this page
	def self.parse_menu_page(url)
		f = RestClient.get(url)
		doc = Nokogiri::HTML(f)
		games = doc.css('div.product_display')
		if games[0] == nil
			return false
		end

		games.each do |game|
			title = parse_name(game)
			current_price = parse_current_price(game)
			game_url = parse_game_url(game)
			puts title
			game_src = nil
			game_doc = nil
			if is_on_sale(game)
				game_src = RestClient.get(game_url)
				game_doc = Nokogiri::HTML(game_src)
				orig_price = parse_orig_price(game_doc)

			else
				orig_price = current_price
			end

			game = GameSearchHelper.find_right_game(title, nil)
   			search_title = StringHelper.create_search_title(title)
			
			if game == nil
				# if game_src == nil
				# 	game_src = RestClient.get(game_url)
				# 	game_doc = Nokogiri::HTML(game_src)
				# end
				# publisher = parse_publisher(game_doc)
				# genres = parse_genres(game_doc)
				# developer = parse_developer(game_doc)
				# description = parse_description(game_doc)
				# boxart = parse_boxart(game_doc)
				# mcurl = GamesdbHelper.build_metacritic_url(title)
				# metacritic_rating = GamesdbHelper.retrieve_metacritic_score(mcurl)
				# puts "Making new game: " + title
				# game = Game.create!(title: title,  description: description,  publisher: publisher, 
				# 		    developer: developer, genres: genres, metacritic_rating: metacritic_rating,
    #        					    image_url: boxart, search_title: search_title)
			else

				if GameSearchHelper.are_games_same(search_title, game.search_title, "you will find no match", game.description)
		          puts "Match found!"
		          puts search_title
		          puts game.search_title
		        else
		          puts "Need to make a new game based off of the found one's info"

		          freshgame = Game.create!(title: title, release_date: game.release_date, description: game.description, publisher: game.publisher, 
		            developer: game.developer, genres: game.genres, search_title: search_title, metacritic_rating: game.metacritic_rating, image_url: game.image_url)

		          puts search_title
		          puts game.search_title

		          game = freshgame
		      end
			end

			if game != nil
				storeSalesData(orig_price, current_price, game, game_url)
				puts "Sales data created for  " + title
			end

		end

		return true


	end

	##use the url base to iterate through all the menu pages on GamersGate.com
	# for each menu page, call parse_menu_page to parse all games
	# stops when parse_menu_page returns false
	def self.parse_ggate_site

		page_number = 1
		parsing = true
		gamers_gate_page_base = "http://www.gamersgate.com/games?state=available&pg="
		while parsing do
			url = gamers_gate_page_base + page_number.to_s
			puts "start parsing page" + page_number.to_s
			parsing = parse_menu_page(url)
			page_number = page_number + 1
		end

	end


end
