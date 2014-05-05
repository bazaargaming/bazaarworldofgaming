require 'spec_helper'
include PriceHistoryHelper

describe PriceHistoryHelper do

	before {
		@gameinfo = {
			title: "Halo: Combat Evolved", 
			release_date: "11/15/2001", 
			description: "In Halo's twenty-sixth century setting, the player assumes the role of the Master Chief, a cybernetically enhanced super-soldier. The player is accompanied by Cortana, an artificial intelligence who occupies the Master Chief's neural interface. Players battle various aliens on foot and in vehicles as they attempt to uncover the secrets of the eponymous Halo, a ring-shaped artificial planet.", 
			esrb_rating: "T - Teen", 
			players: "4+", 
			coop: nil, 
			platform: "PC", 
			publisher: "Microsoft Game Studios", 
			developer: "Bungie", 
			image_url: "http://thegamesdb.net/banners/boxart/original/front/1-1.jpg", 
			genres: ["Shooter"],
			search_title: "halo combat evolved"
		}

		@saleSteam1 = {
			occurred: "2014-03-17 05:27:33.943352",
			game_id: "1",
			store: "Steam",
			price: "19.99",
			created_at: "2014-03-17 05:27:33.981802",
			updated_at: "2014-03-17 05:27:33.981802"
		}

		@saleSteam2 = {
			occurred: "2014-03-17 05:27:33.943352",
			game_id: "1",
			store: "Steam",
			price: "29.99",
			created_at: "2014-03-17 05:27:33.981802",
			updated_at: "2014-03-17 05:27:33.981802"
		}

		@saleAmazon1 = {
			occurred: "2014-03-19 07:55:44.395509",
			game_id: "1",
			store: "Amazon",
			price: "37.49",
			created_at: "2014-03-19 07:55:44.402549",
			updated_at: "2014-03-19 07:55:44.402549"
		}

		@saleAmazon2 = {
			occurred: "2014-03-19 07:55:44.395509",
			game_id: "1",
			store: "Amazon",
			price: "27.49",
			created_at: "2014-03-19 07:55:44.402549",
			updated_at: "2014-03-19 07:55:44.402549"
		}

		@saleGMG1 = {
			occurred: "2014-04-01 01:35:58.659247",
			game_id: "1",
			store: "GMG",
			price: "9.95",
			created_at: "2014-04-01 01:35:58.666185",
			updated_at: "2014-04-01 01:35:58.666185"
		}

		@saleGMG2 = {
			occurred: "2014-04-01 01:35:58.659247",
			game_id: "1",
			store: "GMG",
			price: "4.95",
			created_at: "2014-04-01 01:35:58.666185",
			updated_at: "2014-04-01 01:35:58.666185"
		}

		Game.create(@gameinfo)
		@game = Game.find(1)
		sale_histories = @game.game_sale_histories
		sale_histories.create(@saleSteam1)
		sale_histories.create(@saleSteam2)
		sale_histories.create(@saleAmazon1)
		sale_histories.create(@saleAmazon2)
		sale_histories.create(@saleGMG1)
		sale_histories.create(@saleGMG2)
	}

	it "should keep only three sales histories" do
		histories = PriceHistoryHelper.get_sales_histories(@game)
		expect(@game.game_sale_histories.load.size).to eq(6)
	end

	it "should get cheapest price" do
		histories = PriceHistoryHelper.get_sales_histories(@game)
		cheapestPrice = 9.95
		expect((histories[0])[:price]).to eq(cheapestPrice)
	end

	it "should have the cheaper sale histories from Steam" do
		histories = PriceHistoryHelper.get_sales_histories(@game)
		vendor = "Steam"
		cheapestSale = @game.game_sale_histories.where("Store=?", vendor)
		cheapestPrice = 19.99
		expect((cheapestSale[0])[:price]).to eq(cheapestPrice)
	end

	it "should have the cheaper sale histories from Amazon" do
		vendor = "Amazon"
		cheapestSale = @game.game_sale_histories.where("Store=?", vendor)
		cheapestPrice = 27.49
		expect((cheapestSale[1])[:price]).to eq(cheapestPrice)
	end

	it "should have the cheaper sale histories from GMG" do
		vendor = "GMG"
		cheapestSale = @game.game_sale_histories.where("Store=?", vendor)
		cheapestPrice = 4.95
		expect((cheapestSale[1])[:price]).to eq(cheapestPrice)
	end

	it "should have the cheapest sale histories from Steam" do
		@saleSteam3 = {
			occurred: "2014-03-17 05:27:33.943352",
			game_id: "1",
			store: "Steam",
			price: "9.99",
			created_at: "2014-03-17 05:27:33.981802",
			updated_at: "2014-03-17 05:27:33.981802"
		}
		@game.game_sale_histories.create(@saleSteam3)
		vendor = "Steam"
		cheapestSale = @game.game_sale_histories.where("Store=?", vendor)
		cheapestPrice = 9.99
		expect((cheapestSale[2])[:price]).to eq(cheapestPrice)
	end
	
end

