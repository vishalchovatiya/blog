---
title: "Mastering C++: Books | Courses | Tools | Tutorials | Blogs | Communities"
date: "2020-07-20"
categories: 
  - "cpp"
tags: 
  - "analysing-performance-oriented-c-cod"
  - "attaching-c-code-into-e-mail"
  - "c-blogs-bloggers"
  - "c-books"
  - "c-code-sharing"
  - "c-codeshare-io"
  - "c-coliru"
  - "c-communities"
  - "c-courses"
  - "c-online-debugger"
  - "c-online-developer-documentation"
  - "c-repl-it"
  - "c-tools"
  - "cppinsights-io"
  - "godbolt-org"
  - "jumping-on-new-c-code-base"
  - "latest-c-compilers"
  - "mastering-c"
  - "seeing-things-through-c-compiler-perspective"
  - "some-of-the-best-c-websites"
  - "support-of-boost-library"
featuredImage: "/images/Mastering-C.webp"
---

Do not get carried away with tittle Mastering C++. This is a never-ending journey. Because [ISOCPP](https://isocpp.org/) is releasing the baby elephants every three years. With the standard covering almost 1500 pages currently, C++ is not the simplest language to learn and master. I have spent quite enough time in the industry. But still feel imposter sometimes. It's been quite a while I was thinking of sharing my [Modern C++](/posts/21-new-features-of-modern-cpp-to-use-in-your-project/) journey. Although, I am sharing the knowledge piece-by-piece through such articles. But, there are other things as well which helped me through this journey like online tools, books, courses, blogs, etc. So, following is the list of such items in an unordered way.

## Some of the Best C++ Websites

- [www.learncpp.com](https://www.learncpp.com/)
- [en.cppreference.com](https://en.cppreference.com/w/)

## C++ Books

Apart from classic & latest [Effective series](https://www.amazon.com/Scott-Meyers/e/B004BBEYYW/), there are some modern & pragmatic books I found useful.

- [C++17 STL Cookbook](https://www.amazon.com/STL-Cookbook-enhancements-programming-expressions/dp/178712049X)
- [Inside the C++ Object Model](https://www.amazon.in/Inside-Object-Model-Stanley-Lippman/dp/0201834545)(Classic)
- [C++17 in Detail](https://leanpub.com/cpp17indetail)
- [Expert C++](https://www.packtpub.com/in/programming/mastering-c-programming)
- [C++ Notes For Professionals](https://books.goalkicker.com/)
- [The Modern C++ Challenge](https://www.amazon.in/Modern-Challenge-programmer-real-world-problems/dp/1788993861)(Practice Problem Only)
- [Mastering C++ Programming](https://www.packtpub.com/in/application-development/mastering-c-programming)
- [C++ Concurrency in Action](https://www.manning.com/books/c-plus-plus-concurrency-in-action-second-edition)
- [C++ Best Practices](https://lefticus.gitbooks.io/cpp-best-practices/content/)

If you see packt publishing & leanpub, there is a plethora of C++ book available targeting a different area of language pragmatically. Will keep adding this list in future. . .!

## C++ Courses

- [C9 Lectures: Stephan T. Lavavej - Core C++](https://channel9.msdn.com/Series/C9-Lectures-Stephan-T-Lavavej-Core-C-)
- [C9 Lectures: Stephan T. Lavavej - Standard Template Library (STL)](https://channel9.msdn.com/Series/C9-Lectures-Stephan-T-Lavavej-Standard-Template-Library-STL-)
- [C9 Lectures: Stephan T Lavavej - Advanced STL](https://channel9.msdn.com/Series/C9-Lectures-Stephan-T-Lavavej-Advanced-STL)
- [Design Patterns in Modern C++](https://www.udemy.com/course/patterns-cplusplus/)
- [Complete Modern C++ (C++11/14/17)](https://www.udemy.com/course/beg-modern-cpp/)
- [Modern C++ Concurrency in Depth](https://www.udemy.com/course/modern-cpp-concurrency-in-depth/)
- [Functional Programming using C++](https://www.udemy.com/course/functional-programming-using-cpp/)
- [Mastering C++ Standard Library Features](https://www.udemy.com/course/mastering-c-standard-library-features/)
- [C++17 in Detail: A Deep Dive](https://www.educative.io/courses/cpp-17-in-detail-a-deep-dive)
- [Embedded Programming with Modern C++](https://www.educative.io/courses/embedded-programming-with-cpp)

If you see the structure & content of the above courses, they are mostly targeted to experienced C++ devs. It is certainly not for beginners. Though, I haven't completed some of these courses. But I consider them a best & upto-date.

## C++ Blogs/Bloggers

- **Jonathan Boccara** : [www.fluentcpp.com](https://www.fluentcpp.com/about-me/)
- **Rainer Grimm** : [www.modernescpp.com](http://www.modernescpp.com/)
- **Bartlomiej Filipek** : [www.bfilipek.com](https://www.bfilipek.com/p/about.html)
- **Jonathan** : [foonathan.net](https://foonathan.net/)

Same as book list. These are the blogs I have explored & enjoyed reading.

## C++ Tools

### Online Debugger

[www.onlinegdb.com](https://www.onlinegdb.com/online_c++_debugger) is an online compiler as well as debugger tool. It supports many languages but for C++ at the time of writing this article, it supports till C++17. The good feature of this tool that I like most about is code formatting(i.e. Beautify option) and the sublime keybinding.

### Latest Compilers + Support Of Boost Library

[https://wandbox.org](https://wandbox.org/): The less you say the better. One of my favourite tool. I test almost all my blog post code snippets here. wandbox has a variety of compiler with choice of selecting specific version. You can also pass the compilation flags & runtime arguments explicitly. Creating multiple file option is also there.

### Analysing Performance Oriented C++ Code

[http://quick-bench.com](http://quick-bench.com/): Quick-benchmark is a handy micro benchmarking tool. Intended to quickly & simply compare the performance of two or more code snippets. Internally it uses [google-benchmark](https://github.com/google/benchmark).

A thing to note here is the benchmark runs on a pool of AWS machines whose load is unknown and potentially next to multiple other benchmarks. Any duration it could output would be meaningless. The fact that a snippet takes 100ms to run in quick-bench at a given time gives no information whatsoever about what time it will take to run in your application, with your given architecture.

Quick-bench can, however, give a reasonably good comparison between two snippets of code run in the same conditions. That is the purpose this tool was created for; removing any units ensures only meaningful comparison.

[https://build-bench.com](https://build-bench.com): is another similar platform. But rather than comparing the run time results. It compares the compile-time(i.e. build time) performance of two or more code snippets. This is quite useful while writing template metaprogramming or variadic template code. As we all know C++ is famous for its compile-time performance. ; )

### Seeing Things Through C++ Compiler's Eye

#### [cppinsights.io](https://cppinsights.io/)

C++ Insights is a clang-based tool which does a source to source transformation. Its goal is to make things visible which normally, and intentionally, happen behind the scenes. It's about the magic the compiler does for us to make things work. Or looking through the classes of a compiler.

This is the best tool to see things through compiler's eye. I have understood the importance of this tool when I was writing article :"[How C++ Variadic Template Works?](/posts/variadic-template-cpp-implementing-unsophisticated-tuple/)".

Typical use case of this tool is to see the transformation of a [lambda expression](https://cppinsights.io/s/f7710a4b), [range-based for-loop](https://cppinsights.io/s/40f6a267), [auto](https://cppinsights.io/s/e1a8cf40), etc.

#### [godbolt.org](https://godbolt.org/)

This is an interactive tool that lets you type code in one window and see the results of its compilation in another window. Using the site should be pretty self-explanatory: by default, the left-hand panel is the source window and the right hand has the assembly output that shows [How compiler converted your code into the assembly!](/posts/how-c-program-convert-into-assembly/).

### Online Developer Documentation

If you are going to cppreference many times in a day through google, in a search of standard library functions. Then [runebook.dev](https://runebook.dev/en/docs/cpp/) might be very useful to you. Its just compilation of cppreference in some sort of dictionary form. You can get whatever API you want with a single place search.

### Jumping on New C++ Code Base

[Sourcetrail](https://www.sourcetrail.com/) is free and open-source cross-platform source explorer that simplifies navigation in existing source code by indexing your code and gathering data about its structure. Sourcetrail then provides a simple interface consisting of three interactive views, each playing a key role in helping you obtain the information you need:

- **Search:** Use the search field to quickly find and select indexed symbols in your source code. The autocompletion box will instantly provide an overview of all matching results throughout your codebase.
- **Graph:** The graph displays the structure of your source code. It focuses on the currently selected symbol and directly shows all incoming and outgoing dependencies to other symbols.
- **Code:** The Code view displays all source locations of the currently selected symbol in a list of code snippets. Clicking on a different source location allows you to change the selection and dig deeper.

It also supports C, Java & Python apart from C++.

## Code Sharing

### [codeshare.io](https://codeshare.io)

Codeshare enables developers to share code in real-time. Write or paste code in your browser, share the URL, code in real-time with friends and team mates. The only drawback of this platform is that you can not compile code. It just shares the code in real-time with audio-video support.

### [coliru](http://coliru.stacked-crooked.com)

**Co**mpile, **Li**nk & **Ru**n. Clutter-free simple yet subtle code editor. This is just to share compilable code with an online code editor. You & your teammates can play around it.

### [repl.it](https://repl.it/~)

The repl([**r**ead-**e**val-**p**rint **l**oop](http://en.wikipedia.org/wiki/REPL)) is a simple yet powerful online compiler, IDE, interpreter and interactive environment for programming languages. As far as C++ is concerned this is limited till C++17. I use this platform mostly in conducting real-time interviews or to try out small code snippets. They are currently integrating GitHub. Maybe we can make use of a complete development environment online in the near future.

## Attaching C++ Code Into E-Mail

As a developer, you have to collaborate with other developers. And there are a lot of tools already out there to collaborate in real-time. But when teams scattered globally, have to support multiple timezones & work asynchronously. Often you find yourself in playing mail games.

And if you have ever attached your code in the mail, you might understand the pain. Even if your mail has rich text format, your code snippet may look ugly. And ugly code demotivates other people to look into. In such a case, you can use [tohtml](https://tohtml.com/cpp/), to generate HTML of your code with highlighted syntax according to your choice of programming language.

## C++ Communities

- [CppIndia](https://discord.gg/V8uxmPp)
- [Cpplang slack](https://cpplang.now.sh/)
- [C/C++ telegram](https://telegramchannels.me/groups/programminginc)
- [C++ reddit](https://www.reddit.com/r/cpp/)
- [Awesome C++](https://cpp.libhunt.com/)

## Useful Links

- [C++ Standards Support for All Compilers](https://en.cppreference.com/w/cpp/compiler_support)[](https://en.cppreference.com/w/cpp/compiler_support)
- [C++ Standards Support in GCC](https://gcc.gnu.org/projects/cxx-status.html)
- [C++ Standards Support in Clang](http://clang.llvm.org/cxx_status.html)
- [Awesome Modern C++](https://github.com/rigtorp/awesome-modern-cpp)
- [Quick Look Of All Modern C++ Features](https://github.com/AnthonyCalandra/modern-cpp-features)

## Wrap-Up

Apart from all these online tools, there are many other offline(not considering proprietary) tools. Like [profiler](https://gperftools.github.io/gperftools/cpuprofile.html), [linter](https://clang.llvm.org/extra/clang-tidy/), [formatter](https://clang.llvm.org/docs/ClangFormat.html), etc. Which I have not discussed as I consider them to be too specific. But those tools have certainly its place in stack & development cycle. Out of all these, I like clang-tooling(swiss army knife) the most.

Even after all this! To be perfectly honest, I am still learning or I would say Mastering C++ & getting better day-by-day. As I have mentioned in earlier, this is a never-ending journey, but the complexity of this language attracts me & gives me the drive to keep learning.

_Note:_ _There are many other books, blogs, courses, tools & tutorials available also to learn Modern C++. But, here I have mentioned the ones that I liked the most & helpful. If you feel that there are other things also I am missing or have any suggestions? You can always reach me from [here](/posts/contact-2/)._

