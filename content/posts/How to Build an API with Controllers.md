---
title: How to Build an API with Controllers
date: 2025-11-17
summary: "A basic walkthrough of the Controller-Based API pattern in .NET"
description: "A basic walkthrough of the Controller-Based API pattern in .NET"
toc: false
readTime: true
autonumber: false
math: true
tags: ["dotnet", "csharp"]
showTags: true
hideBackToTop: false
draft: false
dev: false
---

I starting working in ASP.NET after minimal APIs had already been released and reached popularity. My first professional project involved moving endpoints from a .NET controller-based API to the new minimal syntex. Unfortunately for me, that meant I was not going to be able to avoid the controller-based API even though I wasn't particularly comfortable with the paradigm... or C# for that matter.

To save you the headache, I will walk through the very basics of creating a controller-based API and explain what I spent hours staring at code to figure out (after all, 20 hours of reading code can save you 20 minutes of reading documentation). We will create endpoints, accept parameters and document the routes all in the controller-based syntax. 
## What is a controller-based API?

The controller-based API, is... well, an API whose endpoints are is organized with controllers, as opposed to the [minimal API](https://nolanmiller.me/posts/intro-to-.net-apis-for-a-javascript-developer/), whose endpoints are registered directly on the `WebApplication` using extension like `MapGet` and `MapPost`. The pattern is actually just the MVC (model-view-controller) architecture, but with the "V" left out. Since an API doesn't typically return formatted views, it doesn't need to worry about that. But, the routing and model construction all work the same way as it would in an MVC application. Instead of a view, our controllers will return data wrapped in HTTP responses that can be used by any other application that can make HTTP requests.

## Configuring an API for controllers

That's enough background, let's get started by bootstrapping an application using the [`dotnet` cli](https://nolanmiller.me/posts/supercharge-your-productivity-with-the-.net-cli/). In a new terminal window, run the following command:

```sh
dotnet new webapi -n "TodoApi"
```

Once this runs, we'll have a working API, but if you'll open up `Program.cs`, you'll notice that we already have a minimal API endpoint registered here. With a little extra work, we'll have this converted into a controller-based API.

First, **DELETE** the following lines of code from `Program.cs`:

```cs
var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/weatherforecast", () =>
{
    var forecast =  Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return forecast;
})
.WithName("GetWeatherForecast");

// leave in app.Run();

var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/weatherforecast", () =>
{
    var forecast =  Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return forecast;
})
.WithName("GetWeatherForecast");

///////////////////////////
// do not delete app.Run();
///////////////////////////

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
```

Now, replace `var app = builder.Build()`, with the following:

```cs
builder.Services.AddControllers();
var app = builder.Build();
app.MapControllers();
```

This small bit of code here enables the use of controllers in our web app. With the `AddControllers()` extension method, we're registering [all the services](https://learn.microsoft.com/en-us/dotnet/api/microsoft.extensions.dependencyinjection.mvcservicecollectionextensions.addcontrollers?view=aspnetcore-9.0) that we might need for API development in ASP.NET. Once the services are registered and the app is built, instead of manually configuring all of our endpoints, [`.MapControllers()`](https://learn.microsoft.com/en-us/dotnet/api/microsoft.aspnetcore.builder.controllerendpointroutebuilderextensions.mapcontrollers?view=aspnetcore-9.0) goes to look at all of our Controllers and turn the action methods into route endpoints!
## Creating routes from actions

Now that our `Program.cs` file expects to search our app for controllers, we should go and make one. To support the quintessential "todo" app with our API, in the root of the project, create a folder called `Controllers`. Inside that folder, make a new file called `TodoController.cs` and add the following code:

```cs
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace TodoApi.Controllers
{
	[Route("api/[controller]")]
	[ApiController]
	public class TodoController : ControllerBase
	{
	}
}
```

This is the controller that we will use to create endpoints for our API. This controller is just a C# class that inherits from the `ControllerBase` class that is provided by the `Microsoft.AspNetCore.Mvc` package. That base class gives us access to some helper methods that we will use later. We also have to include the `[ApiController]` attribute to tell the framework that we are creating a controller.

If we started our application now, the controller would be registered, but no routes would be added because we haven't added any action methods. So, let's do that right now. In order to add the endpoint, create a method on the controller that returns an `ActionResult`. Add the following method to the `TodoController` class.

```cs
// in TodoController
public ActionResult Health()
{
	return Ok("Healthy");
}
```

This is called an *action method*. It returns a controller action using the `Ok()` helper method provided by `ControllerBase` which returns an `ActionResult` that has a `200` status code and contains the string passed to it. If we build and run our application now, we have a new endpoint! Now let's talk about where we can find it when we're trying to call the API. 

## URL Routing in Controllers

ASP.NET does most of the routing for us when we are using controller-based syntax. If you're familiar with the MVC pattern, then you already know how this will work. Each endpoint is created using the name of the controller class, the name of the action method and optional input parameters.

The action method that we just created was inside of the `TodoController` and it's method name is `Health`. By default, to hit this endpoint, we have to send a `GET` request to `/Todo/Health`. 

- `TodoController` → `Todo`
- `ActionResult Health()` → `Health`

Seems simple enough, but if you try this on your API now, you'll notice that you get back a `404`. Sorry! I tricked you. 

This controller *isn't* using the default routing scheme. If you've been following along with the code I've told you to put in, then you might have noticed, that we added:

`[Route("/api/[controller]")]`

... to the top of the controller.

This is an attribute that we can assign to a class or action method to tell the framework what pattern we want it to use when assigning an endpoint. The pattern syntax is dead simple, it will:
1. match any string that you pass literally, 
2. statically replace wildcards passed between `[]`, and 
3. pass named parameters to action methods between `{}`.

The default pattern for a controller in ASP.NET is `"/[controller]"`, where the wildcard `controller` is replaced by the name of the controller class with the word "Controller" stripped out.

With our custom `Route` attribute, we're using `"/api/[controller]"`. So, to hit our controller endpoints, we would just have to use the base `/api/Todo`.

We didn't add a custom `Route` parameter to our Action method, so it will route using the default pattern `"/[action]"`, where the wildcard `action` will be replaced with the name of the action method. If you're following from above, that makes the full pattern for our endpoint `"/api/[controller]/[action]"`. So, to check the health of our API, get a `GET` request to `/api/Todo/Health`.

With the `Route` parameter, we can change the routes to whatever we would like. Let's illustrate this by adding another endpoint to this API.

```cs
[Route("/api/[controller]")]
public class TodoController : ControllerBase
{
	public ActionResult GetTodo(int id)
	{
		return Ok(id);
	}
}
```

Since we didn't add a `Route` parameter to this action method, we have inherited the default. So, to hit this endpoint in it's current state we would send a `GET` request to `/api/Todo/GetTodo/23`. This would return an action result that would presumably return a Todo that had the ID of 23. So, how is this 23 passed into the `id` parameter of the action method? 

There is one more section of the default route pattern for ASP.NET.

`/[controller]/[action]/[id]`

That means that without adding a custom attribute, we have access to an `id` input parameter that can be submitted as a URL parameter by a user. In order to accept it all we have to do is add the parameter to the action method with the name `id`.

This method seems like a good candidate for customization though. Sending a `GET` request to an endpoint containing `GetTodo` seems redundant and sloppy. So, let's use the `Route` attribute to create our own pattern. While we're at it, our users likely know that they're hitting an API, and we don't have anything else hosted at this address, so we can adjust that too. 

```cs
[Route("todos")]
public class TodosController : ControllerBase
{
	[Route("{id}")]
	public ActionResult GetTodo(int id)
}
```

By combining these two `Route` attributes, we've created a new pattern: `/todos/{id}`. To make the same request as earlier, we would send a `GET` request to `/todos/23`. Using `Route`, we kept the user from having to type out the name of our implementation method, while still leaving it intact for our developer to use. I'll also note that we switched the pattern to the curly brace syntax to better identify that `id` is a route parameter that will be passed in the action method parameter named `id`.

Now that we've got the request side of things figured out, let's take a look at how to handle getting information back to the user.

### Constructing responses

So far, all we've returned is `Ok()`. ASP.NET also provides us  methods like `NotFound()` and `StatusCode()` that return different status codes. Along with these three, we have access to [a long list of helper methods](https://learn.microsoft.com/en-us/dotnet/api/microsoft.aspnetcore.mvc.controllerbase?view=aspnetcore-2.2#methods) through the `ControllerBase` class to send responses to the user. Feel free to peruse them in your own time, but today, I'll just look at four.

+ `Ok()` - Returns a 200 status code. Pass any model into it as a parameter to send this back as serialized JSON.
+ `Created()` - Returns a 201 status code, indicating a successful model creation or update.
+ `NotFound()` - Returns a 404 status code. This is useful if you have a "get one" route that is passed a failed id.
+ `StatusCode()` - If you don't have time to look up the built-in method, or you find they don't have a method that satisfies your needs, you can just pass the status code as a parameter to this method to return a response with that code.

Let's use a couple of them. Here's a `SaveTodo` method that uses `Created` and `NotFound`.

```cs
    [Route("{id}/Save")]
    [HttpPost]
    [ProducesResponseType(201)]
    [ProducesResponseType(404)]
    public ActionResult SaveTodo([FromBody] Todo todo)
    {
        var success = _todoService.SaveTodo(todo);
        if (success)
        {
            return Created();
        }

        return NotFound();
    }
```

In this example, notice the decorations. We have an `[HttpPost]` and  two `[ProducesResponseType]` attributes. 

The `SaveTodo` method takes in a `Todo` class instance. With what we've seen so far this wouldn't be possible without creating a horribly-long URL that took in all string parameters. Not a great interface selection. So why couldn't we pass objects with our request before? By default, action methods will represent `GET` request endpoints. In order to pass a body to our method, we'd send a `POST` request and our endpoint wouldn't match anymore.

Luckily, making this change is as simple as including the attribute `[HttpPost]` before the method as shown in the example.

What about the `[ProducesResponseType]` attribute, though? While not vital, it serves two purposes. If you use OpenAPI to generate your documentation, then these attributes can be used to add helpful details about your route. And even if you don't use OpenAPI, they're a way to provide some in-code documentation for future developers. In a simple method like this, that may seem silly, but as controller methods and their logic grow, it can certainly be nice to know at a glance what the success/failure results for your endpoint are.

## Conclusion

If you've only had exposure to the newer minimal API syntax, then I hope that this makes the controller-based API pattern a bit more approachable. As with many things in "approaching-legacy-status" .NET, it is fairly verbose to get to a working API, but in my next few posts, I'll be exploring some features that you'll need a controller-based API to take advantage of and *hopefully* give you a reason to actually use them! 

Until then! 