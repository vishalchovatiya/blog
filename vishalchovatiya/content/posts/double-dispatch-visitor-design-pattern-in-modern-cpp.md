---
title: "Double Dispatch : Visitor Design Pattern in Modern C++"
date: "2020-04-02"
categories: 
  - "cpp"
  - "design-patterns"
  - "software-engineering"
tags: 
  - "classic-visitor"
  - "difference-between-visitor-vs-decorator-design-pattern"
  - "double-dispatch-visitor-pattern-visitor-design-pattern-in-modern-c"
  - "intrusive-visitor"
  - "reflective-visitor"
  - "use-case-of-the-visitor-design-pattern"
  - "visitor-design-pattern-c-example"
  - "visitor-design-pattern-c-stack-overflow"
  - "visitor-design-pattern-cpp"
  - "visitor-design-pattern-example"
  - "visitor-design-pattern-implementation-in-c"
  - "visitor-design-pattern-in-c"
  - "visitor-design-pattern-pros-and-cons"
  - "visitor-design-pattern-using-stdvisit-stdvariant"
  - "visitor-pattern-c"
  - "visitor-pattern-double-dispatch"
  - "when-should-i-use-the-visitor-design-pattern"
cover:
    image: /images/Visitor-Design-Pattern-in-Modern-C-vishal-chovatiya.png
---

In software engineering, Behavioural Design Patterns deal with the assignment of responsibilities between objects. That in turn, make the interaction between the objects easy & loosely coupled. In this article of the design pattern series, we're going to take a look at Visitor Design Pattern in Modern C++ which is also known as a classic technique for recovering lost type information(using Double Dispatch\[TODO\]). Visitor Design Pattern is **_used to perform an operation on a group of similar kind of objects or hierarchy_**. In this article, we will not only see the classical example but also leverage the [std::visit](https://en.cppreference.com/w/cpp/utility/variant/visit) from the standard library to cut-short the implementation time of the Visitor Design Pattern.

By the way, If you haven’t check out my other articles on Behavioural Design Patterns, then here is the list:

{{% include "/reusable_block/behavioural-design-patterns.md" %}}
{{% include "/reusable_block/design-pattern-prerequisites.md" %}}

## Intent

> **_To define a new operation on a group of similar kind of objects or hierarchy._**

- The classical Visitor Design Pattern has some component which we call a visitor. That is allowed to traverse the entire inheritance hierarchy. But before that what you have to do is you have to implement a single method called `visit()`in the entire hierarchy once.
- And from then on you don't have to touch the hierarchy anymore. So the hierarchy can exist on its own and you can create extra visitors sort of thing on the side which is perfectly consistent with both the [Open-Closed Principle](/posts/open-closed-principle-in-cpp-solid-as-a-rock/) as well as the [Single Responsibility Principle](/posts/single-responsibility-principle-in-cpp-solid-as-a-rock/).

## Visitor Design Pattern Examples in C++

- This is a reasonably complex design pattern & I do not want to confuse you by directly jumping on example. So we will come to the Visitor Design Pattern by exploring other available option. And then you will understand the importance of visitor despite the complexity.

### Intrusive Visitor

- Let's suppose that you have a hierarchy of documents as follows:

```cpp
struct Document {
    virtual void add_to_list(const string &line) = 0;
};

struct Markdown : Document {
    void add_to_list(const string &line) { m_content.push_back(line); }

    string          m_start = "* ";
    list<string>    m_content;
};

struct HTML : Document {
    void add_to_list(const string &line) { m_content.push_back(line); }

    string          m_start = "<li>";
    string          m_end = "</li>";
    list<string>    m_content;
};
```

- And you need to define some new operation on existing infrastructure. For example, we have a `Document` class as above and now you want that different documents(i.e. `HTML` & `Markdown`) to be printable.
- So you have this brand new concern of printing and you want to somehow propagate this through the entire hierarchy by making essentially every single class of your document to be independently printable somehow.
- Now what you don't want to do is you don't want to go back into the existing code and modify each class(with new [virtual function](/posts/part-1-all-about-virtual-keyword-in-cpp-how-virtual-function-works-internally/)) in the hierarchy every time you have a new concern, because, unfortunately, this breaks an [Open-Closed Principle](/posts/open-closed-principle-in-cpp-solid-as-a-rock/), rather we should use inheritance.
- There's also the [Single Responsibility Principle](/posts/single-responsibility-principle-in-cpp-solid-as-a-rock/) that you have to adhere to because if you are introducing a brand new concern such as printing then that should be a separate class. But still, let say we will do it:

```cpp
struct Document {
    virtual void add_to_list(const string &line) = 0;
    virtual void print() = 0;
};

struct Markdown : Document {
    void add_to_list(const string &line) { m_content.push_back(line); }
    void print() {
        for (auto &&item : m_content) 
            cout << m_start << item << endl;
    }

    string          m_start = "* ";
    list<string>    m_content;
};

struct HTML : Document {
    void add_to_list(const string &line) { m_content.push_back(line); }
    void print() {
        cout << "<ul>" << endl;
        for (auto &&item : m_content) {
            cout << "\t" << m_start << item << m_end << endl;
        }
        cout << "</ul>" << endl;
    }

    string          m_start = "<li>";
    string          m_end = "</li>";
    list<string>    m_content;
};

int main() {
    Document *d = new HTML;
    d->add_to_list("This is line");
    d->print();
    return EXIT_SUCCESS;
}
```

- As you can see for only 2-3 class it's good even if it is violating some SOLID principles. But imagine if you have 20 classes as part of this hierarchy. It would be really difficult to go into 20 different files & add a print method for every one of them.
- Moreover, if there is more than one concern like save, process, etc., this approach becomes cumbersome. It would be much nicer to have each concern in a separate class that also goes towards the [Single Responsibility Principle](/posts/single-responsibility-principle-in-cpp-solid-as-a-rock/).

### Reflective Visitor

```cpp
struct Document {
    virtual void add_to_list(const string &line) = 0;
};

struct Markdown : Document {
    void add_to_list(const string &line) { m_content.push_back(line); }

    string          m_start = "* ";
    list<string>    m_content;
};

struct HTML : Document {
    void add_to_list(const string &line) { m_content.push_back(line); }

    string          m_start = "<li>";
    string          m_end = "</li>";
    list<string>    m_content;
};

struct DocumentPrinter {
    static void print(Document *e) {        
        if (auto md = dynamic_cast<Markdown *>(e)) {
            for (auto &&item : md->m_content)
                cout << md->m_start << item << endl;
        }
        else if (auto hd = dynamic_cast<HTML *>(e)) {
            cout << "<ul>" << endl;
            for (auto &&item : hd->m_content) {
                cout << "\t" << hd->m_start << item << hd->m_end << endl;
            }
            cout << "</ul>" << endl;
        }
    }
};

int main() {
    Document *d = new HTML;
    d->add_to_list("This is line");
    DocumentPrinter::print(d);
    return EXIT_SUCCESS;
}
```

- As mentioned above, we created a separate class having printing functionality for the entire hierarchy just to adhere [Single Responsibility Principle](/posts/single-responsibility-principle-in-cpp-solid-as-a-rock/). But in this approach, we have to identify types for a particular class(using [`dynamic_cast<>()`](/posts/cpp-type-casting-with-example-for-c-developers/)) as we have to work on individual [object](/posts/memory-layout-of-cpp-object/) of hierarchy independently.
- This is not an approach which scales efficiently, especially as you expand the set of classes that you're processing, you will end up having a long list of `if/else-if` along with paying performance cost on [RTTI](https://en.wikipedia.org/wiki/Run-time_type_information).

### Classic Visitor

- So far the approaches that have been sort of half measures what we really want is we really want a mechanism that will allow us to extend the entire hierarchies functionality in various different ways without being intrusive and certainly without having massive `if/else-if` statements full of [`dynamic_cast<>()`](/posts/cpp-type-casting-with-example-for-c-developers/) in them.

```cpp
/* --------------------------- Added Visitor Classes ----------------------------- */
struct DocumentVisitor {
    virtual void visit(class Markdown*) = 0;
    virtual void visit(class HTML*) = 0;
};

struct DocumentPrinter : DocumentVisitor {
    void visit(class Markdown* md);
    void visit(class HTML* hd);
};
/* -------------------------------------------------------------------------------- */

struct Document {
    virtual void add_to_list(const string &line) = 0;
    virtual void visit(DocumentVisitor*) = 0; // <<<<<<<<<<--------------------------
};

struct Markdown : Document {
    void add_to_list(const string &line) { m_content.push_back(line); }
    void visit(DocumentVisitor* dv) { dv->visit(this); } // <<<<<<<<<<---------------

    string          m_start = "* ";
    list<string>    m_content;
};

struct HTML : Document {
    void add_to_list(const string &line) { m_content.push_back(line); }
    void visit(DocumentVisitor* dv) { dv->visit(this); } // <<<<<<<<<<---------------

    string          m_start = "<li>";
    string          m_end = "</li>";
    list<string>    m_content;
};


/* -------------------------- Added Visitor Methods ------------------------------- */
void DocumentPrinter::visit(Markdown* md) {
    for (auto &&item : md->m_content)
        cout << md->m_start << item << endl;
}
void DocumentPrinter::visit(HTML* hd) {
    cout << "<ul>" << endl;
    for (auto &&item : hd->m_content) 
        cout << "\t" << hd->m_start << item << hd->m_end << endl;
    cout << "</ul>" << endl;
}
/* -------------------------------------------------------------------------------- */

int main() {
    Document *d = new HTML;
    d->add_to_list("This is line");
    d->visit(new DocumentPrinter);
    return EXIT_SUCCESS;
}
```

- So as you can see we have added two-layer of indirection to achieve what we wanted without violating the [Single Responsibility Principle](/posts/single-responsibility-principle-in-cpp-solid-as-a-rock/) & [Open-Closed Principle](/posts/open-closed-principle-in-cpp-solid-as-a-rock/). Thanks to Double Dispatch in C++\[TODO\].
- If you see all the classes involved in the process, it may seem a bit complicated. But call stack may help you to understand it easily.

![](/images/Double-Dispatch-in-C-Visitor-Design-Pattern-www_vishalhovatiy_com-1024x659.png#center)

- From `d->visit(new DocumentPrinter)`, we call `visit()`method, which will dispatch to the appropriate overridden visit i.e. `HTML::visit(DocumentVisitor* dv).
- From the overridden `HTML::visit(DocumentVisitor*)`, we call `dv->visit(this)`, which will again dispatch to the appropriate overridden method(considering the type of `this` pointer) i.e. `DocumentPrinter::visit(HTML*)`.

## Visitor Design Pattern in Modern C++

```cpp
struct Document {
    virtual void add_to_list(const string &line) = 0;
};

struct Markdown : Document {
    void add_to_list(const string &line) { m_content.push_back(line); }

    string          m_start = "* ";
    list<string>    m_content;
};

struct HTML : Document {
    void add_to_list(const string &line) { m_content.push_back(line); }

    string          m_start = "<li>";
    string          m_end = "</li>";
    list<string>    m_content;
};

/* ------------------------------------ Visitor ------------------------------------- */
struct DocumentPrinter {
    void operator()(Markdown &md) {
        for (auto &&item : md.m_content)
            cout << md.m_start << item << endl;
    }
    void operator()(HTML &hd){
        cout << "<ul>" << endl;
        for (auto &&item : hd.m_content)
            cout << "\t" << hd.m_start << item << hd.m_end << endl;
        cout << "</ul>" << endl;
    }
};
/* ---------------------------------------------------------------------------------- */
using document = std::variant<Markdown, HTML>;

int main() {
    HTML hd;
    hd.add_to_list("This is line");
    document d = hd;
    DocumentPrinter dp;
    std::visit(dp, d);
    return EXIT_SUCCESS;
}
```

- So for those of you who are not familiar with the `std::variant`, you can consider it as a union(a type-safe union). And line `std::variant<Markdown, HTML>`, suggest that you can use/assign/access either `Markdown` or `HTML` at a time.
- And [Modern C++](/posts/21-new-features-of-modern-cpp-to-use-in-your-project/) provides us `std::visit` which accept callable i.e. `DocumentPrinter` in our case having overloaded function operator and `std::variant` as the second argument. You also make use of [lambda functions](/posts/learn-lambda-function-in-cpp-with-example/) rather using functor i.e. `DocumentPrinter`.

## Benefits of Visitor Design Pattern

1. Adhering [Single Responsibility Principle](/posts/single-responsibility-principle-in-cpp-solid-as-a-rock/) meaning separating type-specific logic in the separate entity/class. In our case, `DocumentPrinter` only handles the printing for different document types.
2. Adhering [Open-Closed Principle](/posts/open-closed-principle-in-cpp-solid-as-a-rock/) meaning new functionality can be added without touching any class headers once we inserted `visit()` method for hierarchy, For example, if you want to add `scan()`method for each different Document, you can create `DocumentScanner` & rest of the edit goes as same `DocumentPrinter`.
3. This will be much useful when you already have done the unit-testing for your entire hierarchy. Now you do not want to touch that & wants to add new functionality.
4. Performance over `dynamic_cast`, `typeid()`and check for `enum`/`string` comparison.

## Summary by FAQs

**When should I use the Visitor Design Pattern?**

Visitor Design Pattern is quite useful when your requirement keeps changing which also affects multiple classes in the inheritance hierarchy.

**What is the typical use case of the Visitor Design Pattern?**

- In replacement of `dynamic_cast<>`, `typeid(), etc.  
- To process the collection of different types of objects.  
- Filtering different type of objects from collections.

**Difference between Visitor vs Decorator Design Pattern?**

[Decorator](/posts/decorator-design-pattern-in-modern-cpp/)(Structural Design Pattern) works on an object by enhances existing functionality. While  
Visitor([Behavioral Design Pattern](/posts/chain-of-responsibility-design-pattern-in-modern-cpp/)) works on a hierarchy of classes where you want to run different method based on concrete type but avoiding [dynamic_cast<>()](/posts/cpp-type-casting-with-example-for-c-developers/) or [typeof()](https://blog.toonormal.com/2014/01/25/c-typeof-vs-decltype/) operators.
