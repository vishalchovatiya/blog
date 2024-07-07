---
title: "Builder Design Pattern in Modern C++"
date: "2020-04-06"
categories: 
  - "cpp"
  - "design-patterns"
  - "software-engineering"
tags: 
  - "benefits-of-builder-design-pattern"
  - "builder-design-pattern-c"
  - "builder-design-pattern-code-example"
  - "builder-design-pattern-in-c"
  - "builder-design-pattern-in-c-2"
  - "builder-design-pattern-in-c-github"
  - "builder-design-pattern-in-modern-c"
  - "builder-factory-design-pattern"
  - "builder-pattern-in-c"
  - "c-builder-design-pattern"
  - "c-builder-pattern"
  - "c-builder-pattern-example"
  - "incomplete-type-forward-declaration-c"
  - "intent-builder-design-pattern"
  - "life-without-builders"
  - "prototype-design-pattern-c"
  - "sophisticated-fluent-builder-design-pattern-example"
  - "when-should-the-builder-design-pattern-be-used"
  - "why-do-we-need-a-builder-class-when-implementing-a-builder-design-pattern"
featuredImage: "/images/Builder-Design-Pattern-in-Modern-C-vishal-chovatiya.webp"
---

In software engineering, Creational Design Patterns deal with object creation mechanisms, trying to create objects in a manner suitable to the situation. The basic or ordinary form of object creation could result in design problems or added complexity to the design. Builder Design Pattern in C++ solves this specific problem by **_separating the construction of a complex object from its representation_**.

By the way, If you haven’t check out my other articles on Creational Design Patterns, then here is the list:

{{% include "/reusable_block/creational-design-patterns.md" %}}
{{% include "/reusable_block/design-pattern-prerequisites.md" %}}

## Intent

> **_To create/instantiate complex & complicated object piecewise & succinctly by providing an API in a separate entity._**

- Builder Design Pattern is used when we want to construct a complex object. However, we do not want to have a complex constructor member or one that would need many arguments.
- The Builder Design Pattern constructs a complex object step by step & the final step will return the object. The process of constructing an object should be generic so that it can be used to create different representations of the same object with the help of a variety of methods.

## Life Without Builders

- Suppose you have to create the HTML generator using C++ then very naïve way to do it is :

```cpp
// <p>hello</p>
auto text = "hello";
string output;
output += "<p>";
output += text;
output += "</p>";
printf("<p>%s</p>", text);

// <ul><li>hello</li><li>world</li></ul>
string words[] = {"hello", "world"};
ostringstream oss;
oss << "<ul>";
for (auto w : words)
    oss << "  <li>" << w << "</li>";
oss << "</ul>";
printf(oss.str().c_str());
```

- A sophisticated dev will create a class with a bunch of constructor argument & method to add a child node. This is a good approach though but it may complicate the object representation.
- In general, some objects are simple & can be created in a single constructor call while other objects require a lot of ceremonies to create.
- Having an object with 10 constructor arguments is not productive. Instead, we should opt for piecewise construction.
- Builder provides an API for constructing an object step-by-step without revealing actual object representation.

## Builder Design Pattern Example in Modern C++

```cpp
class HtmlBuilder;

class HtmlElement {
    string                      m_name;
    string                      m_text;
    vector<HtmlElement>         m_childs;
    constexpr static size_t     m_indent_size = 4;

    HtmlElement() = default;
    HtmlElement(const string &name, const string &text) : m_name(name), m_text(text) {}
    friend class HtmlBuilder;

public:
    string str(int32_t indent = 0) {
        ostringstream oss;
        oss << string(m_indent_size * indent, ' ') << "<" << m_name << ">" << endl;

        if (m_text.size()) oss << string(m_indent_size * (indent + 1), ' ') << m_text << endl;

        for (auto &element : m_childs)
            oss << element.str(indent + 1);

        oss << string(m_indent_size * indent, ' ') << "</" << m_name << ">" << endl;
        return oss.str();
    }
    static unique_ptr<HtmlBuilder> build(string root_name) { return make_unique<HtmlBuilder>(root_name); }
};

class HtmlBuilder {
    HtmlElement     m_root;

public:
    HtmlBuilder(string root_name) { m_root.m_name = root_name; }
    HtmlBuilder *add_child(string child_name, string child_text) {
        m_root.m_childs.emplace_back(HtmlElement{child_name, child_text});
        return this;
    }
    string str() { return m_root.str(); }
    operator HtmlElement() { return m_root; }
};

int main() {
    auto builder = HtmlElement::build("ul");
    builder->add_child("li", "hello")->add_child("li", "world");

    cout << builder->str() << endl;
    return EXIT_SUCCESS;
}
/*
<ul>
    <li>
        hello
    </li>
    <li>
        world
    </li>
</ul>
*/
```

- We are forcing users here to use builder by making data members of `HtmlElements` private.
- As you can see, we have declared the `HtmlBuilder` & `HtmlElement` in the same file & to do so, we need forward declaration i.e. `class HtmlBuilder;` as it is an [incomplete type](https://docs.microsoft.com/en-us/cpp/c-language/incomplete-types). And we can not create the object of incomplete type before compiler parses its actual declaration. The reason is simple, the compiler needs the size of an object to allocate memory for it. Hence pointer is only way around so we have taken [unique_ptr](/posts/understanding-unique-ptr-with-example-in-cpp11/)<HtmlBuilder>.

## Sophisticated & Fluent Builder Design Pattern Example

- Following is the more sophisticated example of the Builder Design Pattern in C++ organized in four different files(i.e. `Person.h`, `Person.cpp`, `PersonBuilder.h` `PersonBuilder.cpp`).

**`Person.h`**

```cpp
#pragma once
#include <iostream>
using namespace std;

class PersonBuilder;

class Person
{
    std::string m_name, m_street_address, m_post_code, m_city;  // Personal Detail
    std::string m_company_name, m_position, m_annual_income;    // Employment Detail

    Person(std::string name) : m_name(name) {}

public:
    friend class PersonBuilder;
    friend ostream& operator<<(ostream&  os, const Person& obj);
    static PersonBuilder create(std::string name);
};
```

**`Person.cpp`**

```cpp
#include <iostream>
#include "Person.h"
#include "PersonBuilder.h"

PersonBuilder Person::create(string name) { return PersonBuilder{name}; }

ostream& operator<<(ostream& os, const Person& obj)
{
    return os << obj.m_name
              << std::endl
              << "lives : " << std::endl
              << "at " << obj.m_street_address
              << " with postcode " << obj.m_post_code
              << " in " << obj.m_city
              << std::endl
              << "works : " << std::endl
              << "with " << obj.m_company_name
              << " as a " << obj.m_position
              << " earning " << obj.m_annual_income;
}
```

- As you can see from the above example `Person` may have many details like Personal & Professional. And so does the count of data members.
- In our case, there are 7 data members. Having a single class for all the actions needed to create a Person through constructor might make our class bloated & lose its original purpose. Moreover, the library user needs to take care of all those constructor parameters sequence.

**`PersonBuilder.h`**

```cpp
#pragma once
#include "Person.h"

class PersonBuilder
{
    Person person;

public:
    PersonBuilder(string name) : person(name) {}

    operator Person() const { return move(person); }

    PersonBuilder&  lives();
    PersonBuilder&  at(std::string street_address);
    PersonBuilder&  with_postcode(std::string post_code);
    PersonBuilder&  in(std::string city);
    PersonBuilder&  works();
    PersonBuilder&  with(string company_name);
    PersonBuilder&  as_a(string position);
    PersonBuilder&  earning(string annual_income);
};
```

**`PersonBuilder.cpp`**

```cpp
#include "PersonBuilder.h"

PersonBuilder&  PersonBuilder::lives() { return *this; }

PersonBuilder&  PersonBuilder::works() { return *this; }

PersonBuilder&  PersonBuilder::with(string company_name) {
    person.m_company_name = company_name; 
    return *this;
}

PersonBuilder&  PersonBuilder::as_a(string position) {
    person.m_position = position; 
    return *this;
}

PersonBuilder&  PersonBuilder::earning(string annual_income) {
    person.m_annual_income = annual_income; 
    return *this;
}

PersonBuilder&  PersonBuilder::at(std::string street_address) {
    person.m_street_address = street_address; 
    return *this;
}

PersonBuilder&  PersonBuilder::with_postcode(std::string post_code) {
    person.m_post_code = post_code; 
    return *this;
}

PersonBuilder&  PersonBuilder::in(std::string city) {
    person.m_city = city; 
    return *this;
}
```

- Rather stuffing all those construction related APIs into `Person`, we can delegate that task to separate entity i.e. `PersonBuilder`.

**`Main.cpp`**

```cpp
#include <iostream>
#include "Person.h"
#include "PersonBuilder.h"
using namespace std;

int main()
{
    Person p = Person::create("John")
                                .lives()
                                    .at("123 London Road")
                                    .with_postcode("SW1 1GB")
                                    .in("London")
                                .works()
                                    .with("PragmaSoft")
                                    .as_a("Consultant")
                                    .earning("10e6");

    cout << p << endl;
    return EXIT_SUCCESS;
}
```

- Isn't the above construction looks more intuitive, natural & plain English?
- If you are concerned about blank methods like `lives()` & `works()`, then do not worry, it will be eliminated in optimization.
- You can also observe that we are forcing user's to use builder rather than constructor by making the constructor private & exposing only `create(std::string name)` API.
- Do not over complicate things by designing an interface or abstract classes unless you need it. I have seen this in many Builder Design Pattern Examples on Web.

## Benefits of Builder Design Pattern

- The number of lines of code increases at least to double in builder pattern. But the effort pays off in terms of design flexibility, fewer or no parameters to the constructor and much more readable code.
- Builder Design Pattern also helps in minimizing the number of parameters in constructor & thus there is no need to pass in [null](/posts/what-exactly-nullptr-is-in-cpp/) for optional parameters to the constructor.
- Immutable objects can be built without much complex logic in the object building process.
- Segregating construction from [object representation](/posts/memory-layout-of-cpp-object/) makes the object representation slice & precise. Having a builder entity separate provides the flexibility of creating & instantiating different objects representations.

## Summary by FAQs

**When should the Builder Design Pattern be used?**

Whenever creation of new object requires setting many parameters and some of them (or all of them) are optional.

**Why do we need a Builder class when implementing a Builder Design Pattern?**

It isn't necessary but there are some benefits in doing so:  
- The concern of building object should be in the separate entity as per [SRP](/posts/single-responsibility-principle-in-cpp-solid-as-a-rock/).  
- The original object would not be bloated.  
- Easy & maintainable code.  
- Testing & understanding a constructor with many input arguments gets exponentially more complicated.

**Greatest Advantage of Builder Design Pattern!**

More expressive code.  
```cpp
MyClass o = new MyClass(5, 5.5, 'A', var, 1000, obj9, "hello");
```
- Instead  
```cpp
MyClass o = MyClass.builder().a(5).b(5.5).c('A').d(var).e(1000).f(obj9).g("hello");
```
- You can see which data member is being assigned by what & even change the order of assignment.

**What's the difference between Abstract Factory and Builder Design Pattern?**

- Factory produces the objects in wholesale that could be any object from inheritance hierarchy(like Point, Point2D, Point3D). While Builder deals with instantiation of an object that is limited to a single object(Although this statement is still debatable).  
- You see Factory is all about wholesale object creation while the builder is piecewise object creation. In both the patterns, you can separate out the mechanism related to object creation in other classes.
