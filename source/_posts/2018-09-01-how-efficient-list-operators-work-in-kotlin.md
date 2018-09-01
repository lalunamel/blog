---
layout: post
title: How Efficient List Operators Work in Kotlin
date: 2018-09-01 06:24:59
tags: [Software, Kotlin]
excerpt: "Let's think of a way efficient list operators might work in Kotlin, then see how they're actually implemented in the Sequence list type."
---

In the previous post we took a look at whether or not Kotlin's `List` `map`, `filter`, and `reduce` operators are efficient. 

If you haven't read that post, [go ahead](http://blog.codysehl.net/2018/are-kotlin-list-operators-efficient/)!

So, we understand that they are in fact _not_ efficient, where the definition of efficient means for a given list, the list is iterated over a small number of times. It turns out that using Kotlin's list operators means a list is iterated once per operator! This was the `A loop for every operator method` I described.

I proposed a more efficient method called `Many Operators, One Loop`. That method iterated over the list only once and transformed the list operators into an `if` statement and a series of inline operations.

## What would the Many Operators, One Loop method look like?

In an example from the previous post, I describe a transformation: `.filter()` would become an `if`.
Unfortunately, we're not writing a compiler and don't have the ability to transform one bit of code into another - any solution we come up with can only use the tools available in the language.

I've been thinking about this problem since I wrote the previous blog post: How _would_ efficient list operators work?

Let's get specific about what _efficient_ means: 

1. Iterate over the list only once. 
2. Only do work that is necessary - if a `map` comes after a `filter` that removes an element from a list, the `map` shouldn't be run.

## How efficient list operators might work

Here's my guess at how efficient list operators work.

List operations performed on a list don't immediately execute, but instead, are saved off somewhere containing the source data and a list of _other_ operations to perform. When you're ready for your data, you ask it to compute your results - maybe with a function called `collect`.

The `collect` function is just a loop that, for every element, applies every operation that's been saved off in sequence.
Every operation can return a result or `null` (or some other empty-type value). If an operation receives a `null`, it returns immediately and does no work.
At the end, all the non-null values are rounded up into a list and returned.

## How efficient list operators actually work

Let's take a look at the source for [Sequence](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.sequences/-sequence/index.html).

_(Just as before, you probably don't want to follow the links - the files are thousands of lines long.)_

### Map

The [source](https://github.com/JetBrains/kotlin/blob/1.2.60/libraries/stdlib/common/src/generated/_Sequences.kt#L803) describes a function that simply returns a `TransformingSequence`, which is created by passing a source sequence and a transformation function.

Ok!

#### TransformingSequence

What's a `TransformingSequence`? 

Let's look at [its implementation](https://github.com/JetBrains/kotlin/blob/769344569d7e6b79437221efd6d815e441dc682a/libraries/stdlib/src/kotlin/collections/Sequences.kt#L170).

Mostly, it's something that implements the behavior of an iterator.

```lang-kotlin
override fun iterator(): Iterator<R> = object : Iterator<R> {
  val iterator = sequence.iterator()
  override fun next(): R {
    return transformer(iterator.next())
  }

  override fun hasNext(): Boolean {
    return iterator.hasNext()
  }
}
```

Asking this `TransformingSequence` for its next element will cause it to ask _its_ source sequence for _its_ next element, then apply a given transformation function. 

This recursive behavior could go on for a while - interesting!


### Filter

How about `Filter`? 

The [source](https://github.com/JetBrains/kotlin/blob/1.2.60/libraries/stdlib/common/src/generated/_Sequences.kt#L370) describes a function that returns a new `FilteringSequence` that takes a source sequence, a boolean value[^1], and a function that takes an input and returns true or false (a _predicate_).

#### FilteringSequence

What's a `FilteringSequence`?

Let's look at [its implementation](https://github.com/JetBrains/kotlin/blob/769344569d7e6b79437221efd6d815e441dc682a/libraries/stdlib/src/kotlin/collections/Sequences.kt#L122).

```lang-kotlin
override fun iterator(): Iterator<T> = object : Iterator<T> {
  val iterator = sequence.iterator()
  var nextState: Int = -1 // -1 for unknown, 0 for done, 1 for continue
  var nextItem: T? = null

  private fun calcNext() {
    while (iterator.hasNext()) {
      val item = iterator.next()
      if (predicate(item) == sendWhen) {
        nextItem = item
        nextState = 1
        return
      }
    }
    nextState = 0
  }

  override fun next(): T {
    if (nextState == -1)
      calcNext()
    if (nextState == 0)
      throw NoSuchElementException()
    val result = nextItem
    nextItem = null
    nextState = -1
    @Suppress("UNCHECKED_CAST")
    return result as T
  }

  override fun hasNext(): Boolean {
    if (nextState == -1)
      calcNext()
    return nextState == 1
  }
}
```

Take a few minutes to read that over and understand it.

`FilteringSequence` is similar to `TransformingSequence` in that it the source sequence for a next value, but - here's where it differs! - it'll keep asking until it finds one that satisfies the given predicate! Neat!

### Reduce

Finally, let's look at `reduce` and its [source](https://github.com/JetBrains/kotlin/blob/1.2.60/libraries/stdlib/common/src/generated/_Sequences.kt#L1272).

```lang-kotlin
public inline fun <S, T : S> Sequence<T>.reduce(operation: (acc: S, T) -> S): S {
  val iterator = this.iterator()
  if (!iterator.hasNext()) throw UnsupportedOperationException("Empty sequence can't be reduced.")
  var accumulator: S = iterator.next()
  while (iterator.hasNext()) {
    accumulator = operation(accumulator, iterator.next())
  }
  return accumulator
}
```

There's no `ReducingSequence`!

That's because `reduce` is a _terminal_ operation. A _terminal_ operation is the last thing done to a Sequence. It transforms the Sequence (which is really just a bunch of potential values, yet to be computed) into actual values that are usable by the rest of a program. In the case of `reduce`, all the values in a Sequence are squashed down into one value.

As you can see, the implementation of `reduce` for `Sequence` looks pretty dang similar to `reduce` for `List`, which we covered in [the previous post](http://blog.codysehl.net/2018/are-kotlin-list-operators-efficient/#reduce):

```lang-kotlin
public inline fun <S, T : S> Array<out T>.reduce(operation: (acc: S, T) -> S): S {
  if (isEmpty())
    throw UnsupportedOperationException("Empty array can't be reduced.")
  var accumulator: S = this[0]
  for (index in 1..lastIndex) {
    accumulator = operation(accumulator, this[index])
  }
  return accumulator
}
```

## Is Sequence efficient?

After looking at Kotlin's Sequence and implementations of `map`, `filter`, and `reduce` we can see that they satisfy the definition of _efficient_ put forward at the beginning. The implementations above iterate through the list only once, and in the case of filter, only provide a value when the predicate is fulfilled.

My guess at how efficient list operators might work is a bit off from how they're actually implemented - for one, my list concept is replaced with a series of Sequences calling each other - but I think the outlines match up.

## Wrapping up

I hope this dive into source code has shown you how fun learning the details can be!

Moreover, I hope you've also noticed that the guesswork solution wasn't enormously far off from the real implementation. 

It just goes to show, everyone is capable of solving interesting problems like these, whether you're a whiz creating a programming language or a plebe who just likes to puzzle things out.



[^1]: Explaining this boolean value inline seemed a bit verbose. I think the docs are clear on what role this parameter plays: _If `true`, values for which the predicate returns `true` are returned. Otherwise, values for which the predicate returns `false` are returned_.
