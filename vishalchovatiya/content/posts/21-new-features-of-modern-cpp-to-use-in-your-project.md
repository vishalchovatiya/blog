---
title: "21 New Features of Modern C++ to Use in Your Project"
date: "2019-10-13"
categories: 
  - "cpp"
tags: 
  - "c-digit-separators"
  - "c-smart-pointers"
  - "c-uniform-initialization-non-static-member-initialization"
  - "c-user-defined-literals"
  - "class-template-argument-deduction"
  - "forwarding-reference"
  - "lambda-expression-in-c"
  - "modern-c"
  - "modern-c-features"
  - "new-features-in-c"
  - "nullptr-c"
  - "smart-pointers"
  - "strongly-typed-enums"
  - "strongly-typed-enums-c"
featuredImage: "/images/20-new-features-of-Modern-C-to-use-in-your-project.png"
---

So, you came across the Modern C++ & overwhelmed by its features in terms of performance, convenience & code expressiveness. But in a dilemma that how you can spot where you can enforce Modern C++ features in your day to day coding job. No worries, here we will see 21 new features of Modern C++ you can use in your project.

C++ community releasing new standards more frequently than iPhone releases. Due to this, C++ now becomes like an elephant and it is impossible to eat the whole elephant in one go. That is why I have written this post to kick start your Modern C++ journey. Here my intended audience is peeps who are moving from older(i.e. 98/03) C++ to Modern(i.e. 2011 onwards) C++.

I have chosen some of the Modern C++ features & explained it with the minimalistic example to make you aware that how you can spot the places where you can employ new features.

## Digit separators

```cpp
int no = 1'000'000;                      // separate units like, thousand, lac, million, etc.
long addr = 0xA000'EFFF;                 // separate 32 bit address
uint32_t binary = 0b0001'0010'0111'1111; // now, explanation is not needed i guess
```

- Earlier you have to count digits or zeros, but now not anymore from C++14.
- This will be useful while counting address in word, half-word or digit boundary or let say you have a credit card or social security number.
- By grouping digits, your code would become more expressive.

## Type aliases

```cpp
template <typename T>
using dyn_arr = std::vector<T>;
dyn_arr<int> nums; // equivalent to std::vector<int>

using func_ptr = int (*)(int);
```

- Semantically similar to using a `typedef` , however, type aliases are easier to read and are compatible with [C++ templates](/posts/c-template-a-quick-uptodate-look/) types also. Thanks to C++11.

## User-defined literals

```cpp
using ull = unsigned long long;

constexpr ull operator"" _KB(ull no)
{
    return no * 1024;
}

constexpr ull operator"" _MB(ull no)
{
    return no * (1024_KB);
}

cout<<1_KB<<endl;
cout<<5_MB<<endl;
```

- Most of the times you have to deal with real-world jargons like KB, MB, km, cm, rupees, dollars, euros, etc. rather defining functions which do the unit conversion on run-time, you can now treat it as user-defined literals as you do with other primitive types.
- Very convenient for units & measurement.
- Adding constexpr will serve zero cost run-time performance impact which we will see later in this article & I have written a more detailed article on [when to use const vs constexpr in c++](/posts/when-to-use-const-vs-constexpr-in-cpp/).

## Uniform initialization & Non-static member initialization

Earlier, you have to initialize data members with its default values in the constructor or in the member initialization list. But from C++11, it’s possible to give normal class member variables (those that don’t use the `static` keyword) a default initialization value directly as shown below:

```cpp
class demo
{
private:
    uint32_t m_var_1 = 0;
    bool m_var_2 = false;
    string m_var_3 = "";
    float m_var_4 = 0.0;

public:
    demo(uint32_t var_1, bool var_2, string var_3, float var_4)
        : m_var_1(var_1),
          m_var_2(var_2),
          m_var_3(var_3),
          m_var_4(var_4) {}
};

demo obj{123, true, "lol", 1.1};
```

- This is more useful when there are multiple [sub-object](/posts/memory-layout-of-cpp-object/)s defined as data members as follows:

```cpp
class computer
{
private:
    cpu_t           m_cpu{2, 3.2_GHz};
    ram_t           m_ram{4_GB, RAM::TYPE::DDR4};
    hard_disk_t     m_ssd{1_TB, HDD::TYPE::SSD};

public:
    // ...
};
```

- In this case, you do not need to initialize it in initializer list, rather you can directly give default initialization at the time of declaration.

```cpp
class X
{
    const static int m_var = 0;
};

// int X::m_var = 0; // not needed for constant static data members
```

- You can also provide initialization at the time of declaration if members are `const` & `static` as above.

## std::initializer\_list

```cpp
std::pair<int, int> p = {1, 2};
std::tuple<int, int> t = {1, 2};
std::vector<int> v = {1, 2, 3, 4, 5};
std::set<int> s = {1, 2, 3, 4, 5};
std::list<int> l = {1, 2, 3, 4, 5};
std::deque<int> d = {1, 2, 3, 4, 5};

std::array<int, 5> a = {1, 2, 3, 4, 5};

// Wont work for adapters
// std::stack<int> s = {1, 2, 3, 4, 5};
// std::queue<int> q = {1, 2, 3, 4, 5};
// std::priority_queue<int> pq = {1, 2, 3, 4, 5};
```

- Assign values to containers directly by initializer list as do with C-style arrays.
- This is also true for nested containers. Thanks to C++11.

## auto & decltype

```cpp
auto a = 3.14; // double
auto b = 1; // int
auto& c = b; // int&
auto g = new auto(123); // int*
auto x; // error -- `x` requires initializer
```

- `auto`\-typed variables are deduced by the compiler according to the type of their initializer.
- Extremely useful for readability, especially for complicated types:

```cpp
// std::vector<int>::const_iterator cit = v.cbegin();
auto cit = v.cbegin(); // alternatively

// std::shared_ptr<vector<uint32_t>> demo_ptr(new vector<uint32_t>(0);
auto demo_ptr = make_shared<vector<uint32_t>>(0); // alternatively
```

- Functions can also deduce the return type using `auto`. In C++11, a return type must be specified either explicitly, or using `decltype` like:

```cpp
template <typename X, typename Y>
auto add(X x, Y y) -> decltype(x + y)
{
    return x + y;
}
add(1, 2);     // == 3
add(1, 2.0);   // == 3.0
add(1.5, 1.5); // == 3.0
```

- Defining return type as above called trailing return type i.e. `-> return-type`.

## Range-based for-loops

- Syntactic sugar for iterating over a container's elements.

```cpp
std::array<int, 5> a {1, 2, 3, 4, 5};
for (int& x : a) x *= 2;
// a == { 2, 4, 6, 8, 10 }
```

- Note the difference when using `int` as opposed to `int&`:

```cpp
std::array<int, 5> a {1, 2, 3, 4, 5};
for (int x : a) x *= 2;
// a == { 1, 2, 3, 4, 5 }
```

## Smart pointers

- C++11 introduces new smart(er) pointers: `std::unique_ptr`, `std::shared_ptr`, `std::weak_ptr`. 
- And `std::auto_ptr` now become deprecated and then eventually removed in C++17.

```cpp
std::unique_ptr<int> i_ptr1{new int{5}}; // Not recommendate
auto i_ptr2 = std::make_unique<int>(5);  // More conviniently

template <typename T>
struct demo
{
    T m_var;

    demo(T var) : m_var(var){};
};

auto i_ptr3 = std::make_shared<demo<uint32_t>>(4);
```

- ISO CPP guidelines suggest avoiding the call of `new` and `delete` explicitly by the rule of [no naked new](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Res-new).
- I have already written an article on [understanding unique\_ptr with example in C++ here](/posts/understanding-unique-ptr-with-example-in-cpp11/).

## [nullptr](/posts/what-exactly-nullptr-is-in-cpp/)

- C++11 introduces a new null pointer type designed to replace C's `NULL` macro.
- [`nullptr`](/posts/what-exactly-nullptr-is-in-cpp/) itself is of type `std::nullptr_t` and can be implicitly converted into pointer types, and unlike `NULL`, not convertible to integral types except `bool`.

```cpp
void foo(int);
void foo(char*);
foo(NULL); // error -- ambiguous
foo(nullptr); // calls foo(char*)
```

## Strongly-typed enums

```cpp
enum class STATUS_t : uint32_t
{
    PASS = 0,
    FAIL,
    HUNG
};

STATUS_t STATUS = STATUS_t::PASS;
STATUS - 1; // not valid anymore from C++11
```

- Type-safe enums that solve a variety of problems with C-style enums including implicit conversions, arithmetic operations, inability to specify the underlying type, scope pollution, etc.

## Typecasting

- C style casting only change the type without touching underlying data. While older C++ was a bit type-safe and has a feature of specifying type conversion operator/function. But it was implicit type conversion, from C++11, conversion functions can now be made explicit using the `explicit` specifier as follows.

```cpp
struct demo
{
    explicit operator bool() const { return true; }
};

demo d;
if (d);                             // OK calls demo::operator bool()
bool b_d = d;                       // error: cannot convert 'demo' to 'bool' in initialization
bool b_d = static_cast<bool>(d);    // OK, explicit conversion, you know what you are doing
```

- If the above code looks alien to you, I have written a more detailed article on [C++ typecasting here](/posts/cpp-type-casting-with-example-for-c-developers/).

## Move semantics

- When an object is going to be destroyed or unused after expression execution, then it is more feasible to move resource rather than copying it.
- Copying includes unnecessary overheads like memory allocation, deallocation & copying memory content, etc.
- Consider the following swap function:

```cpp
template <class T>
swap(T& a, T& b) {
    T tmp(a);   // we now have two copies of a
    a = b;      // we now have two copies of b (+ discarded a copy of a)
    b = tmp;    // we now have two copies of tmp (+ discarded a copy of b)
}
```

- using move allows you to swap the resources instead of copying them around:

```cpp
template <class T>
swap(T& a, T& b) {
    T tmp(std::move(a));
    a = std::move(b);   
    b = std::move(tmp);
}
```

- Think of what happens when `T` is, say, `vector<int>` of size n. And n is too big.
- In the first version, you read and write 3\*n elements, in the second version you basically read and write just the 3 pointers to the vectors' buffers, plus the 3 buffers' sizes.
- Of course, class `T` needs to know how to do the moving; your class should have a [move-assignment operator and a move-constructor](/posts/lvalue-rvalue-and-their-references-with-example-in-cpp/) for class `T` for this to work.
- This feature will give you a significant boost in the performance which is why people use C++ for(i.e. last 2-3 drops of speed).

## Forwarding references

- Also known (unofficially) as _universal references_. A forwarding reference is created with the syntax `T&&` where `T` is a template type parameter, or using `auto&&`. This enables two major features
    - move semantics
    - And _[perfect forwarding](https://en.cppreference.com/w/cpp/utility/forward#Example)_, the ability to pass arguments that are either lvalues or rvalues.

Forwarding references allow a reference to binding to either an lvalue or rvalue depending on the type. Forwarding references follow the rules of _reference collapsing_:

1. `T& &` becomes `T&`
2. `T& &&` become `T&`
3. `T&& &` becomes `T&`
4. `T&& &&` becomes `T&&`

Template type parameter deduction with lvalues and rvalues:

```cpp
// Since C++14 or later:
void f(auto&& t) {
  // ...
}

// Since C++11 or later:
template <typename T>
void f(T&& t) {
  // ...
}

int x = 0;
f(0); // deduces as f(int&&)
f(x); // deduces as f(int&)

int& y = x;
f(y); // deduces as f(int& &&) => f(int&)

int&& z = 0; // NOTE: `z` is an lvalue with type `int&&`.
f(z); // deduces as f(int&& &) => f(int&)
f(std::move(z)); // deduces as f(int&& &&) => f(int&&)
```

- If this seems complex & weird to you then [read this first](/posts/lvalue-rvalue-and-their-references-with-example-in-cpp/) & then come back here.

## Variadic templates

```cpp
void print() {}

template <typename First, typename... Rest>
void print(const First &first, Rest &&... args)
{
    std::cout << first << std::endl;
    print(args...);
}

print(1, "lol", 1.1);
```

- The `...` syntax creates a _[parameter pack](https://en.cppreference.com/w/cpp/language/parameter_pack)_ or expands one. A template _parameter pack_ is a template parameter that accepts zero or more template arguments (non-types, types, or templates). A [C++ template](/posts/c-template-a-quick-uptodate-look/) with at least one parameter pack is called a _variadic template_.

## constexpr

```cpp
constexpr uint32_t fibonacci(uint32_t i)
{
    return (i <= 1u) ? i : (fibonacci(i - 1) + fibonacci(i - 2));
}

constexpr auto fib_5th_term = fibonacci(6); // equal to `auto fib_5th_term = 8`

```

- Constant expressions are expressions evaluated by the compiler at compile-time. In the above case, `fibonacci` the function is executed/evaluated by the compiler at the time of compilation & result will be substituted at calling the place.
- I have written a detailed article on [when to use const vs constexpr in C++](/posts/when-to-use-const-vs-constexpr-in-cpp/).

## Deleted & Defaulted functions

```cpp
struct demo
{
    demo() = default;
};

demo d;
```

- Now you might be wondering that rather than writing 8+ letters(i.e. `= default;`), I could simply use {} i.e. empty constructor. That's true! but think about [copy constructor](/posts/all-about-copy-constructor-in-cpp/), [copy assignment operator](/posts/2-wrong-way-to-learn-copy-assignment-operator-in-c/), etc.
- An empty [copy constructor](/posts/all-about-copy-constructor-in-cpp/), for example, will not do the same as a defaulted c[opy constructor](/posts/all-about-copy-constructor-in-cpp/) (which will perform a member-wise copy of its members).

You can limit certain operation or way of [object instantiation](/posts/inside-the-c-object-model/) by simply deleting the respective method as follows

```cpp
class demo
{
    int m_x;

public:
    demo(int x) : m_x(x){};
    demo(const demo &) = delete;
    demo &operator=(const demo &) = delete;
};

demo obj1{123};
demo obj2 = obj1; // error -- call to deleted copy constructor
obj2 = obj1;      // error -- operator= deleted
```

In older C++ you have to make it private. But now you have `delete` compiler directive.

## Delegating constructors

```cpp
struct demo
{
    int m_var;
    demo(int var) : m_var(var) {}
    demo() : demo(0) {}
};

demo d;
```

- In older C++, you have to create common initialization member function & need to call it from all the constructor to achieve the common initialization.
- But from C++11, now constructors can call other constructors in the same class using an initializer list.

## Lambda expression

```cpp
auto generator = [i = 0]() mutable { return ++i; };
cout << generator() << endl; // 1
cout << generator() << endl; // 2
cout << generator() << endl; // 3
```

- I think this feature no need any introduction & hot favourite among other features.
- Now you can declare functions wherever you want. That too with zero cost performance impact. 
- I wrote a separate article to [learn lambda expression in C++ with example](/posts/learn-lambda-function-in-cpp-with-example/).

## Selection statements with initializer

- In earlier C++, the initializer is either declared before the statement and leaked into the ambient scope, or an explicit scope is used.
- [With C++17, the new form of](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2016/p0305r1.html) [if/switch](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2016/p0305r1.html) can be written more compactly, and the improved scope control makes some erstwhile error-prone constructions a bit more robust:

```cpp
switch (auto STATUS = window.status()) // Declare the object right within selection statement
{
case PASS:// do this
    break;
case FAIL:// do that
    break;
}
```

- How it works

```cpp
{
    auto STATUS = window.status();
    switch (STATUS)
    {
    case PASS: // do this
        break;
    case FAIL: // do that
        break;
    }
}
```

## std::tuple

```cpp
auto employee = std::make_tuple(32, " Vishal Chovatiya", "Bangalore");
cout << std::get<0>(employee) << endl; // 32
cout << std::get<1>(employee) << endl; // "Vishal Chovatiya"
cout << std::get<2>(employee) << endl; // "Bangalore"
```

- Tuples are a fixed-size collection of heterogeneous values. Access the elements of a `std::tuple` by unpacking using `std::tie`, or using `std::get`.
- You can also catch arbitrary & heterogeneous return values as follows:

```cpp
auto get_employee_detail()
{
    // do something . . . 
    return std::make_tuple(32, " Vishal Chovatiya", "Bangalore");
}

string name;
std::tie(std::ignore, name, std::ignore) = get_employee_detail();
```

- Use `std::ignore` as a placeholder for ignored values. In C++17, [structured bindings](https://stackoverflow.com/questions/40673080/stdignore-with-structured-bindings) should be used instead.

## Class template argument deduction

```cpp
std::pair<std::string, int> user = {"M", 25}; // previous
std::pair user = {"M", 25};                   // C++17

std::tuple<std::string, std::string, int> user("M", "Chy", 25); // previous
std::tuple user2("M", "Chy", 25);                               // deduction in action!
```

- Automatic template argument deduction much likes how it's done for functions, but now including class constructors as well.

## Closing words

Here, we have just scratched the surface in terms of [new feature](https://github.com/AnthonyCalandra/modern-cpp-features) & the possibility of its application. There are many things to learn in Modern C++, but still, you can consider this as a good starting point. Modern C++ is not only expanding in terms of syntax but there is lot more other features are also added like unordered containers, threads, regex, Chrono, random number generator/distributor, [exception handling](/posts/7-best-practices-for-exception-handling-in-cpp-with-example/) and many new STL algos(like `all_of()`, `any_of()` and `none_of()`, etc).

Happy Modern C++ Coding...!
