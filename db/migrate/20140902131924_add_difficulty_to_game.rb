class AddDifficultyToGame < ActiveRecord::Migration
  def change
    add_column :games, :difficulty, :integer
  end
end
