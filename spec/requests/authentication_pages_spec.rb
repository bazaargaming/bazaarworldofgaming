require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "signin page" do
    before { visit signin_path }

    describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_title('Bazaarworldofgaming') }
      it { should have_selector('div.alert.alert-error') }
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        fill_in "Username",    with: user.username
        fill_in "Password", with: user.password
        click_button "Sign in"
      end

      it { should have_title("Bazaarworldofgaming") }
      it { should have_link('Profile',     href: user_path(user)) }
      it { should have_link('Sign out',    href: signout_path) }
      it { should_not have_link('Log in', href: signin_path) }
    end
  end
end