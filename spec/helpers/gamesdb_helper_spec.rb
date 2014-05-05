require 'spec_helper'

describe GamesdbHelper do
	it "should get game genre from url" do
		genre = GamesdbHelper.get_game_genre('http://thegamesdb.net/api/GetGame.php?id=1')
		expect(genre).to eq(["Shooter"])
	end
	describe "Tests involving halo game info" do
		before {@haloinfo = {title: "Halo: Combat Evolved", 
				release_date: "11/15/2001", 
				description: "In Halo's twenty-sixth century setting, the player assumes the role of the Master Chief, a cybernetically enhanced super-soldier. The player is accompanied by Cortana, an artificial intelligence who occupies the Master Chief's neural interface. Players battle various aliens on foot and in vehicles as they attempt to uncover the secrets of the eponymous Halo, a ring-shaped artificial planet.", 
				esrb_rating: "T - Teen", 
				players: "4+", 
				coop: "No", 
				platform: "PC", 
				publisher: "Microsoft Game Studios", 
				developer: "Bungie", 
				image_url: "http://thegamesdb.net/banners/boxart/original/front/1-1.jpg", 
				genres: ["Shooter"]}}
		it "should say if a game exists in the database" do
			@haloinfo[:search_title] = "halo combat evolved"
			Game.create(@haloinfo)

			expect(GamesdbHelper.game_exists_in_db?("Halo: Combat Evolved","PC")).to be_true
			expect(GamesdbHelper.game_exists_in_db?("Adventures of SnooPingas","PC")).to be_false
		end

		it "should get a games info from gamesdb" do
			gameinfo = GamesdbHelper.fetch_game_info(1,Gamesdb::Client.new)
			expect(gameinfo).to eq(@haloinfo)
		end

    it "should make a url for metacritic" do
      #expect stubbed value
      url = GamesdbHelper.build_metacritic_url("halo: combat evolved","PC")
      expect(url).to eq("http://www.metacritic.com/game/pc/halo-combat-evolved")
    end

    it "should retrieve a metacritic score" do
      #expect stubbed value
      score = GamesdbHelper.retrieve_metacritic_score("http://www.metacritic.com/game/pc/halo-combat-evolved")
      expect(score).to eq("83")
    end
  end
end
