require 'spec_helper'

describe "Games" do

  subject { page }
  
  describe "Game page" do

  	let(:game) { FactoryGirl.create(:game) }
  	let(:user) { FactoryGirl.create(:user) }

  	describe "button doesn't show up when not logged in" do
  		
  		before { visit ("/game/#{game.id}") }
  		it { should_not have_button('Add Game to Profile') }
      it { should_not have_content('Create Alert')}
      it { should_not have_content('Edit Alert')}
  	end

  	describe "button shows up only when logged in" do
  		before do
  			visit signin_path
        	fill_in "Username",    with: user.username
        	fill_in "Password", with: user.password
        	click_button "Sign in"
        	visit ("/game/#{game.id}")
  		end
  		it { should_not have_link('Sign in', href: signin_path) }
  		it { should have_button('Add Game to Profile') }
      describe "proper alert buttons" do
        describe "no alert" do
          it{ should have_content('Create Alert')}
        end
        describe "with alert" do
          before do
            @alert = Alert.create({threshold: 15, game_id: game.id, user_id: user.id})
            visit ("/game/#{game.id}")
          end
            it{ should have_content('Edit Alert')}
          after do
            @alert.destroy
          end
        end
        describe "setting and editing an alert" do
          before do
            click_on "Create Alert"
            fill_in "Threshold", with: 15
            click_on "Set Alert"
          end
          it {should have_content("Alert was successfully created!")}
          it {should have_content('Edit Alert')}
          describe "editing" do
            before{click_on "Edit Alert"}
            describe "with valid info" do
              before do 
                fill_in "Threshold", with: 7
                click_on "Change Threshold"
              end
              it {should have_content("Alert was successfully updated!")}
              it "should have changed the alert" do 
                expect( ( user.alerts & game.alerts)[0].threshold).to eq(7)
              end
            end
            describe "with invalid info" do
              before do
                fill_in "Threshold", with: "hello"
                click_on "Change Threshold"
              end
              it {should have_content("Alert could not be updated")}
            end
          end
          after do
            alert = (user.alerts & game.alerts)[0]
            if alert
              alert.destroy
            end
          end        
        end
      end
  	end
    describe "sales related" do
      before {game.game_sales.destroy_all}
      describe "when there are no sales" do
        before { visit ("/game/#{game.id}")}
        it { should have_content("No sales data for this game.")}
      end
      describe "when there are sales" do
        before do
          @game = Game.create(title: "test", search_title: "test")
          @game_sale1 = @game.game_sales.create(url: "steampowered.com/pingas",occurrence: DateTime.now(), store: "Steam",origamt: 9.95, saleamt: 2.95)
        end
        after do
          @game.destroy
        end
        describe "only 1 sale" do
          before { visit ("/game/#{@game.id}")}
          it {should_not have_content("No sales data")}
          it {should have_content("#{@game.title} - $2.95")}
          it {should have_content("$2.95",count: 2)}
        end
        describe "2 sales" do 
          before do
            @game_sale2 = @game.game_sales.create(url: "amazon.com/pingas",occurrence: DateTime.now(), store: "Amazon",origamt: 9.95, saleamt: 1.95)
            puts @game_sale2.to_s
            visit ("/game/#{@game.id}")
          end
          it {should have_content("$1.95",count: 2)}
          it {should have_content("$2.95")}
          it {should have_content("#{@game.title} - $1.95")}
        end
      end
    end
  end
end
