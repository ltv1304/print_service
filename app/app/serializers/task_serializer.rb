class TaskSerializer < ActiveModel::Serializer
  attributes :ticket, :status

  has_many :sources
  has_many :results
  has_many :artifacts
end
