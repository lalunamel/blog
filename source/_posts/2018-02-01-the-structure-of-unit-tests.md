---
layout: post
title: The Structure of Unit Tests
date: 2018-03-01 06:24:59
tags: [Software, Testing]
excerpt: "The guidelines I've gleaned from books and videos on how to create well written unit tests."
---

Recently, I've read and watched a lot of things that give great guidelines on writing well structured tests. Many of the guidelines that come up are very similar, so I thought I'd summarize them here.

- [Clean Code](http://amzn.to/2FSh5Xo)
- [Advanced Unit Testing - A Pluralsight course by Mark Seemann](https://app.pluralsight.com/library/courses/advanced-unit-testing)
- [Working Effectively with Unit Tests](http://amzn.to/2FdBuom)

## Write Tests In Four Phases
In my opinion, this is the most important guideline. Even if your tests don't follow the other guidelines, if they all have four distinct phases, they will be easy to understand and refactor later.

The four phases of a well written test are

- Setup
- Execution
- Assertion
- Teardown

Teardown isn't a part of most unit test lifecycles, and if you find yourself needing to teardown something after you've unit tested it, you're probably not testing plain ol' code.

If every test sticks to this process and is very clear about which step appears where, they will all be easy to understand.

## Don't Touch The Slow Stuff (Database or Network)
Tests should be fast and deterministic. The easiest way to achieve that is by just testing plain ol' code. Which is to say, just test functions that have input an output. Don't test functions with side effects. Don't test functions that touch the databse. Don't test functions that talk to the network, etc. 

Not to say you can't have those things, just that they shouldn't be part of the core of your application. If you push all your side-effect-y (e.g., database, network) code as far to the edges of your system as possible, your application will be easier to reason about and easier to test.

## Test One Thing
A lot of resources explain the `Test One Thing` rule with "have one assertion per test" but I believe that's a little too strict. I think that should be reworked to say "test one concept." Usually, assertions are implementation details of tests, and testing one concept may require multiple asserts. E.g., when you're testing more than one property of an object.

Conceptually, one test should only ever fail for one reason. If a test can fail for more than one reason, that assertion should be broken out into a new test.

## Don't Use Control Flow Statements
If you're using control flow statements (`if`, `when`, `for`) in your tests, you should rethink how you're testing. Tests should never be complex enough to warrant control flow statements. If you ever find yourself wanting to use a control flow statement, write another test!
