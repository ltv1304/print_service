class CreateTask < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.string :ticket
      t.integer :status

      t.timestamps
    end
  end
end
