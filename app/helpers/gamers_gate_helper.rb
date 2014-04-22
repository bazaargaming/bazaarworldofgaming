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

			if is_on_sale(game)
				game_src = RestClient.get(game_url)
				game_doc = Nokogiri::HTML(game_src)
				orig_price = parse_orig_price(game_doc)

			else
				orig_price = current_price
			end
			#description = parse_description(game_doc)
			game = GameSearchHelper.find_right_game(title, 'asdfjaweofijawpofij')
   			search_title = StringHelper.create_search_title(title)
			
			if game == nil
				



				
			else
				storeSalesData(orig_price, current_price, game, game_url)
				puts "Sales data created for  " + title
			end

		end

		return true


	end

	def self.parse_all_games

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
