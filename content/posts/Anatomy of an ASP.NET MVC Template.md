---
title: Anatomy of an ASP.NET MVC Template
date: 2025-02-06
summary: "What are these folders and files?"
description: "What are these folders and files?"
toc: true
readTime: true
autonumber: false
math: true
tags: ["dotnet", "csharp", "mvc", "beginners"]
showTags: true
hideBackToTop: false
draft: true
dev: false
---

Using a template for a common technology can speed you along the setup process of building an application. It allows you to bypass the tedious and error-prone boilerplate setup and gives you a working app that is easy to extend! If you're unfamiliar with the technology or the structure, seeing the number of files and directories that are generated for you can be daunting.

I am going to create an ASP.NET MVC app today. Well, actually just the template. But, after one command in your terminal, you will have a working application. Today, I'd like to talk about how all of these files work together to create this MVC application. We'll cover files that are specific to this template, and others that are common to all .NET applications.

So, without further adieu, open up a terminal, run `dotnet new mvc` and follow along!

## Describing your project

Before we dive into the specifics of this template, we should first talk about the files included with *every* project template: the `.sln` and `.csproj` files. Without these files, your project isn't going to run. Suffice it to say... they're important.

### Solutions are made up of projects

If you're new to .NET, you might be asking "What the heck is a solution?" I will admit that the terminology threw me a little when I started as well.

A solution is a container for a project or set of projects that work together and depend on one another. In general different projects like class libraries, console apps and MVC applications can work together to create an entire solution.

### The `.sln` file defines your projects

You probably won't look at this file or do much with it, but that doesn't mean it isn't important. It contains vital configurations for your project. Most of the manipulation of this file will be done by your IDE, not you. Just know that you cannot get rid of this file!

### The `.csproj` file sets up your project

The `.csproj` file is similar to the `.sln` file, but it defines your individual projects. What version of .NET is running? Does it depend on a class library? How about a NuGet package? All of that good stuff can be defined right here. 

Your IDE is going to do most of the manipulation of this file for you too, but this one is a bit easier to go in and poke around. The syntax is somewhat similar to HTML. You use opening and closing tags to surround the specific information that you're defining. You can read more about this file in [Microsoft's documentation](https://learn.microsoft.com/en-us/aspnet/web-forms/overview/deployment/web-deployment-in-the-enterprise/understanding-the-project-file).

## Let's get to the actual code, please

Okay, okay. I hear you. The next place that we will look is the first file that gets executed after your program is compiled, the `Program.cs` file.

### `Program.cs` is our entry point

The `Program.cs` file is the entry point of our application. This is true for all .NET applications. This file contains your `Main()` method, which sets up your application, adds middleware, mounts configurations and opens pathways to all of the other classes that you create! 

### `Startup.cs` is where you add middleware

If we keep all of that configuration in one file, it will get really long and kind of hard to maintain. This is where the `Startup.cs` file comes in handy.  This file holds a `ConfigureServices()` method which is called in `Program.cs`. We can use this to setup any configuration or middleware that we need, but isn't directly related to making our application available. We might define dependency injection configurations, specific error-handling middleware, or logging here!

When you go to make edits here, you *will* pick the wrong one. I still do it about 50% of the time.

### You might not have a `Startup.cs` file

You might be looking at your project and thinking that you're missing something....

Depending on the framework version that you chose when you created this template, you may not have a `Startup.cs` file. And when you're looking closer at `Program.cs` it doesn't have a  `Main()` method!

Some of the newer templates in the .NET SDK take advantage of "top-level statements." I won't get into the intricacies of this too much, just know that if you enable top-level statements, you will be reading a simplified syntax that removes lots of boilerplate code. 

You're never going to get confused about which file to go to, but if you're creating a large-scale application with 30 or more middleware components and configuration mounts, then you're going to want to separate these again. 

This use of top-level statements is also very new, so don't use them as an excuse to not know about the `Program.cs` and `Startup.cs` pattern, because most applications running today will still be set up like this.

## Serving web content with `wwwroot`

Now that most of our general .NET files are out the way, lets look at something specific to web applications, the `wwwroot` directory. In a web application, there are a number of files that are delivered directly to the client, and this is the folder that contains these files. 

This files are called *static* files. Static files include CSS stylesheets, Javascript, images and files from libraries like Bootstrap or jQuery. 
### Access static files using their pathname

Since these files are delivered to the client, you can access them in the browser while the app is running. 

Let's test this out. 

Go to `Program.cs` and make sure that you see `app.UseStaticFiles()` somewhere. If you don't you can add it above `app.Run()`.

In `wwwroot`, create a directory and call it `images`.  Drop an image file that you have on your computer into `images`.

When you're done, your directory structure should look like this.

```plaintext
wwwroot/
├── css/
├── images/
│   ├── testimage.png
├── js/
└── lib/
```

Now run your application and visit `https://localhost:{port}/images/testimage.png`. 

You should see the image displayed in your browser! Using the pathname, as you might in a file browser on your local computer, you can access these static files!

## Models, Views, and Controllers

```
Controllers/
└── HomeController.cs
Models/
└── ErrorViewModel.cs
Views/
├── Home/
│   ├── Index.cshtml
│   └── Privacy.cshtml
├── Shared/
│   ├── _Layout.cshtml
│   ├── _ValidationScriptsPartial.cshtml
│   └── Error.cshtml
├── _ViewImports.cshtml
└── _ViewStart.cshtml

```

In the MVC template, there are three folders generated: `Models`, `Views`, and `Controllers`. These contain... well, exactly what they say. This isn't a blog post outlining exactly what the MVC pattern is, if you're not familiar, check out [this article from Codecademy](https://www.codecademy.com/article/mvc). Microsoft also has a great tutorial for an MVC application to create a [basic movie database](https://learn.microsoft.com/en-us/aspnet/core/tutorials/first-mvc-app/start-mvc?view=aspnetcore-9.0&tabs=visual-studio).

This template provides you with a very simple application that has a Home page (called Index) and a Privacy page. If you navigate to a URL that isn't supported by the application, you be shown an Error page, populated by the `ErrorViewModel.cs` that is stored in the `Models` directory.

You will add your application views, your model library and all of your business logic between these three directories.
## Setup a layout for your application

While we aren't going to piece through each and every file here, two that you should be aware of are `_ViewStart.cshtml` and `_Layout.cshtml`. With these two files, you will create a common layout for every view in your application.

The `_ViewStart.cshtml` file...

```cs
@{
	Layout = "_Layout";
}
```

... sets the Layout property for all of the view pages. All views *start* here. The file that we've indicated for our layout, `_Layout.cshtml`, contains the HTML for our layout template.

Open up the `_Layout.cshtml` file and you'll see `<meta>` and `<title>` tags, the doctype declaration, logos, a reference to the navigation partial, all things that you don't want to have to rewrite every time you make a view for your application. 

In `_Layout.cshtml` you'll also see the `@RenderBody()` method. Wherever this method is called is where the HTML for the current view is rendered. Without this method, none of the views that you create will ever be displayed. 

## Scratching the surface

I hope that, armed with this knowledge, you are able to start hacking away at an application template! Over the next few months, keep an eye out as I dig deeper into ASP.NET and uncover more of the nuts and bolts of the technology to share with you.

Thank you for reading!

---

If you're getting value out of these posts, consider subscribing using the link below to receive these posts straight to your inbox! 

[Click here to subscribe!](https://d782b8fa.sibforms.com/serve/MUIFAK2keDpq4jw-krst9Ki0T2Asllq4pHVH7YEaci2JN2o3H1rLOXm-4H3G3lc31swK7WFMNYjoSJqaBleHxcV0vc8EEBLLxb3HK0U59_fRRDFUaj96lZyvOSE2NiYQSi1jC_0L0Tq8wj2_OcG8PFuNsL5SH65CQh_GpSOXqV3FqTJosq6tSRV2e2mw9MSXcAx7-2c_3fY-abRi)