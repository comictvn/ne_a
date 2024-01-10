class Metadatum < ApplicationRecord
  belongs_to :article

  has_many_attached :featured_image, dependent: :destroy

  # validations
  validates :tags, presence: true
  validates :categories, presence: true
  validates_presence_of :article_id
  # end for validations

  # validations

  validates :featured_image, content_type: ['image/png', 'image/jpg', 'image/jpeg', 'image/gif', 'image/svg+xml'],
                             size: { less_than_or_equal_to: 100.megabytes }

  # end for validations

  class << self
  end
end
