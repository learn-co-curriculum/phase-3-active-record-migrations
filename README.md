# Active Record Migrations

## Learning Goals

- Create, connect to, and manipulate a SQLite database using Active Record

## Setup

We're going to use the Active Record gem to create a mapping between our
database and model. This is a long lesson, and there are a lot of important
steps to successfully work with Active Record, so make sure to code along. We'll
summarize the important steps at the end.

Start by cloning down this lesson, then run `bundle install` to set up the
dependencies.

## Migrations

From [the _Rails Guides_ section on Migrations][guide-migrations]:

> Migrations are a convenient way to alter your database schema over time in a
> consistent way. They use a Ruby DSL so that you don't have to write SQL by
> hand, allowing your schema and changes to be database independent.
>
> You can think of each migration as being a new 'version' of the database. A
> schema starts off with nothing in it, and each migration modifies it to add or
> remove tables, columns, or entries. Active Record knows how to update your
> schema along this timeline, bringing it from whatever point it is in the
> history to the latest version. Active Record will also update your
> `db/schema.rb` file to match the up-to-date structure of your database.

Why might you need something like version control for your database? You might
create a table, add some data to it, and then make some changes to it later on.
By adding a new migration for each change you make to the database, you won't
lose any data you don't want to, and you can easily revert changes.

Executed migrations are tracked by Active Record in your database so that they
aren't used twice. Using the migrations system to apply the schema changes is
easier than keeping track of the changes manually and executing them manually at
the appropriate time.

### Creating a Table

One common task when working with databases is creating tables. Remember how we
created a table using SQL with Active Record?

First, we connect to a database, then write the necessary SQL to create the
table. So, first, we'd have to connect to a database:

```rb
ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: "db/artists.sqlite"
)
```

Then write some SQL to create the table:

```rb
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

Using migrations, we will still need to establish Active Record's connection to
the database, but **_we no longer need the SQL!_** Instead of dealing with SQL
directly, we provide the migrations we want and Active Record takes care of
creating and modifying the tables.

To tell Active Record how to connect to the database from here on out, we'll use
a `config/database.yml` file. This file is used by convention to give Active
Record the necessary details about how to connect to our database, like which
"adapter" we are using (right now, we're using SQLite, but Active Record
supports other database adapters such as MySQL and PostgreSQL as well), and the
name of the database file. Here's what it looks like:

```yml
development:
  adapter: sqlite3
  database: db/development.sqlite3

test:
  adapter: sqlite3
  database: db/test.sqlite3
```

As you can see, this has similar information as the Ruby code we used
previously, just in a different format:

```rb
ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: "db/artists.sqlite"
)
```

With the connection to the database configured, we can move on to the next step.

### Active Record Rake Tasks

The simplest way to work with migrations is through Rake tasks that we're given
through a new gem, the `sinatra-activerecord` gem. This gem provides some common
Rake tasks for working with Active Record.

Run `rake -T` to see the list of commands we have.

> **Note**: If you get an error when trying to run `rake` commands, you may have
> a newer version of Rake already installed compared to this lesson, causing a
> conflict. To avoid this error, run `bundle exec rake -T`. Adding `bundle exec`
> indicates that you want `rake` to run within the context of this lesson's
> bundle (defined in the `Gemfile`), not the default version of `rake` you have
> installed globally on your computer. See also:
> [But I Don't Want to `bundle exec`][bundle exec]

Let's look at the `Rakefile`. The commands listed when running `rake -T` are
made available as Rake tasks through `require 'sinatra/activerecord/rake'`.

Now take a look again at `environment.rb`, which our `Rakefile` also requires:

```rb
# config/environment.rb
ENV["RACK_ENV"] ||= "development"

require 'bundler/setup'
Bundler.require(:default, ENV["RACK_ENV"])
```

This file is requiring the gems in our Gemfile and giving our program access to
them. Now that you know where our Rake tasks are coming from, let's use one of
them to create our first migration.

`ENV["RACK_ENV"]` here is known as an **environment variable**. In this case,
this environment variable determines whether our code is running in a
development environment, or a test environment (when running RSpec tests).
`RACK_ENV` is a specific environment variable that is used by the
`sinatra-activerecord` gem to determine which database to connect to: in our
`environment.rb` file, we're specifying that it should use the `development`
database, which is configured in the `database.yml` file.

### Creating Migrations Using a Rake Task

To create a migration for setting up our `artists` table, run this command:

```console
$ bundle exec rake db:create_migration NAME=create_artists
```

Running this command will generate a new file in `db/migrations` called
`20210716095220_create_artists.rb`. The timestamp at the beginning of the
migration is **crucial**, since it will be used as part of the version control
for our migrations and ensure they are run in the correct order.

```txt
├── app
│   └── models
│       └── artist.rb
├── config
│   └── environment.rb
├── db
│   └── migrate
│       └── 20210716095220_create_artists.rb # new file here
├── spec
├── Gemfile
├── Gemfile.lock
└── Rakefile
```

> If you noticed, there's also a `.gitkeep` file in the `db/migrate` folder. You
> can delete this file after creating the migration. Since Git won't track an
> empty directory, creating an empty `.gitkeep` file is a convention for
> creating folders with no content and keeping them in your Git repository.

In addition to creating the migration file, that Rake task also added some
code for us:

```rb
# db/migrate/20210716095220_create_artists.rb
class CreateArtists < ActiveRecord::Migration[6.1]
  def change
  end
end
```

### Active Record Migration Methods: up, down, change

Here we're creating a class called `CreateArtists` that inherits from Active
Record's `ActiveRecord::Migration` module. Within the class, we have a `change`
method, which is the most common for updating the database.

From [the Active Record Migrations RailsGuide][change-method]:

> The `change` method is the primary way of writing migrations. It works for the
> majority of cases, where Active Record knows how to reverse the migration
> automatically

In addition to `change`, Active Record also provides an `up` method to define
the code to execute when the migration is **run** and a `down` method to define
the code to execute when the migration is **rolled back**. Think of it like "do"
and "undo."

Let's take a look at how to finish off our `CreateArtists` migration, which will
generate our `artists` table with the appropriate columns. Remember, table names
are **plural**, so we're creating an `artists` table, which we'll use with an
`Artist` class.

```rb
# db/migrate/20210716095220_create_artists.rb
def change
  create_table :artists do |t|
  end
end
```

Here we've added the `create_table` method and passed the name of the table we
want to create as a symbol. Pretty simple, right? Other methods we can use here
are things like `remove_table`, `rename_table`, `remove_column`, `add_column`
and others. See [this list][writing-migrations] for more.

After the table name `:artists` we write a block of code that is passed a block
parameter `t`, which is a special Active Record migration object that helps add
different columns to the table.

No point in having a table that has no columns in it, so let us add a few:

```rb
# db/migrate/20210716095220_create_artists.rb

class CreateArtists < ActiveRecord::Migration[6.1]
  def change
    create_table :artists do |t|
      t.string :name
      t.string :genre
      t.integer :age
      t.string :hometown
      # the id column is generated automatically for every table! no need to specify it here.
    end
  end
end
```

Looks a little familiar? On the left, we've given the **data type** we'd like to
cast the column as, and on the right, we've given the **name** we'd like to give
the column.

The only thing that we're missing is the _primary key_. Active Record will
generate that column for us, and for each row added, a key will be
auto-incremented.

While this syntax looks intimidating, remember, this is all just Ruby code! If
we were to write this out using parentheses for the method calls, it'd look like
this (which may make it easier to see how the code works, but less pleasant to
read):

```rb
create_table :artists do |t|
  # t.string is a method that takes a symbol as an argument and creates a column
  t.string(:name)
  t.string(:genre)
  t.integer(:age)
  t.string(:hometown)
end
```

And that's it! You've created your first Active Record migration. Next, we're
going to see it in action!

### Running Migrations

It's time to run our migration. Run this command:

```console
$ bundle exec rake db:migrate

== 20210716095220 CreateArtists: migrating ====================================
-- create_table(:artists)
   -> 0.0008s
== 20210716095220 CreateArtists: migrated (0.0009s) ===========================
```

When we run this command, a few things will happen:

- Active Record will create a new database file, if one doesn't already exist,
  based on the configuration in the `database.yml` file
- It will then use the code in the `migrate` folder to update the database
- It will also create a `db/schema.rb` file, which is used as a "snapshot" of
  the current state of your database

The `db/schema.rb` file looks like this:

```rb
ActiveRecord::Schema.define(version: 2021_07_16_095220) do
  create_table "artists", force: :cascade do |t|
    t.string "name"
    t.string "genre"
    t.integer "age"
    t.string "hometown"
  end
end
```

As you can see, it includes a version number that corresponds to the timestamp
of the migration file, as well as a definition for the table we created in the
migration.

You can also use this Rake task to see the status of your migrations:

```console
$ bundle exec rake db:migrate:status

database: db/development.sqlite3

 Status   Migration ID    Migration Name
--------------------------------------------------
   up     20210716095220  Create artists
```

If the status is `up`, that means this migration is **active**: it's been run,
and has updated the database successfully!

### Interacting With the Database

Take a look at `app/models/artist.rb`. You'll notice our model code is in a
slightly different file structure than before: in `app/models` instead of `lib`.
The reason for this is that this file structure is commonly used in modular
Sinatra applications as well as in Rails, so we'll set up our projects this way
from here on out to give you exposure to this file structure.

Let's create an `Artist` class and extend the class with `ActiveRecord::Base`:

```rb
# app/models/artist.rb
class Artist < ActiveRecord::Base
end
```

Remember: **singular** class name, **plural** table name.

To test our newly created class out, let's use the `console` Rake task which
we've created in the `Rakefile`:

```console
$ bundle exec rake console
```

Check that the class exists:

```rb
Artist
# => Artist (call 'Artist.connection' to establish a connection)
```

View the columns in its corresponding table in the database:

```rb
Artist.column_names
# => ["id", "name", "genre", "age", "hometown"]
```

Instantiate a new Artist named Jon, set his age to 30, and save him to the
database:

```rb
a = Artist.new(name: 'Jon')
# => #<Artist id: nil, name: "Jon", genre: nil, age: nil, hometown: nil>

a.age = 30
# => 30

a.save
# => true
```

The `.new` method creates a new instance in memory, but for that instance to
persist, we need to save it. If we want to create a new instance and save it all
in one go, we can use `.create`.

```rb
Artist.create(name: 'Kelly')
# => #<Artist id: 2, name: "Kelly", genre: nil, age: nil, hometown: nil>
```

Return an array of all Artists from the database:

```rb
Artist.all
# => [#<Artist id: 1, name: "Jon", genre: nil, age: 30, hometown: nil>,
 #<Artist id: 2, name: "Kelly", genre: nil, age: nil, hometown: nil>]
```

Find an Artist by name:

```rb
Artist.find_by(name: 'Jon')
# => #<Artist id: 1, name: "Jon", genre: nil, age: 30, hometown: nil>
```

There are several methods you can now use to create, retrieve, update, and
delete data from your database, and a whole lot more.

Take a look at these [CRUD methods][crud], and play around with them.

## Using Migrations To Manipulate Existing Tables

Let's add a `favorite_food` column to our `artists` table. Active Record keeps
track of the migrations we've already run, so **adding the new code to our
`20210716095220_create_artists.rb` file won't work**. If you try running
`rake db:migrate` again now, the `20210716095220_create_artists.rb` migration
won't be re-executed.

Generally, the best practice for database management (especially in a production
environment) is **creating new migrations to modify existing tables**. That way,
we'll have a clear, linear record of all of the changes that have led to our
current database structure.

To make this change we're going to need a new migration:

```console
$ bundle exec rake db:create_migration NAME=add_favorite_food_to_artists
```

And add the migration code to the file:

```rb
# db/migrate/20210716100800_add_favorite_food_to_artists.rb
class AddFavoriteFoodToArtists < ActiveRecord::Migration[6.1]
  def change
    add_column :artists, :favorite_food, :string
  end
end
```

Pretty awesome, right? We just told Active Record to add a column to the
`artists` table called `favorite_food` and that it will contain a string.

Notice the new timestamp for this migration? Imagine for a minute that you
deleted your original database and wanted to execute the migrations again.
Active Record is going to execute each file, but it does so in alpha-numerical
order. If we didn't have the timestamps, our `add_column` migration would have
tried to run first (`[a]dd_favorite...` comes before `[c]reate_artists...`), and
our `artists` table wouldn't have even been created yet! So we used timestamps
to make sure the migrations execute in order. Another benefit of using the Rake
task!

Now that you've saved the migration, go back to the terminal to run:

```console
$ bundle exec rake db:migrate
```

Check the status of the migration:

```console
$ bundle exec rake db:migrate:status

database: db/development.sqlite3

 Status   Migration ID    Migration Name
--------------------------------------------------
   up     20210716095220  Create artists
   up     20210716101748  Add favorite food to artists
```

And see that the `db/schema.rb` file was also updated to include the new column:

```rb
ActiveRecord::Schema.define(version: 2021_07_16_101748) do
  create_table "artists", force: :cascade do |t|
    t.string "name"
    t.string "genre"
    t.integer "age"
    t.string "hometown"
    t.string "favorite_food"
  end
end
```

Awesome! Now go back to the console with the `rake console` command, and check
it out:

```rb
Artist.column_names
# => ["id", "name", "genre", "age", "hometown", "favorite_food"]
```

Great!

Nope... wait. Word just came down from the boss: you weren't supposed to ship
that change yet! We wanted to keep track of the artist's favorite **flower**,
not their favorite **food**. OH NO! No worries, we'll **roll back** to the first
migration.

Run `rake -T`. Which command should we use? That's right: `db:rollback`:

```console
$ bundle exec rake db:rollback
```

Check the status of the migration:

```console
$ bundle exec rake db:migrate:status

database: db/development.sqlite3

 Status   Migration ID    Migration Name
--------------------------------------------------
   up     20210716095220  Create artists
  down    20210716101748  Add favorite food to artists
```

The migration being **down** indicates that it's not part of the database. You
can verify by checking the schema:

```rb
ActiveRecord::Schema.define(version: 2021_07_16_095220) do
  create_table "artists", force: :cascade do |t|
    t.string "name"
    t.string "genre"
    t.integer "age"
    t.string "hometown"
  end
end
```

Since the migration is **down**, we can edit it and correct the name of the
column (as well as the name of the _file_ and the name of the _class_, just to
make this change clear):

```rb
# db/migrate/20210716100800_add_favorite_flower_to_artists.rb
class AddFavoriteFlowerToArtists < ActiveRecord::Migration[6.1]
  def change
    add_column :artists, :favorite_flower, :string
  end
end
```

> **Note**: If you change the class name in the file, but don't also change the
> file name, the migration will error out. Active Record is very particular
> about its conventions! Make sure to change the file name as well:
> `20210716100800_add_favorite_flower_to_artists.rb`.

Now, run the migration again and check the status:

```console
$ bundle exec rake db:migrate
$ bundle exec rake db:migrate:status
database: db/development.sqlite3

 Status   Migration ID    Migration Name
--------------------------------------------------
   up     20210716095220  Create artists
   up     20210716101748  Add favorite flower to artists
```

Success! Run `learn test` now to pass all the tests.

### When Should I Roll Back?

In general, rolling back a migration is safe to do while you are developing a
new feature and experimenting with your code. If you're collaborating with
another developer or a team on a project, once you share the code with other
developers, you shouldn't roll back and modify any existing migrations.
Remember, the migration history is like a version control for your database, so
it's a bad idea to go back in time and rewrite that history.

## Conclusion

Migrations are a crucial part of any Active Record application. They provide a
consistent way to set up and update your database tables, without having to write
any SQL code by hand.

To add a feature to the database, such as creating or altering a table, here is
a summary of the steps:

- Run `rake db:create_migration NAME=description_of_change` to generate a
  migration file
- Write the [migration code][change-method] in the migration file
- Run the migration with `rake db:migrate`
- Check the status of the migration with `rake db:migrate:status`, and inspect
  the `db/schema.rb` file to ensure the correct changes were made

To change an existing migration (that hasn't been shared with other team members
yet), here is a summary of the steps:

- Run `rake db:rollback` to undo the last migration
- Check the status of the migration with `rake db:migrate:status` and make sure
  it is "down"
- Edit the migration file
- Run `rake db:migrate` to update the database
- Check the status of the migration with `rake db:migrate:status`, and inspect
  the `db/schema.rb` file to ensure the correct changes were made

## Resources

- [Active Record Migrations][guide-migrations]
- [Active Record Basics][crud]

[guide-migrations]: https://guides.rubyonrails.org/active_record_migrations.html
[change-method]: https://guides.rubyonrails.org/active_record_migrations.html#using-the-change-method
[writing-migrations]: https://guides.rubyonrails.org/active_record_migrations.html#writing-a-migration
[crud]: http://guides.rubyonrails.org/active_record_basics.html#crud-reading-and-writing-data
[bundle exec]: https://thoughtbot.com/blog/but-i-dont-want-to-bundle-exec
