class Move < ActiveRecord::Base
  attr_accessible :game_id, :square, :player_number, :current_user
  belongs_to :game

  validates :game_id, :square, :player_number, presence: true
  validate :right_player
  validate :square_free
  validate :game_active
  validate :player_allowed

  def right_player
    unless self.right_player?
      errors.add(:number, "Sorry, it is not your turn.") 
    end
  end

  def right_player?
    return true if self.game.moves.empty? && self.player_number == 1
    return true if self.game.moves.count.even? && self.player_number == 1
    return true if self.game.moves.count.odd? && self.player_number == 2
    return false
  end

  def square_free
    unless self.game.free_squares.include?(self.square)
      errors.add(:square, "Sorry, that square has already been taken.") 
    end
  end

  def game_active
    unless self.game.result == 'active' || self.game.result == 'expanding'
      errors.add(:result, "Sorry, that game is no longer active.") 
    end 
  end

  def player_allowed
    unless self.game.next_player == current_user
      errors.add(:allowed, "Sorry, it is not your turn.") 
    end 
  end

end
