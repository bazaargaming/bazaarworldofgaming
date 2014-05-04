require 'nokogiri'
require 'open-uri'
require 'timeout'
require 'restclient'


##
# This module is used to resolve conflicts in searching for games, as well as 
# resolve naming differences between games that may be the same, but might have different titles according to vendors
#
module GameSearchHelper

  # List of genres used to populate drop-down list in search box
  # The first of each pair is the string that is shown in the list
  # The second is the value that corresponds with it.
  def self.genre_list
    [["Select one...",nil],
     ["Action","action"],["Adventure","adventure"],["Educational","Educational"],["Family","Family"],["Fighting","Fighting"],
     ["Horror","horror"],["Indie","Indie"],["Mac","Mac"],["MMORPG","MMO"],["Music","Music"],["Platform","Platform"],
     ["Puzzle","Puzzle"],["Racing","racing"],["Role-Playing","Role-Playing"],["Sandbox","sandbox"],["Shooter","shooter"],
     ["Simulation","simulation"],["Sports","sports"],["Stealth","stealth"],["Strategy","strategy"]]
  end

  # List used to populate the # of items listed drop-down list in search box
  def self.page_options
    [["10",10],["15",15],["20", 20],["25",25]]
  end

  # Map used in resolving mismatches in genre names between different vendors
  def self.genre_map
   [["shooter"],["action"],["adventure"],["sandbox"],["racing"],["horror"],["MMO", "MMOs"],["Role-Playing","RPGs"],
    ["strategy"],["sports"],["stealth"],
    ["simulation","Construction and Management Simulation","Vehicle Simulation","Life Simulation","Flight Simulation"],
    ["Fighting"],["Puzzle"],["Platform"],["Music"],["Family"], ["Indie"], ["Educational"], ["Mac"]]
  end


  #This is a map of words that account for differences in how vendors name certain games
  #This map is checked when comparing a parsed title to titles in the database, to ensure that we don't 
  #miss detecting whether or not the parsed game is already in the database

  def self.potential_messed_up_words
    [["super heroes", "superheroes"],["civilization", "sid meiers civilization"], ["standard edition", ""], ["40k", "40000"], ["2","ii"], ["goty", "game of the year"], ["goty", "game of the year edition"], ["bundle", "collection"],["rise of caesar", "the rise of caesar"],
      ["master thief edition", "thief master thief edition"]]
  end

  # This is a map used to handle roman numerals that may be replaced by their integer representation by some vendors
  def self.roman_numerals
    [["1","I"],["2","II"],["3","III"],["4","IV"],["5","V"],["6","VI"],["7","VII"],["8","VIII"],["9","IX"],["10","X"],
     ["11","XI"],["12","XII"],["13","XIII"],["14","XIV"],["15","XV"],["16","XVI"],["17","XVII"],["18","XVIII"],["19","XIX"],["20","XX"]]
  end

  # Sometimes vendors replace the number with the word representation. This map is used to resolve this.
  def self.number_words
    [["1","one"],["2","two"],["3","three"],["4","four"],["5","five"],["6","six"],["7","seven"],["8","eight"],["9","nine"],["10","ten"]]
  end
  
  def self.character_exceptions
    ["I","X","V"]
  end

  # Function that searches the database for the title entered into the search box
  def self.find_game(title)

    # If the search box was left blank, return an empty list
    if(title == "")
      return []
    end

    # Sanitize search title
    words_list = title.scan /[[:alnum:]]+/
    del_char(words_list)

    search_title = StringHelper.create_search_title(title)

    # Find exact matches first
    exact_matches = Game.where("search_title LIKE ?", "%" + search_title + "%")

    # THe followiing is bunch of function calls and queries used to find all the partials matches for the search title
    title_roman = handle_roman_numeral(search_title)
    roman_matches = Game.where("search_title LIKE ?", "%" + title_roman + "%")
    series_matches = []
    series_name = handle_colon(title)
    if series_name != nil
      series_search_title = StringHelper.create_search_title(series_name)
      series_matches = Game.where("search_title LIKE ?", "%" + series_search_title + "%")
    end

    partial_matches = get_game_lis_partial_match(words_list)

    return exact_matches | roman_matches | series_matches | partial_matches
  end


  #Helper function to filter out games that the user has already added to profile
  def self.find_and_filter_games(title, user)
    games_list = GameSearchHelper.find_game(title)
    already_owned = user.games
    return games_list - already_owned
  end


  #Helper function to filter games by rating. Will return only the games whose metacritic rating is between the two set bounds.
  def self.filter_games_by_metacritic(games_list, lower_bound, upper_bound)
    filtered_results = Array.new
    games_list.each do |game|
      rating = game.metacritic_rating.to_i
      if (rating >= lower_bound and rating <= upper_bound)
        filtered_results.push(game)
      end
    end

    return filtered_results
  end

  #Helper function to sort the games by metacritic rating in ascending order
  def self.sort_games_by_metacritic_asc(games_list)
    return games_list.sort{|x,y| x.metacritic_rating.to_i <=> y.metacritic_rating.to_i}
  end

  #Helper functio to sort the games by metacritic rating in descending order
  def self.sort_games_by_metacritic_desc(games_list)
    return games_list.sort{|x,y| y.metacritic_rating.to_i <=> x.metacritic_rating.to_i}
  end

  #The following two functions are used in sanitizing the search title
  def self.handle_roman_numeral(title)
    new_words_list = title.scan /[[:alnum:]]+/
    roman_numerals.each do |words|
      if new_words_list.index(words[0]) != nil
        index = new_words_list.index(words[0])
        new_words_list[index] = words[1]
      elsif new_words_list.index(words[1]) != nil
        index = new_words_list.index(words[1])
        new_words_list[index] = words[0]
      end
    end
    return new_words_list.join(' ')

  end


  def self.handle_numbers(title)

    new_words_list = title.scan /[[:alnum:]]+/
    number_words.each do |words|
      if new_words_list.index(words[0]) != nil
        index = new_words_list.index(words[0])
        new_words_list[index] = words[1]
      elsif new_words_list.index(words[1]) != nil
        index = new_words_list.index(words[1])
        new_words_list[index] = words[0]
      end
    end
    return new_words_list.join(' ')



  end

  #Function that finds titles that partially match the search title
  def self.get_game_lis_partial_match(words_list)
    counts = Hash.new(0)
    words_list.each do |word|
      games_found = Game.where("search_title LIKE ?", "%" + word + "%")
      games_found.each do |game|
        counts[game] = counts[game] + 1
      end
    end

    sorted_list = counts.sort_by{|k,v| -v}
    games_list = []
    sorted_list.each do |entry|
      games_list << entry.first
    end

    return games_list
  end

  #Another title sanitizing function
  def self.handle_colon(title)
    idx = title.index(':')
    if idx == nil 
      return nil
    else 
      return title[0..idx-1]
    end
  end  

  def self.del_char(words_list)
    words_list.delete_if { |c| c.length < 2}
  end


 
  ##
  # Given a parsed title and a parsed description, trys to see
  # if the appropriate/similar game is already in the database. If it is
  # return that pre-existing game
  #

  def self.find_right_game(title, description)


    search_title = StringHelper.create_search_title(title)
    games_in_db = Game.where("search_title =?", search_title)

    #if we don't find anything by the baseline search title
    if games_in_db.length == 0
      puts "Game Not found! Trying to resolve now!"

      #check by the game description
      games_in_db = Game.where("description =?", description)

      if games_in_db.length != 0
        puts "Match Found!: " + search_title
        return games_in_db.first
      end

      #check by roman numerals to numbers
      title_roman = handle_roman_numeral(search_title)
      games_in_db = Game.where("search_title =?", title_roman)
      if games_in_db.length != 0
        puts "Match Found!: " + title_roman
        return games_in_db.first
      end

      #check by numbers to roman numerals
      title_number = handle_numbers(search_title)
      games_in_db = Game.where("search_title =?", title_number)
      if games_in_db.length != 0
        puts "Match Found!: " + title_number
        return games_in_db.first
      end

      #go into some more specific means of resolving name misses
      GameSearchHelper.resolve_name_miss_of_vendor_title(search_title)

    #otherwise we found a similar game, so return it
    else
      puts "Match Found!: " + search_title
      return games_in_db.first
    end
  end


  ##
  # Given a search title, and two words, depending on which of the two words is in the search title,
  # substitute that word for the second, and then see if the newly substitued search title is contained by 
  # a game in the database. If it is, return that game. Otherwise, return nil.
  #

  def self.resolve_messed_up_words(search_title_original, word1, word2)

    search_title = search_title_original
    if search_title.include? word1
      search_title = search_title.gsub(word1, word2)
      games_in_db = Game.where("search_title =?", search_title)

      if games_in_db.length != 0
        puts "Match found on mismatch!: " + search_title
        return games_in_db.first
      end
    end

    search_title = search_title_original
    if search_title.include? word2
      search_title = search_title.gsub(word2, word1)
      games_in_db = Game.where("search_title =?", search_title)

      if games_in_db.length != 0
        puts "Match found on mismatch!: " + search_title
        return games_in_db.first
      end
    end

    return nil

  end

  ##
  # Given a search title from a parsed game page, see if we can tweak the vendor title to
  # find a match in the game database. If we can, return that match, otherwise, return nil
  #
  def self.resolve_name_miss_of_vendor_title(search_title_original)

    #try adding the word edition, sometimes it gets missed
    search_title = search_title_original + " edition"
    games_in_db = Game.where("search_title =?", search_title)
   
	
    if games_in_db.length != 0
      puts "Match found on mismatch!: " + search_title
      return games_in_db.first
    end

    
    #try adding 'the' at the start
    search_title = "the " + search_title_original
    games_in_db = Game.where("search_title =?", search_title)
   
	
    if games_in_db.length != 0
      puts "Match found on mismatch!: " + search_title
      return games_in_db.first
    end

    #here we'll try words that may be messed up
    GameSearchHelper.potential_messed_up_words.each do |words|
      game = GameSearchHelper.resolve_messed_up_words(search_title_original, words[0], words[1])
      if game != nil 
        return game
      end
    end

    # now we try chopping off versioning/edition words that may cause the title to be different
    # This is useful for finding similar games in the database, i.e. if we are parsing the game of the year version
    # of a game already in the database, or a special edition version, etc...

    search_title = search_title_original

    if(search_title.include? "edition" or search_title.include? "game of the year" or  search_title.include? "gold" or search_title.include? "package" or search_title.include? "deluxe" or search_title.include? "collection")

      until search_title.length == 0
        search_title = search_title.split(' ')[0...-1].join(' ')

        games_in_db = Game.where("search_title =?", search_title)

        if games_in_db.length != 0
          puts "Match found on mismatch!: " + search_title
          return games_in_db.first
        end

      end
    end

    puts "nothing found sorry!"
  end


  ##
  # Takes two search titles, and two words, and determines
  # if the titles are off by one of those two words due to different vendors naming the same game differently.
  # If the titles turn out to be a match based off of this, return true, otherwise return false
  # 
  def self.are_titles_same_but_diff_words(first_search_title, second_search_title, word1, word2)


    if first_search_title.include? word1 and second_search_title.include? word2
      ss = first_search_title.gsub(word1, word2)
      games_in_db = Game.where("search_title =?", ss)

      if games_in_db.length != 0
        return true
      end

      ss = second_search_title.gsub(word2, word1)
      games_in_db = Game.where("search_title =?", ss)

      if games_in_db.length != 0
        return true
      end

    end


    if first_search_title.include? word2 and second_search_title.include? word1
      ss = first_search_title.gsub(word2, word1)
      games_in_db = Game.where("search_title =?", ss)

      if games_in_db.length != 0
        return true
      end

      ss = second_search_title.gsub(word1, word2)
      games_in_db = Game.where("search_title =?", ss)

      if games_in_db.length != 0
        return true
      end

    end
  end

  ##
  # Takes two search titles, and descriptions, and determines
  # if the titles are in reality for the exact same game, either due to the titles being
  # directly equal, or simply named differently, or if they have the exact same game description
  # Returns true if they are the same, false otherwise.
  # 
  def self.are_games_same(first_search_title, second_search_title, first_game_descrip, second_game_descrip)

    if first_search_title == second_search_title
      return true
    end

    if first_search_title.include? "game of the year" and second_search_title.include? "game of the year"
      return true
    end


    #try game description, #need check for dlcs.
    if(first_game_descrip == second_game_descrip)

      #the descriptions are for two separate dlcs
      if first_game_descrip.include? "Requires the base game" and second_game_descrip.include? "Requires the base game"
        return false
      else
        return true
      end
    end


    #here we try common word groups that contain words different vendors use to represent the same word/part of a title 

    GameSearchHelper.potential_messed_up_words.each do |words|
      if GameSearchHelper.are_titles_same_but_diff_words(first_search_title, second_search_title, words[0], words[1])
        return true
      end
    end


    return false
  end


  
  # This functions takes a genre and a list of games and returns the sublist of games that contains that genre
  def self.filter_by_genre(genre, game_list)
    results = []
    game_list.each do |game|
      if game.genres.map(&:downcase).include? (genre.downcase)
        results.push(game)
      end
    end
    return results
  end

  # This is the wrapper function for filtering games by genre
  def self.find_games_by_genre(genre, game_list, method)
    puts genre

    # If no list of games is passed in, set the game_list to be all games
    if game_list.empty?
      game_list = Game.all
    end

    # Call to filter by genre
    games_found = GameSearchHelper.filter_by_genre(genre, game_list)

    # More calls to filter by genre if their are genre name mismatches between vendors for that genre
    GameSearchHelper.genre_map.each do |overlap_genres|
      if overlap_genres.include?(genre)
        overlap_genres.each do |alternative_genre|
          if alternative_genre != genre
            alternative_list = GameSearchHelper.filter_by_genre(alternative_genre, game_list)
            games_found = games_found | alternative_list
          end
        end
      end

      # If sort by relevance is checked (method == 0), sort the games by their search titles
      if method == '0'
        games_found.sort!{|x,y| x.search_title <=> y.search_title}
      end
    end
  
    puts "games found:"
    games_found.each do |game|
      puts game.search_title
    end

  end

  # Function used to call from the console and find all mismatches in genre names
  def self.find_all_genres
    games = Game.all
    genre_list = []
    games.each do |game|
      game.genres.each do |genre|
        if ! genre_list.include?(genre)
          genre_list.push(genre)
        end
      end

    end

    puts genre_list
  end

  # Getter functions for list of genres and page options used in drop-down box

  def self.get_genres
    return GameSearchHelper.genre_list
  end

  def self.get_page_options
    return GameSearchHelper.page_options
  end

end
