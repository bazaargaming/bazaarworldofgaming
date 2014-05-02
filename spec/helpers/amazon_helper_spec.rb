require 'spec_helper'

describe AmazonHelper do



        it "should generate correct information for the game Thief" do
          url = "http://www.amazon.com/Square-Enix-Thief-Online-Game/dp/B00BPEBG8A/ref=sr_1_1?s=videogames-download&ie=UTF8&qid=1395265258&sr=1-1&keywords=thief"
          game_page = AmazonHelper.parse_game_page(url)
          rating = AmazonHelper.parse_rating(game_page)
          img_url = AmazonHelper.parse_box_art(game_page)
          publisher = AmazonHelper.parse_developer(game_page)
          release_date = AmazonHelper.parse_date(game_page)
          description = AmazonHelper.parse_description(game_page)
          expect(rating).to eq("Rating Pending")
          expect(img_url).to eq("http://ecx.images-amazon.com/images/I/41LmXBdUR7L._SY300_.jpg")
          expect(release_date).to eq("February 21, 2014")
        end

        it "should generate correct information for the game FIFA 14" do
          url = "http://www.amazon.com/FIFA-14-Online-Game-Code/dp/B00CMSCWGS/ref=sr_1_1?s=videogames-download&ie=UTF8&qid=1395266651&sr=1-1&keywords=fifa+14"
          game_page = AmazonHelper.parse_game_page(url)
          rating = AmazonHelper.parse_rating(game_page)
          img_url = AmazonHelper.parse_box_art(game_page)
          publisher = AmazonHelper.parse_developer(game_page)
          release_date = AmazonHelper.parse_date(game_page)
          description = AmazonHelper.parse_description(game_page)
          expect(rating).to eq("Rating Pending")
          expect(img_url).to eq("http://ecx.images-amazon.com/images/I/51rOxe0vHmL._SY300_.jpg")
          expect(release_date).to eq("September 20, 2013")
        end

        it "should generate correct information for the game Battlefiled 4: Second Assault" do
          url = "http://www.amazon.com/Battlefield-Second-Assault-Online-Game/dp/B00IIWKDZE/ref=pd_sim_vg_dl_4?ie=UTF8&refRID=00KAD9CVZ2XZ525QMYQJ"
          game_page = AmazonHelper.parse_game_page(url)
          rating = AmazonHelper.parse_rating(game_page)
          img_url = AmazonHelper.parse_box_art(game_page)
          publisher = AmazonHelper.parse_developer(game_page)
          release_date = AmazonHelper.parse_date(game_page)
          description = AmazonHelper.parse_description(game_page)
          expect(rating).to eq("Mature")
          expect(img_url).to eq("http://ecx.images-amazon.com/images/I/51TfKoNRGRL._SY300_.jpg")
          expect(release_date).to eq("March 4, 2014")
        end

end

