class Medium < ApplicationRecord
  belongs_to :article

  enum media_type: %w[image video audio], _suffix: true

  # validations

  # end for validations

  class << self
  end
end
