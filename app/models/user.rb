class User < ApplicationRecord
  has_many :articles, dependent: :destroy

  # validations

  # end for validations

  class << self
  end
end
