Given /^a user visits the home page$/ do
	visit root_path
	Game.create(title: "test", search_title: "test", genres: ["shooter"])
end

When /^they attempt a blank search$/ do
	click_button "Search"
end

Then /^they should receive no results$/ do
	expect(page).to have_content('No matches found.')
end

When /^they enter a sting of garbage into the search box$/ do
	fill_in "stuff", with: "alkdgshlsjgad"
	click_button "Search" 
end

When /^they enter a valid search title into the search box$/ do
	fill_in "stuff", with: "test"
	click_button "Search"
end

Then /^they should receive a results page containing the desired game$/ do
	expect(page).not_to have_content('No matches found.')
	expect(page).to have_selector('div.SearchResult.row')
end

When /^they attempt blank search but select genre$/ do
	select "Shooter", from: 'genre'
	click_button "Search"
end

When /^they enter a valid search title but wrong genre$/ do
	fill_in "stuff", with: "test"
	select "Family", from: 'genre'
	click_button "Search"
end