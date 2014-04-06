require 'spec_helper'

describe GmgHelper do

	it "should update databases with sales info for 'Titanfall'" do
		# Titan Fall on gmg
		url1 = "http://www.greenmangaming.com/s/us/en/pc/games/shooter/titanfall-na/" 
		GmgHelper.getSalePageInfo(url1)

		game_title = "Titanfall"
		result_lis = GameSearchHelper.find_game(game_title)
		result = result_lis[0]
		expect(result[:title]).to eq("Titanfall ")
		
		# Description
		expect(result[:description]).to eq("Also Available:</strong>\n<a href=\"http://www.greenmangaming.com/s/us/en/pc/games/shooter/titanfall-season-pass-na/\"><img src=\"https://d1uxrvegqjaw98.cloudfront.net/medialibrary/2014/03/TitanfallSeasonPass-Available_product-page-image.jpg\" alt=\"level1\" title=\"Titanf\nE3 2013 Awards\nRECORD SETTING 6 GAME CRITIC AWARD WINS!\nPrepare for Titanfall. Crafted by one of the co-creators of Call of Duty and other key developers behind the Call of Duty franchise, Titanfall is an all-new universe juxtaposing small vs. giant, natural vs. industrial and man vs. machine. The visionaries at Respawn have drawn inspiration from their proven experiences in first-person action and with Titanfall are focused on bringing something exciting the next generation of multiplayer gaming. \nKEY FEATURES\nFast-Paced Future Warfare –  In Titanfall the advanced warfare of tomorrow gives you the freedom to fight your way as both elite assault Pilot and agile, heavily armored 24’ tall Titans. Titanfall rethinks fundamental combat and movement giving players the ability to change tactics on the fly, attacking or escaping depending on the situation. \nThe Future of Online Multiplayer Action  –  The game is entirely multiplayer, in a new experience that combines fast-paced online action with the heroic set piece moments traditionally found in campaign mode. The intersection of the two is a big part of what gives Titanfall its iconic identity.\nThe Visionaries that Defined Gaming for a Generation are back! — Founded in 2010, Respawn Entertainment was formed by Vince Zampella and Jason West, former co-founders of Infinity Ward and two of the co-creators of the multi-billion dollar franchise Call of Duty™ They are building on their pedigree and taking a new approach to game design and creating an all new universe with Titanfall\n")
		# publisher, developer, genre, search title
		expect(result[:publisher]).to eq("Electronic Arts")
		expect(result[:developer]).to eq("Respawn Entertainment")
		expect(result[:genres]).to eq(["Shooter", "Action"])
		expect(result[:search_title]).to eq("titanfall")
	
		result_lis = GameSale.where("url LIKE ?", url1)
		expect(result_lis.size).to eq(1)
		
		# Price
		result = result_lis[0]
		expect(result[:store]).to eq("GMG")
		expect(result[:origamt]).to eq(59.99)
		expect(result[:saleamt]).to eq(59.99)
	end


	# game 2
	it "should update databases with sales info for 'goat simulator'" do
		# Goat simulator on gmg
		url1 = "http://www.greenmangaming.com/s/us/en/pc/games/simulation/goat-simulator/" 
		GmgHelper.getSalePageInfo(url1)

		game_title = "Goat Simulator"
		result_lis = GameSearchHelper.find_game(game_title)
		result = result_lis[0]
		expect(result[:title]).to eq("Goat Simulator")
		
		# Description
		expect(result[:description]).to eq("Goat Simulator is the latest in goat simulation technology, bringing next-gen goat simulation to YOU. You no longer have to fantasize about being a goat, your dreams have finally come true! WASD to write history. \nGameplay-wise, Goat Simulator is all about causing as much destruction as you possibly can as a goat. It has been compared to an old-school skating game, except instead of being a skater, you're a goat, and instead of doing tricks, you wreck stuff. Destroy things with style, such as doing a backflip while headbutting a bucket through a window, and you'll earn even more points! Or you could just give Steam Workshop a spin and create your own goats, levels, missions, and more! When it comes to goats, not even the sky is the limit, as you can probably just bug through it and crash the game. \n<code>Disclaimer: Goat Simulator is a completely stupid game and, to be honest, you should probably spend your money on something else, such as a hula hoop, a pile of bricks, or maybe pool your money together with your friends and buy a real goat.</code>\nYou can be a goat\nGet points for wrecking stuff - brag to your friends that you're the alpha goat \nSteam Workshop support - make your own goats, levels, missions, game modes, and more! \nMILLIONS OF BUGS! We're only eliminating the crash-bugs, everything else is hilarious and we're keeping it \nIn-game physics that spazz out all the time \nSeriously look at that goat's neck \nYou can be a goat \n")
		# publisher, developer, genre, search title
		expect(result[:publisher]).to eq("Coffee Stain Studios")
		expect(result[:developer]).to eq("Coffee Stain Studios")
		expect(result[:genres]).to eq(["Simulation"])
		expect(result[:search_title]).to eq("goat simulator")
	
		result_lis = GameSale.where("url LIKE ?", url1)
		expect(result_lis.size).to eq(1)
		
		# Price
		result = result_lis[0]
		expect(result[:store]).to eq("GMG")
		expect(result[:origamt]).to eq(9.99)
		expect(result[:saleamt]).to eq(9.99)
	end


        

end

