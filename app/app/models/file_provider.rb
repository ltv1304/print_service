class FileProvider < ActiveRecord::Base
  def self.table_name
    'file_provider'
  end

  belongs_to :owner, polymorphic: true
  belongs_to :document, class_name: 'Document', dependent: :destroy
end
