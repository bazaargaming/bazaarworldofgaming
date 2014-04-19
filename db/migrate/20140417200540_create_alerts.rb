class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
      t.float :threshold

      t.timestamps
    end
  end
end
