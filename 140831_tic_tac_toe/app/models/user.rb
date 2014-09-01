class User < ActiveRecord::Base
  has_secure_password

    attr_accessible :email, :password, :password_confirmation

    validates :email, presence: true
    validates :email, uniqueness: { case_sensitive: false }
    validates :password, presence: true, on: :create

    has_many :games_player_1, :class_name => 'Game', :foreign_key => 'player_1_id'
    has_many :games_player_2, :class_name => 'Game', :foreign_key => 'player_2_id'

    def games
        games_player_1 + games_player_2 - (games_player_1 & games_player_2)
    end

    def role?(role_to_compare)
      self.role.to_s == role_to_compare.to_s
    end

    before_create :set_role

    private
    def set_role
        self.role = :member
    end

end
