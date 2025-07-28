class ChangeAgeColumnType < ActiveRecord::Migration[8.0]
  def up
    remove_column :artists, :age
    add_column    :artists, :age, :integer
  end

  def down
    remove_column :artists, :age
    add_column    :artists, :age, :string
  end
end
