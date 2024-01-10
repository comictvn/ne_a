
# frozen_string_literal: true

module ArticleService
  class SaveDraft
    def call(user_id:, title:, content:)
      user = User.find_by(id: user_id)
      raise StandardError, I18n.t('errors.user.not_found') unless user
      raise StandardError, I18n.t('errors.user.permission_denied') unless user.can_edit_articles?

      raise StandardError, I18n.t('validation.title.blank') if title.blank?
      raise StandardError, I18n.t('validation.content.blank') if content.blank?
      status = 'draft'

      article = user.articles.find_or_initialize_by(title: title)
      article.assign_attributes(content: content, status: status)

      if article.save
        article.id
      else
        raise StandardError, article.errors.full_messages.to_sentence
      end
    rescue ActiveRecord::RecordNotFound
      raise StandardError, I18n.t('errors.article.not_found')
    rescue StandardError => e
      raise StandardError, e.message
    end
  end
end

# Note: The `can_edit_articles?` method is assumed to be defined in the User model.
# This method should check if the user has the necessary permissions to create or edit articles.
# The I18n translations should be defined in the respective locale files under /config/locales/.
