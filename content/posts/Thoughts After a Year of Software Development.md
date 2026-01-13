---
title: Thoughts After a Year of Software Development
date: 2026-01-06
summary: "Lessons and musings after my first year in development"
description: "Lessons and musings after my first year in development"
toc: false
readTime: true
autonumber: false
math: true
tags: ["career", "discuss"]
showTags: true
hideBackToTop: false
draft: false
dev: false
---


After teaching myself to code, I landed a job a year ago in December. In no particular order, here is an assorted collection of thoughts, opinions, and tidbits that I've accumulated over the past year. 

### Typing speed and accuracy are important

As a junior, I do not spend "most of my time thinking." Many of the problems that I need to solve aren't very mentally taxing, they just need implemented. When I started training my typing speed and accuracy by bouncing between [keybr](https://keybr.com/) and [monkeytype](https://monkeytype.com/), even repetitive "hammer-it-out" coding sessions became much more enjoyable (and shorter too). My backspace key appreciates the rest.

### AI hype is mostly just that

When an application is even remotely complex, or the context needed to solve an issue is of any reasonable size, AI is practically useless. No, I'm not going to type up my organization's application and server architecture so that I can argue with AI to get it to stop hallucinating. AI can make "nice" looking websites and decent interactivity. I really use it to search for Microsoft documentation... which is abysmal. AI is pretty good at that.

### I hate Microsoft

Windows sucks. VS sucks. (Except for the debugger, that's pretty good.)

### Knowing how to host an app is a differentiator

Surprisingly, there's a large portion of developers who have never stood up a production server on a bare VPS. I'm no expert, but it's really not too difficult. Maybe I just enjoy working on servers, but knowing how to host your apps outside of Netlify or Vercel is a good skill to have.

### I'm really good at making really bad code

Did you want to filter that list using 3 helper methods across two classes with injected services? I got you. 

The next day, I usually realize that this could have been done in 3 lines and everyone can magically understand what it does.

### I'm not rich

I make more money than I used to. But, it seems like most development jobs aren't the "f*** you" money that YouTube would have you believe. Lucky for me, I really like coding. 

### I really like developing

I don't know if its the sound of the keyboard, the hacker aesthetic that you get from using a shell for everything, or the feeling catpuccin gives, but being a developer is really fun. 

### Shortcuts will make you feel like a god

I have not measured whether or not it speeds me up a significant degree, but it feels very good to not have to reach for my mouse to perform really common actions. It is well worth taking the time and the initial slowdown to get system shortcuts into your fingers. Did you know that on Windows, you can open and focus applications in your taskbar by using Win + the number corresponding to it's order? Getting used to navigating your computer this way will immediately make everything feel more smooth.

### JavaScript is the worst

But, it's not going away. The event loop is the death of me everytime I mess with WASM in highly-interactive apps. It's evil... but, you need to know it.

### OOP is OOK

I work in C#, and everything is an object no matter what. For most data-heavy problems, I can usually create a pretty solid mental model with this paradigm, but sometimes it feels like I'm just trying to fit into the paradigm when all i need is a couple util functions. I don't know the number of abstractions that I've taken the time to write and then immediately deleted because it no longer makes sense.

### Quality of life features live on the back burner

It's really hard to convince anyone that your "it would be really nice if" idea is worth the time when there are new features and projects that other teams are depending on. At best, I've had a bit of time when I can shove it into the mix when I finish a project early unexpectedly. Instead of creating the "quality of life" ticket for later, just lump it in with the feature that you're working on. 

### Nobody knows what you do, or how long it will take

My manager is great, has lots of industry experience, knows me and my work pretty well, and he still cannot figure out how much time it will take for me to complete something. Being a developer uniquely gives you a lot of trust and autonomy over your schedule. This is a privilege and a responsibility. Some of the best engineering work time can produce no quantifiable output. Don't take advantage of this.

### Assume any data you don't own is toxic

When you don't have crystal clear visibility into a data source for your application, you need to treat it like it can and will be wrong or missing every time. Use fallback values, conditional rendering, and generally assume the worst. It's probably a good idea to do this when you have the visibility too.

### The code I actually use is short and isn't elegant

The code I use the most are tiny scripts that I've written for myself. If they get used a lot, they can't break. If they can't break, they need to be easy to maintain. If they need to be easy to maintain, then they need to be short, and so clear a beginner could understand them. Automation doesn't save time if it's buggy and hard to understand. That said, I don't rela

### Small problems need solved too

When I'm trying to find the biggest and most exciting and most impactful problem to solve, I can't think of anything. But, when I open my eyes to small annoyances, I start to see them everywhere.

### Backend is way more interesting than front end

I wasn't counting on this to be true. A year ago, I thought that my bent towards things that are artistic would have drawn me to the front end more. But, in all the projects I've worked on, it's been far more exhilarating to solve the pivotal logical issue than it was to figure out how to show it to someone. 

### A fast/slow dev server makes a huge difference

Have you ever worked with the Blazor dev server? Maybe I'm doing it wrong, but getting that thing to load up a large project takes *forever*.

### Don't repeat yourself... but don't not repeat yourself

I've rewritten logic in a few places that has bitten me. You will always miss at least one update if you have to go to more than one place. But, in my zealousness I've created some abstractions that make absolutely no sense to work with. DRY is for information, not code. Each piece of information, or logic, should have one authoritative implementation. Don't push things together just because.

### There's almost always a better way

... and someone else thought of it first. You don't need to be a hero and try to come up with the most clever solution to prove you know what you're doing. Ask questions to people at your disposal. Collaboration leads to better ideas and a better team.

### Version control everything

Use git repos and feature branches religiously and neurotically. I can't count the number of times that I've started on a bug fix while I was in the middle of working on a small feature only to realize that I never created a new branch. Not only do I have to start over the bugfix, but often, I also broke my feature branch and have to walk backwards for a while to get it fixed.

### That it....

I learned a lot in year one, and I know I still have so much further to go. I've never stepped into a career that it feels like no matter how much you learn, you've only just scratched the surface. It's overwhelming. But, it's also exciting! 

Hopefully some of this advice is helpful to you! Hopefully you agree with some of it. Hopefully you disagree with some of it. For what it's worth, these are my thoughts. 

For now.