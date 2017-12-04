---
layout: post
title: How to Read Kotlin Function Definitions
date: 2017-12-04 06:24:59
tags: [Software, Kotlin]
excerpt: "Kotlin is a great new language from JetBrains, but its function definitions are hard to read if you've never done it before. Let's learn how to read them!"
---
In case you [missed](https://blog.jetbrains.com/kotlin/2017/05/kotlin-on-android-now-official/) [it](https://spring.io/blog/2017/01/04/introducing-kotlin-support-in-spring-framework-5-0), [Kotlin](https://kotlinlang.org/) is now the [cool kid](https://www.youtube.com/watch?v=TkVjkvaeFnQ) on the block.

It's got all the advantages of Java and a great syntax with modern language features.
Unfortunately, the documentation is a bit hard to parse if you've had limited experience with functional programming. Specifically, documentation for functions can look *really weird*.

So, let's learn how to read function definitions/declarations!
We'll look at a few and break them down piece by piece.

### The general pattern [^1]

Here's how the documentation for functions normally looks.
You can use this as reference as you continue the guide.

Optional elements of a function definition are in curly braces `{}`.

    {FUNCTION_TYPE} fun {<GENERIC_TYPES>} {OBJECT.}FUNCTION_NAME(
      PARAMETER_NAME: PARAMETER_TYPE,
      ...MORE PARAMETERS...
    ): RETURN_TYPE

`FUNCTION_TYPE` defines what type of function is being declared. 
A non-exhaustive list of function types: 

  - `private`
  - `protected`
  - `public` 
  - [`open`](https://kotlinlang.org/docs/reference/classes.html#overriding-rules) allows subclasses to `override` this function. [^2]
  - [`inline`](https://kotlinlang.org/docs/reference/inline-functions.html#inline-functions) puts your function right into your Kotlin source rather than creating an object behind the scenes and managing references to the variables it's closed over. You'd want to use this for performance reasons  
  - [`infix`](https://kotlinlang.org/docs/reference/functions.html#infix-notation) makes it so that you can call functions without dots
  - [`tailrec`](https://kotlinlang.org/docs/reference/functions.html#tail-recursive-functions) converts [tail-recursive](https://stackoverflow.com/questions/33923/what-is-tail-recursion#comment57405901_33923) (like normal recursion, but you go the other way) functions into regular loops, which is more efficient

`fun` is how you declare a function. It's fun! Right?!

[`GENERIC_TYPES`](https://kotlinlang.org/docs/reference/generics.html) are things used in the rest of the function. They don't have any meaning in themselves, just to say something is of one type or another but it doesn't matter *which* type it is.

`OBJECT` is the object the function is defined on.

`FUNCTION_NAME` is self-explanatory.

`PARAMETER_NAME` also the above.

`PARAMETER_TYPE` is self explanatory, but parameters can get confusing fast if you're passing functions around.

`RETURN_TYPE` is self-explanatory.

### [List.map](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.collections/map.html)

    inline fun <T, R> Array<out T>.map(
        transform: (T) -> R
    ): List<R>

Here's what we get from this definition, part by part:

- it's an inline function, so it doesn't close over any variables
- it uses two types, `T` and `R`, that will be **T**ransformed and **R**eturned
- it returns an array with elements of type `T`[^3]
- it takes a function. That function takes a variable of type `T` and returns a variable of type `R`. This is the function that does the mapping from one element to another
- it returns a list with elements of type `R`

### [List.reduce](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.collections/reduce.html)

    inline fun <S, T : S> Array<out T>.reduce(
      operation: (acc: S, T) -> S
    ): S

- it's an inline function. No closure for you!
- it uses two types, `S` and `T`, that represent the type of the accumulated value and the type of the elements the function is accumulating. `T` inherits from `S`.
- it takes one parameter, a function named `operation`. The function takes a parameter named `acc` of type `S`, and another of type `T` and returns a value of type `S`
- it returns a value of type `S`

### [List.binarySearch](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.collections/binary-search.html)
   
    fun <T : Comparable<T>> List<T?>.binarySearch(
        element: T?,
        fromIndex: Int = 0,
        toIndex: Int = size
    ): Int

- it uses a type `T` that inherits from `Comparable`
- it's defined on a `List` of elements of type T that might be null (`?`)
- it takes three parameters, the last two defaulting to `0` and `List.size` if not given
- it returns an Int

### Hope that helps!

Want to know something I didn't cover?
Was I incorrect?
Do you understand compiler stuff and want to explain what `out` means?

Drop me a line — I'd love to hear from you!


[^1]: Read the [documentation for functions](https://kotlinlang.org/docs/reference/functions.html) for sure, just know it takes a bit of parsing to really understand it.

[^2]:  See [here](https://kotlinlang.org/docs/reference/classes.html#overriding-methods). Presumably, this keyword is only allowed on functions in classes (it's also allowed on classes themselves), but I couldn't find any documentation to that effect.

[^3]: What's `out` doing here? That's a very good question! I've read the [docs](https://kotlinlang.org/docs/reference/generics.html#declaration-site-variance), and I get it, but I can't explain it well so I'll come back later and update this post when I do!