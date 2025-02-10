---
title: Can we add AI to that?
date: 2025-02-10
summary: via Lawrence Jones
description: via Lawrence Jones
toc: false
readTime: true
autonumber: false
math: true
tags: ["via", "ai", "product", "mvp"]
showTags: true
hideBackToTop: false
draft: false
dev: true
dev_id: 2269873
---
Quotes in this article are courtesy of Lawrence Jones in his article, [Beyond the AI MVP: What it really takes](https://blog.lawrencejones.dev/ai-mvp/index.html).

A little over a month ago, I was in a conference talk about the value of adding AI to products. The speaker asked the room, "Who has been asked to incorporate AI into a product you've already developed in the past year," and the amount of hands up around the room was staggering. 

While it may seem simple on the face of it to load up a model and incorporate a chat interface in your app, the software development lifecycle around AI is much different than traditional software. 

Lawrence Jones argues that there are many challenges that you don't see up front. He points out that you need robust test suites, hefty ai-integrated programs to evaluate ai responses, a test runner, and hosting strategies to keep costs manageable. On top of all of this, the languages of many of the frameworks is in the way:

>Honestly, writing the tests themselves is the easy bit! Almost all AI tools and frameworks are written in Python, reflecting the origins of AI in the research teams who built the models and the machine-learning community who first adopted them.
>
>But most product teams don’t use Python, which means you need to create a lot of these tools from scratch. That’s big undertaking, and almost no one is talking about how to integrate this stuff into a normal software development lifecycle.

The biggest issue with AI is what Jones calls the "Deceptive MVP." Have you built a basic chat interface with OpenAI's API? It's not all that difficult or complex to do, and if you're using a framework you're familiar with, you could probably piece something together in an afternoon. But, once you begin adding requirements for this application, and expecting it to behave in deterministic(-ish) ways, you're going to run into issues.

>You start iterating on your MVP, trying to improve it. But as you add complexity, the system becomes increasingly unpredictable. You’re making changes based on vibes, improving some edge cases while (invisibly) breaking others.
>
>This is the stage 90% of companies building AI are in. You can even see it in FANG: the AI features Google have added to GCP feel very much like an engineers first attempt to use an LLM in a product, spitting out terrible SQL suggestions in BigQuery. Apple’s message summarisation features cross-pollinating between messages and providing horribly inaccurate headlines is another.

Adding AI to an application is not just a peel-and-stick solution that will dramatically increase the impact of your product. While it may be easy to implement, if you're making any meaningful measurements of the efficacy of your product, it will be much, much, much more difficult.

Adding the connection to an API, or downloading and hosting a model for your codebase to interact with is the easiest part of the product development stage. Brainstorming ways to leverage this technology in a *meaningful* way, ensuring that it performs tasks *reliably*, and setting up systems to *monitor* the efficacy of your product are where your time is going to be spent. So, before you think about building out your AI side-project, thinking that you'll be able to turn this into the next big thing, make sure to evaluate the massive hidden costs first.

>The companies that will succeed with AI won’t be the ones with the biggest budgets, access to the latest models, or even the most ML expertise. They’ll be the ones that invest in understanding their systems, that build the tools to measure and improve them, and that take the time to do things right.