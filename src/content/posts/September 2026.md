---
title: AI for Fantasy Football (September 2026)
date: 2026-10-06
summary: writing an agent in a weekend 
description: writing an agent in a weekend 
toc: false
readTime: true
autonumber: false
math: true
tags: ["log"]
showTags: true
hideBackToTop: false
draft: false
dev: false
---

Writing an AI agent is one of those things that sounds way harder than it is. If you know how to add strings to an array and make API requests, you can pretty much throw one together if you have a couple hours and $20. I did this one weekend this past month. My fantasy football league decided this year to add a dynasty league alongside our redraft league. This sounded like a great idea, until I realized that I really barely do the work that you need to for one league.

I want to win. But, I don't care enough to be watching every game on the weekend and immersing myself in the NFL the way that you need to in order to be good at fantasy. So, it seemed like a perfect thing to hand off to AI, and plus, I'd been looking for an excuse to mess around with an LLM anyways. 

It turns out, it's pretty simple. Sleeper has a public read-only API for real time league information. Tavily has a generous free tier for programmatic web searches. So, I wrapped these API calls in C# methods, and created tool definitions for Gemini. Then, I created a `while` loop that appends context and fires tool results back at Gemini until I get an output. 

Now, every morning at 7am, I have a list of discrete actions to take for my team, from waiver pickups and trade offers, to setting my lineup ahead of the games that day. Check out [the code on GitHub](https://github.com/nmiller15/FantasAIFootball) if you're interested!

## Small wins

+ No software fixes needed during our Annual Conference.
+ Created an AI Fantasy football agent in a weekend.
+ My wife and I are learning how to be parents.

## Worth a read

+ *Red Rising* by Pierce Brown - Haven't finished yet, and it took me a LONG time to come around, but I think I have

## Other things

+ F# looks cool
+ Gallbladders are kind of dumb if you think about it.
+ I 100% completed Lego Star Wars II: The Original Trilogy...