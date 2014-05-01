require 'nokogiri'
require 'open-uri'
require 'timeout'
require 'restclient'

##
# This module is used to strip out odd characters in game titles and strings,
# as well as create search titles for games, which are used as a primary identifier of games across vendors
# who might name their games differently

module StringHelper
    
  ##
  # Given a title, removes any special characters that some vendors might throw into the titles
  #

  def self.sanitize_title(title)
      escape_for_space_characters = Regexp.escape('\\+-&|!®™(){}[]^~*?:&–')     
      escape_for_nothing_characters = Regexp.escape('\',.’,')
      str = title.gsub('&', 'and')
      str = str.gsub('amp;', 'and')
      str = str.gsub(/([#{escape_for_space_characters}])/, ' ')
      str = str.gsub(/([#{escape_for_nothing_characters}])/, '')
      str = str.gsub('dlc', '')
  end


  ##
  # Given a title, strips out any special characters, and converts the title to all lower case
  # This ensures unified and consistent titles across vendors

  def self.create_search_title(title)

    str = title.downcase

    str = sanitize_title(str)


    str = str.squish

  end

  ##
  # Goes through each game in the database and makes its search title
  #
  def self.prep_all_search_titles
    games_all = Game.all
    games_all.each do |game|
      str = StringHelper.create_search_title(game.title)
      game.update_attributes(:search_title => str)
      game.save!
    end
  end

end


