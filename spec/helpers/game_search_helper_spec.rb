require 'spec_helper'

describe GameSearchHelper do

	it "should have two halo games" do
		# puts "number of games: " + Game.all.size.to_s
		games_list = GameSearchHelper.find_game("halo")
		
		puts
		games_list.each do |game|
			puts game[:search_title]
		end
		puts

		expect(games_list.first[:search_title]).to eq("halo combat evolved")
		expect(games_list.second[:search_title]).to eq("halo 2")
 	end

 	it "should have 8 command and conquer games" do
		# puts "number of games: " + Game.all.size.to_s
		games_list = GameSearchHelper.find_game("command & conquer")
		
		puts
		games_list.each do |game|
			puts game[:search_title]
		end
		puts

		expect(games_list.size).to eq(8)
 	end

 	it "should return the most relevant one first" do
		# puts "number of games: " + Game.all.size.to_s
		games_list = GameSearchHelper.find_game("command conquer tiberian sun")
		expect(games_list.first[:search_title]).to eq("command conquer tiberian sun")
 	end

 	describe "Tests for function getGameLisPartialMatch" do

 		it "should have more relevant games on the top of the list" do
	 		words_list = ["command", "conquer", "red", "alert"]
	 		games_list = GameSearchHelper.get_game_lis_partial_match(words_list)
	 		
			puts
	 		games_list.each do |game|
				puts game[:search_title]
			end
			puts

			games_list.first[:search_title].should include("command conquer red alert")
			games_list.second[:search_title].should include("command conquer red alert")
 		end

 	end

 	describe "Tests for function handleColon" do

 		it "should return the substring before the first colon" do
	 		title = "civilization V: breve new world"
	 		result = GameSearchHelper.handle_colon(title)
	 		expect(result).to eq("civilization V")
 		end

 		it "should return nil" do
	 		title = "halo 2"
	 		result = GameSearchHelper.handle_colon(title)
	 		expect(result).to eq(nil)
 		end

 	end

 	describe "Tests for function delChar" do

 		it "should be empty" do
	 		words_list = ["a", "b", "c", "d", "e"]
	 		GameSearchHelper.del_char(words_list)
	 		expect(words_list.size).to eq(0)
 		end

 		it "should have only one element ef left" do
 			words_list = ["a", "b", "c", "d", "ef"]
	 		GameSearchHelper.del_char(words_list)
	 		expect(words_list.size).to eq(1)
 		end

 		it "should have two elements left" do
 			words_list = ["aa", "b", "c", "d", "ef"]
	 		GameSearchHelper.del_char(words_list)
	 		expect(words_list.size).to eq(2)
	 	end

 	end

 	describe "filtering and sorting" do
 		let(:user) {FactoryGirl.create(:user)} 
 		describe "find and filter games" do
 			it "should filter out already owned games" do
 				games_list = GameSearchHelper.find_game("halo")
 				user.games << games_list[0]
 				puts user.games
 				filtered_list = GameSearchHelper.find_and_filter_games("halo", user)
 				expect(filtered_list.include?(games_list[0])).to be_false 
 			end
 			it "should filter games by metacritic" do
 				lowscore = Game.create(title: "test", search_title: "test", metacritic_rating: "40")
 				highscore = Game.create(title: "test2", search_title: "test2", metacritic_rating: "100")
 				all_games = Game.all
 				filtered_games = GameSearchHelper.filter_games_by_metacritic(all_games,60,90)
 				expect(all_games.include?(lowscore) && all_games.include?(highscore)).to be_true
 				expect(filtered_games.include?(lowscore)).to be_false
 				expect(filtered_games.include?(highscore)).to be_false
 			end
 		end
 		describe "sort by metacritic" do
 			before do 
 				@low = Game.new(title: "test", search_title: "test", metacritic_rating: "40")
 				@med = Game.new(title: "test2", search_title: "test2", metacritic_rating: "70")
 				@high = Game.new(title: "test3", search_title: "test3", metacritic_rating: "100")
 			end
 			it "should return a list in ascending" do
 				expect(GameSearchHelper.sort_games_by_metacritic_asc([@med,@high,@low])).to eq([@low,@med,@high])
 			end
 			it "should return a list in descending order" do
 				expect(GameSearchHelper.sort_games_by_metacritic_desc([@med,@high,@low])).to eq([@high,@med,@low])
 			end
 		end
 	end

 	describe "checking if given games are same in reality" do
 		before {@haloinfo = {title: "Halo: Combat Evolved", 
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
				search_title: "halo combat evolved"}

				@assassininfo = {title: "Assassin's Creed", 
				release_date: nil, 
				description: "The game centers on the use of a machine named the 'Animus', which allows the viewing of the protagonist's genetic memories of his ancestors.Through this plot device, details emerge of a struggle between two factions, the Knights Templar and the Assassins (Hashshashin), over an artifact known as a 'Piece of Eden' and the game primarily takes place during the Third Crusade in the Holy Land in 1191.", 
				esrb_rating: "M - Mature", 
				players: "1", 
				coop: nil, 
				platform: "PC", 
				publisher: "Ubisoft", 
				developer: "Ubisoft Montreal", 
				image_url: "http://thegamesdb.net/banners/boxart/original/front/12-1.jpg", 
				genres: ["Shooter"],
				search_title:"assassins creed"}
			}

		it "should return true, given two same titles" do
			expect(GameSearchHelper.are_games_same(@haloinfo[:search_title], @haloinfo[:search_title], "", "")).to be_true
		end

		it "should return true because two search titles include 'game of the year'" do
			@haloinfo[:search_title] = "halo game of the year"
			@assassininfo[:search_title] = "assassins creed game of the year"
			expect(GameSearchHelper.are_games_same(@haloinfo[:search_title], @assassininfo[:search_title], "", "")).to be_true
		end

		it "should return true, given two same descriptions" do
			expect(GameSearchHelper.are_games_same(@haloinfo[:search_title], @assassininfo[:search_title], @haloinfo[:description], @haloinfo[:description])).to be_true
		end

		it "should check if both descriptions include 'Requires the base game'" do
			@haloinfo[:description] = "Requires the base game - " + @haloinfo[:description]
			expect(GameSearchHelper.are_games_same(@haloinfo[:search_title], @assassininfo[:search_title], @haloinfo[:description], @haloinfo[:description])).to be_false
		end

		it "should return true because we handle word differentials" do
			expect(GameSearchHelper.are_games_same(@haloinfo[:search_title], @assassininfo[:search_title], @haloinfo[:description], @assassininfo[:description])).to be_false
			
			halo_search_title = @haloinfo[:search_title]
			@haloinfo[:search_title] = @haloinfo[:search_title] + " super heroes"
			Game.create(@haloinfo)
			
			expect(GameSearchHelper.are_games_same(@haloinfo[:search_title], halo_search_title+" superheroes", @haloinfo[:description], @assassininfo[:description])).to be_true
			
		end

 	end

 	describe "finding right game" do
 		before {@haloinfo = {title: "Halo: Combat Evolved", 
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
				search_title: "halo combat evolved"}

				Game.create(@haloinfo)
			}

		it "should return true, given exactly same title" do
			result = GameSearchHelper.find_right_game(@haloinfo[:title], @haloinfo[:description])
			result.should_not be_nil
			expect(result[:title]).to eq(@haloinfo[:title])
 		end

 		it "should return true, given exactly same descriptions, though titles can be different" do
			result = GameSearchHelper.find_right_game("", @haloinfo[:description])
			result.should_not be_nil
			expect(result[:title]).to eq(@haloinfo[:title])
 		end

 		it "should return false because neither title nor description exists" do
 			result = GameSearchHelper.find_right_game("CS 428", "Software Engineering")
 			result.should be_nil
 		end

 		it "should check if search_title in DB includes 'edition'" do
 			@assassininfo = {title: "CS428 Edition", 
				release_date: nil, 
				description: "The game centers on the use of a machine named the 'Animus', which allows the viewing of the protagonist's genetic memories of his ancestors.Through this plot device, details emerge of a struggle between two factions, the Knights Templar and the Assassins (Hashshashin), over an artifact known as a 'Piece of Eden' and the game primarily takes place during the Third Crusade in the Holy Land in 1191.", 
				esrb_rating: "M - Mature", 
				players: "1", 
				coop: nil, 
				platform: "PC", 
				publisher: "Ubisoft", 
				developer: "Ubisoft Montreal", 
				image_url: "http://thegamesdb.net/banners/boxart/original/front/12-1.jpg", 
				genres: ["Shooter"],
				search_title:"cs428 edition"}

			Game.create(@assassininfo)

			result = GameSearchHelper.find_right_game("CS428", "")
 			result.should_not be_nil
 			expect(result[:title]).to eq(@assassininfo[:title])
 		end

 		describe "handling messed up words" do
 			
	 		it "should resolve 'super heroes' and 'superheroes'" do
	 			@assassininfo = {title: "Assassin's Creed Super Heroes", 
					release_date: nil, 
					description: "The game centers on the use of a machine named the 'Animus', which allows the viewing of the protagonist's genetic memories of his ancestors.Through this plot device, details emerge of a struggle between two factions, the Knights Templar and the Assassins (Hashshashin), over an artifact known as a 'Piece of Eden' and the game primarily takes place during the Third Crusade in the Holy Land in 1191.", 
					esrb_rating: "M - Mature", 
					players: "1", 
					coop: nil, 
					platform: "PC", 
					publisher: "Ubisoft", 
					developer: "Ubisoft Montreal", 
					image_url: "http://thegamesdb.net/banners/boxart/original/front/12-1.jpg", 
					genres: ["Shooter"],
					search_title:"assassins creed super heroes"}

				Game.create(@assassininfo)

	 			result = GameSearchHelper.find_right_game("Assassin's Creed Superheroes", "")
	 			result.should_not be_nil
	 			expect(result[:title]).to eq(@assassininfo[:title])

				result.update_attribute(:title, "Assassin's Creed Superheroes")
				result.update_attribute(:search_title, "assassins creed superheroes")
				
				result = GameSearchHelper.find_right_game("Assassin's Creed Super Heroes", "")
				result.should_not be_nil

	 		end

	 		it "should resolve 'civilization' and 'sid meiers civilization'" do
	 			@civinfo = {title: "Sid Meier's Civilization III", 
					release_date: nil, 
					description: "The game centers on the use of a machine named the 'Animus', which allows the viewing of the protagonist's genetic memories of his ancestors.Through this plot device, details emerge of a struggle between two factions, the Knights Templar and the Assassins (Hashshashin), over an artifact known as a 'Piece of Eden' and the game primarily takes place during the Third Crusade in the Holy Land in 1191.", 
					esrb_rating: "M - Mature", 
					players: "1", 
					coop: nil, 
					platform: "PC", 
					publisher: "Ubisoft", 
					developer: "Ubisoft Montreal", 
					image_url: "http://thegamesdb.net/banners/boxart/original/front/12-1.jpg", 
					genres: ["Shooter"],
					search_title:"sid meiers civilization iii"}

				Game.create(@civinfo)

	 			result = GameSearchHelper.find_right_game("Civilization III", "")
	 			result.should_not be_nil
	 			expect(result[:title]).to eq(@civinfo[:title])

	 			result.update_attribute(:title, "Civilization III")
				result.update_attribute(:search_title, "civilization iii")
				
				result = GameSearchHelper.find_right_game("Sid Meier's Civilization III", "")
				result.should_not be_nil

	 		end

 		end

 		it "should ignore 'edition', 'game of the year', 'gold', 'package', 'deluxe', 'collection'" do
 			words = ['edition', 'game of the year', 'gold', 'package', 'deluxe', 'collection']
 			words.each do |word|
	  			result = GameSearchHelper.find_right_game("halo combat evolved " + word, "")
 				result.should_not be_nil
 				expect(result[:title]).to eq(@haloinfo[:title])
			end

			word = 'cs428'
			result = GameSearchHelper.find_right_game("halo combat evolved " + word, "")
 			result.should be_nil
 		end

 	end

	describe "Filter by genre" do

		it "should pick the correct games" do
			shooter = Game.create(title: "test", search_title: "test", genres: ["shooter"])
			action1 = Game.create(title: "test1", search_title: "test1", genres: ["action"])
			action2 = Game.create(title: "test2", search_title: "test2", genres: ["action"])
			family = Game.create(title: "test3", search_title: "test3", genres: ["family"])
			result = GameSearchHelper.filter_by_genre("shooter", Game.all)
			expect(result.include? (shooter)).to be_true
			result = GameSearchHelper.filter_by_genre("action", Game.all)
			expect(result.include? (action1)).to be_true
			expect(result.include? (action2)).to be_true
			result = GameSearchHelper.filter_by_genre("family", Game.all)
			expect(result.include? (family)).to be_true

		end

		it "should be able to find a game by searching for all of its genres" do
			magic_game = Game.create(title: "test", search_title: "test", genres: ["shooter", "Mac", "Role-Playing", "Action"])
			result = GameSearchHelper.filter_by_genre("shooter", Game.all)
			expect(result.include? (magic_game)).to be_true
			result = GameSearchHelper.filter_by_genre("Mac", Game.all)
			expect(result.include? (magic_game)).to be_true
			result = GameSearchHelper.filter_by_genre("Role-Playing", Game.all)
			expect(result.include? (magic_game)).to be_true
			result = GameSearchHelper.filter_by_genre("Action", Game.all)
			expect(result.include? (magic_game)).to be_true
			result = GameSearchHelper.filter_by_genre("sports", Game.all)
			expect(result.include? (magic_game)).to be_false

		end

		it "should be case insensitive" do
			magic_game = Game.create(title: "test", search_title: "test", genres: ["shooter", "Mac", "Role-Playing", "Action"])
			result = GameSearchHelper.filter_by_genre("SHOOTER", Game.all)
			expect(result.include? (magic_game)).to be_true
			
			result = GameSearchHelper.filter_by_genre("mac", Game.all)
			expect(result.include? (magic_game)).to be_true



		end
	end

	describe "Find games by genre" do

		it "should return same list for MMO and MMOs" do
			mmo = Game.create(title: "test", search_title: "test", genres: ["MMO"])
			result1 = GameSearchHelper.find_games_by_genre("MMO", Game.all)
			result2 = GameSearchHelper.find_games_by_genre("MMOs", Game.all)
			expect(result1.include? (mmo)).to be_true
			expect(result2.include? (mmo)).to be_true
			expect(result2.size).to eq(result1.size)
		end

		it "should return same list for all simulation genres" do
			simulation = Game.create(title: "test", search_title: "test", genres: ["Simulation"])
			result1 = GameSearchHelper.find_games_by_genre("simulation", Game.all)
			result2 = GameSearchHelper.find_games_by_genre("Life Simulation", Game.all)
			result3 = GameSearchHelper.find_games_by_genre("Flight Simulation", Game.all)
			result4 = GameSearchHelper.find_games_by_genre("Vehicle Simulation", Game.all)
			expect(result1.include? (simulation)).to be_true
			expect(result2.include? (simulation)).to be_true
			expect(result3.include? (simulation)).to be_true
			expect(result4.include? (simulation)).to be_true


		end
	end

	describe "Roman Numeral Handler" do
		it "should change roman to arabic" do
			roman = "Civilization V"
			arabic = "Civilization 5"
			modified = GameSearchHelper.handle_roman_numeral(roman)
			expect(arabic).to eq(modified)

		end

		it "should change arabic to roman" do
			roman = "Halo II"
			arabic = "Halo 2"
			modified = GameSearchHelper.handle_roman_numeral(arabic)
			expect(roman).to eq(modified)

		end
	end

end
