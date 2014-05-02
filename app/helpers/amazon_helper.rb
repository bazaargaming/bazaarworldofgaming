require 'nokogiri'
require 'open-uri'
require 'timeout'
require 'restclient'

##
# This helper module contains functions for parsing games off of 
# Amazon's website. 
#
module AmazonHelper
  ##
  # Used to parse the amazon front sale page
  # gets sale information from the front sale page and puts in database
  #
  def self.parse_first_sale_page
    amzn_first_page_url = "http://www.amazon.com/s?ie=UTF8&page=1&rh=n%3A2445220011"

    result = RestClient.get(amzn_first_page_url)
    result = Nokogiri::HTML(result)

    parse_products_off_result_page(result)

    File.open("db/test_files/firstpage.html", 'w') { |file| file.write(result.to_s) }

  end

  ##
  # Used to get title of game from html text
  # Takes in the html string that contains the title
  # obtains the title of the game returns it
  #
  def self.parse_title(row)
      title = row.css("a.title")
      title = title.to_s
      title_encode = title.encode("UTF-8", invalid: :replace, undef: :replace)
      if !(title_encode.valid_encoding?)
        puts "Title encoding error!"
        return nil
      end
      if (!title.include? "[")
        return nil
      end
      if(title.include? "MAC")
        puts "Not avaliable on PC!"
        return nil
      end
      title_start = title.index('">')
      title_end = title.index("[")
      title = title[title_start+2...title_end]
      puts title
      return title

  end

  ##
  # Used to get the avaibility of game from html text
  # Takes in the html string that contains the avaibility
  # returns boolean true if game is available else false
  #
  def self.get_avaibility(row)
     if row.to_s.include? "Sign up to be notified when this item becomes available."
        return false
      end

      if row.to_s.include? "Currently unavailable"
        return false
      end
      return true
  end

  ##
  # Used to get the sale price of game from html text
  # Takes in the html string that contains the sale price
  # returns the sale price of the game
  #
  def self.parse_sale_price(price_chunk)
      sale_price_start = price_chunk.index('">$')
      sale_price_end = price_chunk.index("</a>")
      return price_chunk[sale_price_start+2...sale_price_end]
         
  end

  ##
  # Used to get the both the sale and original price of game from html text
  # Takes in the html string that contains the sale price and original price
  # returns the sale and original price of the game
  #
  def self.parse_price_chunk(row)
      price_chunk = row.css(".toeOurPrice").to_s
      sale_price = parse_sale_price(price_chunk)
      original_price = sale_price

      price_chunk = row.css(".toeListPrice").to_s
      if price_chunk.include? "<strike>"
        original_price = parse_original_price(price_chunk)
      end
      return [sale_price, original_price]

  end

  ##
  # Used to get the original price of game from html text
  # Takes in the html string that contains the original price
  # returns the original price of the game
  #
  def self.parse_original_price(price_chunk)
        original_price_start = price_chunk.index("<strike>")
        original_price_end = price_chunk.index("</strike>")
        return price_chunk[original_price_start+8...original_price_end]
  end

  ##
  # Used to get game url of the game from html text
  # Takes in the html string that contains the urls of the game
  # returns the product url of the game
  #
  def self.parse_url(row)
      product_url = row.css("a.title").to_s
      link_start = product_url.index('href="')
      link_end = product_url.index('">')
      return product_url[link_start+6...link_end]
  end

  ##
  # Used to get the product rating of the game from html text
  # Takes in the html string that contains the product rating
  # returns the product rating of the game
  #
  def self.parse_rating(product_html)
    page_s = product_html.to_s
    rating_start = page_s.index("esrbPopOver")
    if rating_start != nil
      rating = page_s[rating_start...page_s.length]
      start_index = rating.index("<span")
      end_index = rating.index("</span>")
      rating = rating[start_index+31...end_index]
      return rating
    end
  end

  ##
  # Used to get  developer of the game from html text
  # Takes in the html string that contains the developer of the game
  # returns the developer of the game
  #
  def self.parse_developer(product_html)
    page_s = product_html.to_s
    developer_start = page_s.index('ptBrand')
    if developer_start != nil
      developer = page_s[developer_start...page_s.length]
      start_index = developer.index('by')
      end_index = developer.index("</span>")
      developer = developer[start_index+3...end_index]
      return developer
    end

  end

  ##
  # Used to get release date of the game from html text
  # Takes in the html string that contains the release date of the game
  # returns the release date of the game
  #
  def self.parse_date(product_html)
    page_s = product_html.to_s
    date_start = page_s.index("Release Date")
    if date_start != nil
      date = page_s[date_start...page_s.length]
      start_index = date.index('</b>')
      end_index = date.index("</li>")
      date = date[start_index+5...end_index]
      return date
    end
  end

  ##
  # Used to get box art url of the game from html text
  # Takes in the html string that contains the box art of the game
  # returns the box art of the game
  #
  def self.parse_box_art(product_html)
    page_s = product_html.to_s
    img_start = page_s.index('id="main-image"')
    if img_start != nil
      img = page_s[img_start...page_s.length]
      start_index = img.index('src=')
      end_index = img.index("alt")
      img = img[start_index+5...end_index-2]
      return img
    end

  end

  ##
  # Used to get html page of the game from html url
  # Takes in the html url that contains the game page
  # returns the html page of the game
  #
  def self.parse_game_page(product_url)
      result = RestClient.get(product_url)
      return Nokogiri::HTML(result)
    
  end

  ##
  # Used to get description of the game from html text
  # Takes in the html string that contains the description of the game
  # returns the description of the game
  #
  def self.parse_description(product_html)
      page_s = product_html.to_s
      start_index = page_s.index('<div class="productDescriptionWrapper">');
      if start_index != nil
        description = page_s[start_index...page_s.length]
        start_index = description.index(">")
        end_index = description.index("</div>")
        return description[start_index+1...end_index]
      end
  end

  ##
  # Given a url to a page for a product on the Amazon store, 
  # pull out all the information about the game, then determine if the same game exists in the database,
  # or a different edition/package of that game exists in the database. 
  # If it does, just place the sales data into the database,
  # If it doesn't, move on and ignore the game
  #
  def self.parse_products_off_result_page(result)
    rows = result.css(".result.product")
    rows.each do |row|
      title = parse_title(row)
      if title == nil
        puts "Title not found."
        next
      end
      search_title = StringHelper.create_search_title(title)
      game = GameSearchHelper.find_right_game(search_title, "you will find no match")
      product_url = parse_url(row)
      if game == nil
	next
      else
        if GameSearchHelper.are_games_same(search_title, game.search_title, 
                                          "you will find no match", game.description)
          puts "Match found!"
          puts search_title
          puts game.search_title
        else
          puts "Need to make a new game based off of the found one's info"
          game_page_result = parse_game_page(product_url)
          box_art_url = parse_box_art(game_page_result)
          freshgame = Game.create!(title: title, release_date: game.release_date, 
                                   description: game.description, publisher: game.publisher, 
                                   developer: game.developer, genres: game.genres, 
                                   search_title: search_title, 
                                   metacritic_rating: game.metacritic_rating, 
                                   image_url: box_art_url)

          puts search_title
          puts game.search_title

          game = freshgame
        end
      end

      if !get_avaibility(row)
        next
      end

      prices = parse_price_chunk(row)
      sale_price = prices[0]
      original_price = prices[1]

      original_price = '%.2f' %  original_price.delete( "$" ).to_f
      sale_price = '%.2f' %  sale_price.delete( "$" ).to_f
      puts product_url

        amazon_sales = game.game_sales.where(["store = ?", "Amazon"])


        if amazon_sales == nil or amazon_sales.length == 0



              game_sale = game.game_sales.create!(store: "Amazon", 
                                                  url: product_url, 
                                                  origamt: original_price, 
                                                  saleamt: sale_price,
                                                  occurrence: DateTime.now)
              game_sale_history = game.game_sale_histories.create!(store: "Amazon",
                                                                   price: sale_price,
                                                                   occurred: DateTime.now)
        end

    end
  end

  ##
  # parses all the games on the amazon site and place in database
  #
  def self.parse_amazon_site

    AmazonHelper.parse_first_sale_page

    amazon_store_base_url = 'http://www.amazon.com/s?ie=UTF8&page=2&rh=n%3A2445220011'

    AmazonHelper.parse_first_sale_page

    next_url = amazon_store_base_url

    result = RestClient.get(next_url)

    while result != nil
      result = Nokogiri::HTML(result)
      File.open("db/test_files/product_url"  +".html", 'w') { |file| file.write(result.to_s) }

      AmazonHelper.parse_products_off_result_page(result)

      next_url_chunk = result.css(".pagnNext").to_s


      next_url_start = next_url_chunk.index('href="')
      next_url_end = next_url_chunk.index('">')

      
      if next_url_start == nil
        break
      end


      next_url = next_url_chunk[next_url_start+6...next_url_end]

      next_url_chunks = next_url.split("&amp;")

      next_url = "";

      next_url_chunks.each do |url_chunk|
        next_url = next_url + "&" + url_chunk
      end

      next_url = next_url[1...next_url.length]

      puts next_url
      puts "\n"

      next_url = 'http://www.amazon.com' + next_url

      puts next_url
      puts "\n"


      result = RestClient.get(next_url)
    end    
  end
  
end
