class CreateMoves < ActiveRecord::Migration
  def change
    create_table :moves do |t|
      t.integer :player_number
      t.integer :square
      t.integer :game_id

      t.timestamps
    end
  end
end
