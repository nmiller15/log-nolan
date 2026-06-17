---
title: .NET Doesn't Suck in Neovim Anymore
date: 2026-06-17
summary: "roslyn-language-server to the rescue"
description: "roslyn-language-server to the rescue"
toc: false
readTime: true
autonumber: false
math: true
tags: ["dotnet", "neovim"]
showTags: true
hideBackToTop: false
draft: false
dev: false
---

I use Neovim btw...

Unfortunately, I'm also a C# developer.

Anyone who has used .NET in Neovim knows that the language support is tenuous. I've spent hours tweaking my configuration to get the `roslyn` LSP to interact with my code editor, and I could never get the limited feature set that I wanted to feel smooth and native the way other LSPs do in Neovim... especially razor.

That is... until now.

A few weeks ago with [this commit](https://github.com/seblyng/roslyn.nvim/commit/49526a2958893d0c8000d03b16ed923340ce13cc), the developers of the `roslyn.nvim` plugin made it *so* much easier to get up and running with the `roslyn` server that's officially distributed by Microsoft.

Early this year, Microsoft put out a prerelease of a new `dotnet` CLI tool `roslyn-language-server`. Before this release, developers got access to the server by downloading the binaries from an obscure azure feed and pointing the Neovim plugin  to the proper `dll`. Some adventurous and patient developers even got `razor` support in this method, but I was not one of them.

With an officially (pre-) released tool from Microsoft, downloading `roslyn` is now as easy as running:

`dotnet tool install -g roslyn-language-server --prerelease`

After a month or two, the developers of `roslyn.nvim` updated the plugin to support the new `roslyn-language-server` command to setup the plugin. They even set the plugin to search for it on a fallback by default, so no configuration changes are required.

My configuration for `roslyn.nvim` used to be about 20 lines of Lua. Here it is now:

```
  {
    'seblyng/roslyn.nvim',
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    opts = {},
  },
```

It's Simple. It works.

Large projects initialize relatively quickly, and all of the standard language server operations, like semantic highlighting, renaming, jump to definition/implementation, in-editor diagnostics, etc. are available out of the box.

I'm not exactly sure what magic the developers pulled here, but as I've mentioned, I've never gotten `razor` syntax support. With the recent updates, `razor` is supported!

I've been using this setup for about a month now, and it's been smooth and performant. I still have to restart the server somewhat frequently on large, sprawling solutions that have several projects, but development is still active on this plugin, and I expect to see improvements here soon!

If you've been holding off from switching to Neovim because of C# and `razor` support, your wait might be over. Give the plugin a try and see if your old frustrations are gone.