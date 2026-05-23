---
title: Tips for Junior Devs
date: 2025-02-07
summary: via qntm
description: via qntm
toc: false
readTime: true
autonumber: false
math: true
tags: ["via", "learning"]
showTags: true
hideBackToTop: false
draft: false
dev: true
dev_id: 2264655
---
Quotes in this article are courtesy of qntm in their article [Developer philosophy](https://qntm.org/devphilo)

Qntm provides junior devs with many good pieces of advice around software development. These are conclusions that you will come to over time, and things that are hardly found in print, at least in the reading I've been doing. 

Here are the points he makes:

__Ground-up rewrites only become attractive after many avoidable mistakes have been made.__
>Warning signs to watch for: compounding technical debt. Increasing difficulty in making seemingly simple changes to code. Difficulty in documenting/commenting code. Difficulty in onboarding new developers. Dwindling numbers of people who know how particular areas of the codebase actually work. Bugs nobody understands.
>
>Compounding complexity must be fought at every turn.

__Software always takes more time than you think, but you can plan for that.___

>Writing the code, once, and getting it to work, takes a certain amount of time. Once you have done this, you need to understand that you are about half done. Polishing code up to a suitable level of coherence and maintainability, proper handling of edge cases and failure cases, unit testing, integration testing, usability testing/demos, "last-minute" feature changes, performance, serviceability, documentation... all of these things can take immense amounts of additional time, and they are also part of your job.

__If something gets forgotten by you or your team often enough, just automate it.__

>When this happens, there are two ways to get the developer base as a whole to change its behaviour:
>
>1. Socialise it. Tell everybody in person, one at a time or at the scrum or at the team meeting. Send out emails. Add the new guidelines to the wiki, or to the repo README, or the pull request remplate. Remind people to read the documentation, over and over. Manually review everybody's changes for oversights, forever. Make sure you never forget! Add checklists, try to train everybody to properly enforce those checklists. Increase the level of mandatory peer review. Remind everybody again. And again...
>2. Automate it.

__The happy path is the road-less-travelled. Plan for the worst.__

>Edge cases are our _entire job_. Think about ways in which things can fail. Think about ways to try to make things break. Code should handle _every_ possibility.

__KISS: Keep it simple stupid.__

>If you budgeted your time properly (see above), you have time to go back and see if you can do better. _C.f._ the old chess adage, "When you see a good move, look for a better one." And another difficult-to-source quote, "I apologise for writing such a long letter, but I didn't have time to write a short one."

__KITS: Keep it testable stupid.__

>Code which is proving to be difficult to test is probably not properly encapsulated.

And I think that he makes a great point with his last heading alone...

> **It is insufficient for code to be provably correct; it should be obviously, visibly, trivially correct**

Take a look at this article for yourself! There's plenty of wisdom here. Maybe it's not groundbreaking for you, but if we actually do the things that are written here, we can stop giving junior devs a bad name!