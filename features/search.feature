Feature: Search
	
	Scenario: Blank Search
		Given a user visits the home page
		When they attempt a blank search
		Then they should receive no results

	Scenario: Bad Search
		Given a user visits the home page
		When they enter a sting of garbage into the search box
		Then they should receive no results

	Scenario: Valid Search
		Given a user visits the home page
		When they enter a valid search title into the search box
		Then they should receive a results page containing the desired game

	Scenario:Browse by Genre
		Given a user visits the home page
		When they attempt blank search but select genre
		Then they should receive a results page containing the desired game

	Scenario: Search with wrong Genre
		Given a user visits the home page
		When they enter a valid search title but wrong genre
		Then they should receive no results
		