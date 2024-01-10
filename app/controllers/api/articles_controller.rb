# typed: ignore
module Api
  class ArticlesController < BaseController
    before_action :doorkeeper_authorize!, only: [:publish]

    def publish
      begin
        article_id = params[:id]
        raise 'Wrong format.' unless article_id.is_a?(Numeric)

        result = ArticleService::Publish.new(article_id, current_resource_owner).publish_article
        render json: { status: 200, message: result, article_id: article_id }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'This article is not found.' }, status: :not_found
      rescue Pundit::NotAuthorizedError
        render json: { error: 'User does not have permission to publish the article.' }, status: :forbidden
      rescue StandardError => e
        case e.message
        when 'Wrong format.'
          render json: { error: e.message }, status: :unprocessable_entity
        else
          render json: { error: 'An unexpected error occurred on the server.' }, status: :internal_server_error
        end
      end
    end

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
