class RenameArtistToArtists < ActiveRecord::Migration[8.0]
  def change
    rename_table :artist, :artists
  end
end
