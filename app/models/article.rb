class Article < ApplicationRecord
  has_one :metadatum, dependent: :destroy
  has_one :article_stat, dependent: :destroy

  has_many :media, dependent: :destroy

  belongs_to :user

  enum status: %w[draft published unpublished], _suffix: true

  # validations

  # end for validations

  class << self
  end
end
