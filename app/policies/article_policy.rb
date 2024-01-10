# typed: true
# frozen_string_literal: true

class ArticlePolicy < ApplicationPolicy
  def publish?
    # Assuming there is an 'admin' role or similar attribute to check for admin users
    # and that the user is associated with the article either by being its author or an admin.
    user.admin? || record.user_id == user.id
  end
end

