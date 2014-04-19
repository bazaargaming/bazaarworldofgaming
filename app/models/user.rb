class User < ActiveRecord::Base
	before_save { self.email = email.downcase}
	before_create :create_remember_token
	attr_accessible :name, :email, :username, :password, :password_confirmation,:filter
	validates :name, presence: true,
					  length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true,
					  format: { with: VALID_EMAIL_REGEX },
					  uniqueness: { case_sensitive: false }
	validates :username, presence: true,
						 length: { maximum: 50 }, uniqueness: true
	has_many :game_user_wrapper
	has_many :games, through: :game_user_wrapper 
	has_many :alerts, dependent: :destroy
	has_secure_password
	validates :password, length: { minimum: 6 }
	
	def User.new_remember_token
		SecureRandom.urlsafe_base64
	end

	def User.hash(token)
		Digest::SHA1.hexdigest(token.to_s)
	end

	private

		def create_remember_token
			self.remember_token = User.hash(User.new_remember_token)
		end

end
