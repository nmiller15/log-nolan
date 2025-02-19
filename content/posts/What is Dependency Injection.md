---
title: "Interviewers Will Ask You About This: Dependency Injection Made Simple"
date: 2025-02-15
summary: "The simple guide to getting started with DI."
description: "The simple guide to getting started with DI."
toc: false
readTime: true
autonumber: false
math: true
tags: ["dotnet", "csharp", "oop", "learning"]
showTags: true
hideBackToTop: false
draft: true
dev: false
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

HERERERERERER

We have now tightly coupled the `Car` class and the `Me` class. This may not seem like an issue on the face of it. But, what if I was to get a new car? And I had several methods like `GoToStore()` and `GoToPark()` that all created a car object? Now, I have to go and change these everywhere. How can we fix this?

The `Me` class is *dependent* upon some implementation of `IVehicle`. So, to more accurately show this relationship, we need to remove the creation of `IVehicle` from our class. After all, I don't build my car every time I want to go to work.  

```cs
public class Me : IPerson
{
	private readonly IVehicle _vehicle;
	public string Name { get; set; }
	
	// And other identifying features

	public Me(IVehicle vehicle) 
	{ 
		_vehicle = vehicle;
	}

	public void GoToWork()
	{
		vehicle.Drive("Work");
	}
}

// This is how we could call the method now
class Program
{
	public static void Main(string[] args)
	{
		IVehicle car = new Car();
		IPerson me = new Me(car);

		me.DriveToWork();
	}
}

```

Now, I have the freedom to create any type of `IVehicle` and inject it into the `Me` class, because the two classes are now decoupled.

This is dependency injection. You might notice that we've introduced a level of complexity as a tradeoff here. While our classes are decoupled, offering more flexibility and maintainability, we now have a harder time creating implementations of the `Me` class. 

To solve this problem, we use Dependency Injection Containers.

## Inversion of control with DI containers

The example that we used above, illustrates the central concept of dependency injection, called inversion of control. Another fancy term, great... What this refers to is the control over the classes that a subject depends on. 

In our first example, where `GoToWork` created an implementation of `IVehicle`, the `Me` class was totally in control. It decided what implementation to use, when to create it and dispose of it. 

In the second example, where the `IVehicle` is injected, the `Me` class has yielded that control. The control structure of the creation of dependencies has been upended, hence, *inversion of control.* The control now belongs to an outside entity. 

Most of the time, this outside entity is a framework called a dependency injection container. A container will wrap around the application, and it identifies when a dependency is needed and will supply an implementation. This significantly improves our code readability and allows us to take advantage of the flexibility and maintainability of the injection model without worrying about creating implementations. We leave that up to the DI container. 

## Setting up a DI container

If we were to change our earlier example to use the built-in DI container for ASP.NET, we could do the following!

Using the same `Me` class defined above, we would add add our class to our builder's services, like this.

```cs
public static void Main(string[] args)
{
	var builder = WebApplication.CreateBuilder(args);

	// We add this line to bind our implementation
	builder.Services.AddTransient<IVehicle, Car>();

	builder.Services.AddControllersWithViews();

	...
}
```

And that's it! Now, when the framework needs to instantiate our `Me` class, a request for an `IVehicle` will be made, and the DI container will supply a `Car` instance.
## Advantages of DI

While this is certainly more complex than our first example, using the DI pattern gives our code some advantages. 

First, is that our classes follow SRP, the Single-Responsibility Principle. Since our classes are only concerned with carrying out the actions that we need from them, they're more portable and reusable. Our classes should implement behavior, not be concerned about choosing dependency instances, creating them, and disposing them.

Second, the methods in our classes become much more testable. Using dependency injection, we can introduce unit tests that test *only* the functionality of our class's methods. Say that we're trying to test the first version of our `GoToWork` method. If something is broken in the `Car` class, we don't want our unit tests for `GoToWork` to fail. We want to know that there's something wrong with `Car`. If we're injecting our dependencies, then we can inject mock implementations that give us expected outputs, allowing us to test more reliably.

Third, using dependency injection makes our entire codebase far more maintainable. If you're working on a larger-scale application, there will be times that specific implementation details will have to change. Your company decides to go with a new service provider or an external api you're using is slated for shutdown. Whatever the reason, keeping the implementation of your dependencies outside of your dependents allows you to make these transitions in one place, rather than all over your codebase.


