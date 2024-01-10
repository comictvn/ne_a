json.status 200
json.message "Article updated successfully."
json.article do
  json.id @article.id
  json.title @article.title
  json.content @article.content
  json.author_id @article.user_id
  json.updated_at @article.updated_at.iso8601
end
