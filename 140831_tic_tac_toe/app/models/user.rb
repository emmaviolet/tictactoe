class User < ActiveRecord::Base
  has_secure_password

    attr_accessible :username, :email, :password, :password_confirmation

    before_validation :set_role, :on => :create

    validates :username, :role, :email, :password, presence: true
    validates :username, uniqueness: { case_sensitive: false }
    validates :email, uniqueness: { case_sensitive: false }

    has_many :games_player_1, :class_name => 'Game', :foreign_key => 'player_1_id'
    has_many :games_player_2, :class_name => 'Game', :foreign_key => 'player_2_id'
    has_many :friendships
    has_many :friends, :class_name => 'User', through: :friendships

    def games
        games_player_1 + games_player_2
    end

    def games_won
        games_won = []
        self.games.each do |game|
            if game.game_type != "pass" && game.player_1_id == self.id && game.result == "player_1"
                games_won << game
            end
            if game.game_type != "pass" && game.player_2_id == self.id && game.result == "player_2"
                games_won << game
            end
        end
        count = games_won.count
        return count
    end

    def games_lost
        games_lost = []
        self.games.each do |game|
            if game.game_type != "pass" && game.player_1_id == self.id && game.result == "player_2"
                games_lost << game
            end
            if game.game_type != "pass" && game.player_2_id == self.id && game.result == "player_1"
                games_lost << game
            end
        end
        count = games_lost.count
        return count
    end

    def games_drawn
        games_drawn = []
        self.games.each do |game|
            if game.game_type != "pass" && game.result == "draw"
                games_drawn << game
            end
        end
        count = games_drawn.count
        return count
    end

    def role?(role_to_compare)
      self.role.to_s == role_to_compare.to_s
    end

    private
    def set_role
        self.role = :member
    end

end
