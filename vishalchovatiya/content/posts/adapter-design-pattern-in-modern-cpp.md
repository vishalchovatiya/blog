---
title: "Adapter Design Pattern in Modern C++"
date: "2020-04-05"
categories: 
  - "cpp"
  - "design-patterns"
  - "software-engineering"
tags: 
  - "adapter-design-pattern-c"
  - "adapter-design-pattern-c-example"
  - "adapter-design-pattern-in-c-2"
  - "adapter-design-pattern-in-c"
  - "adapter-design-pattern-in-c-example"
  - "adapter-design-pattern-in-modern-c"
  - "adapter-pattern-c"
  - "benefits-of-adapter-design-pattern"
  - "c-adapter-pattern"
  - "c-adapter-pattern-template"
  - "classical-adapter-design-pattern"
  - "generic-adapter-using-template"
  - "pluggable-adapter-design-pattern-using-modern-c"
  - "real-life-practical-example-of-the-adapter-design-pattern"
  - "what-are-the-differences-between-bridge-adapter-design-pattern"
  - "what-is-the-difference-between-decorator-adapter-design-pattern"
  - "what-is-the-difference-between-proxy-adapter-design-pattern"
  - "when-to-use-the-adapter-design-pattern"
featuredImage: "/images/Adapter-Design-Pattern-in-Modern-C-vishal-chovatiya.png"
---

In software engineering, Structural Design Patterns deal with the relationship between object & classes i.e. how object & classes interact or build a relationship in a manner suitable to the situation. The structural design patterns simplify the structure by identifying relationships. In this article of the Structural Design Patterns, we're going to take a look at Adapter Design Pattern in Modern C++ which **_used to convert the interface of an existing class into another interface that client/API-user expect_**. Adapter Design Pattern makes classes work together that could not otherwise because of incompatible interfaces.

By the way, If you haven’t check out my other articles on Structural Design Patterns, then here is the list:

{{% include "/reusable_block/structural-design-patterns.md" %}}
{{% include "/reusable_block/design-pattern-prerequisites.md" %}}

## Intent

> **_To get the interface you want from the interface you have._**

- An adapter allows two incompatible classes to work together by converting the interface of one class into an interface expected by the client/API-user without changing them. Basically, adding intermediate class i.e. Adapter.
- If you find yourself in a situation of using Adapter then you might be working on compatibility between libraries, modules, plugins, etc. If not then you might have serious design issues because, if you have followed [Dependency Inversion Principle](/posts/dependency-inversion-principle-in-cpp-solid-as-a-rock/) early in the design. Use of Adapter Design Pattern won't be the case.

## Adapter Design Pattern Examples in C++

- Implementing an Adapter Design Pattern is easy, just determine the API you have & the API you need. Create a component which aggregates(has a reference to,…) the adaptee.

### Classical Adapter

```cpp
struct Point {
    int32_t     m_x;
    virtual void draw(){ cout<<"Point\n"; }
};

struct Point2D : Point {
    int32_t     m_y;
    void draw(){ cout<<"Point2D\n"; }
};

void draw_point(Point &p) {
    p.draw();
}

struct Line {
    Point2D     m_start;
    Point2D     m_end;
    void draw(){ cout<<"Line\n"; }
};

struct LineAdapter : Point {
    Line&       m_line;
    LineAdapter(Line &line) : m_line(line) {}
    void draw(){ m_line.draw(); }
};

int main() {
    Line l;
    LineAdapter lineAdapter(l);
    draw_point(lineAdapter);
    return EXIT_SUCCESS;
}
```

- You can also create a generic adapter by leveraging [C++ template](/posts/c-template-a-quick-uptodate-look/) as follows:

```cpp
template<class T>
struct GenericLineAdapter : Point {
    T&      m_line;
    GenericLineAdapter(T &line) : m_line(line) {}
    void draw(){ m_line.draw(); }
};
```

- The usefulness of the generic approach hopefully becomes more apparent when you consider that when you need to make other things `Point`\-like, the non-generic approach becomes quickly very redundant.

### Pluggable Adapter Design Pattern using Modern C++

- The Adapter should support the adaptees(which are unrelated and have different interfaces) using the same old target interface known to the client/API-user. Below example satisfy this property by using C++11's [lambda function](/posts/learn-lambda-function-in-cpp-with-example/) & functional header.

```cpp
/* Legacy code -------------------------------------------------------------- */
struct Beverage {
    virtual void getBeverage() = 0;
};

struct CoffeeMaker : Beverage {
    void Brew() { cout << "brewing coffee" << endl;}
    void getBeverage() { Brew(); }
};

void make_drink(Beverage &drink){
    drink.getBeverage();                // Interface already shipped & known to client
}
/* --------------------------------------------------------------------------- */

struct JuiceMaker {                     // Introduced later on
    void Squeeze() { cout << "making Juice" << endl; }
};

struct Adapter : Beverage {              // Making things compatible
    function<void()>    m_request;

    Adapter(CoffeeMaker* cm) { m_request = [cm] ( ) { cm->Brew(); }; }
    Adapter(JuiceMaker* jm) { m_request = [jm] ( ) { jm->Squeeze(); }; }

    void getBeverage() { m_request(); }
};

int main() {
    Adapter adp1(new CoffeeMaker());
    make_drink(adp1);

    Adapter adp2(new JuiceMaker());
    make_drink(adp2);
    return EXIT_SUCCESS;
}
```

- The pluggable adapter sorts out which object is being plugged in at the time. Once an object has been plugged in and its methods have been assigned to the delegate objects(i.e. `m_request` in our case), the association lasts until another set of methods is assigned.
- What characterizes a pluggable adapter is that it will have constructors for each of the types that it adapts. In each of them, it does the delegate [assignments](/posts/2-wrong-way-to-learn-copy-assignment-operator-in-cpp-with-example/) (one, or more than one if there are further methods for rerouting).
- Pluggable adapter provides the following two main benefits:
    1. You can bind an interface(bypassing lambda function in constructor argument), unlike the object we did in the above example.
    2. This also helps when adapter & adaptee have a different number of the argument.

## Benefits of Adapter Design Pattern

1. [Open-Closed Principle](/posts/open-closed-principle-in-cpp-solid-as-a-rock/): One advantage of the Adapter Pattern is that you don't need to change the existing class or interface. By introducing a new class, which acts as an adapter between the interface and the class, you avoid any changes to the existing code.
2. This also limits the scope of your changes to your software component and avoids any changes and side-effects in other components or applications.
3. By above two-point i.e. separate class(i.e. [Single Responsibility Principle](/posts/single-responsibility-principle-in-cpp-solid-as-a-rock/)) for special functionality & fewer side-effects, it's obvious we do requires less maintenance, learning curve & testing.
4. AdapterDesing Pattern also adheres to the [Dependency Inversion Principle](/posts/dependency-inversion-principle-in-cpp-solid-as-a-rock/), due to which you can preserve binary compatibility between multiple releases.

## Summary by FAQs

**When to use the Adapter Design Pattern?**

- Use the Adapter class when you want to use some existing class, but its interface isn't compatible with the rest of your code.  
- When you want to reuse several existing subclasses that lack some common functionality that can’t be added to the superclass.  
- For example, let say you have a function which accepts weather object & prints temperature in Celsius. But now you need to print the temperature in Fahrenheit. In this case of an incompatible situation, you can employ the Adapter Design Pattern.

**Real-life & practical example of the Adapter Design Pattern?**

- In STL, stack, queue & priority\_queue are adaptors from deque & vector. When stack executes [stack](https://en.cppreference.com/w/cpp/container/stack)::push(), the underlying vector does `vector::push_back()`  
- A card reader which acts as an adapter between the memory card and a laptop.  
- Your mobile & laptop charges are kind of adapter which converts standard voltage & current to the required one for your device.

**What are the differences between Bridge & Adapter Design Pattern?**

- Adapter is commonly used with an existing app to make some otherwise-incompatible classes work together nicely.  
- [Bridge](/posts/bridge-design-pattern-in-modern-cpp/) is usually designed up-front, letting you develop parts of an application independently of each other.

**What is the difference between Decorator & Adapter Design Pattern?**

- Adapter converts one interface to another, without adding additional functionalities  
- [Decorator](/posts/decorator-design-pattern-in-modern-cpp/) adds new functionality into an existing interface.

**What is the difference between Proxy & Adapter Design Pattern?**

- Adapter Design Pattern translates the interface for one class into a compatible but different interface.  
- [Proxy](/posts/proxy-design-pattern-in-modern-cpp/) provides the same but easy interface or some time act as the only wrapper.
