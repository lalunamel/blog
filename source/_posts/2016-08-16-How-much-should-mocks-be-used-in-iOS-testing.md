---
layout: post
title: "How much should mocks be used in iOS testing?"
date: 2016-08-16 20:28:01
tags: [Software, iOS, Testing]
excerpt: "Do mocks provide value when writing iOS tests, or are they more trouble than they're worth?"
---
As a newly minted iOS developer at Pivotal, I've had many discussions recently about the Right Way to write tests for iOS/Objective C/Object oriented applications. I'd like to document the key points from those discussions so that I can refer to them later and that one or two other developers will be able to glean some useful information for their own use.

It seems, from my limited obeservation of the outside world (i.e., not Pivotal), that tests aren't a big part of writing iOS applications. That is very strange to me, having been 'raised' at Pivotal and on the Tracker Team, where tests (and agile, by extension), are core practices. Regardless of your feeling around wiritng tests, I hope the following will be helpful.

So, question: *How much should mocks be used in tests?*

I'm using the word _mock_ in the sense of [Cedar](http://www.github.com/pivotal/cedar), the lovely testing framework by Pivotal that uses RSpec-like BDD syntax. A mock in Cedar is created with `nice_fake_for([Dog class])` or `fake_for([Dog class])`, where the first creates an object that _is a_ `Dog` and conforms to the interface of (implements the methods defined on) `Dog`, and the second merely creats an object that _is a_ `Dog`.

A view expressed by a more senior iOS developer in another office[^1] was roughly that mocks should only be employed at architectual boundries[^2]. Moreover, using mocks introduces more maintenance cost than say, using [factories](https://thoughtbot.com/upcase/videos/factory-girl?utm_source=github&utm_medium=open-source&utm_campaign=factory-girl), because every time the method `Dog.haveDinner` changes, I have to update my fakes and expectations with the new signature. A small iOS sidenote is that mocks don't work with Objective C's Key-Value system[^3]. 

On the Tracker team, the philosophy (and by extension, my philosophy) is that mocks should be used everywhere possible. The thought is that the unit under test should be ignorant of the side effects of it's calling of a method on another object. That is to say that the method

	Bowl bowl;
	Dog.haveDinner {
		bowl.eat()
	}
	
should be ignorant of the effects of calling `bowl.eat`, and the test shouldn't have to deal with the internals of a `Bowl`, only that `Bowl.eat` was called.

By not using mocks, your test code will necessarily execute the implimentation of whatever method your unit is calling, causing a cascade of method calls you have to account for and slowing down your tests a bit. The bit about cascading method calls breaks one tenet of unit testing: that the test and unit under test should be ignorant of their dependencies other than those dependencies' interfaces.

This isn't so bad when the dependency is a simple POJO (or POOCO, or whatever), but that's rarely the case.

The point that using mock objects introduces more maintenance costs is not as significant as one might expect. Say you've written several tests that mock out `Dog`, `Dog.haveDinner` and make expectations. Now you add a parameter to `Dog.haveDinner` and uh-oh, you've changed the method signature and have to go through and add that parameter to your test code! This can be solved by your handy-dandy IDE and it's refactor functionality. Any IDE worth it's salt[^4] will allow you to rename a method and highlight all it's usages that need to change. If you're confident, you can even use find and replace[^5] to do all the heavy lifing.

The alternative that is presented in place of mocks are factories. I dislike factories in unit tests because they require that you [create and manage the world](https://www.youtube.com/watch?v=7s664NsLeFM). Either you create the world in every test, which is quite a bit of boilerplate code, or you have something like factory_girl create the world in a single place, which is overkill for testing the interaction of a class and it's dependencies.

Those are my reasons for using mocks in as many places as I can; basically, they're simple and don't require any knowledge of a unit's dependencies. If you have any thoughts about using and not using mocks, be sure to drop me a line!

[^1]: In fairness, the developer hasn't had a chance to respond to my criticisms, and it's always possible I've misinterpreted their stated opinion.
[^2]: I'm not actually sure what was meant by the phrase 'architectual boundries.' Here, I've taken it to mean points of integration with third parties (e.g., making a network request that might fail or take a long time to complete)
[^3]: I've never seen this system used, nor have I thought things would be simpler if I could observe an object's value and respond to changes without it's knowledge. See _event soup_.
[^4]: Notice I didn't mention XCode by name here. That is because XCode is not worth it's stalt in my opinon because it is missing many helpful features like method refactoring. It's worth something less valuable than salt, to be clear. 
[^5]: If, for some odd reason, your beautiful IDE doesn't have support for method refactoring. But why would anyone use anything like that?