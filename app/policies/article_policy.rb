# typed: true
# frozen_string_literal: true

class ArticlePolicy < ApplicationPolicy
  def update?
    return false unless user.present? && record.present?
    record.status == 'published' && (record.user_id == user.id || user.admin?)
  end

  def manage?
    user.role == 'editor' || user.role == 'admin'
  end

  def publish?
    user.admin? || record.user_id == user.id
  end

  # You can add more methods related to other article actions if needed
end
