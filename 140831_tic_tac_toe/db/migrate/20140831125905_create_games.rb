class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :game_type
      t.string :result
      t.integer :player_1_id
      t.integer :player_2_id

      t.timestamps
    end
  end
end
