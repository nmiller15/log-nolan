---
title: Supercharge Productivity with the .NET CLI
date: 2025-01-27
summary: "Speed up your .NET development"
description: "Speed up your .NET development"
toc: false
readTime: true
autonumber: false
math: true
tags: ["dotnet", "learning", "commandline", "Microsoft"]
showTags: true
hideBackToTop: false
draft: true
dev: false
---

To begin my learning in ASP.NET, I thought a good place to start would be the .NET command-line interface. This tool isn't restricted to ASP.NET, but it is an essential development and automation tool for .NET developers. 

## What is the .NET CLI?

The `dotnet` command-line interface (CLI) is a tool released by Microsoft as part of the .NET sdk. This tool is a series of commands that can be executed from your computer's terminal, or shell. The commands included in the CLI help developers run tests, run build servers, package apps for production, generate templated code snippets and more.

## Why would I use the .NET CLI?

When I started developing in C#, I had this question, "Why would I use the command line interface when my IDE handles all of this for me?" It's a good question. 

### Develop faster

First, I would argue that typing the command into your terminal (even the one inside Visual Studio) can save you time. Rather than going through menus to look for a command, you can type <kbd>Ctrl</kdb> + <kdb>`</kbd> in your IDE and type three words and hit enter and the code snippet, project or new file will appear. While this may seem like a small amount of time, and it might take some getting used to, small time-savers like this add up in the development workflow. 

### Break free from your IDE

A better reason to learn this CLI is so that you don't become too dependent upon one specific environment to be able to write code. While Visual Studio is an incredibly powerful and time-saving tool, we shouldn't have to rely on it for everything. Developing .NET applications does have dependencies, Visual Studio isn't one of them. 

Most importantly, you will be able to have access to all the tools that the SDK offers in production environments where you don't want the server to have to bear the weight of the IDE.

As a side note, since Microsoft discontinued Visual Studio for Mac, the CLI has become far more valuable specifically on Mac OS since its the most powerful way to use the .NET SDK.

### What's the real reason...

Okay, you caught me. It's way cooler to type something into your terminal and watch the outcome. Don't you just feel like you're a hacker in a movie? Making things more fun in the process is not a problem!

## Installing .NET CLI

Alright, I've convinced you to pull up your hood and to look like a hacker. How do you get this thing going? Well, if you have the .NET SDK installed on your computer already, then that's it, you should have access to it.

If not, you'll have to download the SDK of your choice from Microsoft.

[Click Here to download.](https://dotnet.microsoft.com/en-us/download)

Once it's installed for you, you can check to make sure that you have the CLI by opening a terminal, and typing the following command:

```powershell
dotnet --version
```

This should give you a version number output!

```powershell
#Output
9.0.100
```

And you're ready to get started!

## Best Uses for the .NET CLI

In this section, I'm going to walk you through some of the most valuable commands that I've discovered and use. Take some time to try them out on your own and work to incorporate them into your own development environment. 

### Setup

Before we start, you're going to want to set up a folder to play in. I'm calling mine `dotnet-sandbox` but you can call yours whatever you want. The following commands will work on Mac, Windows and Linux. 

Open your terminal and make note of the directory you are in (this is typically your User directory). If you're not in your user directory, you can quickly navigate there with the command `cd ~`. Then create a folder and change directories into it

```powershell
mkdir dotnet-sandbox
cd dotnet-sandbox
```

### Getting help

Perhaps the *most* useful command of the .NET cli is the following:

```powershell
dotnet -?
# or
dotnet --help
```

This outputs a list of the possible commands with a brief description of what they do! So, if you are in the moment, and you forget a certain command, you can always run this to jog your memory. 

This flag, `-?` or `--help` can be run after any of the following `dotnet` commands to get more information about them right in your terminal!
### Creating apps from .NET templates

If you're familiar with Visual Studio, then you know that one of the ways that you can start a project is by selecting a template. This will set up all of the necessary, or boilerplate, code and files for you. For a console app you'll get a working "Hello World!", for an api you'll get a working endpoint and for an MVC app you'll get a controller with some options about weather!

The GUI in Visual Studio isn't the only way to generate these templates. You can also run this from right in your terminal. This comes in handy when you're working on an extensive solution that is many projects. Knowing this command can save you some development time. 

It's a very simple command:

```powershell
dotnet new [template-name]
```

That's it, the template will be created! 

Until you know the names of all of the templates that you'll use, you'll probably want to use this command as reference:

```powershell
dotnet new list
```

This will output a chart containing all of the possible projects that can be created using `dotnet new`. 

#### Give your projects a name

A very important flag for this command is `-n`. This flag, followed by a string will allow you to name the project before its generated. This will change the names of some of the files, and it also changes the directory that the CLI operates in. If no name is passed in, then the CLI will add all of the templated files to the current working directory. But, if you pass in a name, it will create a directory with that name and put all of the files in there. 

For the sake of the cleanliness of your repositories, you should do one of two things. Either, create a directory, and move into it before you create an application template...

```powershell
mkdir MyConsoleApp
cd \MyConsoleApp
dotnet new console
```

... or, you should pass it the name flag

```powershell
dotnet new console -n MyConsoleApp
```

Both of these examples will yield the same results!
### Use .NET snippets

If you've been following along in your own terminal, you probably saw just how many options were available when you ran `dotnet new list`. That's because the `dotnet new` command can be used for more than just creating new project templates, you can also insert snippets, which are smaller templates designed to be used within certain projects!

For example, lets assume that you've created an MVC app and you're ready to add another controller for a model. You can `cd` into your Controllers directory and run...

```powershell
dotnet new mvccontroller -n "NewController"
```

...to produce the following file:

```csharp
// NewController.cs
namespace MyApp.Namespace
{
    public class NewController : Controller
    {
        // GET: NewController
        public ActionResult Index()
        {
            return View();
        }
    }
}
```

You can try the same process with your Razor Views, Razor Pages, ViewImports file, ViewStart file, .gitignore and more!
### Test your apps

If you're running your tests with the VSTest framework you can run...

```powershell
dotnet test
```

...to run your entire test suite! It's faster than launching your Test Explorer if you're doing a quick check before a commit!

### Add packages to your app

Yes, yes, the Nuget package manager is very nice, but we're optimizing for speed! Do you already know the name of the package that you're trying to install? 

```powershell
dotnet add package EntityFramework
```

You can do this on the PM Console as well, but if you're already using your Developer Console, then you might as well not switch! 
### BONUS:

A few other commands that I've liked using!

+ `dotnet format whitespace` - Avoid a "blank line" comment on your next code review by running this command!
+ `dotnet build` - Verify that your project builds without touching your mouse!
+ `dotnet pack` - With a few other configurations, turn your project into a NuGet package.
+ `dotnet remove` - Specify a package that you accidentally added to get rid of it!
+ `dotnet watch` - Specify a file to enable hot reloads on file changes! Make your frontend work way less tedious!
+ `dotnet publish` - Bundle your project for distribution! Outputs to the `/bin` directory.

## Have I Convinced You Yet? 

The .NET CLI is quite powerful (and has the potential to make you feel like a 10X dev wizard). Take a few of these commands with you the next time you're working on a project. It will probably take some time and intentionality to start using them regularly, but if you do, you'll be free of your mouse in no time. 😉

This lesson is part of my long-term effort to learn ASP.NET. If you want to see the resources that I'm using, check out my post, [Learn ASP.NET From Scratch](https://nolanmiller.me/posts/learn-asp.net-core-from-scratch/). 

Consider getting these posts straight to your inbox using the form below!

