# frozen_string_literal: true

module ArticleService
  class Delete < BaseService
    def initialize(article_id, user)
      @article_id = article_id
      @user = user
    end

    def call
      article = Article.find(@article_id)
      authorize_deletion!(article)

      article.destroy!

      { message: 'Article has been deleted.' }
    rescue ActiveRecord::RecordNotFound
      { error: 'Article not found.' }
    rescue Pundit::NotAuthorizedError
      { error: 'You are not authorized to delete this article.' }
    end

    private

    def authorize_deletion!(article)
      policy = ArticlePolicy.new(@user, article)
      raise Pundit::NotAuthorizedError unless policy.manage?
    end
  end
end
