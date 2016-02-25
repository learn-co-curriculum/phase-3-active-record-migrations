# Let's Learn About Migrations

## Objective

1. Create, connect to, and manipulate a SQLite database using ActiveRecord.

## Setup

1) We're going to be using the `activerecord` gem to create a mapping between our database and model.

2) While this is marked as a Readme, fork and clone this repository. Take a look at the Gemfile in this directory. Be sure to run `bundle install`.

## Migrations

Migrations are a convenient way for you to alter your database in a structured and organized manner. You could edit fragments of SQL by hand but you would then be responsible for telling other developers that they need to go and run them. You’d also have to keep track of which changes need to be run against the production machines next time you deploy.

Migrations also allow you to describe these transformations using Ruby. The great thing about this is that it is database independent: you don’t need to worry about the precise syntax of CREATE TABLE any more than you worry about variations on SELECT * (you can drop down to raw SQL for database specific features). For example, you could use SQLite3 during development, but Postgres in production.

Another way to think of migrations is like version control for your database. You might create a table, add some data to it, and then make some changes to it later on. By adding a new migration for each change you make to the database, you won't lose any data you don't want to, and you can easily revert changes.

Executed migrations are tracked by ActiveRecord in your database, so they aren't used twice. Using the migrations system to apply the schema changes is easier than keeping track of the changes manually and executing them manually at the appropriate time.

### Setting Up Your Migration

1. If you haven't done so already, fork and clone this repository via Github. (This is marked as a Readme so you'll need to open this on Github.) Make a directory in the directory called `db`. Then within the `db` directory, create a `migrate` directory.

2. In the migrate directory, create a file called `01_create_artists.rb` (we'll talk about why we added the 01 later).

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

Here we're creating a class called `CreateArtists` which inherits from ActiveRecord's `ActiveRecord::Migration` module. Within the class we have an `up` method to define what code to execute when the migration is run, and in the `down` method we define what code to execute when the migration is rolled back. Think of it like "do" and "undo."

Another method is available to use besides `up` and `down`: `change`, which is more common for basic migrations.

```ruby
# db/migrate/01_create_artists.rb

class CreateArtists < ActiveRecord::Migration
  def change
  end
end

```

Which is just short for do this, and then undo it on rollback. Let's look at creating the rest of the migration to generate our artists table and add some columns.

### Creating a Table

Remember how we created a table using SQL with ActiveRecord.

First, we'd have to connect to a database:

```ruby
connection = ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "db/songs.sqlite"
)


```
Then, we'd create our table using SQL:

```ruby
sql = <<-SQL
  CREATE TABLE IF NOT EXISTS songs (
  id INTEGER PRIMARY KEY, 
  title TEXT, 
  length INTEGER
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

Here we've added the `create_table` method, and passed the name of the table we want to create as a symbol. Pretty simple, right? Other methods we can use here are things like `remove_table`, `rename_table`, `remove_column`, `add_column` and others. See [this list](http://guides.rubyonrails.org/migrations.html#writing-a-migration) for more.

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

Looks a little familiar? On the left we've given the data type we'd like to cast the column as, and on the right we've given the name we'd like to give the column. The only thing that we're missing is the primary key. ActiveRecord will generate that column for us, and for each row added, a key will be autoincremented.

And that's it! You've created your first ActiveRecord migration. Next, we're going to see it in action!

### Running Migrations

The simplest way is to run our migrations through a raketask that we're given through the activerecord gem. How do we access these?

Run `rake -T` to see the list of commands we have.

Let's look at the `Rakefile`. The way in which we get these commands as raketasks is through `require 'sinatra/activerecord/rake'`.

Now take a look at `environment.rb`, which our Rakefile also requires:

```ruby
require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "db/artists.sqlite"
)
```

This file is requiring the gems in our Gemfile and giving our program access to them. We're going to connect to our artists db, which will be created in the migration, via sqlite3 (the adapter).

Let's run `rake db:migrate`

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

To test it out, let's use the rake task `rake console`, which we've created in the `Rakefile`.


### Try out the following:

View that the class exists:

```ruby
Artist
#=> Artist (call 'Artist.connection' to establish a connection)
```

View that database columns:

```ruby
Artist.column_names
#=> [:id, :name, :genre, :age, :hometown]
```

Instantiate a new Artist named Jon, set his age to 30, save him to the database:

```ruby
a = Artist.new(name: 'Jon')
#=> #<Artist id: nil, name: "Jon", genre: nil, age: nil, hometown: nil>

a.age = 30
#=> 30

a.save
#=> true
```

The `.new` method creates a new instance in memory, but in order for that instance to persist, we need to save it. If we want to create a new instance and save it all in one go, we can use `.create`.

```ruby
Artist.create(name: 'Kelly')
#=> #<Artist id: 2, name: "Kelly", genre: nil, age: nil, hometown: nil>
```

Return an array of all Artists from the database:

```ruby
Artist.all
#=> [#<Artist id: 1, name: "Jon", genre: nil, age: 30, hometown: nil>,
 #<Artist id: 2, name: "Kelly", genre: nil, age: nil, hometown: nil>]
```

Find an Artist by name:

```ruby
Artist.find_by(name: 'Jon')
#=> #<Artist id: 1, name: "Jon", genre: nil, age: 30, hometown: nil>
```

There are a number of methods you can now use to create, retrieve, update, and delete data from your database, and a whole lot more.

Take a look at these [CRUD methods](http://guides.rubyonrails.org/active_record_basics.html#crud-reading-and-writing-data) here and play around with them.

## Using migrations to manipulate existing tables

Here is another place where migrations really shine. Let's add a gender column to our artists table. Remember that ActiveRecord keeps track of what migrations we've already run, so adding it to our 01_create_artists.rb won't work because it won't get executed when we run our migrations again, unless we drop our entire table before rerunning the migration. But that isn't best practices, especially with a production database.

To make this change we're going to need a new migration, which we'll call `02_add_gender_to_artists.rb`.

```ruby
# db/migrate/02_add_gender_to_artists.rb

class AddGenderToArtists < ActiveRecord::Migration
  def change
    add_column :artists, :gender, :string
  end
end
```

Pretty awesome, right? We basically just told ActiveRecord to add a column to the artists table, call it gender, and it's going to be a string.

Notice how we incremented the number in the file name there? Imagine for a minute that you deleted your original database and wanted to execute the migrations again. ActiveRecord is going to execute each file, but it has to do so in some order and it happens to do that in alpha-numerical order. If we didn't have the numbers, our add_column migration would have tried to run first ('a' comes before 'c') and our artists table wouldn't have even been created yet! So we used some numbers to make sure they execute in order. In reality our two-digit system is very rudimentary. As you'll see later on, frameworks like rails have generators that create migrations with very accurate timestamps so you'll never have that problem.

Now that you've save the migration, back to the terminal to run it:

`rake db:migrate`

Awesome! Now go back to the console: `rake console`

and check it out:

```ruby
Artist.column_names
#=> ["id", "name", "genre", "age", "hometown", "gender"]
```

Great!

Nope- wait. Word just came down from the boss- you weren't supposed to ship that change yet! OH NO! No worries, we'll rollback to the first migration.

Run `rake -T`. Which command should we use?

`rake db:rollback`

Then double check:


```ruby
Artist.column_names
#=> ["id", "name", "genre", "age", "hometown"]
```

Oh good, your job is saved. Thanks ActiveRecord! Now when the boss says it's actually time to add that column, you can just run it again!

`rake db:migrate`

Woohoo!

-<a href='https://learn.co/lessons/mechanics-of-migrations' data-visibility='hidden'>View this lesson on Learn.co</a>

<p data-visibility='hidden'>View <a href='https://learn.co/lessons/mechanics-of-migrations' title='Let's Learn About Migrations'>Let's Learn About Migrations</a> on Learn.co and start learning to code for free.</p>

<p data-visibility='hidden'>View <a href='https://learn.co/lessons/mechanics-of-migrations'>Mechanics of Migrations</a> on Learn.co and start learning to code for free.</p>
