require 'spec_helper'

describe Alert do
  let(:game) {FactoryGirl.create(:game)}
  before {@game_sale = game.game_sales.build(url: "steampowered.com/pingas",occurrence: DateTime.now(), store: "steam",origamt: 9.95, saleamt: 2.95)}
  before { @user = User.new(name: "Example User", email: "user@example.com",
   				username: "testing", password: "password", password_confirmation: "password") }
 


  before {@alert = Alert.create(:threshold => 12.00, :user_id => @user.id, :game_id => game.id )}

  subject {@alert}


  it { should respond_to(:user_id)}
  it { should respond_to(:game_id)}
  it {should respond_to(:threshold)}
  it { should be_valid }


  it "should not be associated with more than one game" do
    game2 = FactoryGirl.create(:game)
    @alert.game = game2
    expect(game2.alerts.include?(@alert)).to be_false
  end

  describe "missing threshold" do 
    before {@alert.threshold = nil}
    it { should_not be_valid }
  end

end
