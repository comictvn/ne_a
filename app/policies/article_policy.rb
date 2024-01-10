# typed: true
# frozen_string_literal: true

class ArticlePolicy < ApplicationPolicy
  def manage?
    # Assuming the user has a role attribute and 'editor' or 'admin' roles are allowed to manage articles
    user.role == 'editor' || user.role == 'admin'
  end

  def publish?
    # Assuming there is an 'admin' role or similar attribute to check for admin users
    # and that the user is associated with the article either by being its author or an admin.
    user.admin? || record.user_id == user.id
  end

  # You can add more methods related to other article actions if needed
end
