Feature: Profile
	
	Scenario: Bad Login Attempt
		Given a user visits the signin page
		When they enter invalid user credentials
		Then they should still see signin link

	Scenario: View Profile
		Given a user has successfully signed into their account
		When they go to their profile page
		Then they should see their info

	Scenario: Add Game
		Given a user has successfully signed into their account
		When they add a game to their profile
		Then they should see it on their page

	
		