class Game < ActiveRecord::Base
  WINS = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [1, 4, 7], [2, 5, 8], [3, 6, 9], [1, 5, 9], [3, 5, 7]]

  attr_accessible :game_type, :result, :player_1_id, :player_2_id

  has_many :moves, dependent: :destroy
  belongs_to :player_1, class_name: "User", :foreign_key => 'player_1_id'
  belongs_to :player_2, class_name: "User", :foreign_key => 'player_2_id'

  before_create :set_result
  before_save :is_over?

  def users
    users = []
    users << player_1
    users << player_2
    return users
  end

  def set_result
    self.result = "active"
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
  end

  def next_player
    if moves.empty? || moves.sort.last.player_number == 2
      @next_player = player_1_id
    else
      @next_player = player_2_id
    end
    return @next_player
  end

  def computer_move
    @move = Move.new
    @move = Move.create game_id: self.id, current_user: 3
    @move.square = self.free_squares.shuffle.sample
    @move.player_number = self.player_number
    @move.save
    self.save
  end

  def all_squares
    [1,2,3,4,5,6,7,8,9]
  end

  def free_squares
    taken_squares = moves.map(&:square)
    free_squares = all_squares - taken_squares
    return free_squares
  end

  def possible_wins
    possible_wins = []
    n = 1 if player_number == 2
    n = 2 if player_number == 1
    Game::WINS.each do |win|
      if(win & player_moves("#{n}")).empty?
        possible_wins << win
      end
    end
  end

  def player_number
    player_number = 1 if self.moves.count.even?
    player_number = 2 if self.moves.count.odd?
    return player_number
  end

  def array
    array = []
    array = ["Me", "Computer"] if self.game_type == "computer"
    array = ["Me", "Them"] if self.game_type == "friend"
    return array
  end

end