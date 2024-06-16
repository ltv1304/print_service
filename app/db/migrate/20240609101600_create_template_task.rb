class CreateTemplateTask < ActiveRecord::Migration[7.1]
  def change
    create_table :template_tasks do |t|

      t.string :ticket
      t.json :params, default: {}
      t.belongs_to :template
      t.belongs_to :task

      t.timestamps
    end
  end
end
