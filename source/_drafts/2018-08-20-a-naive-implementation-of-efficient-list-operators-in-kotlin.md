---
layout: post
title: A Naive Implementation of Efficient List Operators in Kotlin
date: 2018-08-20 06:24:59
tags: [Software, Kotlin]
excerpt: ""
---

In the previous post we took a look at whether or not the default `List` operators (e.g., `map`, `filter`, and `reduce`) are efficient. 

If you haven't read that post, [go ahead](http://blog.codysehl.net/2018/are-kotlin-list-operators-efficient/)!

I'll wait.

So, we understand that they are in fact _not_ efficient, where the definition of efficient means for a given list, the list is iterated over a small number of times. It turns out that using Kotlin's list operators means a list is iterated once per operator! This was the `A loop for every operator method` I described.

I proposed a more efficient method called `Many operators, one loop`. That method iterated over the list only once and transformed the list operators into an `if` statement and a series of inline operations. This method has a caveat though: it doesn't work for impure functions[^1].

I'd like to chance a guess at how this `Many operators, one loop` method could be implemented and just accept the caveat about impure functions.

## What would the Many Operators, One Loop method look like?

In my example I described a code transformation: `.filter()` would transform into `if`.

I don't know enough about transforming code in the Kotlin compiler to say whether or not this is a good way to go about implementing this method. For now, let's just see if this can be implemented using some techniques that are already available to the average developer: data structures and algorithms!

I've been thinking about this problem since I wrote the previous blog post: How _would_ efficient list operators be implemented?

Let's get specific about what _efficient_ means. 

With regards to this method, efficient means iterating over the list only once. It also means only doing work that is necessary - if a `map` comes after a `filter` that removes an element from a list, the `map` shouldn't be run.

## A description of a naive implementation

I believe holding a list of operations to perform, one after another, on each element in a list should create an implementation that matches the method.



[^1]: I think it's easiest to define impure functions by saying they're _not_ pure. </br>
**What's a pure function?** Well, it's a function where 1. The output depends only on the input  2. Has no side effects 3. Doesn't mutate the data it's given. </br>
**What's a side effect?** I've never heard a definition I'm totally satisfied with, but you'll probably know one when you see one. Essentially, a side effect is any change that takes place outside of your function and isn't its responsibility.
