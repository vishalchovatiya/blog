---
title: "Facade Design Pattern in Modern C++"
date: "2020-04-05"
categories: 
  - "cpp"
  - "design-patterns"
  - "software-engineering"
tags: 
  - "benefits-of-facade-design-pattern"
  - "c-facade-pattern"
  - "difference-between-adapter-facade-design-pattern"
  - "facade-design-pattern-c"
  - "facade-design-pattern-c-with-real-time-example"
  - "facade-design-pattern-code"
  - "facade-design-pattern-code-example"
  - "facade-design-pattern-cpp"
  - "facade-design-pattern-example-in-c"
  - "facade-design-pattern-in-c"
  - "facade-design-pattern-in-modern-c"
  - "facade-pattern-c"
  - "is-facade-a-class-which-contains-a-lot-of-other-classes"
  - "what-is-the-practical-use-case-of-the-facade-design-pattern"
featuredImage: "/images/Facade-Design-Pattern-in-Modern-Cpp-vishal-chovatiya.png"
---

Facade Design Pattern is a Structural Design Pattern used **_to provide a unified interface to a complex system_**. It is same as Facade in building architecture, a Facade is an object that serves as a front-facing interface masking a more complex underlying system. A Facade Design Pattern in C++ can:

- Improve the readability & usability of a software library by masking interaction with more complex components by providing a single simplified API.
- Provide a context-specific interface to more generic functionality.
- Serve as a launching point for a broader refactor of monolithic or tightly-coupled systems in favour of more loosely-coupled code. Frankly speaking, even I don't understand this point. I have just copied this from Wikipedia.

Before we move forward, Let me correct the spelling of Facade i.e. "Façade" & it pronounces as "fa;sa;d". A hook or tail added under the letters C called a [cedilla](https://en.wikipedia.org/wiki/Cedilla) used in most of the European languages to indicate a change of pronunciation for that particular letter. We will not go into details of it, otherwise, we would be out of topic.

By the way, If you haven’t check out my other articles on Structural Design Patterns, then here is the list:

{{% include "/reusable_block/structural-design-patterns.md" %}}
{{% include "/reusable_block/design-pattern-prerequisites.md" %}}

## Intent

> **_To provide unified interface by hiding system complexities._**

- This is by far the simplest & easiest design pattern I have ever come across.
- In other words, the Facade Design Pattern is all about providing a simple & easy to understand interface over a large and sophisticated body of code.

## Facade Design Pattern Example in C++

- Imagine you set up a smart house where everything is on the remote. So to turn the lights on you push lights on-button - And same for TV, AC, Alarm, Music, etc…
- When you leave a house you would need to push 100 buttons to make sure everything is off & are good to go which could be a little annoying if you are lazy like me.
- So I defined a Facade for leaving & coming back. (Facade functions represent buttons…). So when I come & leave I just make one call & it takes care of everything…

```cpp
struct Alarm {
    void alarm_on()    { cout << "Alarm is on and house is secured"<<endl; }
    void alarm_off() { cout << "Alarm is off and you can go into the house"<<endl; }
};

struct Ac {
    void ac_on()    { cout << "Ac is on"<<endl; }
    void ac_off()    { cout << "AC is off"<<endl; }
};

struct Tv {
    void tv_on()    { cout << "Tv is on"<<endl; }
    void tv_off()    { cout << "TV is off"<<endl; }
};

struct HouseFacade {
    void go_to_work() {
        m_ac.ac_off();
        m_tv.tv_off();
        m_alarm.alarm_on();
    }
    void come_home() {
        m_alarm.alarm_off();
        m_ac.ac_on();
        m_tv.tv_on();
    }
private:
    Alarm   m_alarm;
    Ac      m_ac;
    Tv      m_tv;
};

int main() {
    HouseFacade hf;
    //Rather than calling 100 different on and off functions thanks to facade I only have 2 functions...
    hf.go_to_work();
    hf.come_home();
    return EXIT_SUCCESS;
}
// Stolen from: https://en.wikibooks.org/wiki/C%2B%2B_Programming/Code/Design_Patterns
```

- Note that we have just combined the different none/somewhat-related classes into `HouseFacade`. We would also be able to use interface with polymorphic `turn_on()` & `turn_off()` method with override in respective [subclasses](/posts/memory-layout-of-cpp-object/), to create a collection of `Ac`, `Tv`, `Alarm` objects to add [Composite Design Pattern](/posts/composite-design-pattern-in-modern-cpp/) for more sophistication.
- But that will complicate system further & add the learning curve. Which is exactly opposite for what Facade Design Pattern is used in the first place.

## Benefits of Facade Design Pattern

1. Facade defines a higher-level interface that makes the subsystem easier to use by wrapping a complicated subsystem.
2. This reduces the learning curve necessary to successfully leverage the subsystem.

## Summary by FAQs

**Is Facade a class which contains a lot of other classes?**

Yes. It is a wrapper for many sub-systems in the application.

**What makes it a design pattern? For me, it is like a normal class.**

All design patterns too are normal classes.

**What is the practical use case of the Facade Design Pattern?**

A typical application of Facade Design Pattern is console/terminal/command-prompt you find in Linux or Windows is a unified way to access machine functionality provided by OS.

**Difference between Adapter & Facade Design Pattern?**

Adapter wraps one class and the Facade may represent many classes
