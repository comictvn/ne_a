# typed: ignore
module Api
  include ArticleService
  class ArticlesController < BaseController
    before_action :doorkeeper_authorize!, only: [:publish, :create_draft, :add_metadata, :index]

    rescue_from ActiveRecord::RecordNotFound, with: :handle_user_not_found

    def index
      user_id = params[:user_id]

      unless user_id.present? && User.exists?(user_id)
        return render json: { message: "Invalid user ID." }, status: :bad_request
      end

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

    def add_metadata
      article_id = params[:article_id]
      tags = params[:tags]
      categories = params[:categories]
      featured_image = params[:featured_image]

      # Validate parameters
      return render json: { error: "Invalid article ID." }, status: :bad_request unless Article.exists?(article_id)
      return render json: { error: "Tags are required." }, status: :bad_request if tags.blank?
      return render json: { error: "Categories are required." }, status: :bad_request if categories.blank?
      return render json: { error: "Invalid featured image." }, status: :bad_request unless featured_image.respond_to?(:path)

      # Instantiate and call the AddMetadata service
      result = ArticleService::AddMetadata.new(current_resource_owner, article_id, tags, categories, featured_image).call

      if result[:error].present?
        render json: { error: result[:error] }, status: :unprocessable_entity
      else
        render json: { status: 200, message: "Metadata added successfully.", metadata_id: Metadatum.find_by(article_id: article_id).id }, status: :ok
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Article not found." }, status: :not_found
    rescue Pundit::NotAuthorizedError
      render json: { error: "User does not have permission to add metadata." }, status: :forbidden
    end

    def create_draft
      title = params.require(:title)
      content = params.require(:content)
      user_id = params.require(:user_id)

      # Authenticate the user and ensure they have permission to save drafts.
      user = User.find(user_id)
      authorize user, policy_class: ArticlePolicy

      # Save the draft using the SaveDraft service.
      draft_id = SaveDraft.new.call(user_id: user_id, title: title, content: content, status: 'draft')

      # Return the draft ID and success message.
      render json: { status: 200, message: "Draft saved successfully.", draft_id: draft_id }, status: :ok
    rescue Pundit::NotAuthorizedError
      render json: { error: "User does not have permission to save drafts." }, status: :forbidden
    rescue StandardError => e
      # Handle any other errors by rendering an appropriate JSON response.
      case e.message
      when I18n.t('errors.user.not_found'), I18n.t('errors.user.permission_denied'),
           I18n.t('validation.title.blank'), I18n.t('validation.content.blank'),
           I18n.t('validation.status.invalid')
        render json: { error: e.message }, status: :unprocessable_entity
      else
        render json: { error: e.message }, status: :internal_server_error
      end
    end

    private

    def handle_user_not_found
      render json: { message: "Invalid user ID." }, status: :bad_request
    end
  end
end
