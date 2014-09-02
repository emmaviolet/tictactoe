class AddBoardSizeToGame < ActiveRecord::Migration
  def change
    add_column :games, :board_size, :integer
  end
end
