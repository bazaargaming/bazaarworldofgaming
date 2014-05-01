require 'nokogiri'
require 'open-uri'
require 'timeout'
require 'restclient'


module GamersGateHelper
	

	

	def self.parse_name(row)
		return row.css('a[class = ttl]')[0]["title"]
	end


	def self.parse_current_price(row)
		price = row.css('span.prtag').text
		return price.delete("$").to_f		
	end

	def self.parse_game_url(row)
		return row.css('a[class = ttl]')[0]['href']
	end

	def self.is_on_sale(row)
		return row.css('span.redbg')[0] != nil
	end

	def self.parse_orig_price(doc)
		price_tag = doc.css('div.price_list').css('span.prtag')
		return price_tag.text.delete("$").to_f

	end



	def self.parse_description(doc)
		return doc.css('meta[name = description]')[0]['content']
	end

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

	def self.parse_developer(doc)
		developer_row = doc.search"[text()*='Developer:']"
		if (developer_row.first == nil)
			return nil
		end
		developer_tag = developer_row.first.parent.css('a')
		return developer_tag.first.text
		
	end

	def self.parse_publisher(doc)
		publisher_row = doc.search"[text()*='Publisher:']"
		if (publisher_row.first == nil)
			return nil
		end
		publisher_tag = publisher_row.first.parent.css('a')
		return publisher_tag.first.text
		
	end


  	def self.storeSalesData(original_price, sale_price, game, sale_link)
  		
    		gmg_sales = game.game_sales.where(["store = ?", "GamersGate"])

    		if gmg_sales == nil or gmg_sales.length == 0

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

	def self.parse_boxart(doc)
		return doc.css('meta[itemprop = image]')[0]['content']
	
	end

	

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
