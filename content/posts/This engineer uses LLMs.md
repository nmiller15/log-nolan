---
title: This engineer uses LLMs
date: 2025-02-05
summary: "via: Sean Goedecke"
description: "via: Sean Goedecke"
toc: false
readTime: true
autonumber: false
math: true
tags: ["linked-post", "ai", "llm", ""]
showTags: true
hideBackToTop: false
draft: true
dev: false
---

Quotes courtesy of Sean Goedecke, [see original article here](https://www.seangoedecke.com/how-i-use-llms/?utm_source=pocket_shared).

Since starting my job, I've debated how appropriate it is to use LLMs for certain tasks. Sean has some good guidance for those in similar positions.

>Personally, I feel like I get a lot of value from AI. I think many of the people who don’t feel this way are “holding it wrong”: i.e. they’re not using language models in the most helpful ways. In this post, I’m going to list a bunch of ways I regularly use AI in my day-to-day as a staff engineer.

AI has many good uses:

>I use Copilot completions every time I write code[1](https://www.seangoedecke.com/how-i-use-llms/?utm_source=pocket_shared#fn-1). Almost all the completions I accept are complete boilerplate (filling out function arguments or types, for instance).

>LLMs excel at writing code that works that doesn’t have to be maintained. Non-production code that’s only run once (e.g. for research) is a perfect fit for this. I would say that my use of LLMs here meant I got this done 2x-4x faster than if I’d been unassisted.

>The magic of learning with LLMs is that you can _ask questions_: not just “how does X work”, but follow-up questions like “how does X relate to Y”. Even more usefully, you can ask “is this right” questions.

But, Sean also warns against trusting the LLM generations completely. As engineers, you should know your tools so well that you are more confident in your own work than an LLM.

>It’s rare that I let Copilot produce business logic for me, but it does occasionally happen. In my areas of expertise (Ruby on Rails, for instance), I’m confident I can do better work than the LLM. It’s just a (very good) autocomplete.

But, we're not always using our most comfortable tools.

>I frequently find myself making small tactical changes in less-familiar areas (for instance, a Golang service or a C library). I know the syntax and have written personal projects in these languages, but I’m less confident about what’s idiomatic. In these cases, I rely on Copilot more. Typically I’ll use Copilot chat with the o1 model enabled, paste in my code, and ask directly “is this idiomatic C?”
>
>Relying more on the LLM like this is risky, because I don’t know what I’m missing.

Using new tools is part of growing as an engineer, but the tool shouldn't make you a worse engineer.