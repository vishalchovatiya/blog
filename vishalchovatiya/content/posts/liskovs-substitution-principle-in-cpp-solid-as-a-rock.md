---
title: "Liskov's Substitution Principle in C++ | SOLID as a Rock"
date: "2020-04-07"
categories: 
  - "cpp"
  - "design-patterns"
  - "design-principles"
  - "software-engineering"
tags: 
  - "benefits"
  - "compatibility"
  - "intent"
  - "liskov-sub"
  - "liskov-substition-principle"
  - "liskov-substitution-principle-covariance-liskov-substitution-principle-code-example"
  - "liskov-substitution-principle-definition"
  - "liskov-substitution-principle-example"
  - "liskov-substitution-principle-real-world-example"
  - "liskov-substitution-principle-uncle-bob"
  - "liskovs-substitution-principle-2"
  - "liskovs-substitution-principle-in-c-2"
  - "lsp-principle"
  - "maintainability"
  - "motivation-violating-the-liskovs-substitution-principle-2"
  - "principle-of-substitutability"
  - "solid-liskov-substitution-principle"
  - "solid-principles-liskov"
  - "solution-example-of-liskovs-substitution-principle-in-c-2"
  - "substitution-principle"
  - "substitution-principle-definition"
  - "type-safety"
  - "with-factory-pattern"
  - "yardstick-to-craft-liskovs-substitution-principle-friendly-software-in-c"
featuredImage: "/images/Liskovs-Substitution-Principle-in-C-SOLID-as-a-Rock-vishal-chovatiya.webp"
---

So you know how to code in general, understand the object-oriented programming, learned C++, and completed at least one Software Development Course (if you’re not there yet, these articles aren't for you). You can write software easily if you know at least one programming language, but is your code any good? Could it be done any better? Is it clean (and what on earth does that mean)? Is your architecture any good? Should you use a different one? [What about Design Patterns?](/posts/what-is-design-pattern/) These were some of the questions I've had when I started, and answering them helped me to step up to a professional level. Which is why I have written these series SOLID as a Rock design principle. **L**iskov's **S**ubstitution **P**rinciple in C++ is the second principle in this series which I will discuss here.

By the way, If you haven't gone through my previous articles on design principles, then below is the quick links:

{{% include "/reusable_block/solid-design-principles.md" %}}
{{% include "/reusable_block/design-pattern-prerequisites.md" %}}

## Intent

> **_Subtypes must be substitutable for their base types without altering the correctness of the program_**

- If I address this in the context of C++, this literally means that functions that use pointers/references to base classes must be able to substitute by its derived classes.
- The Liskov Substitution Principle revolves around ensuring that inheritance is used correctly.

## Motivation: Violating the Liskov's Substitution Principle

- A great & traditional example illustrating LSP was how sometimes something that sounds right in natural language doesn't quite work in code.
- In mathematics, a `Square` is a `Rectangle`. Indeed it is a specialization of a rectangle. The "IS A" makes you want to model this with inheritance. However if in code you made `Square` derive from `Rectangle`, then a `Square` should be usable anywhere you expect a `Rectangle`. This makes for some strange behaviour as follows:

```cpp
struct Rectangle {
    Rectangle(const uint32_t width, const uint32_t height) : m_width{width}, m_height{height} {}

    uint32_t get_width() const { return m_width; }
    uint32_t get_height() const { return m_height; }

    virtual void set_width(const uint32_t width) { this->m_width = width; }
    virtual void set_height(const uint32_t height) { this->m_height = height; }

    uint32_t area() const { return m_width * m_height; }

protected:
    uint32_t m_width, m_height;
};

struct Square : Rectangle {
    Square(uint32_t size) : Rectangle(size, size) {}
    void set_width(const uint32_t width) override { this->m_width = m_height = width; }
    void set_height(const uint32_t height) override { this->m_height = m_width = height; }
};

void process(Rectangle &r) {
    uint32_t w = r.get_width();
    r.set_height(10);

    assert((w * 10) == r.area()); // Fails for Square <--------------------
}

int main() {
    Rectangle r{5, 5};
    process(r);
    Square s{5};
    process(s);
    return EXIT_SUCCESS;
}
```

- As you can see above, we have violated Liskovs's Substitution Principle in the `void process(Rectangle &r)` function. Therefore `Square` is not a valid substitute of `Rectangle`.
- If you see from the design perspective, the very idea of inheriting `Square` from `Rectangle` is not a good idea. Because `Square` does not have height & width, rather it has the size/length of sides.

## Solution: Example of Liskov's Substitution Principle in C++

### Not so good

```cpp
void process(Rectangle &r) {
    uint32_t w = r.get_width();
    r.set_height(10);

    if (dynamic_cast<Square *>(&r) != nullptr)
        assert((r.get_width() * r.get_width()) == r.area());
    else
        assert((w * 10) == r.area());
}
```

- A common code smell that frequently indicates an LSP violation is the presence of [type checking](/posts/cpp-type-casting-with-example-for-c-developers/) code within a code block that is polymorphic.
- For instance, if you have a `std::for_each` loop over a collection of objects of type `Foo`, and within this loop, there is a check to see if `Foo` is in fact `Bar`(a subtype of `Foo`), then this is almost certainly an LSP violation. Rather you should ensure `Bar` is in all ways substitutable for `Foo`, there should be no need to include such a check.

### An OK way to do it

```cpp
void process(Rectangle &r) {
    uint32_t w = r.get_width();
    r.set_height(10);

    if (r.is_square())
        assert((r.get_width() * r.get_width()) == r.area());
    else
        assert((w * 10) == r.area());
}
```

- No need to create a separate class for `Square`. Instead, you can simply check for `bool` flag within the `Rectangle` class to validate `Square` property. Though not a recommended way.

### Use proper inheritance hierarchy

```cpp
struct Shape {
    virtual uint32_t area() const = 0;
};

struct Rectangle : Shape {
    Rectangle(const uint32_t width, const uint32_t height) : m_width{width}, m_height{height} {}

    uint32_t get_width() const { return m_width; }
    uint32_t get_height() const { return m_height; }

    virtual void set_width(const uint32_t width) { this->m_width = width; }
    virtual void set_height(const uint32_t height) { this->m_height = height; }

    uint32_t area() const override { return m_width * m_height; }

private:
    uint32_t m_width, m_height;
};

struct Square : Shape {
    Square(uint32_t size) : m_size(size) {}
    void set_size(const uint32_t size) { this->m_size = size; }
    uint32_t area() const override { return m_size * m_size; }

private:
    uint32_t m_size;
};

void process(Shape &s) {
    // Use polymorphic behaviour only i.e. area()
}
```

### With Factory Pattern

- Still, creation or change is needed to process `Shape`, then you should try to use [Virtual Constructor](/posts/7-advanced-cpp-concepts-idiom-examples-you-should-know/#Virtual-Constructor) & [Virtual Copy Constructor](/posts/prototype-design-pattern-in-modern-cpp/) i.e. [Factory Pattern](/posts/factory-design-pattern-in-modern-cpp/).

```cpp
struct ShapeFactory {
    static Shape CreateRectangle(uint32_t width, uint32_t height);
    static Shape CreateSquare(uint32_t size);
};
```

## Benefits of Liskov's Substitution Principle

### \=> Compatibility

- It enables the binary compatibility between multiple releases & patches. In other words, It keeps the client code away from being impacted.

### \=> Type Safety

- It's the easiest approach to handle type safety with inheritance, as types are not allowed to _vary_ when inheriting.

### \=> Maintainability

- Code that adheres to LSP is loosely dependent on each other & encourages code reusability.
- Code that adheres to the LSP is code that makes the right abstractions.

## Yardstick to Craft Liskov's Substitution Principle Friendly Software in C++

- In most introductions to [object-oriented programming](/posts/memory-layout-of-cpp-object/), inheritance discussed as an "IS-A" relationship with the inherited object. However, this is necessary, but not sufficient. It is more appropriate to say that one object can be designed to inherit from another if it always has an "IS-SUBSTITUTABLE-FOR" relationship with the inherited object.
- The whole point of using an abstract base class is so that, in the future, you can write a new [subclass](/posts/inside-the-cpp-object-model/) & insert it into existing, working, tested code. A noble goal, but how to achieve it? First, start with decomposing your problem space --- domain. Second, express your contract/interfaces/[virtual-methods](/posts/part-1-all-about-virtual-keyword-in-cpp-how-virtual-function-works-internally/) in plain English.

## Closing Notes

Don’t get me wrong, I like SOLID and the approaches it promotes. But it’s just a shape of deeper principles lying in its foundation. The examples above made it clear what this principle is striving for i.e. **_loose coupling & ensuring correct inheritance_**.

Now, go out there and make your subclasses swappable, and thank [**Dr. Barbara Liskov**](https://en.wikipedia.org/wiki/Barbara_Liskov) for such a useful principle.
