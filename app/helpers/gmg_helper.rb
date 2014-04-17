require 'nokogiri'
require 'open-uri'
require 'timeout'
require 'restclient'



module GmgHelper

  def self.getTitle(sale_page)
    game_title = sale_page.css('h1.prod_det')
    game_title = /.*<h1 class="prod_det">(.*)<\/h1>.*/.match(game_title.to_s)
    game_title = game_title[1]
    game_title = game_title.gsub('(NA)', '')
  end

  def self.getDescription(sale_page)
    description_paragraphs = sale_page.css("section.description p")
    description = ""
    description_paragraphs.each do |paragraph|
      if !(paragraph.to_s.include? "<em>") && !(paragraph.to_s.include? "Features:")
        if(!paragraph.to_s.include? "<strong>")
          paragraph_text = (paragraph.to_s)[3...paragraph.to_s.length - 4]
        else
          paragraph_text = (paragraph.to_s)[11...paragraph.to_s.length - 13]
        end
        description += paragraph_text + "\n"
      end
    end

    return description
  end

  def self.getPrices(sale_page)
    current_price = sale_page.css("strong.curPrice")
    current_price = /.*<strong class="curPrice">(.*)<\/strong>.*/.match(current_price.to_s)


    if current_price == nil
      return nil
    end

    # puts current_price[1]
    current_price = current_price[1]

    normal_price = 0;

    if sale_page.to_s.include? "<span class=\"lt\">"
      normal_price = sale_page.css("span.lt")
      normal_price = /.*<span class="lt">(.*)<\/span>.*/.match(normal_price.to_s)
      normal_price = normal_price[1]
      # puts normal_price[1]
    else
      normal_price = current_price
    end    

    arr = [normal_price, current_price]

    return arr
  end


  def self.getGenres(sale_page)
    game_info = sale_page.css("div.game_details")
    game_info_string = game_info.to_s

    #extract genres

    genre_chunk_start = game_info_string.index("<td>Genres:</td>")
    genre_chunk = game_info_string[genre_chunk_start...game_info_string.length]
    genre_chunk_end = genre_chunk.index("</tr>")
    genre_chunk = genre_chunk[0...genre_chunk_end]
    genres = genre_chunk.split("</a>")

    genre_array = []

    genres.each do |genre|
      start_index = genre.index('">')
      if start_index != nil
        genre = genre[start_index+2...genre.length]
        genre = genre.strip
        genre_array.push(genre)
      end
    end

    return genre_array
    
  end

  def self.getBoxArt(sale_page)

    page_string = sale_page.to_s
    start_index =  page_string.index('<meta property="og:image" content="')
    box_art_chunk = page_string[start_index...page_string.length]
    end_index = box_art_chunk.index('">')

    box_art_url = box_art_chunk[35...end_index]

    return box_art_url

  end

  def self.getPublisher(sale_page)
    game_info = sale_page.css("div.game_details")
    game_info_string = game_info.to_s

    publisher_chunk_start = game_info_string.index("<td>Publisher:</td>")
    publisher_chunk = game_info_string[publisher_chunk_start...game_info_string.length]
    publisher_chunk_end = publisher_chunk.index("</tr>")
    publisher_chunk = publisher_chunk[0...publisher_chunk_end]
    start_index = publisher_chunk.index('">')
    end_index = publisher_chunk.index("</a>")

    publisher = publisher_chunk[start_index+2...end_index]

    return publisher
  end

  def self.getDeveloper(sale_page)
    game_info = sale_page.css("div.game_details")
    game_info_string = game_info.to_s
    developer_chunk_start = game_info_string.index("<td>Developer:</td>")
    developer_chunk = game_info_string[developer_chunk_start...game_info_string.length]
    developer_chunk_end = developer_chunk.index("</tr>")
    developer_chunk = developer_chunk[0...developer_chunk_end]
    start_index = developer_chunk.index('">')
    end_index = developer_chunk.index("</a>")
    developer = developer_chunk[start_index+2...end_index]
    return developer
  end

  def self.getReleaseDate(sale_page)
    game_info = sale_page.css("div.game_details")
    game_info_string = game_info.to_s
    released_chunk_start = game_info_string.index("<td>Released:</td>")
    released_chunk = game_info_string[released_chunk_start...game_info_string.length]
    released_chunk_end = released_chunk.index("</tr>")
    released_chunk = released_chunk[0...released_chunk_end]
    released = released_chunk.split('</td>')[1]
    released = released.strip
    released = released[4...released.length]

    return released
  end

  def self.storeSalesData(normal_price, current_price, game, sale_link)
    original_price = '%.2f' %  normal_price.delete( "$" ).to_f
    sale_price = '%.2f' %  current_price.delete( "$" ).to_f

    puts original_price
    puts sale_price

    gmg_sales = game.game_sales.where(["store = ?", "GMG"])

    if gmg_sales == nil or gmg_sales.length == 0

          game_sale = game.game_sales.create!(store: "GMG", 
                                              url: sale_link, 
                                              origamt: original_price, 
                                              saleamt: sale_price,
                                              occurrence: DateTime.now)


          game_sale_history = game.game_sale_histories.create!(store: "GMG",
                                                               price: sale_price,
                                                               occurred: DateTime.now)
    end
  end

  def self.getSalePageInfo(sale_link)

    sale_page = Nokogiri::HTML(open(sale_link))

    #obtain the game title
    game_title = GmgHelper.getTitle(sale_page)
    #obtain description
    description = GmgHelper.getDescription(sale_page)
    #obtain normal price, current price
    price_arr = GmgHelper.getPrices(sale_page)
    if price_arr == nil
      return 
    end

    normal_price = price_arr.first
    current_price = price_arr.last

    #extract genres
    genres = GmgHelper.getGenres(sale_page)

    #publisher
    publisher = GmgHelper.getPublisher(sale_page)

    #developer
    developer = GmgHelper.getDeveloper(sale_page)

    #obtain release date
    release_date = GmgHelper.getReleaseDate(sale_page)

    #box art
    box_art_url = GmgHelper.getBoxArt(sale_page)

    # puts game_title
    # puts description
    # puts normal_price
    # puts current_price
    # puts genres
    # puts publisher
    # puts developer
    # puts release_date
    # puts box_art_url

    puts "\n"

    game = GameSearchHelper.find_right_game(game_title, description)
    search_title = StringHelper.create_search_title(game_title)


    if game == nil
      puts "Making new Game!"
      game = Game.create!(title: game_title, release_date: release_date, 
          description: description,  publisher: publisher, developer: developer, genres: genres, 
           image_url: box_art_url, search_title: search_title)

    elsif !(GameSearchHelper.are_games_same(game.search_title, search_title, game.description, description))
      puts game.search_title
      puts search_title
      puts "Making new game based on another game's info"

      if game.genres != nil
        genres = game.genres
      end

      game_new = Game.create!(title: game_title, release_date: release_date,
        description: description, publisher: publisher, developer: developer, genres: genres,
        image_url: box_art_url, search_title: search_title, metacritic_rating: game.metacritic_rating,
        coop: game.coop, esrb_rating: game.esrb_rating, players: game.players)

      game = game_new
    else
      #update fields?
      puts "no need to do anything but make the sale data"
    end

    #make the sale
    #make the sale history

    puts(game.title)
    puts(game.search_title)

    GmgHelper.storeSalesData(normal_price, current_price, game, sale_link)
  end


  def self.goThroughEntireGenre(genre, num_pages)
    root_url = "http://www.greenmangaming.com/genres/" + genre

    current_page = 1;

    while current_page < num_pages+1
      request_url = root_url + "/?page=" + current_page.to_s
      current_page = current_page + 1
      puts request_url

      result = Nokogiri::HTML(open(request_url))

      product_list = result.css("ul.product-list")
      product_list_links = product_list.css("li a").map { |a|
        a['href'] if a['href'].match("/games")
      }.compact.uniq

      product_list_links.each do |href|
        sale_link = 'http://www.greenmangaming.com' + href
        GmgHelper.getSalePageInfo(sale_link)
      end
    end
  end


  def self.parseGmgSite
    genres = [["action",85],["shooter",16],["strategy",59],["adventure",19],["racing",14],
           ["simulation",31],["sports",5],["rpgs",20],["educational",1],["family",1],
           ["mmos",4],["puzzle",15],["indie",63]]
    genres.each do |(a,b)|
        puts "#{a} #{b}"
        GmgHelper.goThroughEntireGenre(a,b)
    end
  end



end
