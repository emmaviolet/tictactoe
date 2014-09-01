class Move < ActiveRecord::Base
  attr_accessible :game_id, :square, :player_number

  belongs_to :game

end
