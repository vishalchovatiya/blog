---
title: "What Is Design Pattern?"
date: "2020-04-07"
categories: 
  - "cpp"
  - "design-patterns"
  - "design-principles"
  - "software-engineering"
tags: 
  - "before-dive-into-the-design-patterns"
  - "behavioural-design-patterns"
  - "benefits-of-design-patterns"
  - "creational-design-patterns"
  - "design-pattern-example"
  - "design-patterns-c"
  - "design-patterns-examples"
  - "structural-design-patterns"
  - "they-are-easily-reusable"
  - "they-are-expressive"
  - "they-are-proven-solutions"
  - "they-ease-communication"
  - "they-lower-the-size-of-the-codebase"
  - "they-prevent-the-need-for-refactoring-code"
  - "types-of-design-patterns"
  - "what-is-design-pattern-in-c"
  - "what-is-design-patterns"
  - "what-is-not-design-pattern"
  - "why-do-we-need-design-patterns"
  - "why-you-should-learn-design-patterns"
featuredImage: "/images/What-is-Design-Pattern-C-Vishal-Chovatiya-Mind-Map-1536x861-compressed.webp"
---

After hitting a certain level of experience & spending quite enough time in the industry, I have realised the importance of designing/architecting system & software. So I have started looking into system/software design & got to know nothing can better start than a Design Pattern. And the first thing I have done is googling "What is Design Pattern?" Hence got the idea of this article.

But as someone without a computer science background(I am from electronics background), learning them was a struggle. Every material, article, explanation or book was riddled with jargon to sift through. Some of them I still don't quite understand. I barely know how the [Flyweight](/posts/flyweight-design-pattern-in-modern-cpp/) & [Classical Visitor](/posts/double-dispatch-visitor-design-pattern-in-modern-cpp/) pattern work and anyone who says they do is a liar.

So, after taking the online course, YouTube videos, lots of googling, tons compiling & spaced repetition with learning & unlearning. Here is what I have gained so far.

## What Is Design Pattern?

![](/images/Software-Design-Architecture-Stack-1024x628.png)

From Wikipedia[:](https://en.wikipedia.org/wiki/Software_design_pattern)

- In software engineering, a software design pattern is a general, reusable solution to a commonly occurring problem within a given context in software design.  
- It is not a finished design that can be transformed directly into source or machine code. It is a description or template for how to solve a problem that can be used in many different situations.  
- Design patterns are formalized best practices that the programmer can use to solve common problems when designing an application or system.

- Design Patterns establishes solutions to common problems which helps to keep code maintainable, extensible & loosely coupled.
- Developers have given a name to solutions which solve a particular type of problem. And this is how it all started.
- The more one knows them, the easier it gets to solve all the problems we face.
- It is popularized by [**G**ang **O**f **F**our(1994)](https://en.wikipedia.org/wiki/Design_Patterns) book.

## What Is Not Design Pattern?

- It isn't code reuse, as it usually does not specify code. The actual implementation depends on the programming language and even the person that is doing it.
- Design Pattern & Principle([SOLID](/posts/single-responsibility-principle-in-cpp-solid-as-a-rock/)) are two different things.
- A Design Pattern is neither a static solution nor is it an algorithm, No hard rule of the coding standard.
- Software Architecture is not a Design Pattern. Software Architecture dictates what's going to implemented & where it will be put. While Design Patterns states how it should be done.
- **Design Patterns are not ready to code solutions they are more like a description of what the solution should look like**. What you should retain from Design Patterns is that the problem and the solution to the problem are closely related. They are both equally important to learn.

## Why Do We Need Design Patterns?

As Software Developers, we often evaluate our code through some attributes like how clean, expressive, taking less memory footprint & fast our code is. But the most important concern which we often neglect is that you should be able to easily change anything later. What you decide today could be irrelevant tomorrow. And your code should be flexible enough so that it's not too costly to alter. So Design Patterns are best practices to cover such attributes. For me, the core of Design Patterns consists of the following 6 rules:

### They Are Proven Solutions

- Because Design Patterns often uses by many developers, you can be certain that they work. And not only that, you can be certain that they were revised multiple times and optimizations were probably implemented.

### They Are Easily Reusable

- Design Patterns document a reusable solution which can modify to solve multiple particular problems. As they are not tie-up to a specific problem.
- For example, consider the [Iterator Design Pattern](/posts/iterator-design-pattern-in-modern-cpp/), it is reusable throughout STL despite container & algorithm variation. Iterators are working like glue between container & algorithm.

### They Are Expressive

- Design Patterns can explain a large solution quite elegantly. For instance, the [Visitor](/posts/double-dispatch-visitor-design-pattern-in-modern-cpp/) pattern uses to perform a new operation on a range/group of classes. And thus, the standard library adopted such pattern with single function i.e. [`std::visit`](https://en.cppreference.com/w/cpp/utility/variant/visit) algorithm. Same goes for [`boost::flyweight<>`](https://www.boost.org/doc/libs/1_62_0/libs/flyweight/doc/index.html).  
    

### They Ease Communication

- When developers are familiar with Design Patterns, they can more easily communicate with one another about potential solutions to a given problem.
- If you’re working with colleagues in a team of multiple developers, agree with them about the Design Patterns, as they can help you better with a problem. Also with regard to the maintenance of software, you should follow such procedures, as you make maintenance operations faster and more efficient.

### They Prevent the Need for Refactoring Code

- If an application is written with Design Patterns in mind, it is often the case that you won’t need to refactor the code later on because applying the correct Design Pattern to a given problem is already an optimal solution.
- If such solutions are then updates, they can seamlessly apply by any good software developer and do not cause any problems.

### They Lower the Size of the Codebase

- Because Design Patterns are usually elegant and optimal solutions, they usually require less code than other solutions. This does not always have to be the case as many developers write more code to improve understanding.

## Why You Should Learn Design Patterns?

- If you boil-down the definition of Object-Oriented Design, it combining data & its operation into a context-bound entity(i.e. class/struct). And it stands true while designing an individual object.
- But when you are designing complete software you need to take into the account that
    - **Creational Design Patterns:** How do those objects going to be instantiated/created?
    - **Structural Design Patterns:** How do those objects combine with other object & formalize bigger entity? which should also be scalable in future.
    - **Behavioural Design Patterns:** You also need to think in terms of communication between those objects which can anticipate future changes easily & with fewer side effects.
- Do you see where this lead us to? you need to **_think in terms of object everywhere considering maintainability, scalability, expressiveness & stability_**. So in nutshell, this is a **_mindset for good coding_**. And I am pretty sure if you are coming from C background, you don't have this mindset & thought process.

## Before Dive-Into the Design Patterns

But, before dive-into the Design Patterns you should learn some of the basic design principles called SOLID. SOLID is one of the most popular sets of design principles in object-oriented software development introduced by Robert C. Martin, popularly known as [Uncle Bob](https://en.wikipedia.org/wiki/Robert_Cecil_Martin). The SOLID principles comprise of these five principles:

{{% include "/reusable_block/solid-design-principles.md" %}}

- Dev also refers to this SOLID design principle as "The First 5 Principles of Object-Oriented Design".
- These principles also make it easy for developers to avoid code smells, easily refactor code, and are also a part of the agile or adaptive software development.

> **_SOLID are "not principles to adopt" but "frameworks to use"_**

## Types of Design Patterns

### **_Creational Design Patterns_** in C++

{{% include "/reusable_block/creational-design-patterns.md" %}}

### _**Structural Design Patterns**_ in C++

{{% include "/reusable_block/structural-design-patterns.md" %}}

### _**Behavioural Design Patterns**_ in C++

{{% include "/reusable_block/behavioural-design-patterns.md" %}}

## Benefits of Design Patterns

1. Foresee & rectify future problems easily.
2. Helps in maintaining binary compatibility with subsequent releases.
3. Just by following [SOLID Principles](/posts/single-responsibility-principle-in-cpp-solid-as-a-rock/) helps greatly in agile or adaptive software development.
4. The solution facilitates the development of highly [cohesive](https://en.wikipedia.org/wiki/Cohesion_(computer_science)) modules with minimal coupling. Thus, increasing extensibility & reusability.
5. There are some patterns like Facade, Proxy, etc which encapsulates the complexity in itself to provide easy & intuitive interface to the client. Thus, making the overall system easier to understand & reduce learning curve.
6. Design Patterns make communication between designers & developers more crystal & precise. A developer can immediately picture the high-level design in their heads when they refer to the name of the pattern used to solve a particular issue when discussing software design.

## What Next?

I'm not advocating to learn everything by heart, but you should try to understand as much as you can about these concepts as you will encounter them often in your work. By practising to implement them, you will understand better their use cases and the reasons behind them.

I hope to cover most of the classic Gang of Four Design Patterns throughout this series. I struggled to find beginner-friendly material while learning them, and hope these help others avoid the same fate. By the way, I will be using [Modern C++](/posts/21-new-features-of-modern-cpp-to-use-in-your-project/) for all of the patterns. So you can also smell C++ from thought process & some of the definitions(this line is hard for me to put it into the words). This is by no means that you can not apply these patterns to other languages.

## FAQs

**Do you need design pattern all the time?**

Initially, you should not think about Design Pattern. **_An expressive & less code is always the first line of defence_**. You should not complicate the solution because complication is given by the problem.

**Why you should learn the Design Patterns?**

If you are a self-taught developer & does not expose to industry projects then you may not have thought process for using Object-Oriented Design. You can not think every aspect of design in terms of objects. In this case, Design Pattern will give you a new thought process of thinking everything in terms of objects. And if you follow it strictly, you will see your classes & software represent the Domain Specific Language.
