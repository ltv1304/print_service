class Task < ActiveRecord::Base
  STATUS_OK = 200
  STATUS_ERROR = 400

  after_create_commit lambda {
                        broadcast_prepend_later_to 'tasks', partial: 'tasks/task', locals: { template: self, resourse: self },
                                                            target: 'tasks'
                      }
  after_update_commit -> { broadcast_replace_to 'tasks', locals: { resourse: self } }
  after_destroy_commit -> { broadcast_remove_to 'tasks' }


  has_one :template_task

  has_many :source_providers, ->{ where(signature: 'source') }, as: :owner, join_table: 'file_provider', class_name: 'FileProvider', dependent: :destroy
  has_many :sources, through: :source_providers, class_name: 'Document', source: 'document'
  accepts_nested_attributes_for :sources

  has_many :result_providers, ->{ where(signature: 'result') }, as: :owner, join_table: 'file_provider', class_name: 'FileProvider', dependent: :destroy
  has_many :results, through: :result_providers, class_name: 'Document', source: 'document'

  has_many :artifact_providers, ->{ where(signature: 'artifact') }, as: :owner, join_table: 'file_provider', class_name: 'FileProvider', dependent: :destroy
  has_many :artifacts, through: :artifact_providers, class_name: 'Document', source: 'document'

  scope :ordered, -> { order(id: :desc) }

  before_create do
    self.ticket = SecureRandom.uuid
  end

  def name
    "Print task ##{id}"
  end

end
