class CreateTemplates < ActiveRecord::Migration[7.1]
  def change
    create_table :templates do |t|

      t.string :name, null: false
      t.string :description
      t.string :body_id

      t.timestamps
    end
  end
end
