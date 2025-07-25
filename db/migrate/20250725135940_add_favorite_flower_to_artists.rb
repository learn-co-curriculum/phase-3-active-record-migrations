class AddFavoriteFlowerToArtists < ActiveRecord::Migration[8.0]
  def change
    add_column :artists, :favorite_flower, :string
  end
end
