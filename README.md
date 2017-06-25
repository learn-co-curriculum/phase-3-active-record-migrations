# Let's Learn About Migrations

## Objective

1. Create, connect to, and manipulate a SQLite database using ActiveRecord.

## Setup

1) We're going to use the `activerecord` gem to create a mapping between our database and model.

2) While this is marked as a Readme, fork and clone this repository. Take a look at the `Gemfile` in this directory. Be sure to run `bundle install`.

## Migrations
From [the _RailsGuides_ section on Migrations](http://guides.rubyonrails.org/v3.2.8/migrations.html):
>Migrations are a convenient way for you to alter your database in a structured and organized manner. You could edit fragments of SQL by hand but you would then be responsible for telling other developers that they need to go and run them. You’d also have to keep track of which changes need to be run against the production machines next time you deploy.

>Migrations also allow you to describe these transformations using Ruby. The great thing about this is that (like most of Active Record’s functionality) it is database independent: you don’t need to worry about the precise syntax of `CREATE TABLE` any more than you worry about variations on `SELECT *` (you can drop down to raw SQL for database specific features). For example, you could use SQLite3 in development, but MySQL in production.

Another way to think of migrations is like version control for your database. You might create a table, add some data to it, and then make some changes to it later on. By adding a new migration for each change you make to the database, you won't lose any data you don't want to, and you can easily revert changes.

Executed migrations are tracked by ActiveRecord in your database so that they aren't used twice. Using the migrations system to apply the schema changes is easier than keeping track of the changes manually and executing them manually at the appropriate time.

### Setting Up Your Migration

1. If you haven't done so already, [fork and clone this repository via GitHub](https://github.com/learn-co-students/mechanics-of-migrations-v-000). Create a directory called `db` at the top level of the lesson's directory. Then, within the `db` directory, create a `migrate` directory.
    - ***Note***: If you're using the Learn IDE, make sure you create both directories with the `mkdir` command in your IDE terminal. If you create these directories any other way, you'll encounter a permissions error when you try to run `rake db:migrate` later.
2. In the migrate directory, create a file called `01_create_artists.rb` (we'll talk about why we added the `01` later).
```
mechanics-of-migrations-v-000/
  config/
    environment.rb
  db/
    migrate/
      01_create_artists.rb
  spec/
    artist_spec.rb
    spec_helper.rb
  .gitignore
  .learn
  .rspec
  artist.rb
  CONTRIBUTING.md
  Gemfile
  Gemfile.lock
  LICENSE.md
  Rakefile
  README.md
```

```ruby
# db/migrate/01_create_artists.rb

class CreateArtists < ActiveRecord::Migration
  def up
  end

  def down
  end
end
```

### Active Record Migration Methods: up, down, change

Here we're creating a class called `CreateArtists` that inherits from ActiveRecord's `ActiveRecord::Migration` module. Within the class we have an `up` method to define the code to execute when the migration is run and a `down` method to define the code to execute when the migration is rolled back. Think of it like "do" and "undo."

Another method is available to use besides `up` and `down`: `change`, which is more common for basic migrations.

```ruby
# db/migrate/01_create_artists.rb

class CreateArtists < ActiveRecord::Migration
  def change
  end
end

```
From [the Active Record Migrations RailsGuide](http://edgeguides.rubyonrails.org/active_record_migrations.html#using-the-change-method):
>The change method is the primary way of writing migrations. It works for the majority of cases, where Active Record knows how to reverse the migration automatically

Let's take a look at how to finish off our `CreateArtists` migration, which will generate our `artists` table with the appropriate columns.

### Creating a Table

Remember how we created a table using SQL with ActiveRecord.

First, we'd have to connect to a database:

```ruby
connection = ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "db/artists.sqlite"
)
```
Then, we'd create our table using SQL:

```ruby
sql = <<-SQL
  CREATE TABLE IF NOT EXISTS artists (
  id INTEGER PRIMARY KEY,
  name TEXT,
  genre TEXT,
  age INTEGER,
  hometown TEXT
  )
SQL

ActiveRecord::Base.connection.execute(sql)
```

Now that we have access to `ActiveRecord::Migration`, we can create tables using only Ruby. Yay!


```ruby
# db/migrate/01_create_artists.rb
def change
  create_table :artists do |t|
  end
end
```

Here we've added the `create_table` method and passed the name of the table we want to create as a symbol. Pretty simple, right? Other methods we can use here are things like `remove_table`, `rename_table`, `remove_column`, `add_column` and others. See [this list](http://guides.rubyonrails.org/migrations.html#writing-a-migration) for more.

No point in having a table that has no columns in it, so lets add a few:

```ruby
# db/migrate/01_create_artists.rb

class CreateArtists < ActiveRecord::Migration
  def change
    create_table :artists do |t|
      t.string :name
      t.string :genre
      t.integer :age
      t.string :hometown
    end
  end
end
```

Looks a little familiar? On the left we've given the data type we'd like to cast the column as, and on the right we've given the name we'd like to give the column. The only thing that we're missing is the primary key. Active Record will generate that column for us, and for each row added, a key will be auto-incremented.

And that's it! You've created your first Active Record migration. Next, we're going to see it in action!

### Running Migrations

The simplest way is to run our migrations through a raketask that we're given through the `activerecord` gem. How do we access these?

Run `rake -T` to see the list of commands we have.

Let's look at the `Rakefile`. The way in which we get these commands as raketasks is through `require 'sinatra/activerecord/rake'`.

Now take a look at `environment.rb`, which our Rakefile also requires:

```ruby
# config/environment.rb

require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "db/artists.sqlite"
)
```

This file is requiring the gems in our Gemfile and giving our program access to them. We're using the `establish_connection` method from `ActiveRecord::Base` to connect to our `artists` database, which will be created in the migration via SQLite3 (the adapter).

After we've added the above code to `config/environment.rb`, it's time to run `rake db:migrate`.

4) Take a look at `artist.rb`. Let's create an Artist class.

```ruby
# artist.rb

class Artist
end
```

Next, we'll extend the class with `ActiveRecord::Base`

```ruby
# artist.rb

class Artist < ActiveRecord::Base
end
```

To test our newly-created class out, let's use the rake task `rake console`, which we've created in the `Rakefile`.


### Try out the following:

Check that the class exists:

```ruby
Artist
# => Artist (call 'Artist.connection' to establish a connection)
```

View the columns in its corresponding table in the database:

```ruby
Artist.column_names
# => ["id", "name", "genre", "age", "hometown"] 
```

Instantiate a new Artist named Jon, set his age to 30, and save him to the database:

```ruby
a = Artist.new(name: 'Jon')
# => #<Artist id: nil, name: "Jon", genre: nil, age: nil, hometown: nil>

a.age = 30
# => 30

a.save
# => true
```

The `.new` method creates a new instance in memory, but in order for that instance to persist, we need to save it. If we want to create a new instance and save it all in one go, we can use `.create`.

```ruby
Artist.create(name: 'Kelly')
# => #<Artist id: 2, name: "Kelly", genre: nil, age: nil, hometown: nil>
```

Return an array of all Artists from the database:

```ruby
Artist.all
# => [#<Artist id: 1, name: "Jon", genre: nil, age: 30, hometown: nil>,
 #<Artist id: 2, name: "Kelly", genre: nil, age: nil, hometown: nil>]
```

Find an Artist by name:

```ruby
Artist.find_by(name: 'Jon')
# => #<Artist id: 1, name: "Jon", genre: nil, age: 30, hometown: nil>
```

There are a number of methods you can now use to create, retrieve, update, and delete data from your database, and a whole lot more.

Take a look at these [CRUD methods](http://guides.rubyonrails.org/active_record_basics.html#crud-reading-and-writing-data), and play around with them.

## Using migrations to manipulate existing tables

Here is another place where migrations really shine. Let's add a `favorite_food` column to our `artists` table. Remember that Active Record keeps track of the migrations we've already run, so adding the new code to our `01_create_artists.rb` file won't work. Since we aren't rolling back our previous migration (or dropping the entire table), the `01_create_artists.rb` migration won't be re-executed when we run `rake db:migrate` again. Generally, the best practice for database management (especially in a production environment) is creating new migrations to modify existing tables. That way, we'll have a clear, linear record of all of the changes that have led to our current database structure.

To make this change we're going to need a new migration, which we'll call `02_add_favorite_food_to_artists.rb`.

```ruby
# db/migrate/02_add_favorite_food_to_artists.rb

class AddFavoriteFoodToArtists < ActiveRecord::Migration
  def change
    add_column :artists, :favorite_food, :string
  end
end
```

Pretty awesome, right? We just told Active Record to add a column to the `artists` table called `favorite_food` and that it will contain a string.

Notice how we incremented the number in the file name there? Imagine for a minute that you deleted your original database and wanted to execute the migrations again. Active Record is going to execute each file, but it does so in alpha-numerical order. If we didn't have the numbers, our `add_column` migration would have tried to run first (`[a]dd_favorite...` comes before `[c]reate_artists...`), and our `artists` table wouldn't have even been created yet! So we used some numbers to make sure the migrations execute in order. In reality, our two-digit system is very rudimentary. As you'll see later on, frameworks like Rails have generators that create migrations with very accurate timestamps, so you'll never have to worry about hand-numbering.

Now that you've saved the migration, go back to the terminal to run it:

`rake db:migrate`

Awesome! Now go back to the console with the `rake console` command, and check it out:

```ruby
Artist.column_names
# => ["id", "name", "genre", "age", "hometown", "favorite_food"] 
```

Great!

Nope- wait. Word just came down from the boss- you weren't supposed to ship that change yet! OH NO! No worries, we'll roll back to the first migration.

Run `rake -T`. Which command should we use?

`rake db:rollback`

Then drop back into the console to double check:


```ruby
Artist.column_names
# => ["id", "name", "genre", "age", "hometown"]
```

Oh good, your job is saved. Thanks Active Record! When the boss says it's actually time to add that column, you can just run `rake db:migrate` again!

Woohoo!

<p data-visibility='hidden'>View <a href='https://learn.co/lessons/mechanics-of-migrations'>Mechanics of Migrations</a> on Learn.co and start learning to code for free.</p>
