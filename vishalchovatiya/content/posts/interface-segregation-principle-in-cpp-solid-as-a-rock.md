---
title: "Interface Segregation Principle in C++ | SOLID as a Rock"
date: "2020-04-06"
categories: 
  - "cpp"
  - "design-patterns"
  - "design-principles"
  - "software-engineering"
tags: 
  - "advantages-of-interface-segregation-principle"
  - "benefits"
  - "benefits-of-interface-segregation-principle"
  - "clean-code-interface-segregation-principle"
  - "dependency-inversion-principle"
  - "difference-between-liskov-and-interface-segregation"
  - "example-of-interface-segregation-principle"
  - "faster-compilation"
  - "fat-interface-segregation-principle"
  - "intent"
  - "interface-segregation"
  - "interface-segregation-principle"
  - "interface-segregation-principle-isp"
  - "interface-segregation-principle-isp-example"
  - "interface-segregation-principle-abstract-class"
  - "interface-segregation-principle-adapter-pattern"
  - "interface-segregation-principle-benefits"
  - "interface-segregation-principle-c-example"
  - "interface-segregation-principle-definition"
  - "interface-segregation-principle-design-pattern"
  - "interface-segregation-principle-example"
  - "interface-segregation-principle-example-in-c"
  - "interface-segregation-principle-in-agile"
  - "interface-segregation-principle-in-software-engineering"
  - "interface-segregation-principle-in-solid"
  - "interface-segregation-principle-martin"
  - "interface-segregation-principle-principle"
  - "interface-segregation-principle-pros-and-cons"
  - "interface-segregation-principle-real-world-example"
  - "interface-segregation-principle-simple-example"
  - "interface-segregation-principle-solid"
  - "interface-segregation-principle-too-many-interfaces"
  - "interface-segregation-principle-uncle-bob"
  - "interface-segregation-principle-usages"
  - "interface-segregation-principle-violation"
  - "interface-segregation-principle-violation-example"
  - "interface-segregation-principle-vs-single-responsibility"
  - "interface-segregation-principle-with-example"
  - "isp-interface-segregation-principle"
  - "isp-principle"
  - "maintainability"
  - "motivation-violating-the-interface-segregation-principle"
  - "reusability"
  - "segregation-principle"
  - "solid-principles-interface-segregation-principle"
  - "solution-example-of-interface-segregation-principle-in-c"
  - "the-interface-segregation-principle"
  - "what-is-interface-segregation-principle"
  - "why-interface-segregation-principle"
  - "yardstick-to-craft-interface-segregation-principle-friendly-software-in-c"
cover:
    image: /images/Interface-Segregation-Principle-in-C-SOLID-as-a-Rock-vishal-chovatiya.webp
---

**I**nterface **S**egregation **P**rinciple in C++ is the fourth & by far the simplest design principle of a series SOLID as a Rock design principles. The SOLID design principles focus on developing software that is easy to maintainable, reusable & extendable. In this article, we will see a code violating ISP, a solution to the same code, guideline & benefits of ISP.

By the way, If you haven't gone through my previous articles on design principles, then below is the quick links:

{{% include "/reusable_block/solid-design-principles.md" %}}
{{% include "/reusable_block/design-pattern-prerequisites.md" %}}

## Intent

> **_Clients should not be forced to depend on interfaces that they do not use._**

- Interface Segregation Principle is very much related to the Single Responsibility Principle. What it really means is that you should always design your abstractions in such a way that the clients that are using the exposed methods do not have to get the whole pie instead. That imposing the clients with the burden of implementing methods that they don’t actually need.

## Motivation: Violating the Interface Segregation Principle

```cpp
struct Document;

struct IMachine {
    virtual void print(Document &doc) = 0;
    virtual void fax(Document &doc) = 0;
    virtual void scan(Document &doc) = 0;
};

struct MultiFunctionPrinter : IMachine {      // OK
    void print(Document &doc) override { }
    void fax(Document &doc) override { }
    void scan(Document &doc) override { }
};

struct Scanner : IMachine {                   // Not OK
    void print(Document &doc) override { /* Blank */ }
    void fax(Document &doc) override { /* Blank */ }
    void scan(Document &doc) override {  
        // Do scanning ...
    }
};
```

- As you can see, as far as `MultiFunctionPrinter` was concerned it's ok to implement `print()`, `fax()` & `scan()` methods enforced by `IMachine` interface.
- But what if you only need a `Scanner` or `Printer`, some dev still inherits `IMachine` & leave unnecessary methods blank or throw `NotImplemented` exception, either way, you are doing it wrong.

## Solution: Example of Interface Segregation Principle in C++

```cpp
/* -------------------------------- Interfaces ----------------------------- */
struct IPrinter {
    virtual void print(Document &doc) = 0;
};

struct IScanner {
    virtual void scan(Document &doc) = 0;
};
/* ------------------------------------------------------------------------ */

struct Printer : IPrinter {
    void print(Document &doc) override;
};

struct Scanner : IScanner {
    void scan(Document &doc) override;
};

struct IMachine : IPrinter, IScanner { };

struct Machine : IMachine {
    IPrinter&   m_printer;
    IScanner&   m_scanner;

    Machine(IPrinter &p, IScanner &s) : printer{p}, scanner{s} { }

    void print(Document &doc) override { printer.print(doc); }
    void scan(Document &doc) override { scanner.scan(doc); }
};
```

- This gives the flexibility for the clients to combine the abstractions as they may see fit and to provide implementations without unnecessary cargo. 
- As explained in the [Single Responsibility Principle](/posts/single-responsibility-principle-in-cpp-solid-as-a-rock/). You should avoid classes & interfaces with multiple responsibilities. Because they change often and make your software hard to maintain. You should try to **_split up the interface into multiple interfaces based on role_**.

## Benefits

### \=> Faster Compilation

- If you have violated ISP i.e. stuffed methods together in the interface, and when method signature changes, you need to recompile all the derived classes. This is an important aspect for some compiled languages like [C++](/posts/21-new-features-of-modern-cpp-to-use-in-your-project/) which is well known for [slow compilation](https://stackoverflow.com/questions/318398/why-does-c-compilation-take-so-long). While another way around is self explainable.

### \=> Reusability

- [Martin](https://en.wikipedia.org/wiki/Robert_C._Martin) also mentions that **_"fat interfaces" — interfaces with additional useless methods_** — lead to inadvertent coupling between classes. Thus, an experienced dev knows coupling is the bane of reusability.

### \=> Maintainability

- The much more universal ISP benefit is that by avoiding unneeded dependencies, the system becomes
    - easier to understand;
    - lighter to test;
    - quicker to change.
- Similarly, to the reader of your code, it would be harder to get an idea of what your class does from the class declaration line. So, if dev sees only the one god-interface that may have inherited other interfaces it will likely not be obvious. Compare

```cpp
MyMachine : IMachine
```

to

```cpp
MyMachine : IPrinter, IScanner, IFaxer
```

- The latter tells you a lot, the former makes you guess at best.

## Yardstick to Craft Interface Segregation Principle Friendly Software in C++

- This principle comes naturally when you start decomposing your problem space by identifying major roles that take part in your domain. Hence, it's never a mechanical action.
- Following a single question to your self may help you to rectify your design:

**_Do I need all the methods on this interface I'm using?_**

## Closing Notes

Even though big interfaces are a potential problem, the ISP isn't about the size of interfaces. Rather, it's about whether classes use the methods of the interfaces on which they depend. So ISP is poor guidance when designing software, but an excellent indicator of whether it’s healthy or not.
