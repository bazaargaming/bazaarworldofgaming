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


AMAZON_STORE_BASE_URL = 'http://www.amazon.com/s?ie=UTF8&page=2&rh=n%3A2445220011'
next_url = AMAZON_STORE_BASE_URL
result = RestClient.get(next_url)
while result != nil
	result = Nokogiri::HTML(result)
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
end


# the elder scrolls v skyrim dlc hearthfire
