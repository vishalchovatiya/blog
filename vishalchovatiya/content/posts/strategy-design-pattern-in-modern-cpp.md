---
title: "Strategy Design Pattern in Modern C++"
date: "2020-04-02"
categories: 
  - "cpp"
  - "design-patterns"
  - "software-engineering"
tags: 
  - "benefits-of-strategy-design-pattern"
  - "dynamic-strategy"
  - "implementation-of-strategy-design-pattern-in-c"
  - "motivation-of-strategy-design-pattern"
  - "static-strategy"
  - "strategy-design-pattern-c-geeksforgeeks"
  - "strategy-design-pattern-code-example"
  - "strategy-design-pattern-examples-in-c"
  - "strategy-design-pattern-in-c"
  - "strategy-design-pattern-in-c-examples"
  - "strategy-design-pattern-in-cpp"
  - "strategy-design-pattern-in-modern-c"
  - "strategy-pattern-c11"
  - "what-is-the-difference-between-the-strategy-state-design-pattern"
  - "when-should-the-strategy-design-pattern-be-used"
  - "when-to-use-strategy-design-pattern"
  - "why-do-we-use-the-strategy-design-pattern"
featuredImage: "/images/Strategy-Design-Pattern-in-Modern-C-vishal-chovatiya.png"
---

In software engineering, Behavioural Design Patterns deal with the assignment of responsibilities between objects which in turn make the interaction between the objects easy & loosely coupled. In this article of the Behavioural Design Pattern series, we're going to take a look at Strategy Design Pattern in Modern C++. It **_allows you to partially specify the behaviour of the class and then augment it later on_**. This pattern is also known as [policy](https://en.wikipedia.org/wiki/Modern_C%2B%2B_Design#Policy-based_design) in many programming languages including especially in the C++ language.

By the way, If you haven’t check out my other articles on Behavioural Design Patterns, then here is the list:

{{% include "/reusable_block/behavioural-design-patterns.md" %}}
{{% include "/reusable_block/design-pattern-prerequisites.md" %}}

## Intent

> **_To choose particular algorithm from a family of algorithms depending upon need._**

- So many algorithms can actually decomposed into what I would call the higher & lower-level parts. For example, let's consider the process of making tea. So the process of making tea can decomposed into something higher level like the process of making a hot beverage.
- Because, whether you're making tea or coffee or any other hot drink you have to boil the water. Then, you have to pour the water into the cup. So that is the high-level part can reuse.
- And the specific things are to be specific but everything else can be reused for making something else like coffee or hot chocolate for example.
- And this supports the beverage-specific strategies. So that is where the Strategy Design Pattern actually comes in. Strategy Design Pattern essentially enables the exact behaviour of a system to become selective either at compile time or run time.

## Strategy Design Pattern Examples in C++

- We're going to implement a strategy for printing a list of items in different formats like Markdown & HTML. And I will show you how you can implement Dynamic & Static Strategy with two separate examples.

### Dynamic Strategy

```cpp
enum class Format { Markdown, Html };

struct ListStrategy {
    virtual ~ListStrategy() = default;
    virtual void add_list_item(ostringstream& oss, string& item) {};
    virtual void start(ostringstream& oss) {};
    virtual void end(ostringstream& oss) {};
};

struct MarkdownListStrategy: ListStrategy {
    void add_list_item(ostringstream& oss, string& item) override { oss << " - " << item << endl; }
};

struct HtmlListStrategy: ListStrategy {
    void start(ostringstream& oss) override { oss << "<ul>" << endl; }
    void end(ostringstream& oss) override { oss << "</ul>" << endl; }
    void add_list_item(ostringstream& oss, string& item) override { oss << "\t<li>" << item << "</li>" << endl; }
};

struct TextProcessor {
    void clear() {
        m_oss.str("");
        m_oss.clear();
    }

    void append_list(vector<string>& items) {
        m_list_strategy->start(m_oss);
        for (auto& item: items)
            m_list_strategy->add_list_item(m_oss, item);
        m_list_strategy->end(m_oss);
    }

    void set_output_format(Format& format) {
        switch (format) {
            case Format::Markdown: m_list_strategy = make_unique<MarkdownListStrategy>(); break;
            case Format::Html: m_list_strategy = make_unique<HtmlListStrategy>(); break;
        }
    }

    string str() { return m_oss.str(); }
private:
    ostringstream               m_oss;
    unique_ptr<ListStrategy>    m_list_strategy;
};

int main() {
    // markdown
    TextProcessor tp;
    tp.set_output_format(Format::Markdown);
    tp.append_list({ "foo", "bar", "baz" });
    cout << tp.str() << endl;

    // html
    tp.clear();
    tp.set_output_format(Format::Html);
    tp.append_list({ "foo", "bar", "baz" });
    cout << tp.str() << endl;

    return EXIT_SUCCESS;
}
/*  
 - foo
 - bar
 - baz

<ul>
	<li>foo</li>
	<li>bar</li>
	<li>baz</li>
</ul>
*/
```

- Above example is self-explainable, but the thing here to take into account is a [smart pointer](/posts/understanding-unique-ptr-with-example-in-cpp11/) to `TextProcessor::m_list_strategy` which we can use to change the strategy on the fly.

### Static Strategy

- I would not consider a static approach to the Strategy Design Pattern as flexible as the dynamic one but it's still there if you need it.

```cpp
template<typename LS>
struct TextProcessor {
    void append_list(const vector<string> &items) {
        m_list_strategy.start(m_oss);
        for (auto & item: items)
            m_list_strategy.add_list_item(m_oss, item);
        m_list_strategy.end(m_oss);
    }

    string str() const { return m_oss.str(); }
private:
    ostringstream       m_oss;
    LS                  m_list_strategy;
};

int main() {
    // markdown
    TextProcessor<MarkdownListStrategy> tp1;
    tp1.append_list({ "foo", "bar", "baz" });
    cout << tp1.str() << endl;

    // html
    TextProcessor<HtmlListStrategy> tp2;
    tp2.append_list({ "foo", "bar", "baz" });
    cout << tp2.str() << endl;

    return EXIT_SUCCESS;
}
```

- When you looked at the [Decorator Design Pattern](/posts/decorator-design-pattern-in-modern-cpp/) we saw that the decorator can be implemented as both dynamic as well as static and it just so happens that the Strategy Design Pattern is exactly like this.
- There is not anything special about static strategy except we are not referring algorithm(i.e. `add_list_item()` through [virtual table](/posts/part-1-all-about-virtual-keyword-in-cpp-how-virtual-function-works-internally/)(rather passing it as a [C++ template](/posts/c-template-a-quick-uptodate-look/) parameter) which means you do not have the ability to change your algorithm/strategy at runtime.

## Benefits of Strategy Design Pattern

1. It's easy to switch between different algorithms(strategies) in runtime as we're using polymorphism in the interfaces.
2. Clean & readable code because we avoid conditional code for algorithms(strategies).
3. More clean code because you separate the concerns into classes (a class to each strategy) so automatically adhering [Single Responsibility Principle](/posts/single-responsibility-principle-in-cpp-solid-as-a-rock/).
4. Preserving [Open-Closed Principle](/posts/open-closed-principle-in-cpp-solid-as-a-rock/) also as I described in the example above, Strategy allows you to extend a logic in some parts of your code ("open for extension") without rewriting those parts ("closed for modification").

## Summary by FAQs

**When should the Strategy Design Pattern be used?**

- When you need to use several algorithms with different variations.  
- While most of your classes have related behaviours.  
- When there are conditional statements around several related algorithms.

**Why do we use the Strategy Design Pattern?**

- For clean & readable code  
- To adhere the [Single Responsibility Principle](/posts/single-responsibility-principle-in-cpp-solid-as-a-rock/) & [Open-Closed Principle](/posts/open-closed-principle-in-cpp-solid-as-a-rock/).

**What is the difference between the Strategy & State Design Pattern?**

- Strategy is only an algorithm that you can change it in different circumstances upon your need.  
- State can change whole [object](/posts/inside-the-cpp-object-model/) behaviour.
