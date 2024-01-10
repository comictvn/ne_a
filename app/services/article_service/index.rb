# frozen_string_literal: true

module ArticleService
  class Index
    attr_reader :user_id

    def initialize(user_id)
      @user_id = user_id
    end

    def retrieve_articles
      authenticate_user

      articles = Article.includes(:metadatum, :article_stats).where(user_id: user_id)
      articles_with_details = articles.map do |article|
        {
          article: article,
          metadata: article.metadatum,
          statistics: article.article_stats
        }
      end

      {
        articles: articles_with_details,
        total_items: articles.size,
        total_pages: articles.total_pages
      }
    rescue StandardError => e
      { error: e.message }
    end

    private

    def authenticate_user
      # Assuming Pundit is used for authorization
      raise Pundit::NotAuthorizedError unless User.find(user_id).can_manage_articles?
    end
  end
end
