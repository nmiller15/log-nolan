---
title: "Interviewers Will Ask You About This: Dependency Injection Made Simple"
date: 2025-02-24
summary: The simple guide to getting started with DI.
description: The simple guide to getting started with DI.
toc: false
readTime: true
autonumber: false
math: true
tags: ["dotnet", "csharp", "oop", "learning"]
showTags: true
hideBackToTop: false
draft: false
dev: true
dev_id: 2295707
---
My heart rate was elevated and my hands were clenching the plush armrests of a very comfortable chair in a board room. *He knew.*

After thinking about it way too long, I'd just called a singleton a factory method in a code example that was broadcast onto one of the two flat screens on the far wall. 

"So, what do you know about dependency injection?"

*Strike 2.* I remembered reading something about this when I was panic studying for this interview, but I didn't really understand it. "I've... um... never used it before, but I think I understand the concept..." 

*Sigh. This is over isn't it.*

Since I started teaching myself to code, one of the things that's frustrated me the most about this space, is how big all the freaking words are. Dependency Injection? What is that? What does it mean to have a dependency? What the heck is injecting it? 

I struggled through figuring this out so that you don't have to. The concept is not as hard as it might seem, and it can dramatically increase your code quality. If you're self-taught, this is a concept that *will* come up in job interviews, because in any project of a reasonable size, it is probably being used. 

Let's dive in, so that your interview doesn't go how mine did.

## What is a dependency?

In short, a dependency is a piece of code that is *depended upon* for functionality.

When we talk about dependencies, we will talk about *clients* and *services*. The client is the class that *depends* on something else, the class that takes the injection. The service is what is injected, it is the *dependency*. 

It's not always this clean though. Often services will also have a long list of dependencies, creating a chain of interrelated classes. But, to keep things simple for now, we'll just focus on the relationship between one client and one service.

### Real World Dependencies

Dependencies don't only exist in your IDE. This pattern is modeled after the real world, as many concepts in object oriented programming are. 

If you live some distance from your workplace, it is likely that you are dependent upon a car. You are the client, and the service is your car! A dependency relationship. 

Let's quickly create a program that reflects this relationship. First let's create a person and give it some properties.

```cs
public class Person
{
	// Descriptors that are related to a person
	public string Name { get; set; }
	public string Workplace { get; set; }
	public int Age { get; set; }

	// A constructor for our class.
	public Me(string name, int age)
	{
		Name = name;
		Age = age
	}
}

public class Program
{
	public static void Main(string[] args)
	{
		// An instance of Person with my information
		var nolan = new Person("Nolan", 27)
		nolan.Workplace = "Certified Angus Beef"
	}
}
```

Now, lets create a car, and use it to get to work!

```cs
public class Car
{
	// ... Properties

	public bool Drive(string destination)
	{
		Console.WriteLine($"Arrived at {destination}");
		return true;
	}
}

public class Person
{
	// ... Properties and things

	public void GoToWork()
	{
		// Becuase this class needs instantiated
		// for this behavior to work, it is a 
		// service that Person depends on.
		Car car = new Car();
		
		var hasArrived = car.Drive(Workplace);
		if (hasArrived) { Console.WriteLine("Made it to work!") }
	}
}
```

This is all a dependency is. Try looking at some of your own real world relationships and identifying the dependencies that you have. What people do you rely on? What possessions? etc.

There's nothing wrong with relying on other people or things to accomplish goals and tasks, but it *does* become a problem when these things we rely on are the *only* way we know how to accomplish those goals. 

In this example, the only way that the `Person` class knows how to `GoToWork` is by using a `Car`. We have to use this implementation of `Car` no matter what. What if `Car` breaks? We can't borrow a car, or get a rental? We need to introduce more flexibility into this class.

## Create flexibility with interfaces

*I thought this was an article on dependency injection.*

Yes. It is. But, the concept of interfaces is tightly coupled with dependency injection... 😉

To solve our problem of rigidity in `GoToWork`, let's say that at minimum we need a vehicle to get to work. I don't care what kind it is, how many wheels it has or what kind of gas it takes, I just need it to be able to drive. 

We can create an interface for that:

```cs
public interface IVehicle
{
	bool Drive(string destination)
}
```

Now, with one tweak to our `GoToWork` method, we begin to decrease our reliance on `Car` specifically. 

For the sake of illustration, let's say that my `Car` has broken down, I still need to get to work. So, instead I'll use my wife's SUV to get there!

```cs
public class SUV : IVehicle
{
	public bool Drive(string destination) { ... }
}

public class Person
{
	// ... Properties and things
	
	public void GoToWork()
	{
		// Using the interface we created,
		// we can add any implementation 
		// of a vehicle here now.
		IVehicle vehicle = new SUV();
		
		var hasArrived = vehicle.Drive(Workplace);
		if (hasArrived) { Console.WriteLine("Made it to work!") }
	}
}
```

Now that we've achieved some flexibility, we need to address another issue. If we were to translate this `GoToWork` method back to real life, we'd notice something strange.

Every time this person tries to go to work, they're building a vehicle (and taking it back apart once they get there). 

Not very smart is it? 

*But, who cares, this isn't real life.*

Well, no, but there are two programming-related reasons that we don't want to build our dependency inside our method. Single-responsibility, and efficiency.

The way our code is built right now violates the single-responsibility principle. This feature of object-oriented design states that the components of our application should have *one* responsibility. `GoToWork`, despite the name, doesn't just `GoToWork`. It creates an outside class instance *and* goes to work. 

What if I want to create a `GoToSchool` method? Or a `GoToTheStore` method? I'd have to duplicate my code in every one of the methods (violating the DRY principle). Now imagine that my `Car` breaks again, and I need to use the `SUV` class! I need to change it in every place I create that class. 

It's also less efficient. Every time I need to use the `Drive` method, I need to create a new class instance. With a small class like this, there may not be much performance overhead, but as classes get bigger and code gets more complex, this becomes an issue. What if I wanted to track the mileage on the car? Or know how many trips it took? This becomes far more complex if every time I'm using the `Car` I create a new one.

We can solve this though. You might think that we can just move the implementation into a property and instantiate it there, but we can take this one step further, by removing the creation of the instance outside of the class entirely.
## Injecting your first dependency

Let's start by adjusting our `Person` class to make sure that we have somewhere to store the dependency. We don't want our class methods to be able to adjust it, and we don't want it to be accessible outside of our class either, so we'll use a `private readonly` field.

```cs
public class Person
{
	private readonly IVehicle _vehicle;

	// Other properties and things
}
```

Now... we inject. 

We're going to create a constructor that has `IVehicle` as a parameter, then we assign this parameter to our new field.

```cs
public class Person
{
	private readonly IVehicle _vehicle;

	// Other properties and things

	// Inject the IVehicle through this
	// constructor
	public Person(IVehicle vehicle)
	{
		_vehicle = vehicle;
	}
}
```

Now take a look at how this simplifies our `GoToWork` method:

```cs
public class Person
{
	private readonly IVehicle _vehicle;

	// Other properties and things

	public Person(IVehicle vehicle)
	{
		_vehicle = vehicle;
	}

	public void GoToWork()
	{
		// This will now work with any implementation
		// of IVehicle!
		var hasArrived = _vehicle.Drive(Workplace);
		if (hasArrived) { Console.WriteLine("Made it to work!") }
	}
}
```

The reason the `GoToWork` method is simplified is because it is no longer responsible for *choosing an implementation* or *creating an instance* of `IVehicle`. That now takes place outside of the `Person` class entirely!

Take a look at how we might call the `GoToWork` method.

```cs
public class Program
{
	public static void Main(string[] args)
	{
		// Pick and instantiate an IVehicle
		IVehicle car = new Car();
		var nolan = new Person(car);
		nolan.Workplace = "Certified Angus Beef"

		nolan.GoToWork();
	}
}
```

This is the basic concept of dependency injection. Notice that our `Main` method actually got a bit more complex. While the design pattern has its advantages, like testability, separation of concerns and single-responsibility, one of the tradeoffs is that we have made our code a bit more complex to work with.

Luckily for us, we can take advantage of all the benefits of this pattern and sidestep some of this complexity by letting a DI framework do the work of injecting the instances for us. 

## Inversion of control with DI containers

There are many DI frameworks, but the one we'll go over today is the DI container that's built into ASP.NET. No matter the framework that you're using, the goal is the same: automatically provide services to clients that are generated by your framework. Put simply, to inject your dependencies.

The concept is called *Inversion of Control*. Instead of the client controlling the dependencies that it has, the control structure is flipped. The framework is given control over the dependencies and the client is allowed to use it.

> **All these "i" terms...**
>
>*It is important to make a distinction between the terms **interface**, **implementation**, and **instance**. Naturally... they all had to start with "i".
>
>An **interface** is a set of specifications for class definitions. A contract.
>An **implementation** is a definition of a class that adheres to that interface or contract.
>An **instance**, is the usable object with property values and behavior that represents a real-world object. The class definition in actual use somewhere.*
>
>*Just remember: Create **instances** from **implementations** of **interfaces**.*

When we're using a DI container, we have to bind (either manually or automatically) our interface requests to an instance that implements it. When you define a relationship between an interface and an implementation to the DI container, it will fulfill any request for the interface with the bound implementation. 

You can also explicitly attach implementations without an interface. When this is done, the framework will respond directly to requests for that implementation with the implementation.

In the following example, we will look at how to bind interfaces and implementations as this is the most common pattern that you will see.

## Bind services to your DI container

To illustrate how to bind services to your DI container, we will start in the context of an ASP.NET MVC application. The main method of this creates a web app builder. Taking advantage of boilerplate middleware, the controllers and views are collected and instantiated by the framework. 

Let's take simple web application that displays facts. It has a `FactsController` with a few routes and related Views. Let's create this controller now.

```cs
public class FactsController : Controller
{
	public FactsController()
	{
	}

	public IActionResult Index()
	{
		return View();
	}
}
```

We will take for granted that we have a view for `Index` and that we have a `FactsViewModel` that will hold a `Fact` string that we can display. 

Now, we want to generate random facts. We could put all of that logic here in a private method, or in one of our action methods, but that would violate the single responsibility principle and make our project much harder to maintain.

So, let's inject a service to do that for us!

```cs
public class FactsController : Controller

private readonly IFactGenerator _factGenerator;

public FactsController(IFactGenerator factGenerator)
{
	_factGenerator = factGenerator;
}

public IActionResult Index()
{
	var viewModel = new FactsViewModel();
	// The Generate method takes an enum value that lets
	//   us choose the category of fact that is generated.
	// The Fact property of our FactsViewModel is then displayed
	//   in the Fact.cshtml view.
	viewModel.Fact = _factGenerator.Generate(FactTypes.Animal);

	return View(viewModel);
}
```

This looks very similar to what we did above with our manual dependency injection. We defined a field `_factGenerator`, injected the interface through the constructor, and then we accessed the method of our service from within our client: the `.Generate(FactTypes)` method.

However, this *won't* work yet. 

We still need to bind our service within our DI container. We do this by adding a service to the service collection on our `WebApplicationBuilder`. So head over to `Program.cs` and add the following line.

```cs
public static void Main(string[] args)
{
	var builder = WebApplication.CreateBuilder(args);

	// AddSingleton<TInterface, TImplmentation>
	// This line creates a singleton instance of a service.
	// Whenever this interface is called, the instance created by
	// the builder will be delivered.
	builder.Services.AddSingleton<IFactGenerator, FactGenerator>();

	// This is added by the template
	builder.Services.AddControllersWithViews();

	...
}
```

Now, if we boot up our application and navigate to `/Facts` we should see the output of the `FactGenerator`. Using the `.AddSingleton` method, we have told the DI container that wraps our application, "Whenever a class that you build requests an `IFactGenerator`, give them the instance of `FactGenerator` that you've created."

## Deciding what instance to be delivered using binding

In addition to the `.AddSingleton()` method, we can also make decisions about which *instance* of our implementation is injected by our DI container. 

We can use singletons, transients, or we can scope our instances. Here's how each of these behave:

+ `.AddSingleton()` - Only one instance of this type will be created. Every request for an implementation will be fulfilled with the same instance.
+ `.AddTransient()` - For every request for a service, a new instance will be created to fulfil it. 
+ `.AddScoped()` - For every request made of the application (not the DI container) a new instance will be created. The same instance will be used for the duration of the request.

To illustrate how this works, I've adjusted the `FactGenerator` and the `FactController` to show off the differences between the binding types.

In my `FactGenerator`, I've made it so that each instance can only generate one unique fact. After the `.GetFact` method has been used, it will return the initially generated fact. This will give us a very clear look at the instance lifetimes.

In `FactController`, I've created Action Methods for `Singleton`, `Transient` and `Scoped`. These correspond to more or less identical views that all use the `FactsViewModel`.

To get the facts for these views, I've bound and injected 6 different fact generators, two of each binding type. With two of each, we can explore the differences in lifetime between transients, singletons, and scoped.

```cs
public class FactsController : Controller
{
    private readonly TransientRandomFactGenerator _transientRandomFactGenerator1;
    private readonly TransientRandomFactGenerator _transientRandomFactGenerator2;
    private readonly SingletonRandomFactGenerator _singletonRandomFactGenerator1;
    private readonly SingletonRandomFactGenerator _singletonRandomFactGenerator2;
    private readonly ScopedRandomFactGenerator _scopedRandomFactGenerator1;
    private readonly ScopedRandomFactGenerator _scopedRandomFactGenerator2;
    
    public FactsController(
        TransientRandomFactGenerator transientRandomFactGenerator1,
        TransientRandomFactGenerator transientRandomFactGenerator2,
        SingletonRandomFactGenerator singletonRandomFactGenerator1,
        SingletonRandomFactGenerator singletonRandomFactGenerator2,
        ScopedRandomFactGenerator scopedRandomFactGenerator1,
        ScopedRandomFactGenerator scopedRandomFactGenerator2
    )
    {
        _transientRandomFactGenerator1 = transientRandomFactGenerator1;
        _transientRandomFactGenerator2 = transientRandomFactGenerator2;
        _singletonRandomFactGenerator1 = singletonRandomFactGenerator1;
        _singletonRandomFactGenerator2 = singletonRandomFactGenerator2;
        _scopedRandomFactGenerator1 = scopedRandomFactGenerator1;
        _scopedRandomFactGenerator2 = scopedRandomFactGenerator2;
    }
	...
}
```

Let's take a look at how we can call these generators from our action methods.

### Singleton binding

```cs
// Program.cs
builder.Services.AddSingleton<SingletonRandomFactGenerator>();

// FactsController.cs
public IActionResult Singleton()
	{
	    var viewModel = new FactsViewModel();
	    var fact1 = _singletonRandomFactGenerator1.GetFact(FactTypes.Space);
	    var fact2 = _singletonRandomFactGenerator2.GetFact(FactTypes.Animal);
	    viewModel.Fact = fact1;
	    viewModel.Fact2 = fact2;
	    ViewData["Title"] = "Singleton";
	    return View(viewModel);
	}
```

When we bind our `SingletonRandomFactGenerator` and inject it twice, once for each fact. What do you think the output will be? 

![Singleton Facts](https://nolanmiller-image-hosting.s3.us-east-2.amazonaws.com/Scoped+Facts.png)

We got the same fact back! Why is this?

When we bound the SingletonRandomFactGenerator implementation to our builder *as* a singleton, only one instance is created. We called for an injection twice in our controller and the same instance was delivered to both references. So, it didn't matter that we called the `GetFact` method again on our second reference, we still got the same fact back since the `GetFact` method only returns one unique fact.

Let's see how this is different with a transient binding.

### Transient binding

```cs
// Program.cs
builder.Services.AddTransient<TransientRandomFactGenerator>();

// FactsController.cs
public IActionResult Transient()
{
    var viewModel = new FactsViewModel();
    var fact1 = _transientRandomFactGenerator1.GetFact(FactTypes.Space);
    var fact2 = _transientRandomFactGenerator2.GetFact(FactTypes.Animal);
    viewModel.Fact = fact1;
    viewModel.Fact2 = fact2;
    ViewData["Title"] = "Transient";
    return View(viewModel);
}
```

In this example, we are calling for two injections of `TransientRandomFactGenerator`, just as we did with `SingletonRandomFactGenerator`. And this is the output that we get:

![Transient Facts](https://nolanmiller-image-hosting.s3.us-east-2.amazonaws.com/Transient+Facts.png)

Two different facts! 

Since we used `AddTransient`, when we call for two different injections of the same implementation, two *separate instances* are injected. So when we call `GetFact` on the first, it doesn't affect the second! 

Now that we understand the difference between transient and singleton, let tackle scoped, which is a little more subtle.

### Scoped binding

```cs 
// Program.cs
builder.Services.AddScoped<ScopedRandomFactGenerator>();

// FactController.cs
public IActionResult Scoped()
{
    var viewModel = new FactsViewModel();
    var fact1 = _scopedRandomFactGenerator1.GetFact(FactTypes.Space);
    var fact2 = _scopedRandomFactGenerator2.GetFact(FactTypes.Animal);
    viewModel.Fact = fact1;
    viewModel.Fact2 = fact2;
    ViewData["Title"] = "Scoped";
    return View(viewModel);
}
```

With this action method set up the same as the other two, what do you expect will happen? 

![Scoped Facts](https://nolanmiller-image-hosting.s3.us-east-2.amazonaws.com/Scoped+Facts.png)

Hm... the same fact? *So... it's a singleton?* 

It is. But, only for a while. 

When we called for two injections of the generator here, it built them upon request. Since the calls for both of the injections happened on the same request, we got the same instance injected for both, just like a singleton.

We can create a second request by refreshing the page.

![Scoped Facts Refreshed](https://nolanmiller-image-hosting.s3.us-east-2.amazonaws.com/Scoped+Facts+Refreshed.png)

After our refresh, we get a new fact! This is due to the fact that once we entered a new request, a new instance was generated and injected. 

*This still seems like it's just a singleton.* 

Yep, I get it. They're very similar. But, watch what happens if I click back over the the singleton.

![Singleton Facts Refreshed](https://nolanmiller-image-hosting.s3.us-east-2.amazonaws.com/Singleton+Facts+Refreshed.png)

The same fact as the first time we loaded the page!

The singleton binding doesn't care that we've made a separate request. It is still delivering that exact same instance to our controller no matter what.

If I click back over to see the scoped binding, we will get yet another random fact! 

## Wrapping up

Now you don't have to be nervous like me in your next interview. If you've never worked with dependency injection before, take an afternoon and create a small project like this one to get a handle on some of the concepts. 

I would suspect that a great majority of codebases use dependency injection in some form or another, and if you're self-taught it's a topic that doesn't seem to come up in the learning paths online. 

Thanks for taking your time to read this, and it is my sincere hope that it makes your life and coding journey a bit easier than mine was! 

If you found value in this, share it with a friend who wants to learn about dependency injection! 

___

Interested in getting these blog posts direct to your inbox? 

[Click here to sign up!](https://d782b8fa.sibforms.com/serve/MUIFAK2keDpq4jw-krst9Ki0T2Asllq4pHVH7YEaci2JN2o3H1rLOXm-4H3G3lc31swK7WFMNYjoSJqaBleHxcV0vc8EEBLLxb3HK0U59_fRRDFUaj96lZyvOSE2NiYQSi1jC_0L0Tq8wj2_OcG8PFuNsL5SH65CQh_GpSOXqV3FqTJosq6tSRV2e2mw9MSXcAx7-2c_3fY-abRi)