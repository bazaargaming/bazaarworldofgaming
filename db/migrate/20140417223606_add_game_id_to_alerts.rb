class AddGameIdToAlerts < ActiveRecord::Migration
  def change
    add_column :alerts, :game_id, :integer
  end
end
