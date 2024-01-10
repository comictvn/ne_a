
# frozen_string_literal: true

module ArticleService
  class Publish
    attr_reader :article_id, :user, :title, :content, :user_id, :tags, :categories, :featured_image

    def initialize(article_id, user, title, content, user_id, tags, categories, featured_image)
      @article_id = article_id
      @user = user
      @title = title
      @content = content
      @user_id = user_id
      @tags = tags
      @categories = categories
      @featured_image = featured_image
    end

    def publish_article
      raise 'Invalid input' unless article_id.present? && title.present? && content.present? && user_id.present?

      article = Article.find_by(id: @article_id)
      raise 'Article not found' unless article
      raise 'Article does not belong to user' unless article.user_id == user_id

      authorize @user, article, :publish?

      article.status = 'published'
      article.updated_at = Time.current

      metadata = Metadatum.find_or_initialize_by(article_id: article_id)
      metadata.assign_attributes(tags: tags, categories: categories, featured_image: featured_image)
      raise 'Failed to save metadata' unless metadata.save

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

    private

    def authorize(user, article, action)
      # Assuming there's an existing authorization method to be called here
      # This is a placeholder for the actual authorization logic
      true
    end
  end
end
