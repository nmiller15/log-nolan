---
title: Intro to .NET APIs for a JavaScript Developer
date: 2025-04-04
summary: "An intro to Minimal APIs"
description: "An intro to Minimal APIs"
toc: false
readTime: true
autonumber: false
math: true
tags: ["javascript", "dotnet", "api", "learning"]
showTags: true
hideBackToTop: false
draft: true
dev: false
---
When I was applying like crazy to developer jobs, I'd scroll past so many .NET focused ones, thinking, "I'm only a JavaScript developer." 

I felt lied to. 

The internet told me "JavaScript can do it all," but, I felt like the skills that I'd learned would never land me a job. When I *did* find a primarily JavaScript job, it always had so many applicants that I felt like I didn't have a chance.

As of October 2024, JavaScript was still the second most used language on GitHub (though it was just over taken by Python). Check out this [blog post from GitHub](https://github.blog/news-insights/octoverse/octoverse-2024/). But even though there's so much JavaScript code, that doesn't mean that the job market for it is thriving. 

In my experience, the jobs with a .NET focus on job boards were:
1. ... looking for more experience, but appeared to be more flexible.
2. ... were paying higher starting salaries, and
3. ... not attracting very many applicants AT ALL.

JavaScript's reputation for being easy to learn, means that WAY MORE people know it, paradoxically requiring you to be even more experienced to compete in the job market.

## I just started programming, I can't code in C\#!

The first time I looked at C#, it was intimidating. Sure, it uses curly braces, but the boilerplate code is deeply nested, I don't know any of the libraries available, and EVERYTHING IS IN PASCAL CASE. 

The .NET ecosystem is a mature, reliable framework used to develop stable applications in many environments, but it can feel pretty unapproachable to newbies. 

But, C# has a template that will feel very familiar to an intermediate JavaScript developer. A starting place, where you can begin to create useful apps and also begin to wrap your mind around the syntax and features of C# in ASP.NET.

## An unconventional starting point

Start with a simple API. To be more specific, use the Minimal API template. The MVC model, especially when you're starting out, can be overwhelming. So, why start with an API? Because it's a simple way to integrate .NET into something that you're already working on. Have a React application? Well then let it consume your ASP.NET Minimal API as the backend.

You'll probably be surprised that the things you learned as a JavaScript developer (especially if you're using Express.js to build your APIs), will have strong carry over into the .NET ecosystem.

So, let's get up to speed on what a Minimal API even is, and then I'll walk you through how to get your own Minimal API up and running by the end of this post!

### What Are Minimal APIs?

With .NET 6, Microsoft released Minimal APIs. This is opposed to the Controller-based API pattern that is common in .NET. Minimal APIs is that remove a lot of unnecessary boilerplate code that you need to create endpoint routes in a controller-based APIs. 

Here's why this is good news for Javascript developers looking to get into .NET. The removal of this boilerplate code makes the syntax look *very similar* to the syntax used to build an API on Node with Express.js.

### Side-by-Side Comparison: Express.js vs. Minimal APIs

To show you how approachable this can be, I'm going to create a GET and POST route and point out the similarities between the C# Minimal API version and the Express.js version

So let's set up the .NET Minimal API first.

```cs
// set up api
using Microsoft.AspNetCore.Mvc;

namespace MinimalAPI
{
	public class Program
	{
		public static void Main(string[] args)
		{
			var builder = WebApplication.CreateBuilder(args);
			var app = builder.Build();

			// ... add endpoints and middleware here
			
			Console.WriteLine("Server is running on port 3000.");
			app.Run("http://localhost:3000");
		}
	}
}
```

If this syntax is new to you, let me walk you through it. We're first referencing the `Microsoft.AspNetCore.Mvc` which contains the Builder class that we will use to construct our application. We call the `build()` method on the builder and then `run` our application while specifying the port.

Now, to set up the same application on Node in Express.js we would write the following.

```js
// set up express app
const express = require('express');

const app = express();

// ... add endpoints and middleware here

app.listen(3000, () => {
	console.log("Server is running on port 3000");
})
```

Notice how similar. We `require` Express, which abstracts our builder logic. Then we run the application, specifying the port!

==The similarities get more stark wh==en we begin to look at how endpoints are created. This is where the biggest difference between Controller-Based and Minimal APIs is. Instead of creating a controller method, we will just use a Map*Verb* method on our application.

```cs
app.MapGet("/", (HttpRequest request, HttpResponse response) =>
{
	return "Hello World";
});
```

If you're already an Express developer, this is is looking pretty familiar. Here's how we could create the same route in Express.

```js
app.get("/", (req, res) => {
	res.send("Hello World");
})
```

The two-argument syntax is very similar. In both the Minimal API and the Express API, we pass the endpoint route as the first parameters, and the callback function as the second. 

However, our C# Minimal API is *more flexible* than the Express one. In Express, we *must* take in the request and response objects (and a third callback function which continues the chain). But, with a minimal API, it would be equally valid to write:

```cs
app.MapGet("/" => "Hello World");
```

Highlight the simplicity.

### Conclusion

- Recap of key points
    
- Encouragement to explore minimal APIs further

