---
title: Start Automating Easy Tasks
date: 2025-02-06
summary: via Alex Tiniuc
description: via Alex Tiniuc
toc: false
readTime: true
autonumber: false
math: true
tags: ["via", "automation"]
showTags: true
hideBackToTop: false
draft: false
dev: true
dev_id: 2262995
---
Quotes courtesy of Alex Tiniuc, from his article [Unexpected Benefits of Building Your Own Tools](https://tiniuc.com/make-more-tools/)

The amount of time that you can sink into creating a tool to automate a task can sometimes feel like an overcomplication of something that you could just *do.* I certainly feel that way, but Alex Tiniuc makes a good case for spending this time making tools.

>What this has made me realize is that **speeding up part of a workflow can provide value far beyond the mere time savings**: it also unlocks new ways of working that were not possible before.

Creating tools that optimize your workflow save time, which inevitably leads to more discovery taking place in the design process.

>Essentially, the more iterations of the design you can make, the higher quality your game will be - limited, of course, by your budget.

Even if what you want to automate is small, Alex would argue that it's still worth automating.

>One of the highest returns on investment I've had on workflow automation was the script below. It rebuilds an OpenWRT image from scratch with updated dependencies.

```bash
#!/bin/sh
./scripts/feeds update -a
./scripts/feeds install -a
make clean
make -j12
# Write logs to file, for debugging
#make -j12 V=sc -k 2>&1 | tee build_log.txt
cmatrix -b
```

>Ive *(sic)* lost count of how many times I ran `make` without first updating the feed I was working on! The call to `cmatrix` at the end plays a Matrix inspired stream of green characters the moment the build finishes. This solves the problem of starting the build, working on something else & not noticing that the build has completed even when it was a rather high priority task!
>
>Lets say this script took five minutes to write. If it saves one rebuild, _it has already paid for itself four times over_. It has saved _much_ more time since. Thanks to this script, debugging certain things that used to take a whole day now can be done in just a few hours.

Start small, what's one task that you can automate today?