---
layout: post
title: "How frequently should mocks be used in iOS testing?"
date: 2016-08-16 20:28:01
tags: [Software, iOS, Testing]
excerpt: "Do mocks provide value when writing iOS tests, or are they more trouble than they're worth?"
---
After transitioning from a web to an iOS developer at Pivotal, I've had many discussions recently about the Right Way to write tests for iOS/Objective C/object oriented applications. I'd like to document the key points from those discussions so that I can refer to them later and maybe someone else can get some use out of them, too.

As an aside, it seems, from my limited obeservation of the outside world (i.e., not Pivotal) that tests aren't a big part of writing iOS applications. That is very strange to me, having been 'raised' at Pivotal and on the Tracker Team, where tests (and agile, by extension), are core practices. Regardless of your feeling about wiritng tests, I hope the following will be helpful.

So, question:

**How frequently should mocks be used in tests?**

I'm using the word _mock_ in the sense of [Cedar](http://www.github.com/pivotal/cedar), the lovely testing framework by Pivotal that uses RSpec-like BDD syntax. A mock in Cedar is created with `nice_fake_for([Dog class])` or `fake_for([Dog class])`, where the first creates an object that _is a_ `Dog` and conforms to the interface of (implements the methods defined on) `Dog`, and the second merely creates an object that _is a_ `Dog`.

A view expressed by a more experienced iOS developer [^1] was roughly that mocks should only be employed at architectual boundries[^2]. Moreover, using mocks introduces maintenance costs that dont exist when using [factories](https://thoughtbot.com/upcase/videos/factory-girl?utm_source=github&utm_medium=open-source&utm_campaign=factory-girl), because every time the method `Dog.haveDinner` changes I have to update my fakes and expectations with the new signature. A small iOS sidenote is that mocks don't work with Objective C's Key-Value system[^3]. 

My philosophy is that mocks should be used as much as possible. The thought is that the unit under test should be ignorant of the side effects of its calling of a method on another object. That is to say that the method

```lang-java
Bowl bowl;
Dog.haveDinner {
	bowl.eat()
}
```

should be ignorant of the effects of calling `bowl.eat`, and the test shouldn't have to deal with the internals of `Bowl`, and only assert that `Bowl.eat` was called.

By not using mocks, your test code will necessarily execute the implimentation of whatever method your unit is calling, causing a cascade of method calls you have to account for and slowing down your tests a bit. This breaks one tenet of unit testing: that the unit under test should be ignorant of its dependencies' internals.

This isn't so bad when the dependency is a simple data container POJO (or POOCO, or whatever), but that's rarely the case.

The point that using mock objects introduces more maintenance costs is not as significant as one might expect. Say you've written several tests that mock out `Dog` and `Dog.haveDinner` and make some expectations on `Dog.haveDinner`. Now you add a parameter to `Dog.haveDinner` and uh-oh, you've changed the method signature and have to go through and add that parameter to your test code! This can be solved by your handy-dandy IDE and its refactor functionality. Any IDE worth its salt[^4] will allow you to rename a method and highlight all its usages that need to change. If you're confident, you can even use find and replace[^5] to do all the heavy lifting.

An alternative to mocks are factories. I dislike factories in unit tests because they require that you [create and manage the world](https://www.youtube.com/watch?v=7s664NsLeFM). Either you create the world in every test, which is quite a bit of boilerplate code, or you have something like factory_girl create the world in a single place, which is overkill for testing the interaction of a class and its dependencies.

Those are my reasons for using mocks in as many places as I can; basically, they're simple and don't require any knowledge of a unit's dependencies. If you have any thoughts about using and not using mocks, be sure to drop me a line!

[^1]: In fairness, the developer hasn't had a chance to respond to my criticisms, and it's always possible I've misinterpreted their stated opinion.
[^2]: I'm not actually sure what was meant by the phrase 'architectual boundries.' Here, I've taken it to mean points of integration with third parties (e.g., making a network request that might fail or take a long time to complete)
[^3]: I've never actually seen KVO used in production, nor have I ever thought things would be simpler if I could observe an object's value and respond to changes without its knowledge. See _event soup_.
[^4]: Notice I didn't mention XCode by name here. That is because XCode is not worth it's stalt. It's worth something less valuable than salt, to be clear. It is missing many helpful features available in most other IDEs (e.g., refactoring).
[^5]: If, for some odd reason, your beautiful IDE doesn't have support for method refactoring. But why would anyone use anything like that?
