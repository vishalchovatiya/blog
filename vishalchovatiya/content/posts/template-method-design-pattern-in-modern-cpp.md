---
title: "Template Method Design Pattern in Modern C++"
date: "2020-04-02"
categories: 
  - "cpp"
  - "design-patterns"
  - "software-engineering"
tags: 
  - "benefits-of-template-method-design-pattern"
  - "high-level-blueprint-of-an-algorithm-template-method-design-pattern-example-in-c"
  - "template-design-pattern-cpp"
  - "template-design-pattern-example-code"
  - "template-design-pattern-example-in-c"
  - "template-design-pattern-in-c"
  - "template-factory-design-pattern-c"
  - "template-method-design-pattern-in-c"
  - "template-method-design-pattern-in-modern-c"
  - "what-is-the-difference-between-strategy-template-method-design-pattern"
  - "where-should-we-use-the-template-method-design-pattern"
cover:
    image: /images/Template-Method-Design-Pattern-in-Modern-C-vishal-chovatiya.png
---

In software engineering, Behavioural Design Patterns deal with the assignment of responsibilities between objects. And encapsulating behaviour in an object to delegate requests. The Behavioural Design Patterns make the interaction between the objects easy & loosely coupled. In this article of the design pattern series, we're going to take a look at Template Method Design Pattern in Modern C++. It **_allows us to define the skeleton of the algorithm in the base class with concrete implementations defined in derived classes_**.

By the way, If you haven’t check out my other articles on Behavioural Design Patterns, then here is the list:

{{% include "/reusable_block/behavioural-design-patterns.md" %}}
{{% include "/reusable_block/design-pattern-prerequisites.md" %}}

## Intent

> **_To provide high-level blueprint of an algorithm to be completed by its inheritors._**

- Now, this might seem familiar to you because we've seen something like this already in the [Strategy Design Pattern](/posts/strategy-design-pattern-in-modern-cpp/). So we know that algorithms generally can be decomposed into the common parts(i.e. high-level parts) as well as the specifics. And the [Strategy Design Pattern](/posts/strategy-design-pattern-in-modern-cpp/) handles that for us quite efficiently. Then why do we need yet another design pattern
- [Strategy Design Pattern](/posts/strategy-design-pattern-in-modern-cpp/) does this through composition. In which you have the high-level algorithm that uses some interface. And then the concrete implementations actually implement this interface and then you stick them in as pointer or reference.
- Template Method Design Pattern is very similar except it does this through inheritance instead. So the overall algorithm would typically be in an [abstract base class](https://isocpp.org/wiki/faq/abcs). And then, of course, you have inheritors of this class which overrides certain key abstract members. But the base class actually keeps the template for the actual algorithms. So the parent class template method is then invoked to actually orchestrate the algorithm at the high level. This might still do not fit in your head right-away but the following example will surely help.

## Template Method Design Pattern Example in C++

```cpp
struct Game {
    explicit Game(uint32_t players): m_no_of_players(players) {}

    void run() {
        start();
        while (!have_winner())
            take_turn();
        cout << "Player " << get_winner() << " wins.\n";
    }

protected:
    virtual void start() = 0;
    virtual bool have_winner() = 0;
    virtual void take_turn() = 0;
    virtual uint32_t get_winner() = 0;

    uint32_t m_current_player{0};
    uint32_t m_no_of_players{0};
};

struct Chess : Game {
    explicit Chess(): Game {2} {}

protected:
    void start() {
        cout << "Starting chess with " << m_no_of_players << " players\n";
    }

    bool have_winner() { return m_turns == m_max_turns; }

    void take_turn() {
        cout << "Turn " << m_turns << " taken by player " << m_current_player << "\n";
        m_turns++;
        m_current_player = (m_current_player + 1) % m_no_of_players;
    }

    uint32_t get_winner() { return m_current_player; }

private:
    uint32_t m_turns{0}, m_max_turns{4};
};

int main() {
    Chess chess;
    chess.run();
    return EXIT_SUCCESS;
}
/*  
Starting chess with 2 players
Turn 0 taken by player 0
Turn 1 taken by player 1
Turn 2 taken by player 0
Turn 3 taken by player 1
Player 0 wins.
*/
```

- As you can see the `Game::run()`is our template method that the algorithm itself is defined not in some external class but in an abstract base class. And then we inherit `Chess` from `Game` to provide the implementation of the parts(i.e. [pure virtual methods](/posts/part-1-all-about-virtual-keyword-in-cpp-how-virtual-function-works-internally/)) of the `run()`template method.
- To implement the Template Method Design Pattern, you have to think in terms of reverse inheritance. For example, you have a bunch of documents like PDF, Doc, HTML, XML. For which you have to create a data mining algorithm. In case of inheritance what you do is you define `mine()`method as [pure virtual](/posts/part-1-all-about-virtual-keyword-in-cpp-how-virtual-function-works-internally/) in an abstract class. And override it in [subclasses](/posts/memory-layout-of-cpp-object/) while technically you should define the algorithm mine(in abstract class) like:

```cpp
void mine(const string& report_file){
    while(!EOF()){
        auto line = get_line();
        auto data_samples = parse(line);
        add_to_(report_file, data_samples);
    }
}
```

- And make all of this method(i.e. `get_line()`, `parse()`, etc.) of the mining algorithm [pure virtual](/posts/part-1-all-about-virtual-keyword-in-cpp-how-virtual-function-works-internally/) to be implemented by derived class as these are the common yet type-dependent steps among the type of documents to extract data.

## Benefits of Template Method Design Pattern

1. If you have a monolithic algorithm exposed to each & every class. And when steps of that algorithm changes, you might need to modify all the classes. But if you have several classes that contain almost identical algorithms with some minor differences & had employed the Template Method Design Pattern. Then you will have no worries.
2. By pulling the common steps into abstract class, you are limiting code duplicity & encouraging expressiveness of code.

## Summary by FAQs

**What is the difference between Strategy & Template Method Design Pattern?**

- Template Method is based on inheritance which alters parts of an algorithm by extending those parts in derived classes.  
- Strategy is based on the composition which alters parts of the [object](/posts/inside-the-cpp-object-model/)'s behaviour by supplying it with different strategies that correspond to different behaviour.  
  
- Template Method works at the class level, so it's static.  
- Strategy works on the [object](/posts/inside-the-cpp-object-model/) level, letting you switch behaviours at runtime.

**Where should we use the Template Method Design Pattern?**

Employ the Template Method Design Pattern when you want to let clients extend only particular steps of an algorithm, but not the entire algorithm structure.
