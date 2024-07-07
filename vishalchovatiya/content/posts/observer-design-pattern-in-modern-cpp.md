---
title: "Observer Design Pattern in Modern C++"
date: "2020-04-03"
categories: 
  - "cpp"
  - "design-patterns"
  - "software-engineering"
tags: 
  - "benefits-of-observer-design-pattern"
  - "c-observer-design-pattern-listener"
  - "c-observer-pattern"
  - "c-observer-pattern-template"
  - "difference-between-observer-mediator-design-pattern"
  - "observer-design-pattern-c11"
  - "observer-design-pattern-example-in-c"
  - "observer-design-pattern-implementation-c"
  - "observer-design-pattern-implementation-in-c"
  - "observer-design-pattern-in-c"
  - "observer-design-pattern-in-c-example"
  - "observer-design-pattern-in-c-with-example"
  - "observer-design-pattern-in-modern-c"
  - "observer-design-pattern-real-world-example-c"
  - "observer-design-pattern-with-boost-signals"
  - "observer-pattern-c"
  - "observer-pattern-c-github"
  - "publisher-subscriber-pattern-c"
  - "subject-observer-design-pattern-c"
  - "use-cases-of-observer-design-pattern"
  - "what-is-observer-design-pattern-in-c"
featuredImage: "/images/Observer-Design-Pattern-in-Modern-C-vishal-chovatiya.png"
---

The Observer Design Pattern is a type of Behavioural Design Pattern that use **_to get information when certain events happen_** i.e. basically one component want information about something happening in the other component. And that can a lot of things like a field changes to a particular value or you want to information when the object does a particular thing, etc. Observer Design Pattern in Modern C++ enables you to create subscription mechanism to notify multiple objects about events that happen to the object they're observing.

By the way, If you haven’t check out my other articles on Behavioural Design Patterns, then here is the list:

{{% include "/reusable_block/behavioural-design-patterns.md" %}}
{{% include "/reusable_block/design-pattern-prerequisites.md" %}}

## Intent

> **_To get notifications when events happen._**

- The Observer Design Pattern split into two parts:
    1. **observer** i.e. [object](/posts/memory-layout-of-cpp-object/) which gets a notification about something happening somewhere in the system.
    2. **observable** i.e. entity that's actually generating these notifications or events.
- You see this are the terminology I am using which may vary people-to-people & domain-to-domain, For example:
    1. event & subscriber
    2. signal & slot(Boost, Qt, etc.)
    3. broadcaster & listeners, etc.

## Observer Design Pattern Example in C++

```cpp
template<typename T>
struct Observer {
    virtual void field_changed(T& source, const string& field_name) = 0;
};

template<typename T>
struct Observable {
    void notify(T& source, const string& field_name) {
        for (auto observer: m_observers)
            observer->field_changed(source, field_name);
    }
    void subscribe(Observer<T>& observer) { m_observers.push_back(&observer); }
    void unsubscribe(Observer<T>& observer) {
        m_observers.erase(remove(m_observers.begin(), m_observers.end(), &observer), m_observers.end());
    }

private:
    vector<Observer<T>*>    m_observers;
};

struct Person : Observable<Person>{  // Observable <<<<-------------------------------------
    void set_age(uint8_t age) {
        auto old_can_vote = get_can_vote();
        this->m_age = age;
        notify(*this, "age");

        if (old_can_vote != get_can_vote()) notify(*this, "can_vote");
    }
    uint8_t get_age() const { return m_age; }
    bool get_can_vote() const { return m_age >= 16; }

private:
    uint8_t m_age{0};
};

struct TrafficAdministration : Observer<Person>{     // Observer <<<<-----------------------
    void field_changed(Person &source, const string& field_name) {
        if (field_name == "age") {
            if (source.get_age() < 17)
                cout << "Not old enough to drive!\n";
            else {
                cout << "Mature enough to drive!\n";
                source.unsubscribe(*this);
            }
        }
    }
};

int main() {
    Person p;
    TrafficAdministration ta;
    p.subscribe(ta);
    p.set_age(16);
    p.set_age(17);
    return EXIT_SUCCESS;
}
```

- The observer is that thing which wants to monitor something. And the observable is the component that is to monitored. So, in the above case, our `Person` is observable and the observer is `TrafficAdministration`.
- You can also augment above code for passing [lambda](/posts/learn-lambda-function-in-cpp-with-example/) as a subscriber rather than an object for a more functional approach.

## Observer Design Pattern with Boost Signals

- Now what I'm going to do is I'll make a small digression. Because instead of showing you something that we've built ourselves what I want to show you is the observable implementation that comes with the Boost libraries.

```cpp
#include <iostream>
#include <string>
#include <boost/signals2.hpp>
using namespace std;

template<typename T>
struct Observable {  
    void subscribe(const auto&& observer) { m_field_changed.connect(observer); }
    void unsubscribe(const auto&& observer) { m_field_changed.disconnect(observer); }
protected:
    boost::signals2::signal<void(T&, const string&)>  m_field_changed;
};

struct Person : Observable<Person> {  // Observable <<<<-------------------------------------
    void set_age(uint8_t age) {
        this->m_age = age;
        m_field_changed(*this, "age");
    }
    auto get_age() const { return m_age; }

private:
    uint32_t    m_age {0};
};

struct TrafficAdministration {                    // Observer <<<<-----------------------
    static void field_changed(Person &source, const string& field_name) {
        if (field_name == "age") {
            if (source.get_age() < 17)
                cout << "Not old enough to drive!\n";
            else {
                cout << "Mature enough to drive!\n";
                source.unsubscribe(TrafficAdministration::field_changed);
            }
        }
    }
};

int main() {
    Person p;
    p.subscribe(TrafficAdministration::field_changed);
    p.set_age(16);
    p.set_age(20);
    return EXIT_SUCCESS;
}
```

- Mind it, I have used `boost::signals2` as `boost::signals` are no longer being actively maintained. Due to `boost::signals2`, we can get rid of `std/boost::bind`, and can directly use [lambda](/posts/learn-lambda-function-in-cpp-with-example/). You can check out [a quick example of `boost::signals2`](https://theboostcpplibraries.com/boost.signals2-signals) if you want.

## Benefits of Observer Design Pattern

1. It supports the loose coupling between [object](/posts/memory-layout-of-cpp-object/)s that interact with each other hence [Open-Closed Principle](/posts/open-closed-principle-in-cpp-solid-as-a-rock/) will be intact. Above examples also satisfy the [Single Responsibility Principle](/posts/single-responsibility-principle-in-cpp-solid-as-a-rock/) as Observer & Observable are two different templatized classes which can easily be reusable.
2. It provides the flexibility of adding or removing observers at any time which is heavily use in event-driven programming.

## Summary by FAQs

**Use cases of Observer Design Pattern.**

Usually, Observer Design Pattern employs when there is a one-to-many relationship between objects so that when one object changes state, all its dependents are notified and updated automatically. Typical use case area involves GUI libraries, Social media, RSS feeds, Email subscription, etc.

**Difference between Observer & Mediator Design Pattern.**

Observer Design Pattern works on the one-to-many relationship.  
Mediator Design Pattern works on the many-to-many relationship.
