# typed: ignore
module Api
  class ArticlesController < BaseController
    before_action :doorkeeper_authorize!

    def index
      user_id = params.require(:user_id)
      # Authenticate the user and ensure they have permission to manage articles.
      user = User.find(user_id)
      authorize user, policy_class: ArticlePolicy

      # Query the "articles" table to retrieve all articles associated with the provided user_id.
      articles = Article.includes(:metadata, :article_stats).where(user_id: user_id)

      # Compile the article information, metadata, and statistics into a list.
      articles_with_details = articles.map do |article|
        {
          article: article,
          metadata: article.metadata,
          statistics: article.article_stats
        }
      end

      # Return the list of articles with their metadata and statistics to the user.
      render json: { articles: articles_with_details, total_items: articles.size, total_pages: 1 }
    rescue Pundit::NotAuthorizedError
      base_render_unauthorized_error
    end
  end
end
