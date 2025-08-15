---
title: The Perfect Programming Environment
date: 2025-08-11
summary: "Creating my first dotfiles repository"
description: "Creating my first dotfiles repository"
toc: true
readTime: true
autonumber: false
math: true
tags: ["automation", "tooling", "bash", "learning"]
showTags: true
hideBackToTop: false
draft: false
dev: false
---

I often encounter programming terms and lingo that goes way over my head when I'm browsing software engineering content on the internet. I wish that I could say that I drop everything and search these terms as soon as I see them, but this is rarely the case. But, this article is about a time that I took my medicine and not only looked up something I didn't understand, but implemented it into my daily workflow. 

The term? —*dotfiles*

## Centralized and Modular Configurations
### What are dotfiles?

Maybe you're more hip than I was, but if you're not, let me fill you in. *Dotfile* is technical shorthand for a hidden file on your system that provides configuration settings to your operating system, shell, or applications. Most systems' preferred method of hiding files s to add a `.` at the beginning of the file—hence, *dotfile*. 

Many developers choose to alter these files to exert a level of god-like control over their own computers (i.e. to change the color of their terminal prompt... ). Having these files spread across the computer can make them difficult to update and maintain, so it's convenient to package them together into a personal *dotfiles* git repository.

Alright, you're filled in, and I'll admit that on the face of it, dotfiles sound pretty boring. I expected this project to fulfill my neurotic need to organize, but in the end, I found that it presented interesting challenges to solve, and that this project represents the only project that I've built that I use *daily*.

### Why I created my own dotfiles

I hesitate to write this, but Pewdiepie (yes, the Fortnite streamer) was actually the first inspiration for this project. After [watching him install Arch](https://www.youtube.com/watch?v=pVI_smLgTY0), I went down a rabbit hole of customization possibilities for my own devices. 

The discovery of this video coincided pretty closely with the beginning of my transition to Neovim (by the way). Neovim's configurations are all stored in text files, text files that are notoriously easy to break and hard to recover if you've made too many changes at once. It's a good idea to keep these tracked in a git repository, and to change them intentionally so that you can run `git reset HEAD --hard` when the worst happens.

I am not an Arch Linux user quite yet, but my current OS's were another motivation. I work on Windows and do personal development on Mac. If I want to make a change to my dev environment, I'm adjusting it in two places. Not all of the applications that I use are cross platform, but I still like to keep as much of the workflow the same as I can. This means that I wind up translating keyboard shortcuts and other configurations from one DSL to another. This is much easier, when everything is centralized. 

Writing my own version-controlled and modular dotfiles repository solves all of these problems. But, I'd be lying if I said that the primary reason wasn't just that I like to tinker, and this may be one of the most fun ways to explore your operating system.

### Making it your own

In 2010, developer and startup advisor, Zach Holman, wrote a piece called [Dotfiles Are Meant To Be Forked](https://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked/), where he argues that some of the best developers have horribly disorganized configurations, and that a dotfiles repo should be well designed, personalized and extensible. He ends the article with an encouragement to get started:

>So, [fork it](https://github.com/holman/dotfiles). Or, if not mine, then fork some of the awesome other projects I mentioned. Or come up with your own way of organizing your stuff and share it. Everyone’s got their own way of streamlining their system, and sharing dotfiles helps everyone.

I would only alter this advice slightly. If you haven't created your own dotfiles repository before, start from scratch. Before going to see what other people have done, find out what problems *you* are trying to solve for *your* workflow. Once you've done this, digging into someone else's configurations can give you inspiration for things to change. But, I've found that adding configurations from others has led to creating features that I never use, and a more difficult to maintain repository that is cluttered with unnecessary configurations.

This might sound strange coming from a blogger who is about to tell you about his own dotfiles. My goal with this article is not to show you every inch of my configuration. In fact, I won't discuss most of the configurations at all. Rather, I want to give you a skeleton that will get your own repository *working*. The questions that I will answer today are: "How do I centralize my config files?" and "How can I make them modular?"

I'm hoping that removing this barrier makes it easier for you to joyfully discover your preferences, your operating system, and new tools and applications shared by the community.

## Building Dotfiles

### Centralizing configurations

The first problem to solve when creating a dotfiles repo is getting all of your configurations into one directory without breaking all of the software and firmware that read from them. These files are typically located in a few different locations on your computer. That means the configurations aren't portable or easily maintainable. To solve this we need a way to tell our computer where to look for our configuration files.

Luckily, the solution for this is built into your operating system. It's called symbolic linking or symlinking. 

When we boot up, say, Neovim (by the way), the application tries to set its configuration by looking for files. By default, it goes to my user directory for this path `~/.config/nvim`. We could just put the configuration files there, *or* we could put a symlink there that basically says, "This file that you're looking for is over there." The computer will redirect to the linked file or files and read them as if they are in the location of the symlink. 

Let's take another example, a `.zshrc` file that contains some customizations on my terminal prompt. For my terminal to read this file, it has to be in my user directory. If I want to keep this file in my dotfiles repo I'll create a symlink at `~/.zshrc` that points to `/Projects/dotfiles/.zshrc`. Now when the computer goes to `~/.zshrc` it's invisibly redirected to the file at `/Projects/dotfiles/.zshrc`. My terminal can read its configurations and I get to keep them in a tidy folder with all my other configurations.

Implementing a link in a unix-based environment is as simple as running the command:

```sh
ln -sf [source] [link]
```

... where source is the file in your dotfiles and link is the location that you want to put the link.

The following script will allow you to quickly add source/link pairs.

```sh
# Create an associative array for source/target pairs
typeset -A links
links=(
  "$DOTFILES/mac/.zshrc" "$HOME/.zshrc"
  "$DOTFILES/mac/.zprofile" "$HOME/.zprofile"
  "$DOTFILES/mac/.zshenv" "$HOME/.zshenv"
  "$DOTFILES/shared/nvim" "$HOME/.config"
)

# Loop through each key in the associative array
for source in "${(@k)links}"; do
  link="${links[$source]}"
  backup="$link.backup"

  # Check if the link target or [target].backup exists
  if [[ -e "$link" && ! -e "$backup" ]]; then
      if [[ ! -d "$link" ]]; then
		# Backup any existing configuration files (just in case)
        mv -f "$link" "$backup"
        echo "Backed up: $backup"
      fi
  fi

  # This section handles making sure that parent directories exist
  #
  # Checking if the source is a directory and the
  # target doesn't exist
  if [[ -d "$source" && ! -e "$link" ]]; then
      mkdir -p "$link"
  else
	  # We need to split the file name off of the path to 
	  # create all the parent directories.
      parent_dir="${link:h}"
      mkdir -p "$parent_dir"
  fi 

  # Create the link
  ln -sf "$source" "$link"
  
  if [[ -d "$source" ]]; then
      echo "Linked ${source:t} directory to $link"
  else
      echo "Linked ${source:t} to $link"
  fi
done
```

As you need to centralize more files, and create more links, they can quickly be added to the `links` array at the top, and the links will automatically be created. As I encounter more configurations across my system that I'd like to change, it's very simple to add them here, link them, and run the script. The friction to making changes now is pretty much gone. 

### Making them modular

While having everything in one place makes things easier to maintain, if the files get unmanageably long, then that friction comes back. So, combining related configurations into well-named files is a must. I'll focus here on two methods to modularize your configuration files, one for language-based configurations and one for plaintext configurations.

If you're interested in the structure that I use to modularize the configurations of my different operating systems, check out the [repository](https://github.com/nmiller15/dotfiles).

#### Scripting-Language Configurations

When splitting up configurations into multiple files, it's important to know the configuration language of the application. Sometimes, this is a Turing-complete language like Bash or Lua, but other times its a domain specific language (DSL) that can only be used with that piece of software.

When we scripting languages, the way that we make things modular is a bit more straightforward. Let's look at my `.zshrc` for example. I want to customize my prompt, add some functions and keep aliases as shortcuts to different locations on my drive. Since, the `.zshrc` is written in Zsh (very similar to Bash), I can organize my configurations into separate files like this:

```
dotfiles/
├── shell/
|   ├── aliases.sh
|   ├── functions.sh
|   └── prompt.sh
├── .zshrc
└── bootstrap.zsh
```

My shell is still going to look for a `.zshrc` file, not our modules. Instead of jamming all of our configurations in the file, we will tell it to look for our dotfiles repository and loop through the `shell` subdirector and source every readable file that ends in `.sh`.

```sh
DOTFILES="$HOME/Path/To/dotfiles"

for FILE in $DOTFILES/shell/*.sh; do
    [ -r $FILE ] && source "$FILE"
done
```

#### DSL / Plaintext Configuration

While DSLs can still be Turing-complete, many configuration languages aren't, which means that we don't have access to helpful things like conditionals or loops. To make modular configurations, we are going to have to construct the source files from our modules using a scripting language.

For my tmux configuration I have a similar directory structure to my shell configurations.

```
dotfiles/
├── tmux/
|   ├── theme.conf
|   ├── bindings.conf
|   └── general.conf
├── .tmux.conf
└── bootstrap.zsh
```

Notice that we still have a modular structure. But, our `.tmux.conf` file is written in plaintext, it's not executable, so we can't loop through the `tmux/` directory there. Instead, we have to write a function that can write our `.tmux.conf` to use in `bootstrap.zsh`:

```sh
write_conf () {
    local dir=$1
    local out=$2

    cat $dir/* > "$out"
    echo "# Conf written on $(gdate)" >> "$out"
}

write_conf "$DOTFILES/tmux" "$DOTFILES/.tmux.conf"
```

Now for every plaintext configuration, we can write every file in a given directory to a single file. I also added a timestamp to the end of the file to make sure the bootstrap script ran properly.

## Why I don't like forking

You can get a lot of ideas for your own configurations by perusing [my dotfiles](https://github.com/nmiller15/dotfiles), or any of the dotfiles that many people share on [reddit](https://www.reddit.com/r/dotfiles/), or [GitHub](https://github.com/search?type=repositories&q=dotfiles) or other sites. However, I think that *if you're just starting,* forking someone else's configurations can side-step the the self-discovery and growth than comes from starting from scratch. 

By all means, take inspiration from others, but the goal is to solve the problems that *you* have on *your* system. If you start with a fork dotfiles, you're getting someone else's solutions to someone else's problems. Often, these solutions have *way more* configurations that you want or need, because you're jumping into a repository that may have been built on for years. For me, that kind of starting point is overwhelming and adds friction when there are changes that I want to make.

## But, they're *your* dotfiles. 

So, do what you want. If you want to fork, fork. If you want to start from scratch, start from scratch. Nobody's opinion on your dotfiles matters because they are uniquely yours, for your computer, your workflow, and your enjoyment.

Happy scripting!