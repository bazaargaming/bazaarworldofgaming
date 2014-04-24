Given /^a user visits the signin page$/ do
	visit signin_path
end

When /^they enter invalid user credentials$/ do
	fill_in "Username",    with: 'blah'
    fill_in "Password", with: 'thiswillfail'
    click_button "Sign in"
end

Then /^they should still see signin link$/ do
	expect(page).to have_link('Log in', href: signin_path)
	expect(page).to have_link('Sign up', href: signup_path)
	expect(page).to_not have_link('Sign out', href: signout_path)
end

Given /^a user has successfully signed into their account$/ do
	@user = User.create(name: "Example User", email: "user@example.com",
   				username: "testing", password: "password", password_confirmation: "password")
	visit signin_path
	fill_in "Username", with: @user.username
	fill_in "Password", with: @user.password
	click_button "Sign in"
end

When /^they go to their profile page$/ do
	visit user_path(@user)
end

Then /^they should see their info$/ do
	expect(page).to have_content("Example User")
	expect(page).to have_content("user@example.com")
	expect(page).to have_content("testing")
end

When /^they add a game to their profile$/ do
	@game = Game.create(title: "test game", search_title: "test", genres: ["shooter"])
	@game.game_sale_histories.create(occurred: DateTime.new(2011,2,3,4,5,6), store: "steam", price: 1.95)
	visit game_path(@game)
	click_button "Add Game to Profile"
end

Then /^they should see it on their page$/ do
	visit user_path(@user)
	expect(page).to have_content('test game')
end