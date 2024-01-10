class Metadatum < ApplicationRecord
  belongs_to :article

  # validations

  validates :featured_image, length: { in: 0..255 }, if: :featured_image?

  # end for validations

  class << self
  end
end
