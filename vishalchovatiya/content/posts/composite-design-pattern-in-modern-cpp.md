---
title: "Composite Design Pattern in Modern C++"
date: "2020-04-05"
categories: 
  - "cpp"
  - "design-patterns"
  - "software-engineering"
tags: 
  - "advantages-and-disadvantages-of-composite-design-pattern"
  - "benefits-of-composite-design-pattern"
  - "classical-composite-design-pattern"
  - "composite-design-pattern-c"
  - "composite-design-pattern-c-code"
  - "composite-design-pattern-c-example"
  - "composite-design-pattern-c-github"
  - "composite-design-pattern-code"
  - "composite-design-pattern-examples-in-c"
  - "composite-design-pattern-in-c-2"
  - "composite-design-pattern-in-c"
  - "composite-design-pattern-in-modern-c"
  - "composite-design-pattern-using-curiously-recurring-template-patterncrtp"
  - "composite-pattern-c"
  - "composite-strategy-pattern"
  - "composition-in-c"
  - "what-is-the-common-example-of-the-composite-design-pattern"
  - "what-is-the-difference-between-decorator-composite-design-pattern"
  - "when-should-i-use-the-composite-design-pattern"
featuredImage: "/images/Composite-Design-Pattern-in-Modern-C-vishal-chovatiya-1.png"
---

[GoF](https://en.wikipedia.org/wiki/Design_Patterns) describes the Composite Design Pattern as “Compose objects into a tree structure to represent part-whole hierarchies. Composite lets the client treat individual objects and compositions of objects uniformly”. This seems over-complicated to me. So, I would not go into tree-leaf kind of jargon. Rather I directly saw you 2 or 3 different ways to implement Composite Design Pattern in Modern C++. But in simple words, the Composite Design Pattern is a Structural Design Pattern with a goal **_to treat the group of objects in the same manner as a single object_**.

By the way, If you haven’t check out my other articles on Structural Design Patterns, then here is the list:

{{% include "/reusable_block/structural-design-patterns.md" %}}
{{% include "/reusable_block/design-pattern-prerequisites.md" %}}

## Intent

> **_To treat individual & group of objects in a uniform manner._**

![](/images/Composite-Design-Pattern-in-Modern-C-vishal-chovatiya-2-1.png)

- So what is it all about and why do we need it. Well, we know that objects typically use other objects fields or properties or members through either inheritance or composition.
- For example, in drawing applications, you have a `Shape`(e.g. `Circle`) that you can draw on the screen but you can also have a group of `Shape`s(e.g. `vector<Circle>`) which inherits from a collection `Shape`.
- And they have certain common API which you can then call on one or the other without knowing in advance whether you're working with a single element or with the entire collection.

## Composite Design Pattern Examples in C++

- So if you think about an application such as PowerPoint or any kind of vector drawing application you know that you can draw & drag individual shapes around.
- But you can also group shapes together. And when you group several shapes together you can treat them as if they were a single shape. So you can grab the entire thing and also drag it and resize it and whatnot.
- So, we're going to implement the Composite Design Pattern around this idea of several different shapes.

### Classical Composite Design Pattern

```cpp
struct Shape {
    virtual void draw() = 0;
};

struct Circle : Shape {
    void draw() { cout << "Circle" << endl; }
};

struct Group : Shape {
    string              m_name;
    vector<Shape*>      m_objects;

    Group(const string &n) : m_name{n} {}

    void draw() {
        cout << "Group " << m_name.c_str() << " contains:" << endl;
        for (auto &&o : m_objects)
            o->draw();
    }
};

int main() {
    Group root("root");
    root.m_objects.push_back(new Circle);

    Group subgroup("sub");
    subgroup.m_objects.push_back(new Circle);

    root.m_objects.push_back(&subgroup);
    root.draw();

    return EXIT_SUCCESS;
}
/*
Group root contains:
Circle
Group sub contains:
Circle
*/
```

## Composite Design Pattern using Curiously Recurring Template Pattern(CRTP)

- As you've probably noticed machine learning is a really hot topic nowadays. And part of the machine learning mechanics is to use of neural networks so that's what we're going to take a look at now.

```cpp
struct Neuron {
    vector<Neuron*>     in, out;
    uint32_t            id;

    Neuron() {
        static int id = 1;
        this->id = id++;
    }

    void connect_to(Neuron &other) {
        out.push_back(&other);
        other.in.push_back(this);
    }

    friend ostream &operator<<(ostream &os, const Neuron &obj) {
        for (Neuron *n : obj.in)
            os << n->id << "\t-->\t[" << obj.id << "]" << endl;

        for (Neuron *n : obj.out)
            os << "[" << obj.id << "]\t-->\t" << n->id << endl;

        return os;
    }
};

int main() {
    Neuron n1, n2;
    n1.connect_to(n2);
    cout << n1 << n2 << endl;
    return EXIT_SUCCESS;
}
/* Output
[1]	-->	2
1	-->	[2]
*/
```

- As you can see we have a neuron structure which has connections to other neurons that modelled as vectors of pointers for input-output neuron connection. This is a very basic implementation and it works just fine as long as you just have individual neurons. Now the one thing that we haven't accounted for is what happens when you have more than one neuron or group of neurons to connect.
- Let's suppose that we decide to make a neuron layer and now a layer of neurons is basically like a collection.

```cpp
struct NeuronLayer : vector<Neuron> {
    NeuronLayer(int count) {
        while (count-- > 0)
            emplace_back(Neuron{});
    }

    friend ostream &operator<<(ostream &os, NeuronLayer &obj) {
        for (auto &n : obj)
            os << n;
        return os;
    }
};

int main() {
    NeuronLayer l1{1}, l2{2};
    Neuron n1, n2;
    n1.connect_to(l1);  // Neuron connects to Layer
    l2.connect_to(n2);  // Layer connects to Neuron
    l1.connect_to(l2);  // Layer connects to Layer
    n1.connect_to(n2);  // Neuron connects to Neuron

    return EXIT_SUCCESS;
}
```

- Now as you probably guessed if you were to implement this head-on you're going to have a total of four different functions. i.e.

```cpp
Neuron::connect_to(NeuronLayer&)
NeuronLayer::connect_to(Neuron&)
NeuronLayer::connect_to(NeuronLayer&)
Neuron::connect_to(Neuron&)
```

- So this is state-space explosion & permutation problem and it's not good because we want a single function that enumerable both the layer as well as individual neurons.

```cpp
template <typename Self>
struct SomeNeurons {
    template <typename T>
    void connect_to(T &other);
};

struct Neuron : SomeNeurons<Neuron> {
    vector<Neuron*>     in, out;
    uint32_t            id;

    Neuron() {
        static int id = 1;
        this->id = id++;
    }

    Neuron* begin() { return this; }
    Neuron* end() { return this + 1; }
};

struct NeuronLayer : vector<Neuron>, SomeNeurons<NeuronLayer> {
    NeuronLayer(int count) {
        while (count-- > 0)
            emplace_back(Neuron{});
    }
};

template <typename Self>
template <typename T>
void SomeNeurons<Self>::connect_to(T &other) {
    for (Neuron &from : *static_cast<Self *>(this)) {
        for (Neuron &to : other) {
            from.out.push_back(&to);
            to.in.push_back(&from);
        }
    }
}

template <typename Self>
ostream &operator<<(ostream &os, SomeNeurons<Self> &object) {
    for (Neuron &obj : *static_cast<Self *>(&object)) {
        for (Neuron *n : obj.in)
            os << n->id << "\t-->\t[" << obj.id << "]" << endl;

        for (Neuron *n : obj.out)
            os << "[" << obj.id << "]\t-->\t" << n->id << endl;
    }
    return os;
}

int main() {
    Neuron n1, n2;
    NeuronLayer l1{1}, l2{2};

    n1.connect_to(l1); // Scenario 1: Neuron connects to Layer
    l2.connect_to(n2); // Scenario 2: Layer connects to Neuron
    l1.connect_to(l2); // Scenario 3: Layer connects to Layer
    n1.connect_to(n2); // Scenario 4: Neuron connects to Neuron

    cout << "Neuron " << n1.id << endl << n1 << endl;
    cout << "Neuron " << n2.id << endl << n2 << endl;

    cout << "Layer " << endl << l1 << endl;
    cout << "Layer " << endl << l2 << endl;

    return EXIT_SUCCESS;
}
/* Output
Neuron 1
[1]	-->	3
[1]	-->	2

Neuron 2
4	-->	[2]
5	-->	[2]
1	-->	[2]

Layer 
1	-->	[3]
[3]	-->	4
[3]	-->	5

Layer 
3	-->	[4]
[4]	-->	2
3	-->	[5]
[5]	-->	2
*/
```

- As you can see we have covered all four different permutation scenarios using a single `SomeNeurons::connect_to` method with the help of CRTP. And both `Neuron` & `NeuronLayer` conforms to this interface via self templatization.
- **C**uriously **R**ecurring **T**emplate **P**attern comes handy here & has very straight implementation rule i.e. **_separate out the type-dependent & independent functionality and bind type_ _independent functionality with the base class using self-referencing template_**.
- I have written a separate article on [Advanced C++ Concepts & Idioms](/posts/7-advanced-cpp-concepts-idiom-examples-you-should-know/) including CRTP.

## Benefits of Composite Design Pattern

1. Reduces code complexity by eliminating many loops over the homogeneous collection of objects.
2. This intern increases the maintainability & testability of code with fewer chances to break existing running & tested code.
3. The relationship is described in the Composite Design Pattern isn't a subclass relationship, it's a collection relationship. Which means client/API-user does not need to care about operations(like translating, rotating, scaling, drawing, etc.) whether it is a single [object](/posts/inside-the-cpp-object-model/) or an entire collection.

## Summary by FAQs

**When should I use the Composite Design Pattern?**

- You want clients to be able to ignore the difference between the group of objects and individual objects.  
- When you find that you are using multiple objects in the same way, and looping over to perform a somewhat similar action, then composite is a good choice.

**What is the common example of the Composite Design Pattern?**

- File & Folder(collection of files): Here File is a single class. Folder inherits File and holds a collection of Files.

**What is the difference between Decorator & Composite Design Pattern?**

- Decorator works on enhancing interface.  
- Composition works to unify interfaces for single & group of objects.
