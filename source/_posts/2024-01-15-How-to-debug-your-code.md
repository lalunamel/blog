title: How to Debug Your Code
date: 2024-01-15 11:36:33
tags: [Software, Testing]
excerpt: "What is debugging and what's the right way to go about it?"

---

Unless you only write perfect programs, you're going to need to debug them eventually!

"Debugging" is what you do when you want to figure out where the problem is in your code.

The reason we call these problems "bugs" comes from when computers were much larger and much more mechanical. Back in the day, sometimes actual bugs like moths and flies would get into the machines and cause a short circuit. So "debugging" is when you go and look for those little critters and pull them out!

Another way I like to think about debugging is that it's the process of aligning your mental model with reality: you think the program should behave in one way, and it's going another.

So what's the right way to debug?

It's a simple process:

1. **Write down what you know.**

Things like:

What you're doing that produces the problem, what the problem looks like, and any hunches you have about what's causing it.

With trivial bugs you can usually keep all this in your head, but there's really no way to predict whether or not a bug will be trivial or complex, so I prefer to always write things down at the start.

2. **Verify your assumptions.**

Within the list of things you know there will certainly be assumptions.

Do you _know_ that the input you give is recorded properly? Do you _know_ that data is transformed in the way you intended?

Your job is to verify these assumptions. Somewhere along the chain, an assumption you have will be wrong, and it's your job to find out where.

3. **GOTO 1**

</br>

It's that simple. Keep writing down what you know, and then verifying those things.

And a few final tips:

**Imagine what your code will do before you run it.**

Ask yourself "what will happen when I git 'go'?" Developing a mental model is an important part of becoming a more proficient programmer.

**Print statements are useful for debugging but a full-featured debugger is better.**

If you've only been using print statements to debug your code, you will be _shocked_ at how much better a real GUI debugger is! Find one in your favorite IDE and use it.
