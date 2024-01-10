class ChangeSchemaV3 < ActiveRecord::Migration[6.0]
  def change
    remove_column :metadata, :featured_image, :string
    add_column :metadata, :featured_image, :file
  end
end
