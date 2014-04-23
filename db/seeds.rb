# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)


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
require 'restclient'


# # TODO: First wipe out the sales database, then run steam, then run gmg, then run amazon




 # GameSale.delete_all



# # # i = 3286


# # # until i == 6957
# # # 	Game.delete(i)
# # # 	i = i + 1
# # # end


#BEGIN RUNNING GMG

# GmgHelper.parseGmgSite

#END RUNNING GMG








#BEGIN RUNNING STEAM
# i = 1

# until i == 300
# 	APP_BASE_URL = 'http://steamdb.info/apps/page' + i.to_s + '/'

# 	STEAM_STORE_BASE_URL = 'http://store.steampowered.com/app/'

# 	result = Nokogiri::HTML(open(APP_BASE_URL))

# 	rows = result.css("table#table-apps")

# 	rows = rows.css("tbody")
# 	rows = rows.css("tr")

# 	rows.each do |row|
# 		row_info = row.css("td")

# 		row_info_2 = row_info[2].to_s

# 		if row_info[1].to_s.include? "Game" or row_info[1].to_s.include? "DLC"
# 			row_info_app_string = row_info[0].to_s
# 			start_index = row_info_app_string.index('">')
# 			end_index = row_info_app_string.index('</a>')
# 			store_id = row_info_app_string[start_index+2...end_index]

# 			url = STEAM_STORE_BASE_URL + store_id
# 			SteamHelper.extract_page_info(url)

# 		end
# 	end
# 	i = i + 1;
# end

#END RUNNING STEAM



# GameSale.where(:store => "Amazon").delete_all


# #BEGIN RUNNING AMAZON
	

	
	AmazonHelper.parse_first_sale_page

	AMAZON_STORE_BASE_URL = 'http://www.amazon.com/s?ie=UTF8&page=2&rh=n%3A2445220011'

	AmazonHelper.parse_first_sale_page

	next_url = AMAZON_STORE_BASE_URL

	result = RestClient.get(next_url)



	i = 1
	while result != nil
		result = Nokogiri::HTML(result)

		File.open("db/test_files/product_url" + i.to_s  + ".html", 'w') { |file| file.write(result.to_s) }

		AmazonHelper.parse_products_off_result_page(result)

		next_url_chunk = result.css(".pagnNext").to_s
		next_url_start = next_url_chunk.index('<a href="')
		next_url_end = next_url_chunk.index('" class')
		next_url = next_url_chunk[next_url_start+9...next_url_end]

		next_url_chunks = next_url.split("&amp;")

		next_url = "";

		next_url_chunks.each do |url_chunk|
			next_url = next_url + "&" + url_chunk
		end

		next_url = next_url[1...next_url.length]

		puts next_url
		puts "\n"
		result = RestClient.get(next_url)

		i = i+1
	end



#END RUNNING AMAZON




