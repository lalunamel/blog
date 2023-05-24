title: Introducing Filewatcher
date: 2023-05-23 11:36:33
tags: [Software, Swift, XCode]
excerpt: "FileWatcher is a tool for developers that observes the Mac filesystem. It can observe over 30 different types of events!"
---

I'm a person who likes to know how things work. Every couple of years I revamp my text editor setup because I think there might be a slightly more efficient way to do things. I'll admit that's probably overkill, but having curiosity and pushing for efficiency is at the heart of what it means for me to be a software developer.

Sometimes I'll be using the computer and it'll get slow, or it'll do something wacky, and I'll think "what the heck is going on here?" I built something that can help answer that question - I call it FileWatcher.

FileWatcher is a native Mac app for developers that observes the filesystem. I built it because I wanted to know what my compiler was doing behind the scenes.

It uses Mac's [Endpoint Security](https://developer.apple.com/documentation/endpointsecurity) framework and a custom System Extension to efficiently watch for events. That's the same stuff used by anti-virus software - pretty neat!

It's my first Swift app and I'll say that I enjoyed the development experience about as much as any iOS app I've worked on. I started it in SwiftUI and about half way through, realized that SwiftUI was not ready for prime-time and had to rewrite it in the old ViewController style. Beyond that, there was lots of guessing and googling to make up for Apple's lackluster documentation.

So far I've used it to discover hidden aspects of NPM, figure out why XCode doesn't engage in incremental compilation, and find out that Spotlight is _constantly_ indexing my machine.

If you're interested in trying it out, head over to [filewatcher.app](https://www.filewatcher.app)!