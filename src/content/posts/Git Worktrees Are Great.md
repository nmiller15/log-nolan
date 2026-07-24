---
title: Git Worktrees Are Great
date: 2026-06-26
summary: "Get git worktrees working in under 5 minutes."
description: "Get git worktrees working in under 5 minutes."
toc: false
readTime: true
autonumber: false
math: true
tags: ["git", "tooling"]
showTags: true
hideBackToTop: false
draft: false
dev: false
---

I want to tell you about a tool I've been using for a few months now, that I can't believe that I ever went without. Recently, I've been more productive, experimental and I've learned more about my development environment just from using this tool. 

Alright, I'm done burying the lead. The tool is [git worktrees](https://git-scm.com/docs/git-worktree).

Worktrees is a feature built into git that allows you to have multiple working trees of a repository at once. That means you can have multiple branches checked out, with incomplete changes on each one. Instead of having one repository where your manipulation happens, you can have infinite copies (or, as many copies as you can hold on a hard drive)!

Often, I am in the middle of working on a feature and I get an email about an urgent bug or a small change that needs made immediately. Before, I would have to either create a "wip:" commit or stash my changes, and I don't really like doing either one of them. Now, as long as my files are saved, I can safely close my editor, create a new worktree and leave all of my uncomitted changes waiting for me to return.

## How to set up your project for git worktrees

In a normal project, your directory might look something like this:

```plaintext
MyProject/
├── .git/      <-- Git metadata in the project dir
├── bin/
├── obj/
└── Program.cs
```

After following just a few steps, our projects will look more like this:

```plaintext
MyProject/
├── .git/               <-- Git metadata
├── feature-x/          <-- Worktree #1
	├── bin/
	├── obj/
	└── Program.cs
└── bugfix/             <-- Worktree #2
	├── bin/
	├── obj/
	└── Program.cs      A full copy of the project's files.

```

In order to set a project up this way, it's best to start in an empty directory, with your project hosted on a remote git server. First, create a directory for your project.

```sh
mkdir MyProject && cd MyProject
```

Once inside, we're going to clone a bare repository. A bare repository doesn't contain a working tree or any of the files of the project, just the git metadata. We pull that and put it in the `.git` directory by running the following command.

```sh
git clone --bare <url> .git
```

When we do a normal `git clone`, since we have a working tree, our remote pipeline is automatically set up. But, since it's bare, we have to do this manually. This scary looking command maps all the entries in `/refs/heads` to the entries in `refs/remotes/origin`. I would honestly just save this one somewhere.

```sh
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
```

Now we're ready to create our first worktree. It's always a good idea to have the main branch checked out on your system, so that's where I usually start. Since the `main` branch is presumably already created, you don't need to add `-b`, but it doesn't hurt to explicitly tell git what branch you want checked out on your worktree. I always include this flag, plus, it automatically creates the branch if it doesn't exist!

```sh
git worktree add main -b main
```

Now we're officially set up to use git worktrees! But, we only have one worktree so far. Let's also open up a feature branch. First, make sure that your `main` branch is up to date (since we literally just made it, it will be, but it's a good habit to get into).

```sh
cd main && git pull
```

Then go back to your project directory and run the following command.

```sh
git worktree add newWorktree -b newWorktree main
```

Now we have a new worktree called `newWorktree` and a new branch called `newWorktree` based on the current state of `main`. You could specify any existing branch here to select the head of the branch. 

And that's it. When you're done you can safely blow away the entire worktree

```sh
git worktree remove newWorktree && git branch -D newWorktree
```

The ergonomics of using worktrees is a bit weird for a while until you're used to it. But, I've found the benefits far outweigh a few extra commands that you need to remember to run. Besides, you can always [script](https://github.com/nmiller15/dotfiles/blob/main/bin/pwsh/wtbuild.ps1) it! 