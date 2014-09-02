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
    self.game.moves.count.even?
  end

  def free_squares
    self.game.free_squares
  end

  def game_active?
    self.game.result == 'active'
  end

  def player_allowed?
    if self.game.next_player == current_user
      return true
    end
  end

end
