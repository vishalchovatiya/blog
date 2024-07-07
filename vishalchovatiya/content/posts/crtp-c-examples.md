---
title: "CRTP C++ Examples"
date: "2020-07-03"
categories: 
  - "cpp"
tags: 
  - "c-crtp"
  - "c20-solution-spaceship-operator"
  - "c20-spaceship-operator-with-the-help-of-crtp"
  - "crtp-and-static-polymorphism-in-c"
  - "crtp-c"
  - "crtp-c-example"
  - "crtp-pattern"
  - "crtp-to-avoid-code-duplication"
  - "curiously-recurring-template-pattern"
  - "dynamic-polymorphism"
  - "enabling-polymorphic-copy-construction-in-c-with-crtp"
  - "enabling-polymorphic-method-chaining"
  - "limiting-object-count-with-crtp"
  - "modern-c-composite-design-pattern-leveraging-crtp"
  - "solution-till-c17-with-crtp"
  - "static-polymorphism"
featuredImage: "/images/CRTP-C-Examples.webp"
---

Curiously Recurring Template Pattern(CRTP) in C++ is definitely a powerful technique & static alternative to virtual functions. But at the same time, learning it may seem a bit weird at first. If you are like me who struggled to grasp anything in one go. Then this article might help you to provide a thought process on where CRTP fits in day-to-day coding. And, if you are an Embedded Programmer, you may run into CRTP more often. Although, `std::variant` + `std::visit` will also help but 90% of the compilers for embedded processors are either not up to date with standard or dumb.

There is various material effectively accessible for "How" and "What" on CRTP. So, I won't centre there rather address "Where" part i.e. CRTP Applicability.

## CRTP and Static Polymorphism In C++

```cpp
template<typename specific_animal>
struct animal {
    void who() { static_cast<specific_animal*>(this)->who(); }
};

struct dog : animal<dog> {
    void who() { cout << "dog" << endl; }
};

struct cat : animal<cat> {
    void who() { cout << "cat" << endl; }
};

template<typename specific_animal>
void who_am_i(animal<specific_animal> &animal) {
    animal.who();
}

cat c;
who_am_i(c); // prints `cat`

dog d;
who_am_i(d); // prints `dog`
```

- **_Curiously Recurring Template Pattern widely employed for static polymorphism_** without bearing the cost of virtual dispatch mechanism. Consider the above code, we haven't used virtual keyword & still achieved the functionality of polymorphism.
- How it works is not the topic of this article. So, I am leaving it to you to figure out.

## Limiting Object Count with CRTP

- There are times when you have to manage the critical resource with single or predefined object count. And we have [Singleton & Monotone Design Patterns](/posts/singleton-design-pattern-in-modern-cpp/) for this. But this works as long as your object counts are smaller in number.
- **_When you want to limit the arbitrary type to be limited with an arbitrary number of instances_**. CRTP will come to rescue:

```cpp
template <class ToBeLimited, uint32_t maxInstance>
struct LimitNoOfInstances {
	static atomic<uint32_t> cnt;

	LimitNoOfInstances() {
		if (cnt >= maxInstance)
			throw logic_error{"Too Many Instances"};
		++cnt;
	}
	~LimitNoOfInstances() { --cnt; }
}; // Copy, move & other sanity checks to be complete

struct One : LimitNoOfInstances<One, 1> {};
struct Two : LimitNoOfInstances<Two, 2> {};

template <class T, uint32_t maxNoOfInstace>
atomic<uint32_t> LimitNoOfInstances<T, maxNoOfInstace>::cnt(0);


void use_case() {
	Two _2_0, _2_1;

	try {
		One _1_0, _1_1;
	} catch (exception &e) {
		cout << e.what() << endl;
	}
}
```

- You might be wondering that what is the point of the template parameter `ToBeLimited`, if it isn't used. In that case, you should have brush up your [C++ Template](/posts/c-template-a-quick-uptodate-look/) fundamentals or use [cppinsights.io](https://cppinsights.io/). As it isn't useless.

## CRTP to Avoid Code Duplication

- Let say you have a set of containers that support the functions `begin()` & `end()` But, the standard library's requirements for containers require more functionalities like `front()`, `back()`, `size()`, etc.
- We can design such functionalities with a **_CRTP base class that provides common utilities solely based on derived class member function_** i.e. `begin()` & `end()`in our cases:

```cpp
template <typename T>
class Container {
    T &actual() { return *static_cast<T *>(this); }
    T const &actual() const { return *static_cast<T const *>(this); }

public:
    decltype(auto) front() { return *actual().begin(); }
    decltype(auto) back() { return *std::prev(actual().end()); }
    decltype(auto) size() const { return std::distance(actual().begin(), actual().end()); }
    decltype(auto) operator[](size_t i) { return *std::next(actual().begin(), i); }
};
```

- The above class provides the functions `front()`, `back()`, `size()` and `operator[ ]` for any subclass that has `begin()` & `end()`
- For example, subclass could be a simple dynamically allocated array as:

```cpp
template <typename T>
class DynArray : public Container<DynArray<T>> {
	size_t m_size;
	unique_ptr<T[]> m_data;

  public:
	DynArray(size_t s) : m_size{s}, m_data{make_unique<T[]>(s)} {}

	T *begin() { return m_data.get(); }
	const T *begin() const { return m_data.get(); }

	T *end() { return m_data.get() + m_size; }
	const T *end() const { return m_data.get() + m_size; }
};

DynArray<int> arr(10);
arr.front() = 2;
arr[2]		= 5;
asssert(arr.size() == 10);
```

## Modern C++ Composite Design Pattern Leveraging CRTP

- [Composite Design Pattern](/posts/composite-design-pattern-in-modern-cpp/) states that we should **_treat the group of objects in the same manner as a single object_**. And to implement such pattern we can leverage the CRTP.
- For example, as a part of machine learning, we have to deal with `Neuron` which for simplicity defined as:

```cpp
struct Neuron {
    vector<Neuron*>     in, out;    // Stores the input-output connnections to other Neurons
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

Neuron n1, n2;
n1.connect_to(n2);
cout << n1 << n2 << endl;

/* Output
[1]	-->	2
1	-->	[2]
*/
```

- And there is also a `NeuronLayer` i.e. collection of `Neuron` which for simplicity defined as:

```cpp
struct NeuronLayer : vector<Neuron> {
    NeuronLayer(int count) {
        while (count --> 0)
            emplace_back(Neuron{});
    }

    friend ostream &operator<<(ostream &os, NeuronLayer &obj) {
        for (auto &n : obj)
            os << n;
        return os;
    }
};
```

- Now, if you want to connect the `Neuron` with `NeuronLayer` and vice-versa. You're going to have a total of four different functions as follows:

```cpp
Neuron::connect_to(Neuron&)
Neuron::connect_to(NeuronLayer&)

NeuronLayer::connect_to(NeuronLayer&)
NeuronLayer::connect_to(Neuron&)
```

- You see this is state-space explosion(permutation in layman terms) problem and it's not good. Because we want a single function that enumerable both the layer as well as individual neurons. CRTP comes handy here as:

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

/* ----------------------------------------------------------------------- */
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
/* ----------------------------------------------------------------------- */

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
[1]    -->    3
[1]    -->    2

Neuron 2
4    -->    [2]
5    -->    [2]
1    -->    [2]

Layer 
1    -->    [3]
[3]    -->    4
[3]    -->    5

Layer 
3    -->    [4]
[4]    -->    2
3    -->    [5]
[5]    -->    2
*/
```

- As you can see we have covered all four different permutation scenarios using a single `SomeNeurons::connect_to` method. And both `Neuron` & `NeuronLayer` conforms to this interface via self templatization.

## C++20 Spaceship Operator With the Help of CRTP

### **Problem**

```cpp
struct obj_type_1 {
    bool operator<(const value &rhs) const { return m_x < rhs.m_x; }
    // bool operator==(const value &rhs) const;
    // bool operator!=(const value &rhs) const;    
    // List goes on. . . . . . . . . . . . . . . . . . . .
private:
    // data members to compare
};

struct obj_type_2 {
    bool operator<(const value &rhs) const { return m_x < rhs.m_x; }
    // bool operator==(const value &rhs) const;
    // bool operator!=(const value &rhs) const;    
    // List goes on. . . . . . . . . . . . . . . . . . . .
private:
    // data members to compare
};

struct obj_type_3 { ...
struct obj_type_4 { ...
// List goes on. . . . . . . . . . . . . . . . . . . .
```

- For each comparable objects, you need to define respective comparison operators. This is redundant because if we have an `operator <` , we can overload other operators on the basis of it.
- Thus, `operator <` is the only one operator having type information, other operators can be made type independent for **_reusability purpose_**.

### Solution till C++17 with CRTP

```cpp
template <class derived>
struct compare {};

struct value : compare<value> {
    int m_x;
    value(int x) : m_x(x) {}
    bool operator < (const value &rhs) const { return m_x < rhs.m_x; }
};

template <class derived>
bool operator > (const compare<derived> &lhs, const compare<derived> &rhs) {
    // static_assert(std::is_base_of_v<compare<derived>, derived>); // Compile time safety measures
    return (static_cast<const derived&>(rhs) < static_cast<const derived&>(lhs));
}

/*  Same goes with other operators
    == :: returns !(lhs < rhs) and !(rhs < lhs)
    != :: returns !(lhs == rhs)
    >= :: returns (rhs < lhs) or (rhs == lhs)
    <= :: returns (lhs < rhs) or (rhs == lhs) 
*/

int main() {   
    value v1{5}, v2{10};
    cout << boolalpha << "v1 > v2: " << (v1 > v2) << '\n';
    return EXIT_SUCCESS;
}
// Now no need to write comparator operators for all the classes, 
// Write only type dependent `operator <` & inherit with `compare<T>`
```

### C++20 Solution : Spaceship Operator

```cpp
struct value{
    int m_x;
    value(int x) : m_x(x) {}
    auto operator<=>(const value &rhs) const = default;
};
// Defaulted equality comparisons
// More Info: https://en.cppreference.com/w/cpp/language/default_comparisons
```

## Enabling Polymorphic Method Chaining

- _Method Chaining_ is a common syntax for invoking multiple methods on a single object back to back. That too, in a single statement without requiring variables to store the intermediate results. For example:

```cpp
class Printer {
    ostream &m_stream;
public:
    Printer(ostream &s) : m_stream(s) { }

    Printer &print(auto &&t) {
        m_stream << t;
        return *this;
    }

    Printer &println(auto &&t) {
        m_stream << t << endl;
        return *this;
    }
};

Printer{cout}.println("hello").println(500);     // Method Chaining
```

- But, when method chaining applied to an object hierarchy, things can go wrong. For example:

```cpp
struct ColorPrinter : Printer {
    enum Color{red, blue, green};
    ColorPrinter(ostream &s) : Printer(s) {}

    ColorPrinter &SetConsoleColor(Color c) {
        // ...
        return *this;
    }
};

ColorPrinter(cout).print("Hello").SetConsoleColor(ColorPrinter::Color::red).println("Printer!"); // Not OK
```

- Compiling above code prompt you with the following error:

```bash
error: 'class Printer' has no member named 'SetConsoleColor'

ColorPrinter(cout).print("Hello").SetConsoleColor(ColorPrinter::Color::red).println("Printer!");
                                  ^
                                  |____________ We have a 'Printer' here, not a 'ColorPrinter'
```

- This happens because we "lose" the concrete class as soon as we invoke a function of the base class.
- The CRTP can be useful to avoid such problem and to enable Polymorphic Method Chaining.

```cpp
template <typename ConcretePrinter>
class Printer {
    ostream &m_stream;
public:
    Printer(ostream &s) : m_stream(s) { }

    ConcretePrinter &print(auto &&t) {
        m_stream << t;
        return static_cast<ConcretePrinter &>(*this);
    }

    ConcretePrinter &println(auto &&t) {
        m_stream << t << endl;
        return static_cast<ConcretePrinter &>(*this);
    }
};

struct ColorPrinter : Printer<ColorPrinter> {
    enum Color { red, blue, green };
    ColorPrinter(ostream &s) : Printer(s) {}

    ColorPrinter &SetConsoleColor(Color c) {
        // ...
        return *this;
    }
};

int main() {
    ColorPrinter(cout).print("Hello ").SetConsoleColor(ColorPrinter::Color::red).println("Printer!");
    return EXIT_SUCCESS;
}
```

## Enabling Polymorphic Copy Construction in C++ with CRTP

### Problem

- C++ has the support of polymorphic object destruction using it’s base class’s [virtual destructor](/posts/part-3-all-about-virtual-keyword-in-c-how-virtual-destructor-works/). But, equivalent support for creation and copying of objects is missing as С++ doesn’t support virtual constructor/[copy-constructors](/posts/all-about-copy-constructor-in-cpp-with-example/).
- Moreover, you can’t create an object unless you know its static type, because the compiler must know the amount of space it needs to allocate. For the same reason, copy of an object also requires its type to known at compile-time.

```cpp
struct animal {  virtual ~animal(){ cout << "~animal\n"; } };

struct dog : animal  { ~dog(){ cout << "~dog\n"; } };
struct cat : animal  { ~cat(){ cout << "~cat\n"; } };

void who_am_i(animal *who) { // not sure whether `dog` would be passed here or `cat`

    // How to `copy` object of the same type i.e. pointed by who?

    delete who; // you can delete object pointed by who
}
```

### Solution 1 : Dynamic Polymorphism

- As the name suggests, we will use virtual methods to delegate the act of copying(and/or creation) of the object as below:

```cpp
struct animal {
    virtual unique_ptr<animal> clone() = 0;
};

struct dog : animal {
    unique_ptr<animal> clone() override { return make_unique<dog>(*this); }
};

struct cat : animal {
    unique_ptr<animal> clone() override { return make_unique<cat>(*this); }
};

void who_am_i(animal *who) {
    auto duplicate_who = who->clone(); // `copy` object of same type i.e. pointed by who ?    
}
```

### Solution 2 : Static Polymorphism

- Same thing can be accomplished with CRTP as below:

```cpp
template <class specific>
struct animal {
    unique_ptr<animal> clone() {
        return make_unique<specific>(static_cast<specific &>(*this));
    }

protected: // Forcing animal class to be inherited
    animal(const animal &) = default;
};

struct dog : animal<dog> {
    dog(const dog &) { cout << "copied dog" << endl; }
};

struct cat : animal<cat> {
    cat(const cat &) { cout << "copied cat" << endl; }
};

template <class specific>
void who_am_i(animal<specific> *who) {
    auto duplicate_who = who->clone(); // `copy` object of same type i.e. pointed by who ?
}
```

## Wrap-Up

Everything comes with its own price. And CRTP is no exception. For example, if you are using CRTP with run time object creation, your code may behave weird. Moreover,

- As the base class is templated, you can not point derived class object with the base class pointer.
- Also, you can not create generic container like `std::vector<animal*>` because `animal` is not a class, but a template needing specialization. A container defined as `std::vector<animal<dog>*>` can only store `dog`s, not `cat`s. This is because each of the classes derived from the CRTP base class `animal` is a unique type. A common solution to this problem is to add one more layer of indirection i.e. abstract class with a virtual destructor, like the `abstract_animal` & inherit `animal` class, allowing for the creation of a ``std::vector<`abstract_animal`*>``.

There are other useful application of CRTP as well. If you think I am missing any major one & have any suggestion you can always reach me [here](/posts/contact-2/).

## References

- [wikipedia](https://www.wikiwand.com/en/Curiously_recurring_template_pattern)
- [C++ Notes for Professionals Stack Overflow Documentation](https://books.goalkicker.com/CPlusPlusBook/)
- [Advanced C++ Concepts](/posts/7-advance-cpp-concepts-idiom-examples-you-should-know/)
