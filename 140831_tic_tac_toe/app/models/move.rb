class Move < ActiveRecord::Base
  attr_accessible :game_id, :square, :player_number, :current_user

  belongs_to :game

  validates_numericality_of :player_number, :equal_to => 1, if: :move_even?
  validates_numericality_of :player_number, :equal_to => 2, unless: :move_even?
  validates_numericality_of :square, inclusion: { in: :free_squares }
  validates :game_id, :square, :player_number, presence: true
  validates_numericality_of :game_id, :equal_to => 0, unless: :game_active?
  validates_numericality_of :square, :equal_to => 0, unless: :player_allowed?

  def move_even?
    game.moves.count.even?
  end

  def all_squares
    [1,2,3,4,5,6,7,8,9]
  end

  def free_squares
    taken_squares = game.moves.map(&:square)
    free_squares = all_squares - taken_squares
    return free_squares
  end

  def game_active?
    game.result == 'active'
  end

  def player_allowed?
    if game.next_player == current_user
      return true
    end
  end

end
