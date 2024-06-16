class TemplateTask < ApplicationRecord
  STATUS_OK = 200
  STATUS_ERROR = 400

  belongs_to :template
  belongs_to :task, optional: true, dependent: :destroy

  before_create do
    self.ticket = SecureRandom.uuid
  end

  after_create_commit lambda {
                        broadcast_prepend_later_to 'template_tasks', partial: 'template_tasks/template_task', locals: { template_task: self, resourse: self },
                                                                     target: 'template_tasks'
                      }
  after_update_commit -> { broadcast_replace_to 'template_tasks', locals: { resourse: self } }
  after_destroy_commit -> { broadcast_remove_to 'template_tasks' }

  scope :ordered, -> { order(id: :desc) }

  def name
    "Template task ##{id}"
  end
end
