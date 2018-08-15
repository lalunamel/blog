---
layout: post
title: Are Kotlin List Operators Efficient?
date: 2018-08-18 06:24:59
tags: [Software, Kotlin]
excerpt: "Take a look at how Kotlin's map, filter, and reduce are implemented and what that means for their efficiency."
---

Well, that depends on what you mean by _efficient_!

Let's start by exploring some ways list operators (map, filter, reduce and their ilk) might work.

An example:

```lang-kotlin
val numbers = listOf(1, 2, 3, 4, 5, 6)
val evenNumbers = list.filter { num -> num % 2 == 0 } // 2, 4, 6
val evenNumbersDoubled = evenNumbers.map { num -> num * 2 } // 4, 8, 12
val sum = evenNumbersDoubled.reduce { sum, num -> sum + num } // 24
```

In this example, we're given a list of numbers, find the even ones, double those, then sum the whole thing.
Each step is broken out into a variable so that every operation has a name.

Here's a more concise version, closer to how this would probably be written in production:

```lang-kotlin
listOf(1, 2, 3, 4, 5, 6)
  .filter { num -> num % 2 == 0 } // 2, 4, 6
  .map { num -> num * 2 } // 4, 8, 12
  .reduce { sum, num -> sum + num } // 24
```

Given the above, I can conceive of two reasonable ways this code looks under the hood:
(in pseudo-Java for simplicity)

### A loop for every operator

```lang-kotlin
list = [1, 2, 3, 4, 5, 6]

// Filter
evenNumbers = []
for(i=0; i<list.length, i++) {
  num = list[i]
  if(num % 2 == 0) {
    evenNumbers.add(num)
  }
}

// Map
evenNumbersDoubled = []
for(i=0; i<evenNumbers.length, i++) {
  num = evenNumbers[i]
  transformedResult = num * 2
  evenNumbersDoubled.add(transformedResult)
}

// Reduce
sum = 0
for(i=0; i<evenNumbersDoubled.length, i++) {
  num = evenNumbersDoubled[i]
  sum = sum + num
}
```

With this method, the list is iterated over three times.

### Many operators, one loop

```lang-kotlin
list = [1, 2, 3, 4, 5, 6]

sum = 0
evenNumbers = []
for(i=0; i<list.length, i++) {
  num = list[i]

  // Filter
  if(num % 2 == 0) {

    // Map
    num = num * 2

    // Reduce
    sum = sum + num
  }
}
```

With this method, the list is iterated over one time.

## Which way does Kotlin do it?

Now that we've established two possible ways list operators could work, which way does Kotlin choose?

Let's look at the source for map, filter, and reduce!

_(You probably don't want to follow the links - the files are thousands of lines long.)_

### Map

The [source](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.collections/map.html) takes us to [\_Arrays.kt:8255](https://github.com/JetBrains/kotlin/blob/1.2.60/libraries/stdlib/common/src/generated/_Arrays.kt#L8225), which uses `mapTo` defined on line [8542](https://github.com/JetBrains/kotlin/blob/1.2.60/libraries/stdlib/common/src/generated/_Arrays.kt#L8542).

Here's the implementation for `mapTo`:

```lang-kotlin
public inline fun <T, R, C : MutableCollection<in R>> Array<out T>.mapTo(destination: C, transform: (T) -> R): C {
  for (item in this)
    destination.add(transform(item))
  return destination
}
```

### Filter

The [source](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.collections/filter.html) takes us to [\_Arrays.kt:3000](https://github.com/JetBrains/kotlin/blob/1.2.60/libraries/stdlib/common/src/generated/_Arrays.kt#L3000), which uses `filterTo` defined on line [3417](https://github.com/JetBrains/kotlin/blob/1.2.60/libraries/stdlib/common/src/generated/_Arrays.kt#L3417).

Here's the implementation for `filterTo`:

```lang-kotlin
public inline fun <T, C : MutableCollection<in T>> Array<out T>.filterTo(destination: C, predicate: (T) -> Boolean): C {
  for (element in this) if (predicate(element)) destination.add(element)
  return destination
}
```

### Reduce

The [source](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.collections/reduce.html) takes us to [\_Arrays.kt:11384](https://github.com/JetBrains/kotlin/blob/1.2.60/libraries/stdlib/common/src/generated/_Arrays.kt#L11384).

_Note: Reduce does the same thing as Fold, except the initial value of the accumulator is the first element in the given list_

Here's the implementation for `reduce`:

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

As we can see, map, filter, and reduce all use the `A loop for every operator` method, rather than queuing up the operations and using the `Many operators, one loop` method.

## Are Kotlin list operators efficient?

So we're back to our main question - are these operators efficient?
I'll define the word `efficient` in this context to mean using the `Many operators, one loop` method.

Then clearly, no! Kotlin list operators are not efficient.

## Why not?

Language implementers tend to be pretty sharp folks and it's unlikely they've never thought of the scenario I described above.

Let's partake in some [apologetics](https://www.google.com/search?q=apologetics&oq=apologetics&aqs=chrome..69i57j0l5.1969j0j7&sourceid=chrome&ie=UTF-8) and think about why Kotlin's list operators were implemented this way - there's probably a reason!

### Impure functions

I was talking to my friend [Chris Bolin](https://twitter.com/bolinchris?lang=en) about this question the other day and he mentioned a confounding factor: global variables.

What if your map and filter function write to, then read from a variable defined outside of the scope of the operators? Given the same interface or contract, the result of the operators would change based on their implementation details. Definitely not something you want to have happen!

(Also a description of why functions that can give different answers depending on the state of the world, a.k.a, impure functions, are a bad idea)

### They ain't built for efficiency

Perhaps another reason Kotlin's list operators aren't that efficient is because they were never meant to be. As with all things performance related, it's not a problem until it's a problem. Which is to say, until you're in a situation where efficiency matters, who cares how many times you're running a for loop?

_Maybe_ Kotlin has a less efficient list type for small amounts of data, and a different list type for very large amounts of data? _Maybe_ the language implementers made a conscious decision to separate efficient operations into their own special concept?

Next time, we'll take a look at the internals of [Sequence](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.sequences/-sequence/index.html) - a list type that does just that!
