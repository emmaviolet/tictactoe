class Game < ActiveRecord::Base
  attr_accessible :game_type, :result, :player_1_id, :player_2_id, :difficulty, :board_size

  has_many :moves, dependent: :destroy
  belongs_to :player_1, class_name: "User", :foreign_key => 'player_1_id'
  belongs_to :player_2, class_name: "User", :foreign_key => 'player_2_id'

  before_validation :set_default_params, :on => :create
  before_save :is_over?

  validates :game_type, :result, :board_size, presence: true
  validate :player_1_actual
  validate :player_2_actual
  validate :game_type_exists
  validate :game_board_size
  validate :game_result
  validate :game_difficulties

  # HARDCODED VARIABLES AND METHODS
  # CALLBACKS
  # VALIDATIONS
  # BASE FUNCTIONS
  # WIN COMBINATIONS
  # STATE OF PLAY
  # COMPUTER MOVES

  # HARDCODED VARIABLES AND METHODS BEGIN

  GAME_TYPES = ["computer", "friend", "pass"]
  GAME_RESULTS = ["player_1", "player_2", "draw", "active", "expanding"]
  GAME_BOARD_SIZES = [3, 4, 5, 6]
  GAME_DIFFICULTIES = [0, 1, 2]
  NUMBER_PLAYERS = 2
  COMPUTER_HASH = Hash["Easy", 1, "Hard", 2]
  BOARD_SIZE_HASH = Hash["Simple", 3, "Expanding", 6]
  WIN_LENGTH = 3

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

  def first_array
    return ["Me", "Computer"] if self.game_type == "computer"
    return ["Me", "Them"] if self.game_type == "friend"
  end

  def find_board_size
    if self.board_size != 6
      return self.board_size
    end
    if self.board_size == 6 && (self.result == "active" || self.moves.count < 9)
      return 3
    end
    if self.board_size == 6 && (self.result == "expanding" || self.moves.count >= 9)
      return 4
    end
  end

  def game_square_row(n)
    row = "top" if (n <= self.find_board_size)
    row = "bottom" if (n > (self.find_board_size * (self.find_board_size-1)))
    row = "middle" if (n > self.find_board_size && n <= (self.find_board_size * (self.find_board_size-1)))
    return row
  end

  def game_square_column(n)
    column = "left" if (n == 1 || n % self.find_board_size == 1)
    column = "right" if (n % self.find_board_size == 0)
    column = "middle" if (n != 1 && n % self.find_board_size != 1 && n % self.find_board_size != 0)
    return column
  end

  # HARDCODED VARIABLES AND METHODS END

  # CALLBACKS BEGIN

  def set_default_params
    self.difficulty = 0
    self.result = "active"
    self.board_size = 3
  end

  def is_over?
    unless player_win?(1) || player_win?(2)
      self.expand_board if self.board_size == 6 && self.moves.count == 9 
    end
    self.result = "expanding" if self.board_size == 6 && self.moves.count >= 9
    self.result = "player_1" if player_win?(1)
    self.result = "player_2" if player_win?(2)
    self.result = "draw" if (self.result == "active" || self.result == "expanding") && self.moves.count >= self.all_squares.count  
  end

  # CALLBACKS END

  # VALIDATIONS BEGIN

  def player_1_actual
    unless self.player_1_id == nil || User.all.include?(self.player_1)
        errors.add(:no_player_1, "Sorry, Player 1 is not a user we recognise.") 
    end
  end

  def player_2_actual
    unless self.player_2_id == nil || User.all.include?(self.player_2)
        errors.add(:no_player_2, "Sorry, Player 2 is not a user we recognise.") 
    end
  end

  def game_type_exists
    unless Game::GAME_TYPES.include?(self.game_type)
      errors.add(:no_game_type, "Sorry, that game type does not exist.") 
    end
  end

  def game_result
    unless Game::GAME_RESULTS.include?(self.result)
      errors.add(:no_result, "Sorry, that game result is not valid. Please list the game result as active to start play.") 
    end
  end

  def game_board_size
    unless Game::GAME_BOARD_SIZES.include?(self.board_size)
        errors.add(:no_result, "Sorry, that board size is not valid. Please enter a board size of 3, 4, 5, or 6 to play.") 
      end
  end

  def game_difficulties
    unless self.game_type != "computer" || Game::GAME_DIFFICULTIES.include?(self.difficulty)
        errors.add(:no_player_2, "Sorry, please choose a difficulty level of 0, 1, or 2.") 
    end
  end

  # VALIDATIONS END

  # BASE FUNCTIONS BEGIN

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

  def players
    players = []
    players << player_1
    players << player_2
    return players
  end

  def all_squares
    all_squares = []
    n = self.find_board_size
    for x in 1..(n*n)
      all_squares << x
    end
    return all_squares
  end

  # BASE FUNCTIONS END

  # WIN COMBINATIONS BEGIN

  def wins
    n = self.find_board_size
    streaks = (row_streaks(n) + column_streaks(n) + diagonal_streaks(n))
    wins = streaks_to_wins(streaks, n, 0) + diagonal_wins(n)
    return wins
  end

  def streaks_to_wins(streaks, n, x)
    wins = []
    streaks.each do |streak|
      for y in 0..(n-Game::WIN_LENGTH)
        win = streak[(x+y), (n+y)]
          wins << win
        end
      end
    return wins
  end

  def row_streaks(n)
    row_streaks = []
    for x in 0..(n-1)
      y = (x*n)
      row = []
      for z in 1..n 
        square = y+z
        row << square
      end
      row_streaks << row
    end
    return row_streaks
  end

  def column_streaks(n)
    column_streaks = []
    for x in 1..n
      column = []
      for y in 0..(n-1)
        z = (y*n)
        square = x+z
        column << square
      end
      column_streaks << column
    end
    return column_streaks
  end

  def diagonal_streaks(n)
    diagonal_streaks = []
    diagonal_streaks << diagonal_streak(n,1,(n+1))
    diagonal_streaks << diagonal_streak(n,n,(n-1))
    return diagonal_streaks
  end

  def diagonal_wins(n)
    if n == 3
      return []
    end
    if n == 4
      return [[3, 6, 9], [8, 11, 14], [2, 7, 12], [5, 10, 15]]
    end
    if n == 5
      return [[3, 7, 13], [4, 8, 12], [8, 12, 16], [10, 14, 18], [14, 18, 22], [15, 19, 23], [3, 9, 15], [2, 8, 14], [8, 14, 20], [6, 12, 18], [12, 18, 24], [11, 17, 23]]
    end
  end

  def diagonal_streak(n,i,y)
    diagonal_streak = [i]
    (n-1).times do
      i = i + y
      diagonal_streak << i
    end
    return diagonal_streak
  end

  # WIN COMBINATIONS END

  # STATE OF PLAY

  def player_win?(n)
    self.wins.each do |win| 
      return true if (player_moves("#{n}") & win).count == Game::WIN_LENGTH
    end
    return false
  end

  def player_moves(n)
    moves.where("player_number = #{n}").map(&:square)
  end

  def next_player
    if moves.empty? || moves.sort.last.player_number == Game::NUMBER_PLAYERS
      @next_player = player_1_id
    else
      @next_player = player_2_id
    end
    return @next_player
  end

  def free_squares
    taken_squares = moves.map(&:square)
    free_squares = all_squares - taken_squares
    return free_squares
  end

  def expand_board
    if self.board_size == 6
      self.moves.each do |move|
        square_number = move.square
        if square_number <= 3
          move.square = square_number + 4
        elsif square_number > 3 && square_number <= 6
          move.square = square_number + 5
        else
          move.square = square_number + 6
        end
        move.save(:validate => false)
      end
    end
    if self.game_type == "computer" && self.next_player == User.find_by_username("Computer").id
      computer_move
    end
  end

  # STATE OF PLAY END

  # COMPUTER MOVES BEGIN

  def computer_move
    @move = Move.new
    @move = Move.create game_id: self.id
    @move.current_user = User.find_by_username("Computer").id
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

  def computer_move_easy
    return self.free_squares.shuffle.sample
  end

  def winning_move
    wins_now.first[:square]
  end

  def blocking_move
    block_win_moves.first
  end

  def last_square_move
    free_squares.first
  end

  def sorted_move
    next_move_options.sort_by { |h| [h[:num], h[:freq] ] }.last[:square]
  end

  def computer_move_hard
    return winning_move if wins_now.any? 
    return blocking_move if block_win_moves.any?
    return last_square_move if free_squares.length == 1
    return sorted_move if next_move_options.any?
    return computer_move_easy
  end

  def wins_now
    n = self.find_board_size
    wins_now = moves_hash(n, n)
    return wins_now
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

  def next_move_options
    x = self.find_board_size-1
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
    n = self.find_board_size-1
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

  #COMPUTER MOVES END

end