# frozen_string_literal: true

module ArticleService
  class Index
    attr_reader :user_id

    def initialize(user_id)
      @user_id = user_id
    end

    def retrieve_articles
      authenticate_user

      articles = Article.includes(:metadatum, :article_stat).where(user_id: user_id)
      articles_with_details = articles.map do |article|
        {
          title: article.title,
          content: article.content,
          status: article.status,
          views: article.article_stat.views,
          likes: article.article_stat.likes,
          comments_count: article.article_stat.comments_count,
          tags: article.metadatum.tags,
          categories: article.metadatum.categories,
          featured_image: article.metadatum.featured_image.attached? ? article.metadatum.featured_image.blob.service_url : nil
        }
      end

      {
        articles: articles_with_details.as_json(only: [:title, :content, :status, :views, :likes, :comments_count, :tags, :categories, :featured_image]),
        total_items: articles.size,
        total_pages: (articles.size / Article.default_per_page.to_f).ceil
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
