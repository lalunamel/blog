---
layout: post
title: Bugs in Android Found While Creating a Constraint Layout Programmatically
date: 2018-05-13 06:24:59
tags: [Software, Android]
excerpt: ""
---

## Creating an App with a Programmatic Constraint Layout

A few weekends ago I decided to muck around in Android to keep my mobile development skills sharp. I'm currently a Fellow - a sort of temporary instructor - at a code school in Denver called [Turing](www.turing.io). I work in the front end program, which is mostly Javascript, so I was eager to get back to stronger typing of Java/Kotlin.

The project I'd work on, I'd decided, was going to be an app that would notify you when it's time to go to bed by telling you "You have XhYm until you wake up tomorrow." I use [Flux](https://justgetflux.com/) on my Windows machine, and it shows a similar notification at night time. I find the wording to be much better than "You've have XhYm until you need to go to sleep."

When I stopped doing Android development, the new hot thing was [ConstraintLayout](https://developer.android.com/training/constraint-layout/). Android's support for ConstraintLayout has only grown, so I thought I'd try it out in my toy app. Additionally, I'd heard good things about programmatic layout creation (as opposed to managing layouts via the Android Studio XML editor), so I decided to go in that direction, too.

Almost immediately I encountered some befuddling layout behavior. A button with a long title and margins on either side had disappeared! Disappointing, but not entirely unexpected. This isn't too far off from my normal experiences - all of the layout systems I've encountered (Web, Android, iOS) don't work in a way that makes sense to me at first glance.

Despite my expectations, tracking down the root causes of this behavior actually led me to a bug in Android and it's documentation. Let me explain!
