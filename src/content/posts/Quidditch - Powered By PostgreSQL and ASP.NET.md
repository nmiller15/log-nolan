---
title: Quidditch - Powered By PostgreSQL and ASP.NET
date: 2025-06-10
summary: Use Entity Framework to connect Postgres to your ASP.NET API.
description: Use Entity Framework to connect Postgres to your ASP.NET API.
toc: false
readTime: true
autonumber: false
math: true
tags: ["postgres", "asp", "dotnet", "learning"]
showTags: true
hideBackToTop: false
draft: false
dev: true
dev_id: 2720828
---
As a software developer, it's important to work on your craft. That's why I've been studying ASP.NET for the past few months. [In my last article](https://nolanmiller.me/posts/intro-to-.net-apis-for-a-javascript-developer/) I walk through how to set up an ASP.NET Minimal Web API. Today, I'll be building on that foundation, by adding a persistent data store, a la PostgreSQL. In order to configure a .NET API to communicate with a PostgreSQL database, I'm going to use Entity Framework.

Though I could have worked with my animal sounds API, I decided to implement the database for an app that scores a road trip game that my wife and I took this summer.
I recently saw a video about a new road trip game that's inspired by Harry Potter (my favorite book series). I knew that my wife and I had to try it. If you're interested, the rules of the game are [described in this video,](https://www.instagram.com/reel/DEs-Stox4d2/?hl=en) and you can play using my score tracker at https://quidditchtrip.nolanmiller.me. 

In this article, I'll go over making sure that you have PostgreSQL installed and running, and then how to install and configure Entity Framework to read to and write from the database. 

## What you'll need to start:

- A .NET Web API (that you've created [using the dotnet CLI](https://nolanmiller.me/posts/supercharge-your-productivity-with-the-.net-cli/))
- Access to an internet connection
- A little bit of patience

## Install Postgres

There are a few different methods to installing and starting a Postgres server on your machine, but the easiest route is downloading Postgres.app, a MacOS postgres server interface that comes bundled with the `psql` CLI. If you're not on Mac, or if you're interested in other installation methods the [official Postgres website](https://www.postgresql.org/download/) has installation instructions for every operating system and includes instructions for other installation methods.

Once you're done you should be able to start your Postgres server and also connect to it using the `psql` command line interface. 

## Create a database

Before we can start creating our models and writing data, we need to make sure that we have a database for our application. To do this, connect to `psql` using the following command:

```bash
psql -U postgres
```

This will connect us to the Postgres server with the default user `postgres`. If it prompts  you for a password, it should be the default password, `postgres`.

Once you're connected you should see a prompt that ends with `#` and we can issue the following SQL command:

```sql
postgres=# CREATE DATABASE Quidditch;
```

Since this database is for my Quidditch app, I'll name it `Quidditch`, just replace this with whatever name makes sense for your application.

## Connect to your database

With a database set up, it can be connected to our .NET application using Entity Framework, an object-relational mapper for the .NET ecosystem. EF will automate reading and writing data on our database, and handle table creation and modifications through the development process.

To get started with EF for Postgres, install two NuGet packages by running the following commands from a terminal in your .NET project:

```sh
dotnet add package Microsoft.EntityFrameworkCore.PostgreSQL
dotnet add package Microsoft.EntityFrameworkCore.Design
```

To interact with a database we have to create a database context to allow us to interface with the database, configure the context object to use the proper connection string, set up models and create a migration using EF that will scaffold our database. 

## 1. Database Context

To create a database context, create a class that inherits from EF's DbContext class, like so:

```cs
using Microsoft.EntityFrameworkCore;

public class QuidditchContext : DbContext
{
	public QuidditchContext(DbConextOptions<QuidditchContext> options) : base(options) { }
}
```

Then wire it into your `Program.cs` file.

```cs
// in Program.cs
var connectionString = "[Your connection string]";
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<QuidditchContext>(options => options.UseNpgsql(connectionString));
```

This way of setting a connection string isn't secure, and should only be used for testing. Make sure that you load these in via a config file!

And with these two small additions, Entity Framework can access your database server.

## 2. Set up models

The next step in configuration is defining the models that we want to persist. For my Quidditch game, since it's a simple score tracker, I really only need to capture two data models: games and teams. Instead of creating two database tables for these and setting up their columns, I can just create the model in my C# code and EF will reason out the structure of the database!

```cs
public class Team
{
	public int TeamKey { get; set; }
	public string Name { get; set; }
	public int Score { get; set; }
	public bool IsActive { get; set; }
	public DateTime CreatedDateTime { get; set; }
	public int? GameKey { get; set; }

	[JsonIgnore]
	public Game Game { get; set; }
}

public class Game
{
    public int GameKey { get; set; }
    public DateTime GameStartDateTime { get; set; }
    public DateTime? GameEndDateTime { get; set; }
    public bool IsActive { get; set; } = true;
    public bool IsFinished => GameEndDateTime != null;

    public List<Team> Teams { get; set; } = new List<Team>();
}
```

A couple of things to point out here. First, I'm using the terminology `[Entity]Key` to define my primary keys. This is *not* automatically picked up by EF. They would prefer that you use `[Entity]Id` instead. Unfortunately, I am stubborn and would have been mistyping "Key" instead of "Id" of for the whole project, so I took the extra couple of steps to define my keys and relationships. 

When I add these models to my database context in the next step, EF will use these models to set up tables and columns based on them. Not everything will be one for one though. There are two special properties here. The `Team.Game` property and the `Game.Teams` properties are called *Navigations*. 

A Navigation property models a relationship between two tables. They work by associating related models using primary and foreign keys on the models and are kept in sync by EF. 

Before these will behave as expected, we need to register these models in our `DbContext` with `DbSet` properties. This can be done as easily as adding properties to any other class, but set the type to `DbSet<[Entity]>` where `[Entity]` is the model that you want to register.

```cs
// QuidditchContext
public class QuidditchContext : DbContext
{
	public QuidditchContext(DbConextOptions<QuidditchContext> options) : base(options) { }

	public DbSet<Team> Teams { get; set; }
	public DbSet<Game> Games { get; set; }
}
```

The `DbSet<>` class comes from Entity Framework and inherits from `IEnumerable<T>`, which allows us to use LINQ (and some Entity Framework specific versions of LINQ) to access our models.

Since I decided to use a different convention for my primary and foreign keys, I have another configuring step to define the relationships between my tables. To manually define table and column relationships, override the `OnModelCreating` method in `DbContext`. The relationships that I used are below.

```cs
public class QuidditchContext : DbContext
{
	// ...
	protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
		// .HasKey tell EF what the name of the primary key should be
        modelBuilder.Entity<Team>()
            .HasKey(t => t.TeamKey);

        modelBuilder.Entity<Game>()
            .HasKey(g => g.GameKey);

		// These methods define the one-to-many relationship in
		// what looks like plain language. 
        modelBuilder.Entity<Team>()
            .HasOne(e => e.Game)
            .WithMany(e => e.Teams)
            .HasForeignKey(t => t.GameKey)
            .OnDelete(DeleteBehavior.SetNull);
        // .OnDelete can set what happens to related tables
        // when the record they reference is deleted.

		// I don't want a table to be created for this model.
        modelBuilder.Ignore<LeaderboardEntry>();
    }	
```

Even if you're not using custom naming for your properties, it is probably a good idea to override this method so that your complex relationships are explicitly set by you. This will help mitigate unexpected behavior and has the added benefit of providing some in-code documentation.

Now that configuration is done, it's time to create a database through a process called migration.
## 3. Create a migration

As you work on a project, inevitably the shape of your data will change here and there. Instead of manually updating your database tables, Entity Framework handles this through *migrations.*

Since the models are already defined in the code, Entity Framework can scaffold and re-scaffold database, throughout the lifecycle of the application. A migration can be created using the `dotnet` CLI with the following command. 

```sh
dotnet ef migrations add InitialCreate
```

With `dotnet ef` the Entity Framework-specific tools are specified, and then using the `migrations add` command a migration is created called `InitialCreate`. A migration can have any name, but it's a good idea to give it a descriptive title for when you need to roll your changes back.

To finalize the changes on our database (or "creation of" in this instance) we still have to run one more command. EF separates this process of updating the database into two steps. In the first step, a few things happen:

+ a `Migrations` directory is created in the root of your project if not already there
+ a `[TIMESTAMP]_InitialCreate.cs` file is generated, containing the steps to implement the changes to your context, and steps to walk it back if needed.
+ a `[TIMESTAMP]_InitialCreate.Designer.cs` file is generated with metadata for EF to use.
+ a `MyContextModelSnapshot.cs` file containing a current snapshot of your context model is created.

The syntax in these files is fairly easy to interpret, so it's a good idea to do a once-over of the `Up` method in the `[TIMESTAMP]_InitialCreate.cs` method so that you aren't surprised by any changes!

Now to finalize those changes and apply them to the database run the following command.

```sh
dotnet ef database update
```

This will updates the database to the most recent migration. Be careful as you do this, there is potential for data loss when running this command! Now, the database and it's tables are set up and ready for you to start querying!

## Using LINQ to access your data

To illustrate how to query a database using Entity Framework, take a look at one of the service methods that I created for my application:

```cs
public async Task<ServiceResponse<Game>> GetGameByKey(int gameKey)
{
	var game = await _context.Games
		.Include(g => g.Teams)
		.SingleAsync(g => g.GameKey == gameKey);
	if (game == null) { return ServiceResponse<Game>.Failure("..."); }
	return ServiceResponse<Game>.Success(game);
}
```

If you're familiar with LINQ syntax, then this should be familiar. 

```cs
public async Task<ServiceResponse<Game>> GetGameByKey(int gameKey)
```

First, I'm declaring a method called `GetGameByKey`, that returns a custom response object with the generic type `Game`. I just created a response class with a generic `Payload` property so that I can send back metadata along with the requested models if needed.

```cs
var game = await _context.Games
		.Include(g => g.Teams)
		.SingleAsync(g => g.GameKey == gameKey);
```

This line queries the database, translating the database record into a usable model and assigning it to a variable that we can return from the method! By default, navigation properties are not included, but using `.Include()` and specifying the navigation property includes the related navigation in the query. 

Query execution is signaled by the `.SingleAsync()` method, which works the same way as `.Single()` in LINQ. So this query, will return a only a single record where the `GameKey` column's value is equal to the `gameKey` argument passed in when this method is called.

Here's another method example:

```cs
public async Task<ServiceResponse<Game>> SetGameInactive(int gameKey)
{
	var gameResponse = await GetGameByKey(gameKey);
	if (!gameResponse.WasSuccessful) { return gameResponse; }
	var game = gameResponse.Payload;
	
	game.IsActive = false;
	_context.Games.Update(game);
	var changedRows = await _context.SaveChangesAsync();
	if (changedRows < 1) { return ServiceResponse<Game>.Failure("Failed."); }

	return ServiceResponse<Game>.Success(game);
}
```

There's a little more logic going on in this method. The goal is to find the `Game` with the matching `GameKey` and then set its `IsActive` property to `false`. The `Game` is retrieved in the same way as the first method we looked at. Once it's been accessed, then it's properties can be updated like any other class instance in C#. 

The `_context.Games.Update()` method prepares EF to send the command to the database. Unlike the first query, the execution is started by `SaveChangesAsync()`, which returns the number of affected rows. This is the EF pattern for modifying existing data. The changes are made in the code, and `SaveChanges()` or `SaveChangesAsync()` must be called. 

I hope that this shows just how simple it can be to access the data from a database using familiar C# list patterns. For a full list of methods available to Entity Framework, [check out their documentation](https://learn.microsoft.com/en-us/ef/core/querying/).

## Summary

If you made it this far, thank you for reading! I hope that you found it helpful and I wish you the best of luck in implementing EF Core into your own C# applications. 

This was a unique challenge for me. I primarily write in C# for my job, but we use a custom data access library that requires mapping our models manually. While Entity Framework has some nice quality-of-life features, I found that lose some of the flexibility gained by writing your own SQL. 

This was a very simple project, but even still, it felt like I didn't save much time by using an ORM. Rather than save time on having to write SQL, I traded that time for configuring my database and tables in C#. 

In my day job, I rely on libraries that have been provided for me, so I'm looking forward to learning how to implement database connections on my own. I don't know that I would choose to use Entity Framework again. I liked how easy it was to set up my models and navigations made implementing business logic very nice, but the configuration of relationships just wasn't as straightforward as it is in SQL. 

Regardless, it is always good to take some time to learn new technologies.

Thanks again for reading!