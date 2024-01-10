class ChangeSchemaV4 < ActiveRecord::Migration[6.0]
  def change
    change_table_comment :users, from: 'Registered users in the blog application',
                                 to: 'Registered users who can create and manage articles'
    change_table_comment :articles, from: 'Articles created by users in the blog application',
                                    to: 'Articles created by users'
    change_table_comment :article_stats, from: 'Statistics for articles', to: 'Statistics related to articles'
    change_table_comment :media, from: 'Multimedia content used in articles', to: 'Multimedia content for articles'
    change_table_comment :metadata, from: 'Metadata associated with articles', to: 'Metadata for articles'

    add_column :media, :file_type, :integer, default: 0
  end
end
