---
title: "Factory Design Pattern in Modern C++"
date: "2020-04-06"
categories: 
  - "cpp"
  - "design-patterns"
  - "software-engineering"
tags: 
  - "abstract-factory"
  - "abstract-factory-c"
  - "abstract-factory-c-example"
  - "abstract-factory-design-pattern"
  - "abstract-factory-design-pattern-c"
  - "abstract-factory-in-c"
  - "abstract-factory-pattern-c"
  - "abstract-factory-pattern-c-example"
  - "benefits-of-factory-design-pattern"
  - "c-abstract-factory"
  - "c-abstract-factory-pattern"
  - "c-design-pattern-factory"
  - "c-factory-method"
  - "c-factory-pattern"
  - "c-factory-pattern-example"
  - "c-factory-pattern-template"
  - "classical-factory-design-pattern"
  - "design-pattern-factory-c"
  - "example-of-abstract-factory-design-pattern"
  - "factory-design-pattern-c"
  - "factory-design-pattern-c-example"
  - "factory-design-pattern-cpp"
  - "factory-design-pattern-example-in-c"
  - "factory-design-pattern-examples-in-c"
  - "factory-design-pattern-in-c"
  - "factory-design-pattern-in-c-with-example"
  - "factory-design-pattern-in-cpp"
  - "factory-design-pattern-in-modern-c"
  - "factory-design-pattern-intent"
  - "factory-method-c"
  - "factory-method-design-pattern-c"
  - "factory-method-design-pattern-in-c"
  - "factory-method-in-c"
  - "factory-method-pattern-c"
  - "factory-pattern-c-2"
  - "factory-pattern-c-example"
  - "factory-pattern-in-c"
  - "functional-factory-design-pattern-using-modern-c"
  - "inner-factory"
  - "motivation-for-factory-design-pattern"
  - "what-is-the-correct-way-to-implement-the-factory-design-pattern-in-c"
  - "when-to-use-the-factory-design-pattern"
  - "why-do-we-need-an-abstract-factory"
cover:
    image: /images/Factory-Design-Pattern-in-Modern-C-vishal-chovatiya.webp
---

In software engineering, Creational Design Patterns deal with object creation mechanisms, i.e. try to create objects in a manner suitable to the situation. In addition to this basic or ordinary form of object creation could result in design problems or added complexity to the design. Factory Design Pattern in C++ helps to mitigate this issue by **_creating objects using separate methods or polymorphic classes_**.

By the way, If you haven’t check out my other articles on Creational Design Patterns, then here is the list:

{{% include "/reusable_block/creational-design-patterns.md" %}}
{{% include "/reusable_block/design-pattern-prerequisites.md" %}}

## Intent

> **_For the creation of wholesale objects unlike builder(which creates piecewise)._**

## Motivation

- Let say you have a `Point` class having `x` & `y` as co-ordinates which can be Cartesian or Polar coordinate as below:

```cpp
struct Point {
	Point(float x, float y){ /*...*/ } 		// Cartesian co-ordinates

	// Not OK: Cannot overload with same type of arguments
	// Point(float a, float b){ /*...*/ } 	 // Polar co-ordinates

	// ... Implementation
};
```

- This isn't possible as you might know you can not create two constructors with the same type of arguments.
- Other way around is:

```cpp
enum class PointType{ cartesian, polar };

class Point {
    Point(float a, float b, PointTypetype = PointType::cartesian) {
        if (type == PointType::cartesian) {
            x = a; b = y;
        }
        else {
            x = a * cos(b);
            y = a * sin(b);
        }
    }
};
```

- But this isn't a sophisticated way of doing this. Rather we should delegate separate instantiation to separate methods.

## Factory Design Pattern Examples in C++

- So as you can guess. We are going to mitigate constructor limitation by moving the initialization process from constructor to other structure. And we gonna be using the Factory Method for that.
- And just as the name suggests it uses the method or member function to initialize the object.

### Factory Method

```cpp
enum class PointType { cartesian, polar };

class Point {
	float 		m_x;
	float 		m_y;
	PointType 	m_type;

	// Private constructor, so that object can't be created directly
	Point(const float x, const float y, PointType t) : m_x{x}, m_y{y}, m_type{t} {}

  public:
	friend ostream &operator<<(ostream &os, const Point &obj) {
		return os << "x: " << obj.m_x << " y: " << obj.m_y;
	}
	static Point NewCartesian(float x, float y) {
		return {x, y, PointType::cartesian};
	}
	static Point NewPolar(float a, float b) {
		return {a * cos(b), a * sin(b), PointType::polar};
	}
};

int main() {
	// Point p{ 1,2 };  // will not work
	auto p = Point::NewPolar(5, M_PI_4);
	cout << p << endl;  // x: 3.53553 y: 3.53553
	return EXIT_SUCCESS;
}
```

- As you can observe from the implementation. It actually disallows the use of constructor & forcing users to use static methods instead. And this is the essence of the **_Factory Method i.e. private constructor & static method_**.

### Classical Factory Design Pattern

- If you have dedicated code for construction then why don't we move it to a dedicated class! And Just to separation the concerns i.e. [Single Responsibility Principle](/posts/single-responsibility-principle-in-cpp-solid-as-a-rock/) from SOLID design principles.

```cpp
class Point {
    // ... as it is from above
    friend class PointFactory;
};

class PointFactory {
public:
    static Point NewCartesian(float x, float y) {
        return { x, y };
    }
    static Point NewPolar(float r, float theta) {
        return { r*cos(theta), r*sin(theta) };
    }
};
```

- Mind that this is not the abstract factory this is a concrete factory.
- Making the `PointFactory` friend class of `Point` we have violated the [Open-Closed Principle](/posts/open-closed-principle-in-cpp-solid-as-a-rock/)(OCP). As friend keyword itself contrary to OCP.

### Inner Factory

- There is a critical thing we missed in our Factory that there is no strong link between `PointFactory` & `Point` which confuses user to use `Point` just by seeing everything is `private`.
- So rather than designing a factory outside the class. We can simply put it in the class which encourage users to use Factory.
- Thus, we also serve the second problem which is breaking the [Open-Closed Principle](/posts/open-closed-principle-in-cpp-solid-as-a-rock/). And this will be somewhat more intuitive for the user to use Factory.

```cpp
class Point {
    float   m_x;
    float   m_y;

    Point(float x, float y) : m_x(x), m_y(y) {}
public:
    struct Factory {
        static Point NewCartesian(float x, float y) { return { x,y }; }
        static Point NewPolar(float r, float theta) { return{ r*cos(theta), r*sin(theta) }; }
    };
};

int main() {
    auto p = Point::Factory::NewCartesian(2, 3);
    return EXIT_SUCCESS;
}
```

### Abstract Factory

#### Why do we need an Abstract Factory?

- C++ has the support of polymorphic object destruction using it’s base class’s [virtual destructor](/posts/part-3-all-about-virtual-keyword-in-c-how-virtual-destructor-works/). Similarly, equivalent support for creation & copying of objects is missing as C++ doesn't support [virtual constructor](/posts/7-advanced-cpp-concepts-idiom-examples-you-should-know/) & [virtual copy constructors](/posts/all-about-copy-constructor-in-cpp-with-example/).
- Moreover, you can’t create an object unless you know its static type, because the compiler must know the amount of space it needs to allocate. For the same reason, copy of an object also requires its type to known at compile-time.

```cpp
struct Point {
    virtual ~Point(){ cout<<"~Point\n"; }
};

struct Point2D : Point {
    ~Point2D(){ cout<<"~Point2D\n"; }
};

struct Point3D : Point {
    ~Point3D(){ cout<<"~Point3D\n"; }
};

void who_am_i(Point *who) { // Not sure whether Point2D would be passed here or Point3D
    // How to `create` the object of same type i.e. pointed by who ?
    // How to `copy` object of same type i.e. pointed by who ?
    delete who; // you can delete object pointed by who, thanks to virtual destructor
}
```

#### Example of Abstract Factory Design Pattern

- The Abstract Factory is useful in a situation that requires the creation of many different types of objects, all derived from a common base type.
- The Abstract Factory defines a method for creating the objects, which [subclasses](/posts/memory-layout-of-cpp-object/) can then override to specify the derived type that will be created. Thus, at run time, the appropriate Abstract Factory Method will be called depending upon the type of object referenced/pointed & return a base class pointer to a new instance of that object.

```cpp
struct Point {
	virtual ~Point() = default;
	virtual unique_ptr<Point> create() = 0;
	virtual unique_ptr<Point> clone()	= 0;
};

struct Point2D : Point {
	unique_ptr<Point> create() { return make_unique<Point2D>(); }
	unique_ptr<Point> clone() { return make_unique<Point2D>(*this); }
};

struct Point3D : Point {
	unique_ptr<Point> create() { return make_unique<Point3D>(); }
	unique_ptr<Point> clone() { return make_unique<Point3D>(*this); }
};

void who_am_i(Point *who) {
	auto new_who	   = who->create(); // `create` the object of same type i.e. pointed by who ?
	auto duplicate_who = who->clone();	// `copy` the object of same type i.e. pointed by who ?
	delete who;
}
```

- As shown above, we have leveraged polymorphic methods by delegating the act of creation & copying the object to the derived class through the use of pure virtual methods.
- Above code is not only implement [virtual constructor](/posts/7-advanced-cpp-concepts-idiom-examples-you-should-know/#Virtual-Constructor)(i.e. `create()`) but also implements [virtual copy constructor](/posts/7-advanced-cpp-concepts-idiom-examples-you-should-know/#Virtual-Constructor)(i.e. `clone()`).
- Make sure while using Abstract Factory you have ensured the [Liskov's Substitution Principle(LSP)](/posts/liskovs-substitution-principle-in-cpp-solid-as-a-rock/).

### Functional Approach to Factory Design Pattern using Modern C++

- In our Abstract Factory example, we have followed the object-oriented approach but its equally possible nowadays to a more functional approach.
- So, let's build a similar kind of Factory without relying on polymorphic functionality as it might not suit some time-constrained application like an [embedded system](https://en.wikipedia.org/wiki/Embedded_system). Because the [virtual table & dynamic dispatch mechanism](/posts/part-1-all-about-virtual-keyword-in-cpp-how-virtual-function-works-internally/) may troll system during critical functionality.
- This is pretty straight forward as it uses functional & [lambda functions](/posts/learn-lambda-function-in-cpp-with-example/) as follows:

```cpp
struct Point { /* . . . */ };
struct Point2D : Point {/* . . . */};
struct Point3D : Point {/* . . . */};

class PointFunctionalFactory {
    map<PointType, function<unique_ptr<Point>() >>      m_factories;

public:
    PointFunctionalFactory() {
        m_factories[PointType::Point2D] = [] { return make_unique<Point2D>(); };
        m_factories[PointType::Point3D] = [] { return make_unique<Point3D>(); };
    }    
    unique_ptr<Point> create(PointType type) { return m_factories[type](); }  
};

int main() {
    PointFunctionalFactory pf;
    auto p2D = pf.create(PointType::Point2D);
    return EXIT_SUCCESS;
}
```

- If you are thinking that we are over-engineering, then keep in mind that our object construction is simple here just to demonstrate the technique & so does our lambda function.
- When your object representation increases, it requires a lot of methods to call in order to instantiate object properly, in such case you just need to modify lambda expression of the factory or introduce [Builder Design Pattern](/posts/builder-design-pattern-in-modern-cpp/).

## Benefits of Factory Design Pattern

1. Single point/class for different object creation. Thus easy to maintain & understand software.
2. You can create the object without even knowing its type by using Abstract Factory.
3. It provides great modularity. Imagine programming a video game, where you would like to add new types of enemies in the future, each of which has different AI functions and can update differently. By using a factory method, the controller of the program can call to the factory to create the enemies, without any dependency or knowledge of the actual types of enemies. Now, future developers can create new enemies, with new AI controls and new drawing member functions, add it to the factory, and create a level which calls the factory, asking for the enemies by name. Combine this method with an XML description of levels, and developers could create new levels without having to recompile their program. All this, thanks to the separation of creation of objects from the usage of objects.
4. Allows you to change the design of your application more readily, this is known as loose coupling.

## Summary by FAQs

**What is the correct way to implement the Factory Design Pattern in C++?**

Abstract Factory & Functional Factory is always a good choice.

**Factory vs Abstract Factory vs Functional Factory?**

- Factory: Create an object with varied instantiation.  
- Abstract Factor: Create an object without knowing its type & refer using base class pointer & reference. Access using polymorphic methods.  
- Functional Factory: When object creation is more complex. Abstract Factory + [Builder Design Pattern](/posts/builder-design-pattern-in-modern-cpp/). Although I have not included Builder in Functional Factory example.

**What's the difference between Abstract Factory and Builder Design Pattern?**

- Factory produces the objects in wholesale that could be any object from inheritance hierarchy(like Point, Point2D, Point3D). While Builder deals with instantiation of an object that is limited to a single object(Although this statement is still debatable).  
- You see Factory is all about wholesale object creation while the builder is piecewise object creation. In both the patterns, you can separate out the mechanism related to object creation in other classes.

**When to use the Factory Design Pattern?**

Employ Factory Design Pattern to create an object of required functionality(s) but the type of object will remain undecided or it will be decided on dynamic parameters being passed.
