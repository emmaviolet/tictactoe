class User < ActiveRecord::Base
  has_secure_password

    attr_accessible :username, :email, :password, :password_confirmation

    validates :username, presence: true
    validates :username, uniqueness: { case_sensitive: false }
    validates :email, presence: true
    validates :email, uniqueness: { case_sensitive: false }
    validates :password, presence: true, on: :create

    has_many :games_player_1, :class_name => 'Game', :foreign_key => 'player_1_id'
    has_many :games_player_2, :class_name => 'Game', :foreign_key => 'player_2_id'
    has_many :friendships
    has_many :friends, :class_name => 'User', through: :friendships

    def games
        games_player_1 + games_player_2
    end

    def role?(role_to_compare)
      self.role.to_s == role_to_compare.to_s
    end

    # def friends
    #     friends = []
    #     friendships = self.friendships
    #     friendships.each do |friendship|
    #         friend = friendship.friend_2 if friendship.friend_1_id == self.id
    #         friend = friendship.friend_1 if friendship.friend_2_id == self.id
    #         friends << friend
    #     end
    #     return friends
    # end

    before_create :set_role

    private
    def set_role
        self.role = :member
    end

end
