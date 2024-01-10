json.status 200
json.articles @articles_with_details do |article|
  json.extract! article, :id, :title, :content, :author_id, :created_at, :status

  article_metadata = article.metadata
  if article_metadata.present?
    json.metadata do
      json.extract! article_metadata, :tags, :categories, :featured_image
    end
  end

  article_stats = article.article_stats
  if article_stats.present?
    json.stats article_stats, :views, :likes, :comments_count
  end
end
