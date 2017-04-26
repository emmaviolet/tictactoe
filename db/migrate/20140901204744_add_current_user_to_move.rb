class AddCurrentUserToMove < ActiveRecord::Migration
  def change
    add_column :moves, :current_user, :integer
  end
end
