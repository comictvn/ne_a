json.error do
  json.message @error_message if @error_message.present?
end if @error_message.present?

json.metadata do
  json.tags @article.metadatum.tags if @article.metadatum.present?
  json.categories @article.metadatum.categories if @article.metadatum.present?
  json.featured_image url_for(@article.metadatum.featured_image) if @article.metadatum.present? && @article.metadatum.featured_image.attached?
end if @article.present? && @article.metadatum.present? && @error_message.blank?

json.article do
  json.status 200
  json.message "Article published successfully."
  json.article_id @article.id
end if @article.present? && @error_message.blank?
