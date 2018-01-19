---
layout: post
title: Moving Away From a Dependency Injection Framework
date: 2018-01-18 06:24:59
tags: [Software, Kotlin]
excerpt: "There are a few ways to do dependency injection. Here's an exploration of constructors & factories in a small Kotlin Android app."
---

I've been reading up a on the fundamental elements of good software recently. The [Pluralsight course on SOLID](https://www.pluralsight.com/courses/encapsulation-solid) has been a great resource, and it's been interesting to finally read *Clean Code*[^1]

In that vein, I had a conversation with a coworker about the dependency injection framework used in the Tracker iOS app, how it was unwieldy and introduced a layer of indirection, and how they wanted to replace it with another method of dependency injection: constructors and factories.

Before that I had an inkling of how to use software components without dependency injection, but hadn't thought much about it beyond "Well, you'd need to pass an object's collaborators in somehow. Passing them through every function sounds like it'd get old fast." My conversation with my coworker helped me complete the thought:

- Constructors receive a component's collaborators and save them off as instance variables
- Factories wrap a component's constructor and allow clients of the component to be ignorant of the its implementation details

I like the constructor & factory pattern because it replaces an injection framework with plain old code.

The more I think about it, the more reasons I find for keeping your components as close to plain old code (POC) as possible:

- it's super easy to test POC
- there are fewer third party libraries to rely on and manage
- POC is performant (it's faster than any library)
- POC is easy to understand (there's no new API to learn)
- the tooling for the language you're in is at your fingertips

## Notes

I took some notes while I moved [my toy Android project](https://github.com/lalunamel/ReaderAndroid) [away](https://github.com/lalunamel/ReaderAndroid/commit/3f19d5160bc5c416ec36e2f96c3c57d221e9b251) from [Kodein](https://salomonbrys.github.io/Kodein/), a DI framework for Kotlin.

### Default objects and configurations are no longer centralized.
This felt weird at first. There's nothing inherently good about the centralization of configuration and default objects, but it still felt weird. The more I thought about it, the more it felt like the practice of putting all your controllers in one place because they exist on the same layer in your application, when it's actually more useful to group components by their domain or functionality. Totally okay with the decentralization of configuration now.

### Consumers now need to be aware of what implements an interface in order to get an object that implements that interface
Say you've got an application that searches for books, and an interface `BookSearchService` with a function `search(term: String): Observable<Book>`. You could use Amazon to search for books, or Google, or you could create an implementation of the `BookSearchService` that talked to your local library.

The consumers of that service don't need to know where the results come from (whether it's Amazon, Google, or another), so if you're using a DI framework, that detail can be hidden away in some file that binds all of your dependencies (in Kodein and others this is called a `Module`).

At first it made me uncomfortable to bring that detail into the factory method of a component, mostly because I defined the factory method and the component itself in the same file. Further thinking, though, made me realize that it's not the *physical* separation of that detail that matters, it's the separation of the *construction and the use* of that detail. As long as the place where the `BookSearchService` is used doesn't know it's actually an `AmazonBookSearchService`, that characteristic of the DI framework is maintained.

### What about creating instances of third party libraries?
I got into the groove of removing a component's dependence on a DI framework and replacing it with a factory method. Then I ran into a component from a third party library - how would I add a factory method?

Well, I didn't actually need to create a factory method - I wasn't responsible for wiring up that component's dependencies.

Separate from that, it's good practice to wrap third party libraries in an interface and have your clients consume that interface so you can isolate your code from any changes in the library.

<br/>

After reading these notes, every question I posed sounds really stupid and has an obvious answer to it.
I realize that after working through them, but perhaps the answers were just hard to see while I was shifting the paradigms I use to think about software.



[^1]: Perhaps I'll write up a post about it, but I didn't find *Clean Code* particularly groundbreaking. It focuses heavily on OOP but I feel like many of the concepts it analyzes are tenants of functional programming.
