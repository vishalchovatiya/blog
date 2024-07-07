---
title: "Decorator Design Pattern in Modern C++"
date: "2020-04-05"
categories: 
  - "cpp"
  - "design-patterns"
  - "software-engineering"
tags: 
  - "benefits-of-decorator-design-pattern"
  - "c-decorator-examples"
  - "c-decorator-pattern-c11"
  - "c-design-patterns"
  - "decorator-design-pattern-c"
  - "decorator-design-pattern-c-code"
  - "decorator-design-pattern-examples-in-c"
  - "decorator-design-pattern-in-c"
  - "decorator-design-pattern-in-c-example"
  - "decorator-design-pattern-in-modern-c"
  - "decorator-pattern-c"
  - "decorator-pattern-c-example"
  - "difference-between-adapter-decorator-design-pattern"
  - "difference-between-proxy-decorator-design-pattern"
  - "dynamic-decorator"
  - "functional-decorator"
  - "limitation-of-dynamic-decorator"
  - "static-decorator"
  - "what-are-the-drawbacks-of-using-the-decorator-design-pattern"
  - "when-to-use-the-decorator-design-pattern"
featuredImage: "/images/Decorator-Design-Pattern-in-Modern-C-vishal-chovatiya.png"
---

In software engineering, Structural Design Patterns deal with the relationship between object & classes i.e. how object & classes interact or build a relationship in a manner suitable to the situation. The Structural Design Patterns simplify the structure by identifying relationships. In this article of the Structural Design Patterns, we're going to take a look at the not so complex yet subtle design pattern that is Decorator Design Pattern in Modern C++ due to its extensibility & testability. It is also **_known as Wrapper_**.

By the way, If you haven’t check out my other articles on Structural Design Patterns, then here is the list:

{{% include "/reusable_block/structural-design-patterns.md" %}}
{{% include "/reusable_block/design-pattern-prerequisites.md" %}}

## Intent

> **_To facilitates the additional functionality to objects._**

- Sometimes we have to augment the functionality of existing objects without rewrite or altering existing code, just to stick to the [Open-Closed Principle](/posts/open-closed-principle-in-cpp-solid-as-a-rock/). This also preserves the [Single Responsibility Principle](/posts/single-responsibility-principle-in-cpp-solid-as-a-rock/) to have extra functionality on the side.

## Decorator Design Pattern Examples in C++

- And to achieve this we have two different variants of Decorator Design Pattern in C++:
    1. **Dynamic Decorator**: Aggregate the decorated object by reference or pointer.
    2. **Static Decorator**: Inherit from the decorated object.

### Dynamic Decorator

```cpp
struct Shape {
    virtual operator string() = 0;
};

struct Circle : Shape {
    float   m_radius;

    Circle(const float radius = 0) : m_radius{radius} {}
    void resize(float factor) { m_radius *= factor; }
    operator string() {
        ostringstream oss;
        oss << "A circle of radius " << m_radius;
        return oss.str();
    }
};

struct Square : Shape {
    float   m_side;

    Square(const float side = 0) : m_side{side} {}
    operator string() {
        ostringstream oss;
        oss << "A square of side " << m_side;
        return oss.str();
    }
};
```

- So, we have a hierarchy of two different `Shape`s(i.e. `Square` & `Circle`) & we want to enhance this hierarchy by adding colour to it. Now we're suddenly not going to create two other classes e.g. coloured circle & a coloured square. That would be too much & not a scalable option.
- Rather we can just have `ColoredShape` as follows.

```cpp
struct ColoredShape : Shape {
    const Shape&    m_shape;
    string          m_color;

    ColoredShape(const Shape &s, const string &c) : m_shape{s}, m_color{c} {}
    operator string() {
        ostringstream oss;
        oss << string(const_cast<Shape&>(m_shape)) << " has the color " << m_color;
        return oss.str();
    }
};

// we are not changing the base class of existing objects
// cannot make, e.g., ColoredSquare, ColoredCircle, etc.

int main() {
    Square square{5};
    ColoredShape green_square{square, "green"};    
    cout << string(square) << endl << string(green_square) << endl;
    // green_circle.resize(2); // Not available
    return EXIT_SUCCESS;
}
```

**_Why this is a dynamic decorator?_**  
Because you can instantiate the `ColoredShape` at runtime by providing needed arguments. In other words, you can decide at runtime that which `Shape`(i.e. `Circle` or `Square`) is going to be coloured.

- You can even mix the decorators as follows:

```cpp
struct TransparentShape : Shape {
    const Shape&    m_shape;
    uint8_t         m_transparency;

    TransparentShape(const Shape& s, const uint8_t t) : m_shape{s}, m_transparency{t} {}

    operator string() {
        ostringstream oss;
        oss << string(const_cast<Shape&>(m_shape)) << " has "
            << static_cast<float>(m_transparency) / 255.f * 100.f
            << "% transparency";
        return oss.str();
    }
};

int main() {
    TransparentShape TransparentShape{ColoredShape{Square{5}, "green"}, 51};
    cout << string(TransparentShape) << endl;
    return EXIT_SUCCESS;
}
```

#### Limitation of Dynamic Decorator

If you look at the definition of `Circle`, You can see that the circle has a method called `resize()` we can not use this method as we did aggregation on-base interface `Shape` & bound by the only method exposed in it.

### Static Decorator

- The dynamic decorator is great if you don't know which object you are going to decorate and you want to be able to pick them at runtime but sometimes you know the decorator you want at compile time in which case you can use a combination of [C++ templates](/posts/c-template-a-quick-uptodate-look/) & inheritance.

```cpp
template <class T>  // Note: `class`, not typename
struct ColoredShape : T {
    static_assert(is_base_of<Shape, T>::value, "Invalid template argument"); // Compile time safety

    string      m_color;

    template <typename... Args>
    ColoredShape(const string &c, Args &&... args) : m_color(c), T(std::forward<Args>(args)...) { }

    operator string() {
        ostringstream oss;
        oss << T::operator string() << " has the color " << m_color;
        return oss.str();
    }
};

template <typename T>
struct TransparentShape : T {
    uint8_t     m_transparency;

    template <typename... Args>
    TransparentShape(const uint8_t t, Args... args) : m_transparency{t}, T(std::forward<Args>(args)...) { }

    operator string() {
        ostringstream oss;
        oss << T::operator string() << " has "
            << static_cast<float>(m_transparency) / 255.f * 100.f
            << "% transparency";
        return oss.str();
    }
};

int main() {
    ColoredShape<Circle> green_circle{"green", 5};
    green_circle.resize(2);
    cout << string(green_circle) << endl;

    // Mixing decorators
    TransparentShape<ColoredShape<Circle>> green_trans_circle{51, "green", 5};
    green_trans_circle.resize(2);
    cout << string(green_trans_circle) << endl;
    return EXIT_SUCCESS;
}
```

- As you can see we can now call the `resize()`method which was the limitation of Dynamic Decorator. You can even mix the decorators as we did earlier.
- So essentially what this example demonstrates is that if you're prepared to give up on the dynamic composition nature of the decorator and if you're prepared to define all the decorators at compile time you get the added benefit of using inheritance.
- And that way you actually get the members of whatever object you are decorating being accessible through the decorator & mixed decorator.

### Functional Approach to Decorator Design Pattern using Modern C++

- Up until now, we were talking about the Decorator Design Pattern which decorates over a class but you can do the same for functions. Following is a typical logger example for the same:

```cpp
// Need partial specialization for this to work
template <typename T>
struct Logger;

// Return type and argument list
template <typename R, typename... Args>
struct Logger<R(Args...)> {
    function<R(Args...)>    m_func;
    string                  m_name;

    Logger(function<R(Args...)> f, const string &n) : m_func{f}, m_name{n} { }
 
    R operator()(Args... args) {
        cout << "Entering " << m_name << endl;
        R result = m_func(args...);
        cout << "Exiting " << m_name << endl;
        return result;
    }
};

template <typename R, typename... Args>
auto make_logger(R (*func)(Args...), const string &name) {
    return Logger<R(Args...)>(std::function<R(Args...)>(func), name);
}

double add(double a, double b) { return a + b; }

int main() {
    auto logged_add = make_logger(add, "Add");
    auto result = logged_add(2, 3);
    return EXIT_SUCCESS;
}
```

- Above example may seem a bit complex to you but if you have a clear understanding of [variadic template](/posts/variadic-template-cpp-implementing-unsophisticated-tuple/) then it won't take more than 30 seconds to understand what's going on here.

## Benefits of Decorator Design Pattern

1. Decorator facilitates augmentation of the functionality for an existing object at run-time & compile time.
2. Decorator also provides flexibility for adding any number of decorators, in any order & mixing it.
3. Decorators are a nice solution to permutation issues because you can wrap a component with any number of Decorators.
4. It is a wise choice to apply the Decorator Design Pattern for already shipped code. Because it enables backward compatibility of application & less unit level testing as changes do not affect other parts of code.

## Summary by FAQs

**When to use the Decorator Design Pattern?**

- Employ the Decorator Design Pattern when you need to be able to assign extra behaviours to objects at runtime without breaking the code that uses these objects.  
- When the class has [final](https://en.cppreference.com/w/cpp/keyword/final) keyword which means the class is not further inheritable. In such cases, the Decorator Design Pattern may come to rescue.

**What are the drawbacks of using the Decorator Design Pattern?**

- Decorators can complicate the process of instantiating the component because you not only have to instantiate the component but wrap it in a number of Decorators.  
- Overuse of Decorator Design Pattern may complicate the system in terms of both i.e. Maintainance & learning curve.

**Difference between Adapter & Decorator Design Pattern?**

- **Adapter changes the interface** of an existing object  
- **Decorator enhances the interface** of an existing object

**Difference between Proxy & Decorator Design Pattern?**

- **Proxy** provides a somewhat same or **easy interface**  
- **Decorator** provides **enhanced interface**
