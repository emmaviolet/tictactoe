class RemoveDifficultyFromMove < ActiveRecord::Migration
  def up
    remove_column :moves, :difficulty
  end

  def down
    add_column :moves, :difficulty, :integer
  end
end
