# This model allows the many->many relationship
# between games and users in the user library
class GameUserWrapper < ActiveRecord::Base
	belongs_to :game 
end
