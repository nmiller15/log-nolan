---
title: Learn Application Configuration in ASP.NET
date: 2025-03-24
summary: Creating a configurable music player.
description: Creating a configurable music player.
toc: false
readTime: true
autonumber: false
math: true
tags: ["dotnet", "learning", "asp", "configuration"]
showTags: true
hideBackToTop: false
draft: false
dev: true
dev_id: 2353588
---
As a self-taught developer, a part of software development that I didn't know much about when I started my first development job was configuration.

When I was building solo projects, it was hard to see the value in loading configurations rather than just hard coding. *Why would I introduce complexity?* *It would take time learn how to load them in.* *Maybe I'll learn how to do it later, but that's just a waste of time.*  

I knew that these thoughts weren't true, but the excuses kept me from learning. As I got some experience with larger codebases, however, I started seeing the clear need for configuration objects. We have to able to change specific behaviors of our application without releasing. This is what enables us to connect one release of an application to different databases or APIs, to change features for development or production, and make many other important changes. 

If you follow along with this article, we will create a basic console application that shuffles through the titles of songs to demonstrate how to load values into a configuration object and access them to change functionality in .NET.

## Let's create a music player!

Okay... only sort of. Unfortunately, we won't be sending anything to your speakers. For the purpose of learning how to load and use configurations within ASP.NET, I created a console application called SongShuffle! 

To follow along with the sections in this article, go ahead and clone the GitHub repo by running the `git clone` command below in your console.

```sh
git clone https://github.com/nmiller15/SongShuffle/
```

I've created branches to guide you through the codebase in this article, at any point you can checkout the branches and arrive at a working application at a different step! I encourage you to experiment and load some of your own configurations and functionality here though!

To make sure you're on the correct branch, run the following in your console.

```sh
git checkout 1-start
```

### A tour of our music player

If you launch the SongShuffle console application by clicking Run/Debug, or using `dotnet run` in the project directory, you will see a modest user command line interface that asks you to press any key to start listening. 

The song screen shows the title, artist and year of the current song's release at the top of the screen and will allow you to select a new song by pressing enter. If you type in `q` before pressing enter, the program will exit. 

![SongShuffle Interface](https://nolanmiller-image-hosting.s3.amazonaws.com/SongShuffle+Interface.png)

This is the basic function of the music player that we will configure. Go ahead and play around with it!

Take some time to familiarize yourself with the classes that we have here that create the behavior for this application: `Song.cs` and `SongProvider`. 

If you're digging around in the song bank in the `SongProvider`, you might notice that we only have 80s music loaded into the application. While this might be all that I play, others might want their music player to be a bit more versatile, so this is going to be the first configurable feature that we are going to add to the music player.

## Configuring for the 90s groove

To add this feature, we have to add another song bank and a way to select those banks. To see my implementation, run the following command in your console.

```sh
git checkout 2-pick-a-decade
```

Most of our changes are in the `SongProvider` class. I've added three more song banks, containing music from different decades. I've created an Enum `Decades` that will select the song set for the `SongBank`. And I've added a switch statement in the `SongPovider` constructor, that sets the `SongBank` property.

With these changes the `SongProvider` is able to change its selection of songs without having to alter it's implementation details. We've now moved control of the song bank selection outside of the provider. That means that we'll have to define our Enum to pass in before we can instantiate our `SongProvider`.

```cs
// SongProvider.cs
public SongProvider(Decades decade)
{
    switch (decade)
    {
        case Decades.Eighties:
            SongBank = EightiesSongs; break;
        case Decades.Nineties:
            SongBank = NinetiesSongs; break;
        case Decades.TwoThousands:
            SongBank = TwoThousandsSongs; break;
        case Decades.TwentyTens:
            SongBank = TwoThousandTensSongs; break;
        default:
            throw new ArgumentException("Must include a valid decade.");
    }
}

// Program.cs
public static void DisplaySong()
{
	var userResponse = string.Empty;
	var decade = SongProvider.Decades.Nineties;

	var provider = new SongProvider(decade);

	// ... 
}
```

And now we can rock out to some Madonna!

![SongShuffle Hard Coded Nineties Music](https://nolanmiller-image-hosting.s3.amazonaws.com/SongShuffle+Hard+Coded+Nineties+Music.png)

If we wanted to change the decade we can do that a bit more easily now, but its still a developer task. Someone without any code experience would have issues working with this. We'd have to go in, change the value of the `Decades` Enum. Then, we'd also have to create a release and push it. 

Man... That's a lot of work for a small feature.

 So, we've moved the song bank selection out of the `SongProvider` but, what if we pull it out of the application itself. This would keep us from having to deal with this release issue.

## Loading our first configuration

Checkout the next branch to see how we can load values into our .NET program from external files.

```sh
git checkout 3-config-from-json
```

The first thing I'd like to point out is the `LoadConfig()` method that I've created which has a fairly straightforward goal.... to load the configuration. But, how is this handled in .NET?

```cs
static void Main(string[] args)
{
	var config = LoadConfig()
	Welcome();
	DisplaySong(config);
}
```

### The configuration interface

Microsoft has an `IConfiguration` interface built into the framework. The interface allows us to attach key-value pairs from multiple sources and then access them later. These values are what we will use to configure parts of our application.

The `LoadConfig()` method that I created, just returns an instance of `IConfiguration` loaded with our configuration values. The configuration object that is returned by this method will be passed around our application with values being accessed and determining app behavior.

### Accessing values from a config object

There are a few ways that we can use to access these values. First, is using the Indexer syntax, borrowed from the dictionary.

```cs
var value = configuration["KeyName"];
```

This is the way that we will access them throughout this article, but also know that .NET provides other ways to access complex configuration objects using methods like `.GetSection()` and `.Bind()`. If you'd like more information on those, [check out this article from Microsoft's documentation](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/configuration/?view=aspnetcore-9.0#bind-hierarchical-configuration-data-using-the-options-pattern).

### Registering key-value pairs to a config object

The most common way to register key-value pairs is through an `appsettings.json` file. This is a file that contains a valid JSON object that sits at the root level of your project. 

>**Note:** It is common for `appsettings.json` to be checked into source control, so do *not* store sensitive data like API keys or connection strings here.

In our example `appsettings.json`, we have a simple JSON object that defines a "Decade" key.

```json
{
  "Decade": "TwoThousands"
}
```

Now, to add this file to our configuration object, we need to use the built-in `ConfigurationBuilder` and use the `AddJsonFile` method. Pass the relative path of the JSON file that you want to add to register the key-value pairs inside it.

```cs

public static IConfiguration LoadConfig()
{
	var builder = new ConfigurationBuilder()
		.AddJsonFile("appsettings.json");
	return builder.Build();
}
```

When we run `LoadConfig()` any values that we have in our `appsettings.json` file will be accessible within our application in our `IConfiguration` object!

### Using our configuration object in the application

To actually make use of this `IConfiguration` object, we have to pass it into our `DisplaySong` method. You can take a look at the necessary changes below.

```cs

public static void DisplaySong(IConfiguration config)
{
	var userResponse = string.Empty;
	
	var decade = config["Decade"] switch
	{
	    "Nineties" => SongProvider.Decades.Nineties,
	    "TwoThousands" => SongProvider.Decades.TwoThousands,
	    "TwentyTens" => SongProvider.Decades.TwentyTens,
	    _ => SongProvider.Decades.Eighties
	};
	
	var provider = new SongProvider(decade);
}
```

With this method, the selection of the decade is decoupled from the logic that displays the song. The selection of the decade is being set outside of our application.

> **If this isn't working for you...**
> 
> Try the following steps if the configuration isn't loading for you.
> 
>+ Right click on `appsettings.json` in Visual Studio. 
>+ Properties > Copy To Output Directory. Make sure it is set to "Copy Always".
> 
> **What did I just do?**
> 
> Your application runs from the `/bin/Debug/netX.X` directory when you run your application in Debug mode. When Visual Studio tries to compile and run your project, it's looking for the `appsettings.json` file relative to the file that it complied (in the `bin`). 
> 
> By setting the "Copy Always", whenever we click "Debug" our `appsettings.json` will be copied into `/bin/Debug/netX.X` so that we can access it in our program.

While we don't have to release another version of the application to change this behavior, it's still a little bit involved. We still have to find the right text file and change the correct value to get this to happen. Now let's explore how we can change the behavior of our application without having to edit any additional files!

## Passing command-line arguments

With only a few changes to our application, we can take in strings from outside the application by allowing command line arguments. Run the following command to see the changes.

```sh
git checkout 4-config-from-commandline
```

You may not notice the change at first because it's so small, but there is one. We've added one line which calls the `.AddCommandLine(args)` to the `ConfigurationBuilder`.

```cs
public static IConfiguration LoadConfig(string[] args)
{
	var builder = new ConfigurationBuilder()
		.AddJsonFile("appsettings.json")
		.AddCommandLine(args);
	return builder.Build();
}
```

By chaining this to the `.AddJsonFile()` method, we're adding all the values from both to our configuration object.

Command line arguments are key-value pairs declared after the execution command. To attach a key-value pair you would run the program like this:

```sh
dotnet run --Decade "TwentyTens"
```

The key `"Decade"` would then be passed into the program with the value `"TwentyTens"`. Luckily, we don't have to type these arguments into the program every time we want to Debug our program.

In order to add a command line argument to your Debug profile, first, right-click your project and click *Properties*. 

In that window, select *Debug* from the sidebar, and click *Launch Profiles UI*. After you click this, you will see the following UI window. Under *Command line arguments* you can type in anything you like.

![Visual Studio Command Line Arguments For Debug](https://nolanmiller-image-hosting.s3.amazonaws.com/Visual+Studio+Command+Line+Arguments+For+Debug.png)

Command line arguments can be passed in four different syntaxes.
+ `[command] --key value`
+ `[command] --key=value`
+ `[command] /key value`
+ `[command] /key=value`

I'm not sure what the advantage of having these different syntaxes is, but I prefer the first, since it is the most common way that I've seen arguments passed.

### Didn't we just pass `"Decade"` twice?

If never removed our `appsettings.json` file, it's still being loaded into the configuration with a `Decade` key, meaning that the `"Decade"` key was loaded twice. 
 
Our `ConfigurationBuilder` doesn't handle key collisions. It doesn't check to see if a key has already been assigned before binding a value to it. 

What does this mean? 

If you have two configuration files or methods that assign the same key, the key that was loaded earlier will be overwritten by the one loaded later. 

If you go back to the `appsettings.json` file, you'll see that we still have a `"TwoThousands"` value there. That value was successfully loaded, but immediately after that, our command line argument with the same key overwrote it with its value `"TwentyTens"`. In our final configuration object, the key `"Decade"` will have the value of the command line argument.

This behavior allows us to keep configuration files that are subsets of other configuration files. Take for example an application that uses a different API in production and development. We can create a config file that only have the values that we need to overwrite, like a API key and endpoint that is only loaded in development.

```cs
var builder = new ConfigurationBuilder();
builder.AddJsonFile("appsettings.json");
if (env.IsDevelopment())
{
	builder.AddJsonFile("appsettings.development.json");
}
return builder.Build();
```

If you're going to use this approach, make sure to be mindful of the order that you add your files and configuration sources in. There are no priority rules, so keys will *always* be overwritten load methods later in the chain.

## Environmental influence

There may by instances in which multiple applications will all share the same configuration values if they're running in the same environment. In that case, we can also load these into our program. Run the following command to see the changes that we make:

```sh
git checkout 5-environment-variables
```

Just like the above methods, environment variables will be added as key-value pairs . It goes beyond the scope of this article to talk about how to set these on various systems, but I'll show you how you can set them in Visual Studio for development. 

If you open up the *Launch Profiles UI* that we accessed to set our command line variables (*Properties* > *Debug* > *Launch Profiles*), you can also set environment variables!

![Visual Studio Launch Profiles Environment Variables](https://nolanmiller-image-hosting.s3.amazonaws.com/Visual+Studio+Launch+Profiles+Environment+Variables.png)

Since we already have sources defining our decade, let's use a new variable `ShowImage` that we will use to decide whether or not you see my beautiful ASCII rendering of an iPod. 

In the *Environment Variables* section, under "Name", write "ShowImage", and for it's value, type "false". 

Now to access these when we run our code, all we need to do is add the `.AddEnvironmentVariables()` method to our `ConfigurationBuilder`. 

```cs
public static IConfiguration LoadConfig(string[] args)
{
	var builder = new ConfigurationBuilder()
	    .AddJsonFile("appsettings.json")
	    .AddCommandLine(args)
	    .AddEnvironmentVariables();
	return builder.Build();
}
```

All we have to do to get this configuration up and running is to use our Boolean conversion in an `if` statement and put our image inside it. 

```cs
public static void DisplaySong(IConfiguration config)
{
	// Additional setup ommitted for space

	while (userResponse != "q")
	{
		song = provider.ShuffleSelect();

		Console.Clear();
		Console.WriteLine();
		Console.WriteLine($"Now playing {song.ToString()}");
		Console.WriteLine();

		if (config["ShowImage"]?.ToLower() == "true")
		{
			Console.WriteLine(@"
				╔═══╗
				║███║
				║(O)║♫ ♪ ♫ ♪
				╚═══╝
			▄ █ ▄ █ ▄ ▄ █ ▄ █ ▄ █
			");
		}

		// ...
	}
}
```

Now, our iPod will only be displayed if the configuration is set to "true". 

![SongShuffle ShowImage false](https://nolanmiller-image-hosting.s3.amazonaws.com/SongShuffle+ShowImage+false.png)

But, I like to see my ASCII masterpiece while I'm "listening" to music, so I'm going to change this configuration back!

>It's worth noting here that this is a fairly atypical usage of environment variables. Since both environment variables and command line arguments come in as strings, it isn't wise to use them as Booleans or integers or any other type unless you're parsing or validating them into another object.

Let's add one more configuration to this application, I'd like to make the songs play automatically, but again, I don't want to have to change any code. I could add another configuration in a JSON file or any of the other methods that we've discussed, but I want to show you how to do this with a .NET-specific solution, User Secrets.

## Setting up User Secrets in .NET

See the code changes to accept user secrets by running the following command, but keep it open, we'll have a few more to run to make sure that we're all set up.

```sh
git checkout 6-user-secrets
```

User Secrets is a Microsoft-created, development-only solution for storing sensitive strings outside of source control. It's built right into the .NET SDK and makes loading sensitive information into your application very simple for development.

You do **not** want to use this in production because this offers no encryption for your sensitive information, you would be better off using some sort of secrets manager. 

### How does User Secrets work?

User Secrets is very similar to adding a JSON file to your application. We will create a file with key-value pairs and tell the framework where to look for the file. 

We identify the file using the `<UserSecretsId>` tag with a Guid value in our .csproj file. Then in our `%AppData%\Microsoft\UserSecrets\{project-guid}` we can store our secrets in a file called `secrets.json`. 

Don't worry though, you don't have to set this up manually.

### Setting up User Secrets

Using the .NET CLI, all we have to do is run one command to get set up.

```sh
dotnet user-secrets init
```

When you run this command a few things happen: 
+ an ID is created
+ the ID is saved to your .csproj file in a `<UserSecretsId>` tag
+ a directory named for the ID is created
+ a `secrets.json` file is created

The CLI also provides us a method of adding values to our `secrets.json` file without having to dig through our user directory.

```sh
dotnet user-secrets set {key} {value}
```

### Using User Secrets to auto-play our songs 

In our `LoadConfig` method, we only have to add one line to bind our user secrets.

```cs
public static IConfiguration LoadConfig(string[] args)
{
    var builder = new ConfigurationBuilder()
        .AddJsonFile("appsettings.json")
        .AddCommandLine(args)
        .AddEnvironmentVariables()
        .AddUserSecrets<Program>();
    return builder.Build();
}
```

We also have to add a little logic to our `DisplaySong` method to create our auto-play behavior. 

```cs
public static void DisplaySong(IConfiguration config)
{
	var userResponse = string.Empty;
	var counter = 0;

	var decade = config["Decade"] switch
	{
		"Nineties" => SongProvider.Decades.Nineties,
		"TwoThousands" => SongProvider.Decades.TwoThousands,
		"TwentyTens" => SongProvider.Decades.TwentyTens,
		_ => SongProvider.Decades.Eighties
	};

	while (userResponse != "q")
	{
	// ... existing logic remains unchanged ... after 

		if (counter == 4)
		{
			Console.WriteLine("You've listened to 5 songs! Want to keep going?");
			Console.WriteLine("(Type q to quit.)");
			userResponse = Console.ReadLine()?.ToLower();
			counter = 0;
		}
		if (config["Autoplay"]?.ToLower() == "true")
		{
			Thread.Sleep(2000);
			counter++;
		}
		else
		{
			userResponse = Console.ReadLine()?.ToLower();
		}
	}
}
```

> These variables also come in as strings, so they carry the same warning as environment variables did above.

### Adding the `"Autoplay"` key

Run the following command to write the `"Autoplay"` key to our `secrets.json` file.

```sh
dotnet user-secrets set "Autoplay" "true"
```

We can quickly check what keys are accessible in our `secrets.json` by running the following command:

```sh 
dotnet user-secrets list
```

Oh no! Did you verify and see that you misspelled something? That's okay, we can remove the key using:

```sh
dotnet user-secrets remove {key}
```

... or, we can clear out all the keys by using:

```sh
dotnet user-secrets clear
```

... and you can add the key again to correct any misspellings.

And we're done! If we start up our application, now, a new song will appear on the screen every two seconds until 5 consecutive songs have played!

## Misusing configurations

As I previously stated in some asides, this is a wild misuse of the `ConfigurationBuilder`, but I believe it demonstrates the ways in which you can pass data from different sources into your application.

So, if this is wrong, what is the right way to use a configuration object? 

The most common use-cases for configurations are storing connection strings for databases, external API keys for authentication, setting logging behaviors, to turn on and off features, and configuring environment-specific variables. 

While we may not be using it to select the specific decade of music that you're listening to, you no longer have to look at your `Program.cs` file and wonder how these values are making their way into the projects that you work on. 

## Using configurations on your own

In your next project, give the `ConfigurationBuilder` a try! A good time to think about this is in the deployment phase of your next personal project. 

What are the lines of code that you're changing because you're about to load the application on another machine? These are great candidates to load into an `IConfiguraiton` object!

___
If you're getting value out of these posts, consider subscribing using the link below to receive these posts straight to your inbox! 

[Click here to subscribe!](https://d782b8fa.sibforms.com/serve/MUIFAK2keDpq4jw-krst9Ki0T2Asllq4pHVH7YEaci2JN2o3H1rLOXm-4H3G3lc31swK7WFMNYjoSJqaBleHxcV0vc8EEBLLxb3HK0U59_fRRDFUaj96lZyvOSE2NiYQSi1jC_0L0Tq8wj2_OcG8PFuNsL5SH65CQh_GpSOXqV3FqTJosq6tSRV2e2mw9MSXcAx7-2c_3fY-abRi)