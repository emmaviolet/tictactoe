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

  def computer_move_easy
    @move = Move.new
    @move = Move.create game_id: self.id
    @move.current_user = 3
    @move.player_number = self.player_number
    @move.square = self.free_squares.shuffle.sample
    @move.save
    self.save
  end

  def computer_move
    @move = Move.new
    @move = Move.create game_id: self.id
    @move.current_user = 3
    @move.player_number = self.player_number

    if self.block_win_moves.empty?

      next_move_options = []
      for num in 1..3
        self.next_moves.each do |move|
          self.possible_wins.each do |win|
            if move.class == Fixnum
              x = []
              x << move
              move = x
            end
            if(win & move).length == num
              (move - player_moves("#{self.player_number}")).each do |move|
                square = move.to_i
                h = Hash[:square, square, :num, num]
                next_move_options << h
              end 
            end
          end
        end
      end

      next_move_options.each do |hash|
        s = hash[:square]
        n = hash[:num]
        freq = 0
        freq = next_move_options.count { |h| h[:square] == s && h[:num] == n }
        hash.store(:freq, freq)
      end

      if free_squares.length == 1
        @move.square = free_squares.first
      else 
        sorted_options = next_move_options.sort_by { |h| [h[:num],h[:freq] ] }
        best_move = sorted_options.last[:square]
        @move.square = best_move
      end

    else 
      @move.square = self.block_win_moves.first
    end

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
    Game::WINS.each do |win|
      if(win & player_moves("#{other_player_number}")).empty?
        possible_wins << win
      end
    end
    return possible_wins
  end

  def opponent_wins
    opponent_wins = []
    Game::WINS.each do |win|
      if (win & player_moves("#{other_player_number}")).length == 2
        if (win & player_moves("#{player_number}")).empty?
          opponent_wins << win
        end
      end
    end
    return opponent_wins
  end

  def next_moves
    next_moves = []
    free_squares.each do |square|
      if player_moves("#{player_number}").empty?
        next_moves << square
      else
        square_array = []
        square_array << square
        next_moves << (square_array + player_moves("#{player_number}"))
      end
    end
    return next_moves
  end

  def player_number
    player_number = 1 if self.moves.count.even?
    player_number = 2 if self.moves.count.odd?
    return player_number
  end

  def other_player_number
    n = 1 if player_number == 2
    n = 2 if player_number == 1
    return n
  end

  def block_win_moves
    block_win_moves = []
    if self.opponent_wins.any?
      self.opponent_wins.each do |win|
        move_array = (win - player_moves("#{other_player_number}"))
        move_array.each do |move|
          block_win_moves << move
        end
      end
    end
    return block_win_moves
  end

  def array
    array = []
    array = ["Me", "Computer"] if self.game_type == "computer"
    array = ["Me", "Them"] if self.game_type == "friend"
    return array
  end

end