require 'nokogiri'
require 'open-uri'
require 'timeout'
require 'restclient'


##
# This helper module contains functions for parsing games off of 
# Steam's website. 
#

module SteamHelper
    
  ##
  # Used to get pass the age check page
  # when polling a game page on the Steam store.
  # Takes in the url for the game page, passes in an age response that passes, then 
  # obtains the html of the actual game page and returns it

  def self.age_passer(product_url)
    shiny = RestClient.post(product_url, {'ageDay'=>'18', 'ageMonth'=>'February', 'ageYear'=>'1968'}){ 
      |response, request, result, &block|
      if [301, 302, 307].include? response.code
        response.follow_redirection(request, result, &block)
      else
        response.return!(request, result, &block)
      end
    }
    Nokogiri::HTML(shiny)
  end

  ##
  # Used to obtain a game's title from its store page
  #
  def self.get_title(page)

    #game title
    game_title = page.at_xpath('//*[@id="main_content"]/div[1]/div[2]/div/div[3]').to_s
    game_title = /.*<div class="apphub_AppName">(.*)<\/div>.*/.match(game_title)

    #no title found
    if game_title == nil || game_title[0] == ""
      return nil
    end

    game_title = game_title[1]
    return game_title
  end


  ##
  # Used to obtain a game's description from its store page 
  #
  def self.get_description(page)

    #game description
    game_description = page.at_xpath('//*[@id="game_highlights"]/div[2]/div/div[2]').to_s
    game_description = game_description[38...game_description.length - 6]


    return game_description

  end



  ##
  # Used to obtain an array containing all the game's genres listed on its store page
  # returns nil if no genres listed
  #
  def self.get_genres(page)
    page_string = page.to_s

    #obtain genres
    genre_start = page_string.index("Genre: ")
    genre_array = []
    if genre_start != nil
      genre_chunk = page_string[genre_start...page_string.length]
      genre_end = genre_chunk.index("<br>")

      genres = genre_chunk[0...genre_end]

      #genres are comma separated, need to split em up and go through each one
      genres = genres.split(',')
      genres.each do |genre|
        # strip the html
        start_index = genre.index('">')
        end_index = genre.index("</a>")

        if start_index != nil
          genre = genre[start_index+2...end_index] #obtain each genre
          #add to the array we return
          genre_array.push(genre)
        end
      end
      return genre_array  
    end  

    return nil
  end

  ##
  # Used to obtain a game's developer from its store page 
  # return N/A if no developer is listed.
  #
  def self.get_developer(page)
    page_string = page.to_s
    developer = "N/A"
    developer_start = page_string.index("<b>Developer:</b>")
    if !developer_start.nil?
      developer_chunk = page_string[developer_start...page_string.length]
      developer_end = developer_chunk.index("<br>")
      developer_chunk=developer_chunk[0...developer_end]
      start_index = developer_chunk.index('">')
      end_index = developer_chunk.index("</a>")
      developer = developer_chunk[start_index+2...end_index]
    end

    return developer
  end


  ##
  # Used to obtain a game's publisher from its store page 
  # return N/A if no publisher is listed.
  #
  def self.get_publisher(page)
    page_string = page.to_s
    publisher = "N/A"
    publisher_start = page_string.index("<b>Publisher:</b>")
    if !publisher_start.nil?
      publisher_chunk = page_string[publisher_start...page_string.length]
      publisher_end = publisher_chunk.index("<br>")
      publisher_chunk=publisher_chunk[0...publisher_end]
      start_index = publisher_chunk.index('">')
      end_index = publisher_chunk.index("</a>")
      publisher = publisher_chunk[start_index+2...end_index]
    end

    return publisher    
  end


  ##
  # Used to obtain a game's release date from its store page 
  # return N/A if no release date is listed.
  #  
  def self.get_release_date(page)
    page_string = page.to_s
    release_date = "N/A"
    release_start = page_string.index("<b>Release Date:</b>")
    if !release_start.nil?
      release_chunk = page_string[release_start...page_string.length]
      release_end = release_chunk.index("<br>")
      release_chunk = release_chunk[0...release_end]

      release_date = release_chunk[21...release_end]

      release_date = release_date.strip
    end
    
    return release_date    
  end


  ##
  # Used to obtain a game's pricing information from its store page
  # Obtains the current price, then if the game is on sale, obtains the original price
  # Returns a pair array containing the sale price and the original price
  #

  def self.get_pricing(page)
    price_chunk = page.css(".game_purchase_action")[0]

    if price_chunk == nil
      price_chunk = page.css(".game_purchase_action")
    end

    #check the original price and sale price fields
    original_price = price_chunk.css(".discount_original_price")[0].to_s
    sale_price = price_chunk.css(".discount_final_price")[0].to_s


    #an empty original price field means the game isn't on sale
    if original_price == "" 
      original_price = price_chunk.css(".game_purchase_price.price")[0].to_s
      sale_price = ""

      if !original_price.include? "$" || original_price == ""
        original_price = ""
      end
    end

    #game is just on sale for regular price
    if original_price != "" && sale_price == ""
      original_price_start = original_price.index('">')
      original_price_end = original_price.index('</div>')
      original_price = original_price[original_price_start+2...original_price_end]
    end

    #game is on sale
    if original_price != "" && sale_price != ""
      original_price_start = original_price.index('">')
      original_price_end = original_price.index('</div>')
      original_price = original_price[original_price_start+2...original_price_end]

      sale_price_start = sale_price.index('">')
      sale_price_end = sale_price.index('</div>')
      sale_price = sale_price[sale_price_start+2...sale_price_end]
    end

    #remove spaces
    original_price = original_price.strip
    sale_price = sale_price.strip

    #no sale price listed, so its just equal to the original price
    if sale_price == ""
      sale_price = original_price
    end



    arr = [original_price, sale_price]

    return arr

  end


  ##
  # Used to obtain the url to the image for the game's box art
  #  

  def self.get_box_art(page)
    box_art_chunk = page.css(".game_header_image").to_s
    box_art_start = box_art_chunk.index('src="')
    box_art_end = box_art_chunk.index('">')
    box_art_url = box_art_chunk[box_art_start+5...box_art_end]
    return box_art_url
  end



  ##
  # Given a url to a page for a product on the Steam store, 
  # pull out all the information about the game, then determine if the same game exists in the database,
  # or a different edition/package of that game exists in the database. 
  # If it does, just place the sales data into the database,
  # If it doesn't, make a new game, put it into the database, then place the sales data into the database
  #

  def self.extract_page_info(page_link)

    #Get by the age page
    page = SteamHelper.age_passer(page_link)
    puts page_link

    #game title
    game_title = SteamHelper.get_title(page)

    # no title so do nothing
    if(game_title == nil)
      return
    end

    #game description
    game_description = SteamHelper.get_description(page)

    #obtain genres
    genres = SteamHelper.get_genres(page)


    #developer
    developer = SteamHelper.get_developer(page)


    #publisher
    publisher = SteamHelper.get_publisher(page)

    #release date
    release_date = SteamHelper.get_release_date(page)


    #boxart
    box_art_url = SteamHelper.get_box_art(page)

    #pricing
    price_arr = SteamHelper.get_pricing(page)
    original_price = price_arr[0]
    sale_price = price_arr[1]

    # No price so do nothing
    if original_price == ""
      return
    end

    #Find out if the game exists in the database
    game = GameSearchHelper.find_right_game(game_title, game_description)
    search_title = StringHelper.create_search_title(game_title)

    puts game_title
    puts search_title

    #Game is not in the database, so add a new entry for it
    if game == nil
      puts "Making new Game!"

      mcurl = GamesdbHelper.build_metacritic_url(game_title)

      metacritic_rating = GamesdbHelper.retrieve_metacritic_score(mcurl)


      game = Game.create!(title: game_title, release_date: release_date, 
          description: game_description,  publisher: publisher, developer: developer, genres: genres, 
           image_url: box_art_url, search_title: search_title, metacritic_rating: metacritic_rating)

    #A similar game was found, but the titles are different, meaning that its a different package/version of
    # an existing game in the database 
    elsif !(GameSearchHelper.are_games_same(game.search_title, search_title, game.description, game_description))
      puts "Making new game based on another game's info"

      puts game.search_title
      puts search_title

      # try to fill in the gaps of information from the steam page with information from the existing
      # entry in the database
      if game.genres != nil
        genres = game.genres
      end

      game_new = Game.create!(title: game_title, release_date: release_date,
        description: game_description, publisher: publisher, developer: developer, genres: genres,
        image_url: box_art_url, search_title: search_title, metacritic_rating: game.metacritic_rating,
        coop: game.coop, esrb_rating: game.esrb_rating, players: game.players)

      game = game_new
    else
      puts "no need to do anything but make the sale data"
    end

    #make the sale
    #make the sale history


    puts(game.title)
    puts(game.search_title)

    #convert the prices to floats and strip the usd
    original_price = '%.2f' %  original_price.delete( "$" ).to_f
    sale_price = '%.2f' %  sale_price.delete( "$" ).to_f

    puts original_price
    puts sale_price

    #make sure we don't already have a sale for this game in the database
    steam_sales = game.game_sales.where(["store = ?", "Steam"])
    if steam_sales == nil or steam_sales.length == 0

          game_sale = game.game_sales.create!(store: "Steam", 
                                              url: page_link, 
                                              origamt: original_price, 
                                              saleamt: sale_price,
                                              occurrence: DateTime.now)


          game_sale_history = game.game_sale_histories.create!(store: "Steam",
                                                               price: sale_price,
                                                               occurred: DateTime.now)
    end
  end



  ##
  # Used to go through the entire steam store and parse out every game and its sale information
  #
  def self.parse_steam_site
    i = 1
    until i == 300
      app_base_url = 'http://steamdb.info/apps/page' + i.to_s + '/'

      steam_store_base_url = 'http://store.steampowered.com/app/'

      #Open the first page of products on the steam site
      result = nil
      begin
        file = open(app_base_url)
        result = Nokogiri::HTML(file) do
          # handle doc
        end
      rescue OpenURI::HTTPError => e
        if e.message == '404 Not Found'
          break
        else
          break
        end
      end

      if (result == nil)
      end

      rows = result.css("table#table-apps")

      rows = rows.css("tbody")
      rows = rows.css("tr")

      #Go through each product entry on the sale pages and parse each product's page
      rows.each do |row|
        row_info = row.css("td")

        row_info_2 = row_info[2].to_s

        if row_info[1].to_s.include? "Game" or row_info[1].to_s.include? "DLC"
          row_info_app_string = row_info[0].to_s
          start_index = row_info_app_string.index('">')
          end_index = row_info_app_string.index('</a>')
          store_id = row_info_app_string[start_index+2...end_index]

          url = steam_store_base_url + store_id
          SteamHelper.extract_page_info(url)
        end
      end
      i = i + 1;
    end    
  end
  
end




