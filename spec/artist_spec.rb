require_relative './spec_helper'

describe "Artist" do
  let(:artist) {Artist.new(name: 'Justice', genre: 'Electronic', age: Time.now.strftime("%Y").to_i - 2003, hometown: "Paris")}

  it "can instantiate a new instance" do
    expect(Artist.new.is_a?(Object)).to eq(true)
  end

  it "can instantiate with a name, genre, age and hometown" do

    expect(artist.name).to eq("Justice")
    expect(artist.genre).to eq("Electronic")
    expect(artist.age).to eq(Time.now.strftime("%Y").to_i - 2003)
    expect(artist.hometown).to eq("Paris")
  end

  it "can be saved to the database" do
    artist.genre = "Electronic"

    expect(artist.save).to eq(true)
  end

  it "can instantiate and save at the same time with create" do
    artist = Artist.create(name: 'Justice', genre: "Electronic", age: Time.now.strftime("%Y").to_i - 2003, hometown: "Paris")

    expect(Artist.all.last.name).to eq("Justice")
  end

  it "can find an Artist by name" do
    weeknd = Artist.create(name: 'The Weeknd', genre: "Alternative R&B", age: Time.now.strftime("%Y").to_i - 2010, hometown: "Toronto")
    taytay = Artist.create(name: 'Taylor Swift', genre: "Pop / Country", age: Time.now.strftime("%Y").to_i - 2006, hometown: "Reading")
    queen = Artist.create(name: 'Queen', genre: "Rock", age: Time.now.strftime("%Y").to_i - 1973, hometown: "London")

    expect(Artist.find_by(name: "Taylor Swift")).to eq(taytay)
  end

  it "can roll back to have no gender attribute for Artist" do
    expect(Artist.column_names).to eq(["id", "name", "genre", "age", "hometown"])
  end
end
