require 'spec_helper'

describe StringHelper do

	before {@haloinfo = {title: "Software Engineering I", 
				release_date: "11/15/2001", 
				description: "In Halo's twenty-sixth century setting, the player assumes the role of the Master Chief, a cybernetically enhanced super-soldier. The player is accompanied by Cortana, an artificial intelligence who occupies the Master Chief's neural interface. Players battle various aliens on foot and in vehicles as they attempt to uncover the secrets of the eponymous Halo, a ring-shaped artificial planet.", 
				esrb_rating: "T - Teen", 
				players: "4+", 
				coop: nil, 
				platform: "PC", 
				publisher: "Microsoft Game Studios", 
				developer: "Bungie", 
				image_url: "http://thegamesdb.net/banners/boxart/original/front/1-1.jpg", 
				genres: ["Shooter"]}

				@assassininfo = {title: "Software Engineering II", 
				release_date: nil, 
				description: "The game centers on the use of a machine named the 'Animus', which allows the viewing of the protagonist's genetic memories of his ancestors.Through this plot device, details emerge of a struggle between two factions, the Knights Templar and the Assassins (Hashshashin), over an artifact known as a 'Piece of Eden' and the game primarily takes place during the Third Crusade in the Holy Land in 1191.", 
				esrb_rating: "M - Mature", 
				players: "1", 
				coop: nil, 
				platform: "PC", 
				publisher: "Ubisoft", 
				developer: "Ubisoft Montreal", 
				image_url: "http://thegamesdb.net/banners/boxart/original/front/12-1.jpg", 
				genres: ["Shooter"]}
			}

	it "should prepare all search titles" do
		@haloinfo[:search_title] = "unknown"
		@assassininfo[:search_title] = "unknown"
		Game.create(@haloinfo)
		Game.create(@assassininfo)
		size = Game.all.size
		expect((Game.all[size-2])["search_title"]).to eq("unknown")
		expect((Game.all[size-1])["search_title"]).to eq("unknown")

 		StringHelper.prep_all_search_titles()

 		expect((Game.all[size-2])["search_title"]).to eq("software engineering i")
 		expect((Game.all[size-1])["search_title"]).to eq("software engineering ii")
 	end

	it "should get rid of ':'" do
		original_title = "Halo: Combat Evolved"
		search_title = StringHelper.create_search_title(original_title)
		expect(search_title).to eq("halo combat evolved")
 	end

 	it "should get rid of '''" do
		original_title = "Assassin's Creed"
		search_title = StringHelper.create_search_title(original_title)
		expect(search_title).to eq("assassins creed")
 	end

 	it "should get rid of '(' and ')'" do
		original_title = "Prince of Persia (2008)"
		search_title = StringHelper.create_search_title(original_title)
		expect(search_title).to eq("prince of persia 2008")
 	end

 	it "should get rid of '&'" do
		original_title = "Command & Conquer: Red Alert 3"
		search_title = StringHelper.create_search_title(original_title)
		expect(search_title).to eq("command and conquer red alert 3")
 	end

 	it "should get rid of '.'" do
		original_title = "S.T.A.L.K.E.R.: Clear Sky"
		search_title = StringHelper.create_search_title(original_title)
		expect(search_title).to eq("stalker clear sky")
 	end

 	it "should get rid of ','" do
		original_title = "Warhammer 40,000: Dawn of War II"
		search_title = StringHelper.create_search_title(original_title)
		expect(search_title).to eq("warhammer 40000 dawn of war ii")
 	end

 	it "should get rid of '-'" do
		original_title = "Half-Life 2"
		search_title = StringHelper.create_search_title(original_title)
		expect(search_title).to eq("half life 2")
 	end

end
