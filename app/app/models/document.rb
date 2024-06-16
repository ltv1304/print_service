class Document < ActiveRecord::Base
  has_one_attached :file

  has_many :consumers, join_table: 'file_provider', class_name: 'FileProvider'

  before_create do
    self.ticket = SecureRandom.uuid
  end

  def path
    ActiveStorage::Blob.service.path_for(file.key)
  end

  def full_name
    file.filename.to_s
  end

  def short_name
    tmp = full_name.split('.')
    tmp[..-2].join('0')
  end
end
