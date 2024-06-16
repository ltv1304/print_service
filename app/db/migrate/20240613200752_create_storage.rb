class CreateStorage < ActiveRecord::Migration[7.1]
  def change
    create_table :documents do |t|
      t.string :ticket

      t.timestamps
    end

    create_table :file_provider do |t|

      t.references :document
      t.references :owner, polymorphic: true
      t.string :signature

    end
  end
end
