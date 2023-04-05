title: Debugging XCode Build Performance by Understanding llbuild
date: 2023-03-20 11:36:33
tags: [iOS, Swift, XCode]
excerpt: "The XCode build system is used every day by every iOS and Mac developer, but not many people understand how it works. Here's a small, technical overview."
---

XCode is a powerful tool that allows developers to create amazing apps, games, and full featured applications. I've used it as a mobile developer in the past, and now as a mobile infrastructure engineer. Most of the time it does its job without complaint, but sometimes it doesn't, and doesn't give much indication as to why.

I've explored the nitty gritty of [how Android apps get built efficiently](https://www.youtube.com/watch?v=m2Zb6Nkq0n0) and here I'll document the same, but for the build system used by XCode called `llbuild`.

`llbuild` [was integrated into XCode fairly recently](https://developer.apple.com/documentation/xcode-release-notes/build-system-release-notes-for-xcode-10) (XCode 10, 2018) and is still sometimes referred to as "the new build system". The [next version is in the works](https://forums.swift.org/t/llbuild2/36896), but that's probably a long way out and will change a fair bit before it's used.

Both build systems for Android and iOS (Gradle and `llbuild`) operate with similar fundamental concepts. Gradle operates on `tasks` with `inputs` and `outputs`. `llbuild` uses `commands`, `rules`, and `tasks` - all of which also have `inputs` and `outputs`. In order for builds to operate efficiently, the inputs and outputs from a build are recorded and stored. On subsiquent builds those outputs are reused if the inputs haven't changed. That's the basic idea behind incremental compilation, also called compilation avoidance.

So if a clean build takes 10 minutes, subsiquent builds with no changes should hypothetically run in seconds - the power of caching!

But what happens when the dream of incremental compilation doesn't come true? Up until recently I chalked it up to "just the way things are". Today, though, lets dive in and figure out what's really going on and how we can reach the promised land of build system performance and 0 sescond incremental compilation.

### Investigating a slow incremental build

#### Finding the slow part

Before we get into the details, find a part of the build to investigate. For this I recommend XCode's "build with timing summary" or the third party tool [XCLogParser](https://github.com/MobileNativeFoundation/XCLogParser). A ton has already been written on how to use these tools to find slow aspects of a build, so I won't duplicate that here - a quick google will turn up some great guides.

#### The information we'll be working with

Now we'll get some files in front of us and explore what they do and how they're structured.

Firstly, run this in your terminal: `defaults write com.apple.dt.XCBuild EnableBuildDebugging -bool YES`.

That will tell XCode to enable build debugging output, which will tell `llbuild` to do the same. Once you're done debugging your builds, change that `YES` to a `NO` and rerun the command. The artifacts that get produced are a bit less than 100Mb per run, which can really add up if you're building all day every day.

Now, build your project with XCode. The build logs (View > Navigators > Reports) will tell you about a few new files:

- `manifest.xcbuild`
  - This is the `build file` that describes your build as a yml file with a bunch of json in it. It's fed to the build system as a set of instructions.
- `build.db`
  - This is an SQLite database that holds prior build metadata. It's one half of the cache that allows incremental compilation. The other half is the actual files stored in DerivedData.
- `build.trace`
  - The trace file is the log of what `llbuild` actually did as it executed the instructions in `manifest.xcbuild`

#### Investigating

Now, lets look at those files and investigate what's going on. Open up the `manfifest.xcbuild` and `build.trace` in your text editor of choice (careful - they're big!). You can find the exact location of those files by looking at the build log file in the Report Navigator.

This next part will be fairly freeform - you're going to need to put on your detective hat and explore:

1. Start by taking a look at the `build.trace` and try and find any log lines related to the slow aspect of the build you're investigating.

  Eventually you should find a line that mentions the framework you're interested in and whatever operation is taking a long time - maybe the string `:Debug:CompileSwiftSources` if you're curious about why the framework is being recompiled. Try and find the line that describes the entire slow operation you're interested in and not just one part, i.e. compiling an entire framework rather than an individual file.

2. After you've located the slow operation, the next question to answer is "why did this happen?"
  To answer this, just employ the standard process you use every day to debug regular programs: start from the observed behavior, walk backwards to find its cause, and repeat until you find the root of the problem.

As you're working through the trace, use the handy glossary at the bottom to understand what each line means.

Eventually you'll reach a trace line that makes you say "huh, I didn't modify that file!" or "why'd that change?". What you do next will totally depend on the aspect of the build you're investigating, the cause of the slowness, and so on. I'll leave that up to you!

#### Wrapping Up

Assuming you've followed the steps above, you've walked backwards from the observed slow behavior and found its root cause, whether that's an errant file modification, mis-configured build settings, or something else. Hopefully you've been able to remedy that root cause and are on your way to faster, more consistent builds.

Remember that you don't have to tackle every single slowdown all at once! Any non-trivial XCode project will have multiple steps that can be improved or optimized.

Good luck, and keep working towards 0 second incremental builds in XCode!

#### Glossary

##### Anatomy of a trace line

```
{ "new-rule", "R7897", "N/Users/blah/foo/bar/file.json" }

The first element is the "trace keyword" - it describes what this trace line is doing
The second element is the rule ID, formatted something like R###
The third element is the rule key, and it usually looks like the path to a file. The N at the front is a marker for the build system. It might be a different capital letter sometimes.
```

```
{ "rule-scanning-next-input", "R7853", "R7854" }

The first element is the trace keyword
The second element is a rule ID for the rule that's being scanned
The third element is a rule ID for the input of the rule that's being scanned. 

Think of it this way: the third element is an input to the second, and therefore to scan the second element, all its inputs must be scanned as well - that's what's happening here.
```

##### Trace keywords

- `new-task` - when a new task is created
- `new-rule` - when a new rule is created
- `build-started` - when the build is started
- `handling-build-input-request` - when a build input request is handled from the BuildEngine. A "build input request" is a request made by a `rule` to do some work
- `created-task-for-rule` - when a rule creates a task to do some work on its behalf
- `handling-task-input-request` - when a build input request is handled from the BuildEngine. A "build input request" is a request made by a `task` to do some work
- `paused-input-request-for-rule-scan` - when a rule is scanned, but already marked as "pending scan", so it's skipped and not scanned twice 
- `readying-task-input-request` - when a rule's inputs are computed/completed and the work that the rule represents is enqueued
- `added-rule-pending-task` - when a rule's inputs are not computed/completed and the work that the rule represents is attempted to be enqueued (but fails because its inputs are not ready)
- `completed-task-input-request` - when a rule is dequeued after it's been enqueued by "readying-task-input-request"
- `updated-task-wait-count` - when a task is no longer waiting on an input (tasks wait on all their inputs before they're run)
- `unblocked-task` - when a task is no longer waiting on any inputs (happens right after "updated-task-wait-count")
- `readied-task` - when a task is dequeued from `readyTaskInfos` queue and ready to run. The `readyTaskInfos` queue contains tasks that are waiting on no inputs
- `finished-task` - when a task is dequeued from `finishedTaskInfos`. Tasks are placed on this queue when they are completed. A task is "changed" if its value was computed in the current build (and not pulled from a prior build).
- `build-ended` - when the build ends
- `checking-rule-needs-to-run` - when a rule is scanned to determine whether or not it needs to be run
- `rule-scheduled-for-scanning` - when it is determined that a rule needs to be run and it is enqueued for processing (where its inputs are checked to make sure it's ready to run, then it's executed)
- `rule-scanning-next-input` - while a rule is processed, when one of its inputs is retrieved and enqueued for scanning, and has been scanned already
- `rule-scanning-deferred-on-input` - while a rule is processed, when one of its inputs is retrieved, has not been scanned, and is therefore enqueued for scanning
- `rule-scanning-deferred-on-task` - when a rule is processed, when one if its inputs is retrieved, has been scanned already, but the task representing that input has not been completed
- `rule-needs-to-run, never-built` - when a rule is scanned and has not been run and therefore is marked as "needs to run"
- `rule-needs-to-run, signature-changed` - when a rule is scanned and the file associated with the rule for this run has a different `signature` than that of the previous cached build
- `rule-needs-to-run, invalid-value` - when a rule is scanned and the file associated with the rule for this run has a different `stat` output (file modification time and other file metadata) than that of the previous cached build
- `rule-needs-to-run, input-missing` - this is a possible trace output, but it isn't currently used anywhere
- `rule-needs-to-run, input-rebuilt` - when the rule has been computed at a certain time, but has an input that's been computed more recently
- `rule-does-not-need-to-run` - if the rule has no dependencies
- `cycle-force-rule-needs-to-run` - force a rule to be run in order to break a build cycle `llbuild` has detected
- `cycle-supply-prior-value` - when a rule is forced to be run in order to break a build cycle and the value from the previous build is set as the rule result

##### `manifest.xcbuild` (build file)

This file describes your build.
It has a few different parts: `client`, `target`, `nodes`, and `commands`.

I've not seen `client` or `target` contain particularly useful information. `nodes` and `commands` are where it's at.

You can find the source documentation for each of these things [here](https://llbuild.readthedocs.io/en/latest/buildsystem.html#build-file), but I'll cover them in my own words now.

##### Nodes

A `node` represents some input or output of the build process. Typically, this is a file.

Nodes can have [attributes](https://llbuild.readthedocs.io/en/latest/buildsystem.html#node-attributes).

#### Sources

- Gist from Daniel Dunbar (works at apple on build systems) describing how to turn on build debugging
  - https://gist.github.com/ddunbar/2dda0e836c855ea96759d1d05f086d69
- `swift-llbuild` repo
  - https://github.com/apple/swift-llbuild
- Docs on `llbuild`
  - https://llbuild.readthedocs.io/en/latest/buildsystem.html
- Blog post on this whole thing
  - https://asifmohd.github.io/ios/2021/03/11/xcbuild-debug-info.html
- My raw notes on this post
  - https://gist.github.com/lalunamel/716de8bb16cbf1d942324fc2120931ee
