require 'spec_helper'

describe Game do
  before {@game = Game.create(title: "pingas,")}
  subject {@game}
  it {should respond_to(:title)}
  it {should respond_to(:search_title)}

  describe "when title is not present" do
    before { @game.title = " "}
    it { should_not be_valid}
  end

  describe "when search_title is not present" do
    before {@game.search_title = " "}
    it { should_not be_valid}
  end
end
