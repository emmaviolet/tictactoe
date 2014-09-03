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

  def get_variables
    @game_types = ["computer", "friend", "pass"]
    @game_results = ["player_1", "player_2", "draw", "active"]
    @game_board_sizes = [3, 4, 5]
    @game_difficulties = [0, 1, 2]
    @number_players = 2
    @computer_hash = Hash["Easy", 1, "Hard", 2]
    @board_size_hash = Hash["3x3", 3, "4x4", 4, "5x5", 5]
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

  def first_array
    return ["Me", "Computer"] if self.game_type == "computer"
    return ["Me", "Them"] if self.game_type == "friend"
  end

  # HARDCODED VARIABLES AND METHODS END

  # CALLBACKS BEGIN

  def set_default_params
    self.difficulty = 0
    self.result = "active"
    self.board_size = 3
    self.player_1_id = @current_user.id
  end

  def is_over?
    self.result = "player_1" if player_win?(1)
    self.result = "player_2" if player_win?(2)
    self.result = "draw" if self.result == "active" && self.moves.count >= self.all_squares.count
  end

  # CALLBACKS END

  # VALIDATIONS BEGIN

  def player_1_actual
    get_variables
    unless self.player_1_id == nil || User.all.include?(self.player_1)
        errors.add(:no_player_1, "Sorry, Player 1 is not a user we recognise.") 
    end
  end

  def player_2_actual
    get_variables
    unless self.player_2_id == nil || User.all.include?(self.player_2)
        errors.add(:no_player_2, "Sorry, Player 2 is not a user we recognise.") 
    end
  end

  def game_type_exists
    get_variables
    unless @game_types.include?(self.game_type)
      errors.add(:no_game_type, "Sorry, that game type does not exist.") 
    end
  end

  def game_result
    get_variables
    unless @game_results.include?(self.result)
      errors.add(:no_result, "Sorry, that game result is not valid. Please list the game result as active to start play.") 
    end
  end

  def game_board_size
    get_variables
    unless @game_board_sizes.include?(self.board_size)
        errors.add(:no_result, "Sorry, that board size is not valid. Please enter a board size of 3, 4, or 5 to play.") 
      end
  end

  def game_difficulties
    get_variables
    unless self.game_type != "computer" || @game_difficulties.include?(self.difficulty)
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
    n = self.board_size
    for x in 1..(n*n)
      all_squares << x
    end
    return all_squares
  end

  # BASE FUNCTIONS END

  # WIN COMBINATIONS BEGIN

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
    diagonal_wins << diagonal_win(n,1,(n+1))
    diagonal_wins << diagonal_win(n,n,(n-1))
    return diagonal_wins
  end

  def diagonal_win(n,i,y)
    diagonal_win = [i]
    (n-1).times do
      i = i + y
      diagonal_win << i
    end
    return diagonal_win
  end

  # WIN COMBINATIONS END

  # STATE OF PLAY

  def player_win?(n)
    self.wins.each do |win| 
      return true if (player_moves("#{n}") & win).count == self.board_size
    end
    return false
  end

  def player_moves(n)
    moves.where("player_number = #{n}").map(&:square)
  end

  def next_player
    if moves.empty? || moves.sort.last.player_number == @number_players
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

  def computer_move_hard
    @square_move = wins_now.first[:square] if wins_now.any?
    @square_move = block_win_moves.first if wins_now.empty? && block_win_moves.any?
    @square_move = free_squares.first if wins_now.empty? && block_win_moves.empty? && free_squares.length == 1
    if wins_now.empty? && block_win_moves.empty? && free_squares.length != 1
      sorted_options = next_move_options.sort_by { |h| [h[:num], h[:freq] ] }
      best_move = sorted_options.last[:square]
      @square_move = best_move
    end
    return @square_move
  end

  def wins_now
    n = self.board_size
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

  #COMPUTER MOVES END

end