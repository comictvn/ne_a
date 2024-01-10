# typed: ignore
module Api
  class ArticlesController < BaseController
    include ArticleService
    before_action :doorkeeper_authorize!, only: [:publish, :create_draft, :add_metadata, :index, :update]

    rescue_from ActiveRecord::RecordNotFound, with: :handle_user_not_found

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

    def update
      article_id = params[:id]
      title = params[:title]
      content = params[:content]

      begin
        raise ArgumentError, 'Wrong format.' unless article_id.is_a?(Numeric)
        raise ArgumentError, 'You cannot input more than 200 characters.' if title.length > 200
        raise ArgumentError, 'You cannot input more than 10000 characters.' if content.length > 10000

        result = ArticleService::Update.new.call(current_resource_owner, article_id, title, content, 'published')

        if result[:success]
          article = Article.find(article_id)
          render json: {
            status: 200,
            message: 'Article updated successfully.',
            article: {
              id: article.id,
              title: article.title,
              content: article.content,
              author_id: article.user_id,
              updated_at: article.updated_at
            }
          }, status: :ok
        else
          render json: { error: result[:message] }, status: :unprocessable_entity
        end
      rescue ArgumentError => e
        render json: { error: e.message }, status: :bad_request
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'This article is not found.' }, status: :not_found
      rescue Pundit::NotAuthorizedError
        render json: { error: 'User does not have permission to edit the article.' }, status: :forbidden
      rescue => e
        render json: { error: e.message }, status: :internal_server_error
      end
    end

    # ... rest of the existing methods (publish, add_metadata, create_draft) ...

    private

    def handle_user_not_found
      render json: { message: "Invalid user ID." }, status: :bad_request
    end
  end
end
