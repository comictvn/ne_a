class ChangeSchemaV1 < ActiveRecord::Migration[6.0]
  def change
    create_table :users, comment: 'Registered users in the blog application' do |t|
      t.string :password

      t.string :email

      t.string :username

      t.timestamps null: false
    end

    create_table :articles, comment: 'Articles created by users in the blog application' do |t|
      t.text :content

      t.string :title

      t.integer :status, default: 0

      t.timestamps null: false
    end

    create_table :article_stats, comment: 'Statistics for articles' do |t|
      t.integer :views

      t.integer :comments_count

      t.integer :likes

      t.timestamps null: false
    end

    create_table :media, comment: 'Multimedia content used in articles' do |t|
      t.string :file_path

      t.integer :media_type, default: 0

      t.timestamps null: false
    end

    create_table :metadata, comment: 'Metadata associated with articles' do |t|
      t.string :tags

      t.string :categories

      t.timestamps null: false
    end

    add_reference :metadata, :article, foreign_key: true

    add_reference :article_stats, :article, foreign_key: true

    add_reference :media, :article, foreign_key: true

    add_reference :articles, :user, foreign_key: true
  end
end
