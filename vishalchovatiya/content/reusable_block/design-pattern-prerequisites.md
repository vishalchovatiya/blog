---
title: "Design Pattern : Prerequisites"
date: "2019-12-20"
---

The code snippets you see throughout this series of articles are simplified not sophisticated. So you often see me not using keywords like `override`, `final`, `public`(while inheritance) just to make code compact & consumable(most of the time) in single standard screen size. I also prefer `struct` instead of `class` just to save line by not writing "`public:`" sometimes and also miss [virtual destructor](/posts//part-3-all-about-virtual-keyword-in-c-how-virtual-destructor-works/), constructor, [copy constructor](/posts//all-about-copy-constructor-in-cpp-with-example/), prefix `std::`, deleting dynamic memory, intentionally. I also consider myself a pragmatic person who wants to convey an idea in the simplest way possible rather than the standard way or using Jargons.

**_Note:_**

- If you stumbled here directly, then I would suggest you go through [What is design pattern?](/posts//what-is-design-pattern/) first, even if it is trivial. I believe it will encourage you to explore more on this topic.
- All of this code you encounter in this series of articles are compiled using C++20(though I have used [Modern C++](/posts//21-new-features-of-modern-cpp-to-use-in-your-project/) features up to C++17 in most cases). So if you don't have access to the latest compiler you can use [https://wandbox.org/](https://wandbox.org/) which has preinstalled boost library as well.
