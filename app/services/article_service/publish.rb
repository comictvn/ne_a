# frozen_string_literal: true

module ArticleService
  class Publish
    def initialize(article_id, user)
      @article_id = article_id
      @user = user
    end

    def publish_article
      article = Article.find_by(id: @article_id)
      raise 'Article not found' unless article

      authorize @user, article, :publish?

      article.status = 'published'
      article.updated_at = Time.current

      if article.save
        # Trigger additional processes for a published article
        # For example: ClearCacheJob.perform_later(article)
        # For example: UpdateSearchIndexesJob.perform_later(article)
        # For example: SendNotificationsJob.perform_later(article)

        'Article published successfully'
      else
        raise 'Failed to publish article'
      end
    end
  end
end
