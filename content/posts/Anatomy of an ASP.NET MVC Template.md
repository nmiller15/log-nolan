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

If you're newer to ASP.NET, the distinction between Solutions and Projects may just seem like a weird semantic difference. The first time that I went through the UI on the 

### The .sln file defines your projects

### The .csproj file gives your project dependencies


## The heart of your project


### Startup.cs is where you add middleware

### You might not have a Startup.cs file


## Give the people what they want

### Access static files using their pathname


## Your Code Goes Here

### Models are just C# classes

### Views are written in HTML... sort of

### Setup a layout for your application