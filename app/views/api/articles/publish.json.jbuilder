json.error do
  json.message @error_message if @error_message.present?
end if @error_message.present?

json.article do
  json.status 200
  json.message "Article published successfully."
  json.article_id @article.id
end if @article.present? && @error_message.blank?
