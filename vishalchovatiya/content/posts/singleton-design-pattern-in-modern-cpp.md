---
title: "Singleton Design Pattern in Modern C++"
date: "2020-04-06"
categories: 
  - "cpp"
  - "design-patterns"
  - "software-engineering"
tags: 
  - "benefits-of-singleton-design-pattern"
  - "c-class-singleton"
  - "c-singleton"
  - "c-singleton-class-example"
  - "c-singleton-design-pattern"
  - "c-singleton-example"
  - "c-singleton-implementation"
  - "c-singleton-pattern-example"
  - "c-singleton-template"
  - "cpp-singleton"
  - "design-patterns-singleton-c-destructor"
  - "example-of-singleton-design-pattern-in-c"
  - "how-to-implement-singleton-design-pattern-in-c"
  - "multiton-design-pattern"
  - "real-time-example-of-singleton-class-in-c"
  - "real-time-example-of-singleton-design-pattern-in-c"
  - "singleton-c-class"
  - "singleton-c-example"
  - "singleton-class-c"
  - "singleton-class-c-example"
  - "singleton-class-design-pattern-in-c"
  - "singleton-class-example-in-c"
  - "singleton-class-in-cpp"
  - "singleton-constructor-c"
  - "singleton-design-pattern-c-11"
  - "singleton-design-pattern-c-copy-constructor"
  - "singleton-design-pattern-c-implementation"
  - "singleton-design-pattern-c-inheritance"
  - "singleton-design-pattern-c-tutorial"
  - "singleton-design-pattern-examples-in-c"
  - "singleton-design-pattern-in-c"
  - "singleton-design-pattern-in-c-code"
  - "singleton-design-pattern-in-c-example"
  - "singleton-design-pattern-in-c-reference"
  - "singleton-design-pattern-in-c-simple-example"
  - "singleton-design-pattern-in-c-with-example"
  - "singleton-design-pattern-in-cpp"
  - "singleton-design-pattern-in-modern-c"
  - "singleton-design-pattern-program-c"
  - "singleton-design-pattern-with-dependency-injection"
  - "singleton-object-c"
  - "singleton-pattern-c-2"
  - "singleton-pattern-c"
  - "the-problem-of-testability-with-singleton"
  - "use-of-singleton-class-in-c"
  - "use-of-singleton-design-pattern-in-c"
  - "what-are-the-limitations-of-singleton-design-pattern-in-c"
  - "what-is-singleton-design-pattern-in-c"
  - "what-is-so-bad-about-the-singleton-design-pattern"
  - "what-is-the-correct-way-to-implement-singleton-design-pattern"
  - "what-is-the-use-of-singleton-design-pattern-in-c"
  - "when-should-you-use-the-singleton-design-pattern"
  - "why-singleton-design-pattern-in-c"
  - "why-we-use-singleton-design-pattern-in-c"
featuredImage: "/images/Singleton-Design-Pattern-in-Modern-C-vishal-chovatiya.png"
---

In software engineering, Creational Design Patterns deal with object creation mechanisms, i.e. try to create objects in a manner suitable to the situation. The basic or ordinary form of object creation could result in design problems or added complexity to the design. In this article of the Creational Design Patterns, we're going to take a look at the much-hated & commonly asked design pattern in a programming interview. That is Singleton Design Pattern in Modern C++ which criticizes for its extensibility & testability. I will also cover the Multiton Design Pattern which quite contrary to Singleton.

By the way, If you haven’t check out my other articles on Creational Design Patterns, then here is the list:

{{% include "/reusable_block/creational-design-patterns.md" %}}
{{% include "/reusable_block/design-pattern-prerequisites.md" %}}

## Intent

> **_To ensure one & only one instance of a class exist at any point in time._**

- The Singleton Design Pattern ensures that a class has only one instance and provides a global point of access to that instance. This is useful when exactly one object need to coordinate actions across the system.
- So, essentially, the Singleton Design Pattern is nothing more than specifying a lifetime.

## Singleton Design Pattern C++ Example

- The motivation for using a Singleton Design Pattern is fairly obvious. Some components in our system only need to have a single instance. For example, a database that loads up from its constructor into memory & then gives out information about its contents. Once it's loaded up you don't really want more than one instance of it because there is no point.
- And you also want to prevent your clients/API-users from making any additional copies of that [object](/posts/inside-the-cpp-object-model/). Following is a trivial example of the Singleton Design Pattern in C++.

```cpp
/* country.txt 
Japan
1000000
India
2000000
America
123500
*/
class SingletonDatabase {
    std::map<std::string, int32_t>  m_country;

    SingletonDatabase() {
        std::ifstream ifs("country.txt");

        std::string city, population;
        while (getline(ifs, city)) {
            getline(ifs, population);
            m_country[city] = stoi(population);
        }
    }

public:
    SingletonDatabase(SingletonDatabase const &) = delete;
    SingletonDatabase &operator=(SingletonDatabase const &) = delete;

    static SingletonDatabase &get() {
        static SingletonDatabase db;
        return db;
    }

    int32_t get_population(const std::string &name) { return m_country[name]; }
};

int main() {
    SingletonDatabase::get().get_population("Japan");
    return EXIT_SUCCESS;
}
```

- Some of the things to note here from the design perspective are:
    
    - Private constructor
    - Deleted [copy constructor](/posts/all-about-copy-constructor-in-cpp-with-example/) & [copy assignment operator](/posts/2-wrong-way-to-learn-copy-assignment-operator-in-cpp-with-example/)
    
    - Static object creation & static method to access

## The Problem of Testability With Singleton

- So we have our Singleton database and let's suppose that we decide to use this database to do some research and we actually made a new class called a `SingletonRecordFinder` which is going to find the total population from the collection of city names provided in the argument as follow.

```cpp
struct SingletonRecordFinder {
    static int32_t total_population(const vector<string>&   countries) {
        int32_t result = 0;
        for (auto &country : countries)
            result += SingletonDatabase::get().get_population(country);
        return result;
    }
};
```

- But let's suppose that we decide that we want to test the `SingletonRecordFinder` and this is where all the problems show up.

```cpp
vector<string> countries= {"Japan", "India"}; // Strongly tied to data base entries
TEST(1000000 + 2000000, SingletonRecordFinder::total_population(countries));
```

- Unfortunately, because we are strongly tied to the real database and there is no way to substitute this database. I have to use the values taken from the actual file. And when later on these entries change, your test will start failing as you may have not updated the code. And this going to be a continuous problem.
- Moreover, this is not going to be a unit-test rather it is integration test as we are not only testing our code but also a production database which is not good design.
- Surely there is a better way of actually implementing this particular construct so that we can still use the singleton but if need we can supply an alternative to the singleton implementation with some dummy data of our own.

## Singleton Design Pattern With Dependency Injection

- The problem that we're encountering in the testing of the `SingletonRecordFinder` is to do with the fact that we have a dependency upon essentially the details of how a database provides its data because we're depending directly on the singleton database and the fact that it's a singleton.
- So why don't we use a little bit of [dependency injection](https://en.wikipedia.org/wiki/Dependency_injection) on an interface or abstract class!

```cpp
struct Database { // Dependency 
    virtual int32_t get_population(const string& country) = 0;
};

class SingletonDatabase : Database {
    map<string, int32_t>    m_countries;

    SingletonDatabase() {
        ifstream ifs("countries.txt");

        string city, population;
        while (getline(ifs, city)) {
            getline(ifs, population);
            m_countries[city] = stoi(population);
        }
    }

public:
    SingletonDatabase(SingletonDatabase const &) = delete;
    SingletonDatabase &operator=(SingletonDatabase const &) = delete;

    static SingletonDatabase &get() {
        static SingletonDatabase db;
        return db;
    }

    int32_t get_population(const string &country) { return m_countries[country]; }
};

class DummyDatabase : public Database {
    map<string, int32_t>    m_countries;
public:
    DummyDatabase() : m_countries{{"alpha", 1}, {"beta", 2}, {"gamma", 3}} {}
    int32_t get_population(const string &country) { return m_countries[country]; }
};

/* Testing class ------------------------------------------------------------ */
class ConfigurableRecordFinder {
    Database&       m_db;  // Dependency Injection
public:
    ConfigurableRecordFinder(Database &db) : m_db{db} {}
    int32_t total_population(const vector<string> &countries) {
        int32_t result = 0;
        for (auto &country : countries)
            result += m_db.get_population(country);
        return result;
    }
};
/* ------------------------------------------------------------------------- */

int main() {
    DummyDatabase db;
    ConfigurableRecordFinder rf(db);
    rf.total_population({"Japan", "India", "America"});
    return EXIT_SUCCESS;
}
```

- Due to Dependency Injection i.e. `Database` interface, our both following issues are resolved:
    1. We have done a proper unit test rather an integration test,
    2. Now our testing class is not directly tie-up to Singleton. So no need to change our unit-test over & over in accordance with a database change.

## Multiton Design Pattern

- Multiton is a variation to singleton but not directly linked to it. Remember that singleton prevents you to have additional instances while Multiton Design Pattern sets up kind of key-value pair along with the limitation for the number of instance creation.

```cpp
enum class Importance { PRIMARY, SECONDARY, TERTIARY };

template <typename T, typename Key = std::string>
struct Multiton {
    static shared_ptr<T> get(const Key &key) {
        if (const auto it = m_instances.find(key); it != m_instances.end()) { // C++17
            return it->second; 
        }
        return m_instances[key] = make_shared<T>();
    }

private:
    static map<Key, shared_ptr<T>>  m_instances;
};

template <typename T, typename Key>
map<Key, shared_ptr<T>>     Multiton<T, Key>::m_instances; // Just initialization of static data member


struct Printer {
    Printer() { cout << "Total instances so far = " << ++InstCnt << endl; }

private:
    static int InstCnt;
};
int Printer::InstCnt = 0;


int main() {
    using mt = Multiton<Printer, Importance>;

    auto main = mt::get(Importance::PRIMARY);
    auto aux = mt::get(Importance::SECONDARY);
    auto aux2 = mt::get(Importance::SECONDARY); // Will not create additional instances
    return EXIT_SUCCESS;
}
```

- So as you can see we have three printers i.e. primary, secondary & tertiary whose access & instantiation is controlled by `Multiton`. Rest of the code is self-explanatory I hope.

## Benefits of Singleton Design Pattern

1. The Singleton Design Pattern is quite helpful for application configurations as configurations may need to be accessible globally, and future expansions to the application configurations can be consolidated at single place.
2. A second common use of this class is in updating old code to work in a new architecture. Since developers may have used globals liberally, moving them into a single class and making it a singleton, can be an intermediary step to bring the program inline to the stronger object-oriented structure.
3. Singleton Design Pattern also enhance the maintainability as it provides a single point of access to a particular instance.

## Summary by FAQs

**What is so bad about the Singleton Design Pattern?**

- Singleton object holds the state for the lifetime of the application. Which is bad for testing since you can end up with a situation where tests need to be ordered which is a big no-no for unit tests. Why? Because each unit test should be independent of the other.  
- Singleton object causes code to be tightly coupled. This makes guessing the expected result under test scenarios rather difficult as we have seen above in database example. But you can overcome it by using Dependency Injection along with Singleton Design Pattern.  
- Imagine the situation where you have a concurrent application accessing Singleton object from every part of your application, It just mashes up things or slows it down if you use a mutex or any other synchronization primitives.

**What is the correct way to implement Singleton Design Pattern?**

The right way to implement Singleton is by dependency injection, So instead of directly depending on a singleton, you might want to consider it depending on an abstraction(e.g. an interface). I would also encourage you to use synchronization primitives(like a mutex, semaphores, etc) to control access.

**When should you use the Singleton Design Pattern?**

- Usually, Singleton is used in hardware interface usage limitation. For example, Printers are limited in numbers, so in such case, a singleton or multiton design pattern is used to manage access.  
- Singleton Design Pattern is also widely employed in managing configuration or properties file to manage access.  
- We can use the cache as a singleton object as it can have a global point of reference and for all future calls to the cache object, the client application will use the in-memory [object](/posts/memory-layout-of-cpp-object/).
