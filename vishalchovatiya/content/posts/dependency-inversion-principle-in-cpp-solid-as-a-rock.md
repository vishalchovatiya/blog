---
title: "Dependency Inversion Principle in C++ | SOLID as a Rock"
date: "2020-04-06"
categories: 
  - "cpp"
  - "design-patterns"
  - "design-principles"
  - "software-engineering"
tags: 
  - "benefits"
  - "dependency-inversion"
  - "dependency-inversion-example"
  - "dependency-inversion-pattern"
  - "dependency-inversion-principle"
  - "dependency-inversion-principle-c"
  - "dependency-inversion-principle-c-example"
  - "dependency-inversion-principle-example"
  - "dependency-inversion-principle-in-c"
  - "dependency-inversion-principle-real-world-example"
  - "dip-principle"
  - "intent"
  - "inversion-of-control-principle"
  - "inversion-principle"
  - "maintainability"
  - "motivation-violating-dependency-inversion-principle"
  - "open-closed-principle-vs-dependency-inversion"
  - "reusability"
  - "solid-dependency-inversion"
  - "solid-principles"
  - "solid-principles-dependency-inversion"
  - "solution-example-of-dependency-inversion-principle-in-c"
  - "the-dependency-inversion-principle-c"
  - "uncle-bob-dependency-inversion"
  - "when-to-use-dependency-inversion"
  - "yardstick-to-craft-dependency-inversion-principledip-friendly-software-in-c"
featuredImage: "/images/SOLID-as-a-Rock-Dependency-Inversion-Principle-in-C-Vishal-Chovatiya.webp"
---

**D**ependency **I**nversion **P**rinciple in C++ is the fifth & last design principle of a series SOLID as a Rock design principles. The SOLID design principles focus on developing software that is easy to maintainable, reusable & extendable. In this article, we will see an example code with the flaw & correct it with help of DIP. We will also see guideline & benefits of DIP in closure of the article.

By the way, If you haven't gone through my previous articles on design principles, then below is the quick links:

{{% include "/reusable_block/solid-design-principles.md" %}}
{{% include "/reusable_block/design-pattern-prerequisites.md" %}}

## Intent

> **=> High-level modules should not depend on low-level modules. Both should depend on abstractions.**

> **=> Abstractions should not depend on details. Details should depend on abstractions.**

- Above lines might seem cryptic at first but don't stick here keep going. You will get it by example.

**What are the High-level & Low-level modules?**

**_\=>_** **High-level modules**: _describes operations_ which is more abstract in nature & contain more complex logic. These modules orchestrate low-level modules in our application.  
**_\=>_** **Low-level modules**: _describes implementations_ more specific & individual to components focusing on details & smaller parts of the application. These modules are used inside the high-level modules.

## Motivation: Violating Dependency Inversion Principle

```cpp
enum class Relationship { parent, child, sibling };

struct Person {
    string      m_name;
};

struct Relationships {      // Low-level <<<<<<<<<<<<-------------------------
    vector<tuple<Person, Relationship, Person>>     m_relations;

    void add_parent_and_child(const Person &parent, const Person &child) {
        m_relations.push_back({parent, Relationship::parent, child});
        m_relations.push_back({child, Relationship::child, parent});
    }
};

struct Research {           // High-level  <<<<<<<<<<<<------------------------
    Research(const Relationships &relationships) {
        for (auto &&[first, rel, second] : relationships.m_relations) {// Need C++17 here
            if (first.m_name == "John" && rel == Relationship::parent)
                cout << "John has a child called " << second.m_name << endl;
        }
    }
};

int main() {
    Person parent{"John"};
    Person child1{"Chris"};
    Person child2{"Matt"};

    Relationships relationships;
    relationships.add_parent_and_child(parent, child1);
    relationships.add_parent_and_child(parent, child2);

    Research _(relationships);

    return EXIT_SUCCESS;
}
```

- When later on the container of `Relationships` changes from `vector` to `set` or any other container, you need to change in many places which isn't a very good design. Even if just the name of data member i.e. `Relationships::m_relations` changes, you will find yourself breaking other parts of code.
- As you can see Low-level module i.e. `Relationships` directly depend on High-level module i.e. `Research` which is essentially a violation of DIP.

## Solution: Example of Dependency Inversion Principle in C++

- Rather we should create an abstraction and bind Low-level & High-level module to that abstraction. Consider the following fix:

```cpp
struct RelationshipBrowser {
    virtual vector<Person> find_all_children_of(const string &name) = 0;
};

struct Relationships : RelationshipBrowser {     // Low-level <<<<<<<<<<<<<<<------------------------
    vector<tuple<Person, Relationship, Person>>     m_relations;

    void add_parent_and_child(const Person &parent, const Person &child) {
        m_relations.push_back({parent, Relationship::parent, child});
        m_relations.push_back({child, Relationship::child, parent});
    }

    vector<Person> find_all_children_of(const string &name) {
        vector<Person> result;
        for (auto &&[first, rel, second] : m_relations) {
            if (first.name == name && rel == Relationship::parent) {
                result.push_back(second);
            }
        }
        return result;
    }
};

struct Research {                                // High-level <<<<<<<<<<<<<<<----------------------
    Research(RelationshipBrowser &browser) {
        for (auto &child : browser.find_all_children_of("John")) {
            cout << "John has a child called " << child.name << endl;
        }
    }
    //  Research(const Relationships& relationships)
    //  {
    //    auto& relations = relationships.relations;
    //    for (auto&& [first, rel, second] : relations)
    //    {
    //      if (first.name == "John" && rel == Relationship::parent)
    //      {
    //        cout << "John has a child called " << second.name << endl;
    //      }
    //    }
    //  }
};
```

- Now no matter, the name of container or container itself changes in Low-level module, High-level module or other parts of code which followed DIP will be in-tact.
- The Dependency Inversion Principle (DIP) suggest that the most flexible systems are those in which source code dependencies refer only to abstractions, not to concretions.
- This is the reason why most experienced dev uses STL or library functions along with generic containers. Even using an `auto` keyword at appropriate places may help in creating generic behaviour with less fragile code.
- There are many ways you can implement DIP, as long as C++ concerns most people use static polymorphism(i.e. [CRTP](/posts/7-advanced-cpp-concepts-idiom-examples-you-should-know/#CRTP) unless they need dynamic one), [template specialization](https://stackoverflow.com/a/43576623), [Adapter Design Pattern](/posts/adapter-design-pattern-in-modern-cpp/), [type-erasure](/posts/7-advanced-cpp-concepts-idiom-examples-you-should-know/#Type-Eraser), etc.

## Yardstick to Craft Dependency Inversion Principle(DIP) Friendly Software in C++

- If you find enforcing DIP difficult then just design abstraction first & implement your high-level module on the bases of abstraction. Without having any knowledge of the low-level module or its implementation. Because of this process DIP is also known as **_Coding To Interface_**.
- Keep in mind that all Low-level-modules/[subclasses](/posts/memory-layout-of-cpp-object/) adhere to the [Liskov Substitution Principle](/posts/liskovs-substitution-principle-in-cpp-solid-as-a-rock/). This is because the Low-level-modules/[subclasses](/posts/inside-the-cpp-object-model/) will be used via the abstract interface, not the concrete classes interface.

## Benefits

### \=> Reusability

- Effectively, the DIP reduces coupling between different pieces of code. Thus we get reusable code.

### \=> Maintainability

- It is also important to mention that changing already implemented modules is risky. By depending on abstraction & not on concrete implementation, we can reduce that risk by not having to change high-level modules in our project.
- Finally, DIP when applied correctly gives us flexibility and stability at the level of the entire architecture of our application. Our application will be able to evolve more securely and become stable & robust.

## Conclusion

As you can see we took a basic example of code & converted it into a reusable, flexible & modular piece of code. If I would have to summarize DIP in simple & short sentence then it would be like:
1. Do not use the concrete object directly unless you have a strong reason to do so. Use abstraction instead.
2. DIP trains us to think about classes in terms of behaviour, rather than construction or implementation.
