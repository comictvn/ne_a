
# frozen_string_literal: true

class ArticleMetadataPolicy < ApplicationPolicy
  # Check if the user has permission to create metadata for an article
  def create?
    raise Pundit::NotAuthorizedError unless user.present? && user.articles.exists?(record.id)
    true
  end

  # Check if the user has permission to update metadata for an article
  def update?
    raise Pundit::NotAuthorizedError unless user.present? && user.articles.exists?(record.id)
    true
  end

  private

  attr_reader :user, :record
end
