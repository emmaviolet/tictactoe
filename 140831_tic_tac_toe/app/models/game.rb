class Game < ActiveRecord::Base
  attr_accessible :game_type, :result, :player_1_id, :player_2_id, :difficulty, :board_size

  has_many :moves, dependent: :destroy
  belongs_to :player_1, class_name: "User", :foreign_key => 'player_1_id'
  belongs_to :player_2, class_name: "User", :foreign_key => 'player_2_id'

  validates :game_type, :result, :board_size, presence: true
  validate :player_1_actual
  validate :player_2_actual
  validate :game_type_exists

  before_save :is_over?

  def wins
    n = self.board_size
    wins = (row_wins(n) + column_wins(n) + diagonal_wins(n))
    return wins
  end

  def row_wins(n)
    row_wins = []
    for x in 0..(n-1)
      y = (x*n)
      row = []
      for z in 1..n 
        square = y+z
        row << square
      end
      row_wins << row
    end
    return row_wins
  end

  def column_wins(n)
    column_wins = []
    for x in 1..n
      column = []
      for y in 0..(n-1)
        z = (y*n)
        square = x+z
        column << square
      end
      column_wins << column
    end
    return column_wins
  end

  def diagonal_wins(n)
    diagonal_wins = []

    win1 = [1]
      x = 1
    (n-1).times do
      x = x + (n+1)
      win1 << x
    end
    win2 = [n]
    x = n
    (n-1).times do
      x = x + (n-1)
      win2 << x
    end

    diagonal_wins << win1
    diagonal_wins << win2
    return diagonal_wins
  end

  def player_1_actual
    if self.player_1_id != nil
      unless User.all.include?(self.player_1)
        errors.add(:no_player_1, "Sorry, Player 1 is not a user we recognise.") 
      end
    end
  end

  def player_2_actual
    if self.player_2_id != nil
      unless User.all.include?(self.player_2)
        errors.add(:no_player_2, "Sorry, Player 2 is not a user we recognise.") 
      end
    end
  end

  def game_type_exists
    unless ["computer", "friend", "pass"].include?(self.game_type)
      errors.add(:no_game_type, "Sorry, that game type does not exist.") 
    end
  end

  def game_result
    unless ["active", "player_1", "player_2", "draw"].include?(self.result)
      errors.add(:no_result, "Sorry, your game result must be listed as 'active' to begin.") 
    end
  end

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
    self.wins.each do |win| 
      return true if (player_moves("#{n}") & win).count == self.board_size
    end
    return false
  end

  def is_over?
    self.result = "player_1" if player_win?(1)
    self.result = "player_2" if player_win?(2)
    self.result = "draw" if self.result == 'active' && self.moves.count >= self.all_squares.count
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
    return self.free_squares.shuffle.sample
  end

  def wins_now
    n = self.board_size
    wins_now = moves_hash(n, n)
    return wins_now
  end

  def moves_hash(x, y)
    moves_hash = []
    for @num in x..y
      self.next_moves.each do |move|
        move_array = make_array(move)
        self.possible_wins.each do |win|
          if(win & move_array).length == @num
            (move_array - player_moves("#{self.player_number}")).each do |square|
              square_int = square.to_i
              h = Hash[:square, square_int, :num, @num]
              moves_hash << h
            end 
          end
        end
      end 
    end
    return moves_hash
  end

  def next_move_options
    x = self.board_size-1
    next_move_options = moves_hash(1, x)
    next_move_options.each do |hash|
      s = hash[:square]
      n = hash[:num]
      freq = 0
      freq = next_move_options.count { |h| h[:square] == s && h[:num] == n }
      hash.store(:freq, freq)
    end
    return next_move_options
  end

  def make_array(n)
    if n.class != Array
      x = []
      x << n
      array = x
      return array
    else
      return n
    end
  end

  def computer_move_hard
    @square_move = wins_now.first[:square] if wins_now.any?
    @square_move = block_win_moves.first if wins_now.empty? && block_win_moves.any?
    @square_move = free_squares.first if wins_now.empty? && block_win_moves.empty? && free_squares.length == 1

    if wins_now.empty? && block_win_moves.empty? && free_squares.length != 1
      sorted_options = next_move_options.sort_by { |h| [h[:num], h[:freq] ] }
      best_move = sorted_options.last[:square]
      @square_move = best_move
    end

    if self.moves.count > 5
      raise
    end
    return @square_move
  end

  def computer_move
    @move = Move.new
    @move = Move.create game_id: self.id
    @move.current_user = 3
    @move.player_number = self.player_number

    case self.difficulty
    when 1
      @move.square = computer_move_easy
    when 2
      @move.square = computer_move_hard
    end

    @move.save
    self.save
  end

  def all_squares
    all_squares = []
    n = self.board_size
    for x in 1..(n*n)
      all_squares << x
    end
    return all_squares
  end

  def free_squares
    taken_squares = moves.map(&:square)
    free_squares = all_squares - taken_squares
    return free_squares
  end

  def possible_wins
    possible_wins = []
    self.wins.each do |win|
      if(win & player_moves("#{other_player_number}")).empty?
        possible_wins << win
      end
    end
    return possible_wins
  end

  def opponent_wins
    opponent_wins = []
    n = self.board_size-1
    self.wins.each do |win|
      if (win & player_moves("#{other_player_number}")).length == n
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

  def first_array
    return ["Me", "Computer"] if self.game_type == "computer"
    return ["Me", "Them"] if self.game_type == "friend"
  end

  def computer_array
    computer_array =Hash["Easy", 1, "Hard", 2]
  end

  def board_size_array
    board_size_array =Hash["3x3", 3, "4x4", 4, "5x5", 5]
  end

end