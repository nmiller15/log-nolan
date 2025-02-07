---
title: Anatomy of an ASP.NET MVC Template
date: 2025-02-06
summary: "What are these folders and files?"
description: "What are these folders and files?"
toc: true
readTime: true
autonumber: false
math: true
tags: [".NET", "csharp", "mvc", "beginners"]
showTags: true
hideBackToTop: false
draft: true
dev: false
---

Templates for common projects can really speed up the beginning of a project. The .NET SDK has templates for the most common types of projects, allowing you to bypass the tedious boilerplate setup and skip straight to a working app that you can quickly add your own code to. 

While this saves quite a lot of time, if you haven't used ASP.NET before, or used the MVC pattern, these templates can be intimidating. There are so many files and folders, where do you begin? 

I'll go through each of the major folders that you'll see if you create an mvc template using Visual Studio or the .NET CLI and talk a little about what it does and why it's there. By the end, you'll be able to start adding your own code into the template with confidence!

So, without further adieu, open up a terminal, run `dotnet new mvc` and follow along!

## Describing your project

Before we dive into all of the different folders that are available in this template that you're looking at, the first thing we should talk about are files that are included with every project type: the `.sln` and `.csproj` files. Without these files, your project isn't going to run. Both of these define important pieces of your project.

### Solutions are made up of projects

If you're newer to ASP.NET, the distinction between Solutions and Projects may just seem like a weird semantic difference. The first time that I created an app from a template in Visual Studio, I wasn't sure either.

Well, let there be no more confusion. A solution is a set of projects that work together and interdepend on one another. Not every project in a soltion will be referenced in every other, but in general different projects like class libraries, console apps and MVC applications can work together to create an entire solution.

### The .sln file defines your projects

You won't do much in this file, or even open it really if you're using an IDE. This file has a good amount of very difficult-to-read configuration. It's not really important that you know how to manipulate this as long as you're using something like Visual Studio or Jetbrains Rider. The main function of this file is to talk with your IDE and link all of your projects to a startup project.

### The .csproj file gives your project dependencies

The `.csproj` file, on the other hand, defines the dependencies of an individual project. Does it need a class library? How about a NuGet package? All of that good stuff can be defined right here. The syntax is somewhat similar to HTML, using matching opening and closing tags to surrond the information.

## The heart of your project

All of that is interesting and important to know, but it's not where the fun of the application lives. ASP.NET is object-oriented, meaning that its essentially made up of a bunch of classes with properties and methods. With software designed this way, we need an entry-point.

The `Program.cs` file will serve as this entry point for us. If you're familiar with C#, you will be familiar with the `Main([])` method. This is the method that will be called to start your program. This method sets up your application, server, adds middleware, and other important configurations that let all of your classes work as an application! 

### Startup.cs is where you add middleware

Most of these configurations are actually set in a different file though. The `Startup.cs` file actaully contains most of the explicit configurations for an application. The .NET runtime will call `.ConfigureServices()` which lives inside the `Startup.cs` file. 

I'm going to be honest, I still pick the wrong one about 50% of the time. The best way to remember it, though, is the the program lives in `Program.cs` and it learns about its startup configuration in `Startup.cs`. 

### You might not have a Startup.cs file

If you ran the command at the beginning of this article though, you might be looking at your project and thinking that you're missing something. Depending on the framework version that you chose when you created this template, you may only have a `Project.cs` file. And it might not even have a `Main()` method in it!

This is because of the new templates that the sdk uses. They take advantage of something called "Top-Level Statements." These allow the project to run on a much more minimal syntax, implying much of the boilerplate code for these projects. 

While it might be a little easier to point out the important bits with this syntax, when you're creating a large-scale application with 30 or more middleware components and configuration mounts, then you're going to want to separate these again. 

This use of top-level statements is also very new, so if you're working in a codebase that wasn't created yesterday, odds are, you're going to see a `Program.cs` and a `Startup.cs` file.

## Give the people what they want

A very important file in this template is the `wwwroot` folder. This is where files that are delivered directly to the client are stored. Everything else in your project will live on your server while the application is running, but as soon as someone requests the app from their computer, these files will be delivered.

This files are called *static* files. They include CSS stylesheets, Javascript, and you can even add images to be referenced from in here. Libraries for Bootstrap and jQuery are also stored in here. 
### Access static files using their pathname

Since these files are delivered to the client, you can access these files in the browser while the app is running. To make sure this works, ensure that in `Program.cs`, before your `app.Run()` call, you have mounted the middleware to use static files. Add a line that says `app.UseStaticFiles()`. 

In your wwwroot folder, create a directory named images and put a picture that you have stored on your computer there. Your directory structure should look like this.

```plaintext
wwwroot/
├── css/
├── images/
│   ├── testimage.png
├── js/
└── lib/
```

Now run your application and visit `https://localhost:{port}/images/testimage.png`. Using your folder structure as a pathname, as you might in your computer's own file system, you can access these files!

## Your Code Goes Here

Now it's time to talk about the fun stuff. Where the C# code that you write goes! In the MVC template, there are three folders generated: `Models`, `Views`, `Controllers`. These contain... well exactly what they say. I won't dig too far into exactly what the MVC pattern is here, but for a good resource check out [this article from Codecademy](https://www.codecademy.com/article/mvc). 
### Models are just C# classes

```
Models/
└── ErrorViewModel.cs
```

Starting with the Models folder, you can see that the template doesn't give us a lot. Just a file called `ErrorViewModel.cs`. If you click on it you will find a very simple C# class with properties for `RequestID` and a Boolean `ShowRequestId`.

This class is used by the simple application that is provided for you when you generate the template. The thing to notice here, is that it is a vanilla C# class. There's nothing special added here. This is just a class that can be instantiated later.

Lets say that we were creating [a movie application](https://learn.microsoft.com/en-us/aspnet/core/tutorials/first-mvc-app/start-mvc?view=aspnetcore-9.0&tabs=visual-studio). This is the folder where you would create a class for a movie that stores all of its related information: title, director, runtime, etc. This model will then be referenced by all of the places in the application that a movie object is needed.

### Views are written in HTML... sort of

```plaintext
Views/
├── Home/
│   ├── Index.cshtml
│   ├── Privacy.cshtml
├── Shared/
│   ├── _Layout.cshtml
│   ├── _ValidationScriptsPartial.cshtml
│   └── Error.cshtml
├── _ViewImports.cshtml
└── _ViewStart.cshtml
```

Like I mentioned above, the template that is generated is a working application. If you launch it, you will see that you can navigate between the home pages (called Index) and a Privacy page. You may notice that there are two files in our `Views/Home/` directory that represent these pages! Let's take a look at our Index file. (Formatted for easier reading.)

```html
@{
    ViewData["Title"] = "Home Page";
}

<div class="text-center">
    <h1 class="display-4">@ViewData["Title"]</h1>
    <p>
	    Learn about 
		    <a href="https://learn.microsoft.com/aspnet/core">
			    building Web apps with ASP.NET Core
			</a>
		.
	</p>
</div>
```


### Setup a layout for your application