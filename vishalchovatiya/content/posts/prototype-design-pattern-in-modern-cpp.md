---
title: "Prototype Design Pattern in Modern C++"
date: "2020-04-06"
categories: 
  - "cpp"
  - "design-patterns"
  - "software-engineering"
tags: 
  - "applicability-of-prototype-design-pattern"
  - "benefits-of-prototype-design-pattern"
  - "but-we-do-create-in-the-clone"
  - "c-prototype-design-pattern"
  - "c-prototype-pattern"
  - "is-the-prototype-design-pattern-really-just-clone"
  - "leveraging-prototype-design-pattern-to-implement-virtual-copy-constructor"
  - "motivation-for-prototype-design-pattern"
  - "prototype-design-pattern-c"
  - "prototype-design-pattern-c-example"
  - "prototype-design-pattern-code"
  - "prototype-design-pattern-examples-in-c"
  - "prototype-design-pattern-in-c-2"
  - "prototype-design-pattern-in-c"
  - "prototype-design-pattern-in-c-example"
  - "prototype-design-pattern-in-modern-c"
  - "prototype-design-pattern-intent"
  - "prototype-design-pattern-pros-and-cons"
  - "prototype-design-pattern-to-be-used-when-creation-is-costly"
  - "prototype-design-pattern-vs-copy-constructor"
  - "prototype-factory"
  - "prototype-pattern-c"
  - "what-is-the-point-of-using-the-prototype-design-pattern"
featuredImage: "/images/Prototype-Design-Pattern-in-Modern-C-vishal-chovatiya.webp"
---

Prototype Design Pattern is a Creational Design Pattern that **_helps in the prototyping(creating/copying cheaply) of an object using separate methods or polymorphic classes_**. You can consider the prototype as a [template](/posts/c-template-a-quick-uptodate-look/) of an object before the actual object is constructed. In this article of the Creational Design Patterns, we're going to take a look at why we need a Prototype Design Pattern in C++ i.e. motivation, prototype factory & leveraging prototype design pattern to implement [virtual copy constructor](/posts/7-advanced-cpp-concepts-idiom-examples-you-should-know/#Virtual-Constructor).

By the way, If you haven’t check out my other articles on Creational Design Patterns, then here is the list:

{{% include "/reusable_block/creational-design-patterns.md" %}}
{{% include "/reusable_block/design-pattern-prerequisites.md" %}}

## Intent

> **_To create a new object cheaply with the help of an already constructed or pre-initialized stored object._**

![](/images/Prototype-Design-Pattern-Cell-Division-Vishal-Chovatiya.png)

- The prototype provides flexibility to create complex object cheaply. The concept is to copy an existing object rather than creating a new instance from scratch, something that may include costly operations.
- The existing object then acts as a prototype & newly copied object may change the same properties only if required. This approach saves costly resources and time, especially when the object creation is a heavy process.
- So essentially the prototype is quite simply a partially or fully initialized object that you make a copy of. And then you subsequently use for your own benefit with variations.

## Motivation

```cpp
struct Office {
	string 	    m_street;
	string 	    m_city;
	int32_t 	    m_cubical;

    Office(string s, string c, int32_t n):m_street(s), m_city(c), m_cubical(n){}
};

struct Employee {
    string      m_name;
    Office		m_office;

    Employee(string n,  Office o):m_name(n), m_office(o){}
};

int main() {
	Employee john{ "John Doe", Office{"123 East Dr", "London", 123} };
    Employee jane{ "Jane Doe", Office{"123 East Dr", "London", 124} };
	Employee jack{ "jack Doe", Office{"123 ORR", "Bangaluru", 300} };
	return EXIT_SUCCESS;
}
```

- This is not the right approach as you have to write the main office address again & again for each employee detail. This is cumbersome & become more when you want to create an employee list. Moreover, consider the situation when your main office moved to another address.

## Prototype Design Pattern Examples in C++

- A more pragmatic approach would be like this :

```cpp
struct Employee {
    string          m_name;
    const Office*   m_office;    
    
    Employee(string n,  Office *o):m_name(n), m_office(o){}
};

static Office   LondonOffice{"123 East Dr", "London", 123};
static Office   BangaluruOffice{"RMZ Ecoworld ORR", "London", 123};

int main() {
	Employee john{ "John Doe", &LondonOffice };
    Employee jane{ "Jane Doe", &LondonOffice };
	Employee jack{ "jack Doe", &BangaluruOffice };
	return EXIT_SUCCESS;
}
```

- Above solution is suitable for our use case but sometimes we want to customize that office address. And when it comes to pointers & references and any sort of indirection, ordinary copying using operator equals quite simply does not work.
- A standard way to implement this is by implementing the [copy constructor](/posts/all-about-copy-constructor-in-cpp-with-example/)

### Prototype Factory

- So in the previous example of the Prototype Design Pattern, we basically had a global [object](/posts/memory-layout-of-cpp-object/) for office addresses and used their address for creating prototypes.
- Now, this isn't particularly convenient to the consumers of your API because you might want to give them a prototype to work with. And you should explicit enough in terms of letting people know there is the only a unified way by which they create instances from a prototype and so that they cannot make individual instances by themselves.
- And in this case, what you would build is off-course is a Prototype Factory:

```cpp
struct Office {
    string      m_street;
    string      m_city;
    int32_t     m_cubical;
};

class Employee {
    string      m_name;
    Office*     m_office;

    // Private constructor, so direct instance can not be created except for `class EmployeeFactory`
    Employee(string n, Office *o) : m_name(n), m_office(o) {}
    friend class EmployeeFactory;

public:
    Employee(const Employee &rhs) : m_name{rhs.m_name}, m_office{new Office{*rhs.m_office}} 
    { }

    Employee& operator=(const Employee &rhs) {
        if (this == &rhs) return *this;
        m_name = rhs.m_name;
        m_office = new Office{*rhs.m_office};
        return *this;
    }

    friend ostream &operator<<(ostream &os, const Employee &o) {
        return os << o.m_name << " works at " 
        << o.m_office->m_street << " " << o.m_office->m_city << " seats @" << o.m_office->m_cubical;
    }
};

class EmployeeFactory {
    static Employee     main;
    static Employee     aux;
    static unique_ptr<Employee> NewEmployee(string n, int32_t c, Employee &proto) {
        auto e = make_unique<Employee>(proto);
        e->m_name = n;
        e->m_office->m_cubical = c;
        return e;
    }

public:
    static unique_ptr<Employee> NewMainOfficeEmployee(string name, int32_t cubical) {
        return NewEmployee(name, cubical, main);
    }
    static unique_ptr<Employee> NewAuxOfficeEmployee(string name, int32_t cubical) {
        return NewEmployee(name, cubical, aux);
    }
};

// Static Member Initialization 
Employee EmployeeFactory::main{"", new Office{"123 East Dr", "London", 123}};
Employee EmployeeFactory::aux{"", new Office{"RMZ Ecoworld ORR", "London", 123}};

int main() {
    auto jane = EmployeeFactory::NewMainOfficeEmployee("Jane Doe", 125);
    auto jack = EmployeeFactory::NewAuxOfficeEmployee("jack Doe", 123);
    cout << *jane << endl << *jack << endl;
    return EXIT_SUCCESS;
}
/*
Jane Doe works at 123 East Dr London seats @125
jack Doe works at RMZ Ecoworld ORR London seats @123
*/
```

- The subtle thing to note here is the private constructor of `Employee` & `friend EmployeeFactory`. This is how we enforce the client/API-user to create an instance of `Employee` only through `EmployeeFactory` .

### Leveraging Prototype Design Pattern to Implement Virtual Copy Constructor

- In C++, Prototype is also useful to create a copy of an object without knowing its concrete type. Hence, it is also known as Virtual Copy Constructor.

#### Problem

- C++ has the support of polymorphic object destruction using it's base class's [virtual destructor](/posts/part-3-all-about-virtual-keyword-in-c-how-virtual-destructor-works/). Equivalent support for creation and copying of objects is missing as С++ doesn't support virtual constructor & virtual [copy constructors](/posts/all-about-copy-constructor-in-cpp-with-example/).
- Moreover, you can't create an object unless you know its static type, because the compiler must know the amount of space it needs to allocate. For the same reason, copy of an object also requires its type to known at compile-time.
- Consider the following example as problem statement:

```cpp
struct animal {
    virtual ~animal(){ cout<<"~animal\n"; }
};

struct dog : animal {
    ~dog(){ cout<<"~dog\n"; }
};

struct cat : animal {
    ~cat(){ cout<<"~cat\n"; }
};

void who_am_i(animal *who) { // not sure whether dog would be passed here or cat
    // How to `create` the object of same type i.e. pointed by who ?
    // How to `copy` object of same type i.e. pointed by who ?
    delete who; // you can delete appropriate object pointed by who, thanks to virtual destructor
}
```

- Just don't think of [dynamic_cast<>](/posts/cpp-type-casting-with-example-for-c-developers/), its code smell.

#### Solution

- The Virtual Constructor/Copy-Constructor technique allows polymorphic creation & copying of objects in C++ by delegating the act of creation & copying the object to the derived class through the use of virtual methods.
- Following code is not only implements virtual [copy constructor](/posts/all-about-copy-constructor-in-cpp-with-example/) (i.e. `clone()) but also implement virtual constructor(i.e. `create()`.

```cpp
struct animal {
    virtual ~animal() = default;
    virtual std::unique_ptr<animal> create() = 0;
    virtual std::unique_ptr<animal> clone() = 0;
};

struct dog : animal {
    std::unique_ptr<animal> create() { return std::make_unique<dog>(); }
    std::unique_ptr<animal> clone() { return std::make_unique<dog>(*this); }
};

struct cat : animal {
    std::unique_ptr<animal> create() { return std::make_unique<cat>(); }
    std::unique_ptr<animal> clone() { return std::make_unique<cat>(*this); }
};

void who_am_i(animal *who) {
    auto new_who = who->create();// `create` the object of same type i.e. pointed by who ?
    auto duplicate_who = who->clone(); // `copy` object of same type i.e. pointed by who ?    
    delete who; 
}
```

## Benefits of Prototype Design Pattern

1. Prototypes are useful when the object instantiation is expensive, thus avoid expensive "creation from scratch", and support cheap cloning of a pre-initialized prototype.
2. The prototype provides the flexibility to create highly dynamic systems by defining new behaviour through object [composition](https://stackoverflow.com/questions/50113353/differentiating-composition-and-aggregation-programmatically) & specifying values for an object's data members at the time of instantiation unlike defining new classes.
3. You can simplify the system by producing complex objects more conveniently.
4. Especially in C++, Prototype Design Pattern is helpful in creating copy of an object without even knowing its type.

## Summary by FAQs

**What's the point of using the Prototype Design Pattern?**

- To create an object rapidly based on cloning a pre-configured object.  
- Useful to remove a bunch of boilerplate code.  
- Handly while working with object without knowing its type.  
- Prototype Design Pattern is an obvious choice while you are working with the [Command Design Pattern](/posts/command-design-pattern-in-modern-cpp/). For example, in HTTP request most of the time header & footer content remains the same, what changes are data. In such a scenario, you should not create an object from scratch. Rather leverage Prototype Design Pattern.

**Is the Prototype Design Pattern Really Just Clone?**

It isn't if you combine it with the [Factory Design Pattern](/posts/factory-design-pattern-in-modern-cpp/).

**Prototype design pattern to be used when creation is costly, but we do create in the clone.**

You must be wondering that in Prototype Factory we show above, we are creating instances in the copy constructor. Isn't that expensive. Yes, it is. But just think about HTTP request, its header consist version, encoding type, content type, server-type, etc. Initially, you need a find out these parameters using respective function calls. But once you got these, these are not going to change until connection closed. So there is no point in doing function calls to extract these params over & over. What cost us here is not parameters but their functions to extract value.
