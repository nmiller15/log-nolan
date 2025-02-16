---
title: What is Dependency Injection?
date: 2025-02-15
summary: ""
description: ""
toc: false
readTime: true
autonumber: false
math: true
tags: ["", "", "", ""]
showTags: true
hideBackToTop: false
draft: true
dev: false
---

When you're learning to code, there are so many words that are "scary." Concepts that seem so far out of reach that you might never understand them. And it seems like there's nobody willing to just tell you what the heck in means in English. 

Dependency Injection was one of these terms for me. I remember hearing about it, how it changes the game in your programs, and how you need to be using it. What the heck is a DI Container, what is a dependency, why is everyone talking about this like its the simplest thing in the world? 

I'd like to explain today, in plain language, what dependency injection is and the problems that it solves.

## What is a dependency?

In short, a dependency is a piece of code that is *depended upon* for functionality. If we were to think about this in the real world, if you live some distance from your workplace, and need to drive to get there you would need some kind of vehicle to get there. In this case, that vehicle is something you depend upon, it's a dependency. 

There's no need to make it more complex than that in code. Often, when you create a class, that class will have other services that it will need to call to complete the behaviors that you're trying to implement. The other services are called dependencies. 

What if we took the real world example and put it into code?

```cs
public class Me : IPerson
{
	public string Name { get; set; }
	// And other identifying features

	public Me() { }

	public void GoToWork()
	{
		IVehicle car = new Car();
		car.Drive("Work");
	}
}
```

In the example, it's clear that we need an implementation of `IVehicle` in this case `Car` to get `Me` to `GoToWork`. 

## What does it mean to inject a dependency?

Well, look closer at this example, if we're being strict about the single-responsibility principle in our class, you'll see that the `GoToWork` function actually does three things. It picks an implementation of `IVehicle`, instantiates the implementation and calls the `.Drive` method of the implementation. 

We have now tightly coupled the `Car` class and the `Me` class. This may not seem like an issue on the face of it. But, what if I was to get a new car? And I had several methods like `GoToStore()` and `GoToPark()` that all created a car object? Now, I have to go and change these everywhere. How can we fix this?

We have to move the instantiation of the class outside of the method, and we do that by *injecting it* as a parameter in the method.

```cs
public class Me : IPerson
{
	private readonly IVehicle _vehicle;
	public string Name { get; set; }
	
	// And other identifying features

	public Me() { }

	public void GoToWork(IVehicle vehicle)
	{
		vehicle.Drive("Work");
	}
}

// This is how we could call the method now
class Program
{
	public static void Main(string[] args)
	{
		IPerson me = new Me();
		IVehicle car = new Car();

		me.DriveToWork(car);
	}
}

```

[Move the injection to the class level.]

## Inversion of control with DI containers

## Advantages of DI

