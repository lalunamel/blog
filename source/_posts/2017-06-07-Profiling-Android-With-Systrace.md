---
layout: post
title: Using Systrace and Profile GPU Rendering to Reduce Jank in the Tracker Android App
date: 2017-03-02 06:24:59
tags: [Software, Android]
excerpt: "An in-depth picture of the rendering bottlenecks in Tracker Android using Systrace and Profile GPU Rendering"
---
This post was originally prepared at and for the Pivotal Tracker Team in Denver, CO. [It appears on the Pivotal Tracker blog](https://pivotaltracker.com/blog/using-systrace-profile-GPU-rendering-Tracker-Android/).

When the Tracker Team noticed jank while using the [new and updated](https://www.pivotaltracker.com/blog/android-1.0/) Android application we went straight away looking for something like Chrome's [Timeline tool](https://developers.google.com/web/tools/chrome-devtools/evaluate-performance/timeline-tool). For Android, that tool is [systrace](https://developer.android.com/studio/profile/systrace-commandline.html). We also used Android's native 'Profile GPU Rendering' feature to get a more in-depth picture of the bottlenecks in our app's rendering pipeline.

This guide is intended as an addition to the official Google documentation [Analyzing UI Performance with Systrace](https://developer.android.com/studio/profile/systrace.html) and the page that describes [Systrace](https://developer.android.com/studio/profile/systrace-commandline.html); it is written because those pages offer good technical detail and answer a few specific questions, but aren't organized well and don't address the general usage of the tool.
    
### General Information About Android Performance

Before viewing the results of your trace let's understand what we're aiming for when we're profiling. 

Google has produced a [few videos](https://www.youtube.com/playlist?list=PLOU2XLYxmsIKEOXh5TwZEv89aofHzNCiu) that give a great overview of this topic. The series of videos that are pertinent to this discussion start with "Android Performance Patterns: Rendering Performance 101" and end with "Android Performance Patterns: Overdraw, Cliprect, QuickReject."

**The golden rule for display performance is as follows:**

Displays render at 60 frames per second, 1000ms exist per second, 1000ms/60fps, therefore **we have 16.66ms to render each frame**.

Keep this metric in mind as you profile your app. Frames that take longer than 16ms to render will produce visual stutter.

### Profile GPU Rendering

The easiest way to understand the rendering performance of your app is to use Android's built in `Profile GPU Rendering` tool. Google has written [documentation](https://developer.android.com/studio/profile/dev-options-rendering.html) covering how to get it up and running and some basic instructions on how to use it.

Once you get the profiler running, open your application. The graph at the bottom of your screen will slide to the left as new frames are rendered. The Y axis of the graph represents the render time of each frame. The horizontal green bar at the bottom of the graph represents the 16ms threshold. Frames that take longer than 16ms to render will be slightly wider. If your app has multiple frames above the green line it has entered the [Danger Zone](https://youtu.be/ZzQ3eBerHfM?t=54s) and will look janky.

![Profile GPU Rendering on an Android Emulator](https://imgur.com/5RjmfF1.png)

The graph includes many different colors. Take a look at [Google's handy guide](https://developer.android.com/studio/profile/dev-options-rendering.html) to understand what each of these mean.

Play around with your app. Do some expensive operations. Note when the graphs rise above the green line. Once you've found a few places that do expensive rendering operations, take a closer look using `systrace`.

### systrace

Just like Chrome's Timeline tool, `systrace` captures the operations of your application (using `adb` and `atrace`, which uses `ftrace`) and displays them in a handy timeline format. You can invoke the tool either through Android Studio or via the command line. I prefer (and this post will cover) the latter because it lends a bit more transparency to any errors you encounter in the process. This guide will use `systrace` with Android 4.3 and higher (the official guide covers using the tool with all versions of Android).

#### Setup

`systrace` is a python script bundled with the Android SDK and is located in its `platform-tools` directory. It also requires root access on the device you're testing on. I recommend using an emulator rather than rooting a physical device.

###### So, you'll need:

- Python
- Android SDK
- An emulator (Run with something like Android Studio)

Once you've got those dependencies met, run your application on the emulator.

Because `systrace` requires root permissions, open up your terminal and restart adb with `adb root`.

On your local machine, change directories to `systrace` with `cd $ANDROID_HOME/platform-tools/systrace`.


##### Before you start tracing

Here's a few interesting configuration options. For a complete list, see [systrace](https://developer.android.com/studio/profile/systrace-commandline.html) or `python systrace.py --help`:

- `-t <seconds>` or `--time <seconds>` specify the length of time `systrace` will trace your application
- `-o <OUTPUT_FILE_PATH.html>` specify where you'd like the output to be saved (`systrace` renders output as an html document)

Once you've got all your options figured out, run something like `python systrace.py -t 5 ~/Desktop/android_trace_1.html`

##### Errors you might run into

Running `systrace` for the first time resulted in more than a few errors for us. The docs say nothing about most of them, so here are the solutions we found:

- `ImportError: No module named serial`
    - Install `pip`, the python package manager. Then install the `serial` package with `pip install pyserial`
- `adb cannot run as root in production builds`
    - You're running `systrace` against an unrooted device. Start up the Android emulator instead.
- `IOError: Unable to get atrace data. Did you forget adb root?` along with a scary looking stack trace
    - You're not running adb in root mode. Restart it in root mode with `adb root`
- If you've got multiple emulators or devices running on your machine
    - Only run/connect one device or emulator to your machine
    - Specify which device to use with `-e DEVICE_SERIAL_NUMBER`

##### Viewing the results of your trace

Go ahead and open up the output of `systrace` in Chrome (it doesn't open properly in Firefox).
The trace file looks pretty intimidating from the outset, so let's break it down:

- Navigation
  - The tool palette on the right side of the window includes the event selector, pan, zoom, and timespan selector tools
    - ![event selector tool](http://imgur.com/ESpz3hV.png) The event selector tool allows you to select a single event with a single click, or multiple events by clicking and dragging a selection rectangle
    - ![pan tool](http://imgur.com/PPC2HXD.png) The pan tool allows you to pan your view up, down, left, and right
    - ![zoom tool](http://imgur.com/5HJA591.png) The zoom tool allows you to zoom in by clicking and dragging up and down
    - ![timespan selector tool](http://imgur.com/7cSGGY2.png) The timespan selector allows you to highlight a time range by clicking and dragging left to right
  - You can view navigation shortcuts with `?` or with the question mark icon at the top right
  
  
Select the event selector tool by clicking on it in the floating toolbar or by pressing `1`. 

###### UI Thread (and other threads)

Click on a slice in the `UI Thread` section. 

The bottom section of the window will display information about the item you just selected, including it's name, timing information, and perhaps documentation.

You'll notice a thin bar displayed at the top of the `UI Thread` section. This thin bar is separated into selectable pieces:

 ![Thin bar at the top of UI Thread](http://i.imgur.com/f75pyel.png)
 
- Green (Running)
  - Code from the thread is running on a CPU. The entry `Running instead` will describe which CPU is doing the work. You can click on this description to select the block at the top of the page in the `kernel` section.
- Blue (Runnable)
  - Code from the thread is ready to run, but something else is occupying the CPU. The entry `Running instead` will describe what is running instead of this code.
- Red (Uninterruptible Sleep)
  - Code from the thread is sleeping and will not respond to wake up signals. I'm not a systems programmer, but [Wikipedia tells me](https://en.wikipedia.org/wiki/Sleep_\(system_call\)#Uninterruptible_sleep) this happens while waiting for IO.
- White (Sleeping)
 
  
###### Frames

Click on an `F` in the `Frames` section.

These `F`s represent frame renders. Green `F`s mean that a frame has taken less than or equal to 16.6ms to render. Yellow and red means that a frame has taken longer than 16.6ms to render. Selecting a yellow or red frame will describe the problem that caused the long render times.

Press `v` to highlight [VSync boundaries](https://www.youtube.com/watch?v=1iaHxmfZGGc) and get a good sense of what 16ms looks like on the graph.


### Outcomes for the Pivotal Tracker Android Application

After learning how to use `Profile GPU Rendering` and `systrace`, the Tracker mobile team wielded their powers to squash jank in our new Android application. 

We found that loading and switching between project panel fragments (the various lists of stories available under Backlog, Icebox, etc) caused a significant amount of the jank we saw on the projects page. This happens because the project panel loads many stories, each of which has _its_ own views.

After investigating a few options (e.g., flattening the view hierarchy) we decided that the quickest and easiest way to reduce jank was to cache the project panel fragments displayed in the project panel list (Backlog, Icebox, Epics, Done, My Work). 

It turns out that when asked to switch from the first to the last tab in its list, the default behavior of a ViewPager is to render all intermediate views along the way. Rendering four (complex!) panels instead of one is a great way to cause jank, but it's necessary effect for the ViewPager because it creates fluidity and the perception of persistence in the application.

Rather than rerendering every panel in-between, we cached the project panel fragments with `viewPager.setOffscreenPageLimit` to reduce visual stutter when switching between project panels. The only downside to this caching is a slight (10MB) increase in memory footprint, which we are willing to pay for the performance gains.

![Backlog to Done Rendering Performance](http://i.imgur.com/uiKkoqF.png)

As you can see, caching pages on the ViewPager doesn't increase the speed of rendering a panel the first time it is visited.

![Backlog to Done to Backlog Rendering Performance](http://imgur.com/fkqcqHw.png)

On subsequent renders, though, the rendering speedup is significant. This fix doesn't address the underlying issues (complex and nested view hierarchies) which would take a long time to diagnose and treat but it does offer a great benefit for a small cost. 

<br/>

The rendering profiling tools available on the Android platform are quite complicated. Hopefully this post has made clear the concepts behind rendering performance and some of the undocumented aspects of these tools. 

If you'd like to see the results of our profiling in a real world application, be sure to download Pivotal Tracker's redesigned and rewritten Android Application.

Make sure to checkout out our previous blog post, [Re-Engineering the Pivotal Tracker Android App](https://www.pivotaltracker.com/blog/reengineering-android/), for an overview of the technical considerations that went into building Pivotal Tracker for Android.