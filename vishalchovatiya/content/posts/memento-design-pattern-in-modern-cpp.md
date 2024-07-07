---
title: "Memento Design Pattern in Modern C++"
date: "2020-04-03"
categories: 
  - "cpp"
  - "design-patterns"
  - "software-engineering"
tags: 
  - "benefits-of-memento-design-pattern"
  - "c-memento"
  - "difference-between-command-memento-design-pattern"
  - "difference-between-state-memento-design-pattern"
  - "memento-design-pattern-c-example"
  - "memento-design-pattern-example-in-c"
  - "memento-design-pattern-in-c"
  - "memento-design-pattern-in-modern-c"
  - "memento-in-c"
  - "memento-pattern-encapsulation"
featuredImage: "/images/Memento-Design-Pattern-in-Modern-C-vishal-chovatiya.png"
---

Memento Design Pattern in Modern C++ is a very straight forward Behavioural Design Pattern. The motivation behind using the Memento Design Pattern is **_to keep some sort of token which then allows you to restore an object to a particular state_**. This is particularly useful if you have a system with medieval components i.e. an object or indeed a set of objects goes through a set of changes.

By the way, If you haven’t check out my other articles on Behavioural Design Patterns, then here is the list:

{{% include "/reusable_block/behavioural-design-patterns.md" %}}
{{% include "/reusable_block/design-pattern-prerequisites.md" %}}

## Intent

> **_To store and restore the state of the component/object._**

- In keep changing & well-designed OOPs software systems, the usual problem you may face while implementing rollback functionality is encapsulation. Because the [object's representation](/posts/memory-layout-of-cpp-object/) (data structure) is hidden. And can't access from outside the object directly without using setter & getter.
- Memento Design Pattern is the right way to address this problem. Memento is a kind of immutable object. It captures & externalizes an object's internal state at given a particular time without violating encapsulation. So that the object can restore to that state on later point of time.

## Memento Design Pattern Example in C++

- With continuing our previous example of the bank account from [Command Design Pattern](/posts/command-design-pattern-in-modern-cpp/) where we were recording every change as a command & made facility to undo that command using member function.
- Here in Memento Design Pattern, we simply save the snapshot of the system/component at a particular point of time. And allow the user to roll back the system to that snapshot.

```cpp
class BankAccount {
    int32_t         m_balance{0};
    uint32_t        m_current{0};

    struct Memento {
        int32_t m_balance;
        Memento(int32_t b): m_balance(b) {}
    };

    vector<shared_ptr<const Memento>>   m_changes;
public:
    BankAccount(const int32_t b): m_balance(b) {
        m_changes.emplace_back(make_shared<const Memento>(m_balance));
    }

    const shared_ptr<const Memento> deposit(int32_t amount) {
        m_balance += amount;
        m_changes.emplace_back(make_shared<const Memento>(m_balance));
        return m_changes[m_current++];
    }

    void restore(const shared_ptr<const Memento>& m) {
        if (m) {
            m_balance = m->m_balance;
            m_changes.push_back(m);
            m_current = m_changes.size() - 1;
        }
    }

    const shared_ptr<const Memento> undo() {
        if (m_current > 0) {
            m_balance = m_changes[--m_current]->m_balance;
            return m_changes[m_current];
        }
        return {};
    }

    const shared_ptr<const Memento> redo() {
        if ((m_current + 1) < m_changes.size()) {
            m_balance = m_changes[++m_current]->m_balance;
            return m_changes[m_current];
        }
        return {};
    }

    friend ostream& operator<<(ostream & os, const BankAccount & ac) {
        return os << "balance: " << ac.m_balance;
    }
};

int main() {
    BankAccount ba{100};
    ba.deposit(50);
    ba.deposit(25);
    cout << ba << "\n"; // 175

    ba.undo();
    cout << "Undo 1: " << ba << "\n";
    ba.undo();
    cout << "Undo 2: " << ba << "\n";
    ba.redo();
    cout << "Redo 2: " << ba << "\n";

    return EXIT_SUCCESS;
}
/*  
balance: 175
Undo 1: balance: 150
Undo 2: balance: 100
Redo 2: balance: 150
*/
```

- So as you can see the state of the system is sufficiently small in terms of the memory footprint to actually record every single change and as a result not only do you get the user to be able to restore the system to any particular state just by using the memento.
- But you also have this ability to walk forwards and backwards in terms of the overall timeline. You let the user kind of undo and redo depending on their needs.
- So this is the proper way by which you can implement memento to jump back from one state to another. Undo mechanism is slightly different from we have seen earlier in the [Command Design Pattern](/posts/command-design-pattern-in-modern-cpp/).

## Benefits of Memento Design Pattern

- Because what we're doing here is Undo-ing at a discrete point of time unlike a line of changes we looked at the [Command Design Pattern](/posts/command-design-pattern-in-modern-cpp/). By using memento, you can go backwards and forwards or you can go to discrete points of time that you've saved by saving a memento of that point in time & restore it.
- A memento is very useful in almost all applications which must restart from their last known working state or draft. An example of this can be an IDE which restarts from changes user-made before closing the IDE.
- Memento Design Pattern maintains high [cohesion](https://www.mysoftkey.com/design-pattern/low-coupling-and-high-cohesion-in-software-design/).

## Summary by FAQs

**Difference between Command & Memento Design Pattern?**

- In [Command Design Pattern](/posts/command-design-pattern-in-modern-cpp/), the token represents a request; in Memento, it represents the internal state of an object at a particular time.  
- Polymorphism is important to [Command Design Pattern](/posts/command-design-pattern-in-modern-cpp/), but not to Memento because its interface is so narrow that a memento can only be passed as a value.

**Difference between State & Memento Design Pattern?**

- State Design Pattern is used to dictates the previous, current or future behaviour of the system.  
- While Memento Design Pattern is typically used to store only the historical state of an object which also does not have any direct relation to behaviour.
