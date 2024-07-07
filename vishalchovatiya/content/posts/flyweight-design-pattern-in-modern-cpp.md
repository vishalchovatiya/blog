---
title: "Flyweight Design Pattern in Modern C++"
date: "2020-04-05"
categories: 
  - "cpp"
  - "design-patterns"
  - "software-engineering"
tags: 
  - "benefits-of-flyweight-design-pattern"
  - "difference-between-singleton-and-flyweight-design-pattern"
  - "drawbacks-of-flyweight-design-pattern"
  - "flyweight-c"
  - "flyweight-design-pattern-advantages-and-disadvantages"
  - "flyweight-design-pattern-c"
  - "flyweight-design-pattern-cpp"
  - "flyweight-design-pattern-creational"
  - "flyweight-design-pattern-example-in-c"
  - "flyweight-design-pattern-in-c-2"
  - "flyweight-design-pattern-in-c"
  - "flyweight-design-pattern-in-modern-c"
  - "implementing-flyweight-design-pattern-using-boost"
  - "when-to-use-a-flyweight-design-pattern"
cover:
    image: /images/Flyweight-Design-Pattern-in-Modern-C-vishal-chovatiya.png
---

Flyweight Design Pattern is a Structural Design Pattern that **_concerned with space optimization_**. It is a technique to minimizes memory footprint by sharing or avoiding redundancy as much as possible with other similar objects. Flyweight Design Pattern in Modern C++ is often used in a situation where object count is higher which uses an unacceptable amount of memory. Often some parts of these objects can be shared & kept in common data structures that can be used by multiple objects.

If you haven’t check out my other articles on Structural Design Patterns, then here is the list:

{{% include "/reusable_block/structural-design-patterns.md" %}}
{{% include "/reusable_block/design-pattern-prerequisites.md" %}}

## Intent

> **_To avoid redundancy when storing data_**.

- Flyway Design Pattern is quite simply a space optimization technique. That allows you to use less memory by storing some of the common data to several items or several [object](/posts/memory-layout-of-cpp-object/)s.
- We store it externally and simply refer(by reference, pointer or any other mechanism) to it when we actually need it.

## Flyweight Design Pattern Example in C++

- Well, the one thing that we want to do if we're storing lots of data is to avoid any redundancy. It's like compression in images or films if you have the same block repeating over and over again. You probably want to actually avoid having that block take up memory. But instead, you just write it and say how many times it repeats.
- For example, let say you are designing a game. You're going to have lots of users with identical first and/or last names. You are going to have lots of people called \`John Smith\`. But you're also going to have lots of people called \`John\` and lots of people whose last name is \`Smith\`.
- And there are no point in actually storing the same first & last name combinations over & over again. Because you are simply wasting memory. So what you would do instead is you would store a list of names somewhere else. And then you would keep the pointers to those names.

```cpp
// Note: You can try following code at  https://wandbox.org/. 
#include <boost/bimap.hpp>

struct User {
    User(string f, string l) : m_first_name{add(f)}, m_last_name{add(l)} { }

    string get_first_name() {return names.left.find(m_first_name)->second;}
    string get_last_name() {return names.left.find(m_last_name)->second;}

    friend ostream& operator<<(ostream& os, User& obj) {
        return os <<
            obj.get_first_name() << "(id=" << obj.m_first_name << "), " <<
            obj.get_last_name() << "(id=" << obj.m_last_name << ")" ;
    }

protected:
    using key = uint32_t;
	static boost::bimap<key, string>        names;
    static key                              seed;

    static key add(string s) {
        auto it = names.right.find(s);
        if (it == names.right.end()) {
            names.insert({++seed, s});
            return seed;
        }
        return it->second;
    }

    key     m_first_name, m_last_name;
};

User::key                           User::seed = 0;
boost::bimap<User::key, string>     User::names{};

int main() {
    User john_doe {"John","Doe"};
    User jane_doe {"Jane","Doe"};

    cout << "John Details: " << john_doe << endl;
    cout << "Jane Details: " << jane_doe << endl;

    return EXIT_SUCCESS;
}
/*
John Details: John(id=1), Doe(id=2)
Jane Details: Jane(id=3), Doe(id=2)
*/
```

- If you see the essence from above flyweight implementation, it just storing data in the static qualified data structure by taking care of redundancy. So that it can be reusable between multiple objects of the same [type](/posts/cpp-type-casting-with-example-for-c-developers/).

## Implementing Flyweight Design Pattern using Boost

- The Flyweight Design Pattern isn't exactly new. And this approach of caching information is something that people have already packaged into different libraries for you to use.
- So instead of building all these wonderful by maps and whatnot what you can do is just use a library solution.

```cpp
#include <boost/flyweight.hpp>

struct User {
	boost::flyweight<string>   m_first_name, m_last_name;

	User(string f, string l) : m_first_name(f), m_last_name(l) { }
};

int main() {
	User john_doe{ "John", "Doe" };
	User jane_doe{ "Jane", "Doe" };

	cout<<boolalpha ;
	cout<<(&jane_doe.m_first_name.get() == &john_doe.m_first_name.get())<<endl;    // False
	cout<<(&jane_doe.m_last_name.get() == &john_doe.m_last_name.get())<<endl;      // True

	return EXIT_SUCCESS;
}
// Try @ https://wandbox.org/. 
```

- As you can see, we are comparing the address of John's last name & Jane's last name in the `main()`function which prints out to be true if you run the above code suggesting that redundancy is perfectly taken cared by [boost::flyweight<>](https://www.boost.org/doc/libs/1_62_0/libs/flyweight/doc/index.html).

## Benefits of Flyweight Design Pattern

1. Facilitates the reuse of many fine-grained objects, making the utilization of large numbers of objects more efficient. - verbatim GoF.
2. Improves data caching for higher response time.
3. Data caching intern increases performance due to a lesser number of heavy objects
4. Provide a centralized mechanism to control the states/common-attributes objects.

## Summary by FAQs

**When to use a Flyweight Design Pattern?**

- In need of a large number of objects  
- When there is a repetitive creation of heavy objects which can be replaced by a few shared objects

**Difference between Singleton and Flyweight Design Pattern?**

- In Singleton Design Pattern, you cannot create more than one object. You need to reuse the existing object in all parts of the application.  
- While in Flyweight Design Pattern you can have a large number of similar objects which can share a common single resource.

**Drawbacks of Flyweight Design Pattern?**

As similar to Singleton Design Pattern, concurrency is also a headache in the Flyweight Design Pattern. Without appropriate measures, if you create Flyweight objects in a concurrent environment, you may end up having multiple instances of the same object which is not desirable.
