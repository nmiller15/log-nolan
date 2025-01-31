---
title: Supercharge Your Productivity with the .NET CLI
date: 2025-01-28
summary: "Speed up your .NET development"
description: "Speed up your .NET development"
toc: false
readTime: true
autonumber: false
math: true
tags: ["dotnet", "learning", "commandline", "Microsoft"]
showTags: true
hideBackToTop: false
draft: false
dev: false
---

I figured a good place to start [my ASP.NET journey](https://nolanmiller.me/posts/learn-asp.net-core-from-scratch/) was the .NET CLI. The tool isn't ASP.NET specific, rather it is an essential development and automation tool for the entire .NET landscape. 

## What is the .NET CLI?

The `dotnet` command-line interface (CLI) is a Microsoft tool that's part of the .NET SDK. It is a series of commands that can be executed from your computer's terminal, or shell. The commands included in the CLI help developers run tests, run build servers, package apps for production, generate templated code snippets and more.

## Why would I use the .NET CLI?

When I started developing in C#, I asked, **"Why would I use the command line interface when my IDE handles all of this for me?"** I hope that if you have the same question, that I can answer it for you today.

### Develop faster

First, typing the command into your terminal can *save you time*. Rather than going through menus to look for a command, you can type <kbd>Ctrl</kdb> + <kdb>`</kbd> in your IDE, type three words and hit enter. The code snippet will appear, tests will run, whatever you need to happen. This may take a bit of time to get used to, but the accumulation of these small bits of time will add up over hours, days, and weeks.

### Break free from your IDE

A better reason to learn this CLI is to break your dependence upon your development environment. Visual Studio is an incredibly powerful and time-saving tool, but that doesn't mean have to rely on it. 

Developing using .NET has dependencies, Visual Studio isn't one of them. 

With the CLI, you have access to all the tools that the SDK offers in development *and* production environments. This allows you to make quick additions, run tests, or a quick build in environments that don't have Visual Studio involved. Knowing the CLI well can also assist in creating automation for CI/CD processes.

As a side note, since Microsoft discontinued Visual Studio for Mac, the CLI has become almost necessary on Mac OS.

### What's the real reason...

Okay, you caught me. It's way cooler to type something into your terminal and watch the outcome. Don't you just feel like you're a hacker in a movie? Making your development process more fun is a good thing!

## Installing .NET CLI

Alright, have I convinced you? Let's get started by installing what we need.

If you have the .NET SDK installed on your computer already, then that's it, you should have access already.

If not, you'll have to [download the SDK of your choice](https://dotnet.microsoft.com/en-us/download) from Microsoft.

Once it's installed for you, you can check to make sure that you have the CLI by opening a terminal, and typing the following command:

```powershell
dotnet --version

#Output
9.0.100
```

This should give you a version number output, and you know you're ready to get started.

## Best Uses for the .NET CLI

Here are the most valuable commands that I've discovered and *actually use*. Take some time to try them out on your own and work to incorporate them into your own development environment. 

### Setup

Before we start, create a folder that we can play in. I'm calling mine `dotnet-sandbox` but you can call yours whatever you want. The following commands will work on Mac, Windows and Linux. 

Open your terminal and make note of the directory you are in (this is typically your User directory). If you're not in your user directory, you can quickly navigate there with the command `cd ~`. Then create a folder and change directories into it.

```powershell
mkdir dotnet-sandbox
cd dotnet-sandbox
```

### Getting help

The first and perhaps *most useful* command of the .NET cli is the following:

```powershell
dotnet -?
# or
dotnet --help
```

This outputs a list of the possible commands with a brief description of what they do. So, when you forget a command, just run this. 

The flag, `-?` or `--help` can be run after any of the following `dotnet` commands to get more information about them right in your terminal!
### Creating apps from .NET templates

Visual Studio, lets you start a projects by selecting a template to build off of, but the GUI in isn't the only way to generate these templates. 

Run this command to create a console application template

```powershell
dotnet new console
```

You can create any of the provided templates with this command, provided that you have the short name of the template. Until you know the names of all of the templates that you'll use, you can use this command to list all of the possible short names.

```powershell
dotnet new list
```

#### Give your projects a name

I hardly ever use the `dotnet new` command without the `-n` flag. Follow this flag with a string and you can give a name to your project. This name will be used for the namespace, the class name or the directory of your project, depending on the template that you use.

I recommend always giving a name to these templates. Adding the `-n` flag results in project templates being created inside their own directory. Without the flag, the CLI dumps all of the template files into your current working directory, which has burned me before.

To illustrate the power of the `-n` flag, here's an example of two command sequences that do the exact same thing.

```powershell
mkdir MyConsoleApp
cd \MyConsoleApp
dotnet new console
```

```powershell
dotnet new console -n MyConsoleApp
```

One of these is much quicker to type if you get in the habit of it.
### Use .NET snippets

If you've been following along in your own terminal, you saw how many options were available when you ran `dotnet new list`. The `dotnet new` command can be used for more than creating new project templates.  It will also insert snippets, smaller templates designed to be used within projects!

For example, in your `dotnet-sandbox` directory, create a new MVC app and `cd` into it.

```powershell
dotnet new mvc -n SampleMVC
cd SampleMVC
```

You'll have a working MVC app. But, now we can extend it easily using `dotnet new`.

```powershell
cd Controllers
dotnet new mvccontroller -n "NewController"
```

And we will get the following file in the Controllers directory.

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

You can use the same process to create Razor Views, Razor Pages, ViewImports file, ViewStart file, .gitignore and others.
### Test your apps

If you're running your tests with the VSTest framework you can run...

```powershell
dotnet test
```

...to run your entire test suite! It's faster than launching your Test Explorer if you're doing a quick check before a commit!

You can also use your `dotnet new` command to create test projects and items!

### Add packages to your app

Yes, yes, the Nuget package manager is very nice, but we're optimizing for speed! Do you already know the name of the package that you're trying to install? 

```powershell
dotnet add package EntityFramework
```

You can do this on the PM Console as well, but if you're already using your Developer Console, then you might as well not switch! 
### BONUS commands!

A few other commands that I've liked using!

+ `dotnet format whitespace` - Avoid a "blank line" comment on your next code review by running this command!
+ `dotnet build` - Verify that your project builds without touching your mouse!
+ `dotnet pack` - With a few other configurations, turn your project into a NuGet package.
+ `dotnet remove` - Specify a package that you accidentally added to get rid of it!
+ `dotnet watch` - Specify a file to enable hot reloads on file changes! Make your frontend work way less tedious!
+ `dotnet publish` - Bundle your project for distribution! Outputs to the `/bin` directory.

## Have I convinced you yet? 

The .NET CLI is quite powerful (and has the potential to make you feel like a 10X dev wizard). Take a few of these commands with you the next time you're working on a project. It will probably take some time and intentionality to start using them regularly, but if you do, you'll be free of your mouse in no time. 😉

This lesson is part of my long-term effort to learn ASP.NET. If you want to see the resources that I'm using, check out my post, [Learn ASP.NET From Scratch](https://nolanmiller.me/posts/learn-asp.net-core-from-scratch/). 

Consider getting these posts straight to your inbox using the form or clicking the link below!

[Get these blog posts in your email inbox!](https://d782b8fa.sibforms.com/serve/MUIFAK2keDpq4jw-krst9Ki0T2Asllq4pHVH7YEaci2JN2o3H1rLOXm-4H3G3lc31swK7WFMNYjoSJqaBleHxcV0vc8EEBLLxb3HK0U59_fRRDFUaj96lZyvOSE2NiYQSi1jC_0L0Tq8wj2_OcG8PFuNsL5SH65CQh_GpSOXqV3FqTJosq6tSRV2e2mw9MSXcAx7-2c_3fY-abRi)