class Template < ApplicationRecord
  validates :name, presence: true
  after_create_commit lambda {
                        broadcast_prepend_later_to 'templates', partial: 'templates/template', locals: { template: self, resourse: self },
                                                                target: 'templates'
                      }
  after_update_commit -> { broadcast_replace_to 'templates', locals: { resourse: self } }
  after_destroy_commit -> { broadcast_remove_to 'templates' }

  has_one :source_providers, as: :owner, class_name: 'FileProvider', dependent: :destroy
  has_one :source, through: :source_providers, class_name: 'Document', source: 'document'
  accepts_nested_attributes_for :source

  scope :ordered, -> { order(id: :desc) }

  def file_path
    ActiveStorage::Blob.service.path_for(file.key)
  end
end
