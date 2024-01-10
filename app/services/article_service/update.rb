
# frozen_string_literal: true

module ArticleService
  class Update < BaseService
    def call(user, article_id, title, content, status = 'published')
      raise ArgumentError, 'Article ID, title, and content cannot be blank' if article_id.blank? || title.blank? || content.blank?

      article = Article.find_by(id: article_id)
      raise ActiveRecord::RecordNotFound, 'Article not found' unless article
      raise 'Article is not published' unless article.status == 'published'
      
      authorize user, :update?, article

      article.title = title
      article.content = content
      article.status = status
      article.updated_at = Time.current

      if article.save
        # Trigger additional processes like clearing cache or updating search indexes
        # Example: ClearCacheService.new(article).call
        # Example: UpdateSearchIndexesJob.perform_later(article)
        { success: true, message: 'Article updated successfully' }
      else
        { success: false, message: 'Article could not be updated' }
      end
    end
    
    private

    def authorize(user, action, record)
      policy = ApplicationPolicy.new(user, record)
      raise Pundit::NotAuthorizedError unless policy.public_send(action)
    end
  end
end
