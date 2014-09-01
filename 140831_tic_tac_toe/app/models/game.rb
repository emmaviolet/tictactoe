class Game < ActiveRecord::Base
  WINS = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [1, 4, 7], [2, 5, 8], [3, 6, 9], [1, 5, 9], [3, 5, 7]]

  attr_accessible :game_type, :result, :player_1_id, :player_2_id

  has_many :moves, dependent: :destroy
  belongs_to :player_1, class_name: "User", :foreign_key => 'player_1_id'
  belongs_to :player_2, class_name: "User", :foreign_key => 'player_2_id'

  def users
      users = []
      users << player_1
      users << player_2
      return users
  end

  def player_moves(n)
    moves.where("player_number = #{n}").map(&:square)
  end

  def player_win?(n)
    Game::WINS.each do |win| 
      return true if (player_moves("#{n}") & win).count == 3
    end
    return false
  end

  def is_over?
    self.result = "player_1" if player_win?(1)
    self.result = "player_2" if player_win?(2)
    self.result = "draw" if self.result == 'active' && self.moves.count >= 9
    return self.result
  end

  def next_player
    if moves.empty? || moves.sort.last.player_number == 2
      @next_player = player_1_id
    else
      @next_player = player_2_id
    end
    return @next_player
  end

end