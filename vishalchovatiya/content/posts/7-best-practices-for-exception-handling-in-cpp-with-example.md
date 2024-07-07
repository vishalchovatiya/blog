---
title: "C++ Exception Handling Best Practices: 7 Things To Know"
date: "2019-11-03"
categories: 
  - "cpp"
tags: 
  - "best-practices-for-exception-handling-in-c"
  - "best-practices-for-exception-handling-in-c-with-example"
  - "c-exception-example"
  - "c-exception-handling-best-practices"
  - "c-throw-exception-example"
  - "c-try-catch-example"
  - "copy-move-constructor-while-throwing-user-defined-type-object"
  - "cpp-exception-example"
  - "exception-handling-example-in-c"
  - "exception-handling-in-c-example"
  - "exception-handling-in-c-example-programs"
  - "exception-handling-in-c-simple-program"
  - "exception-handling-in-c-using-class"
  - "exception_ptr"
  - "keyword-ideas"
  - "move-semantics-exception-c"
  - "noexcept-operator-what-is-it-used-for"
  - "noexcept-specifier"
  - "noexcept-specifier-vs-operator"
  - "performance-cost-of-exceptions-c"
  - "rethrowing-nested-exceptions"
  - "rethrowing-nested-exceptions-with-stdexception_ptr"
  - "simple-exception-handling-program-in-c"
  - "simple-program-for-exception-handling-in-c"
  - "stdmove_if_noexcept"
  - "throw-c-example"
  - "throw-exception-c-example"
  - "throwing-exception-from-the-constructor"
  - "throwing-exception-from-the-constructor-c"
  - "throwing-exceptions-out-of-a-destructor"
  - "throwing-exceptions-out-of-a-destructor-c"
  - "try-catch-c-syntax"
  - "try-catch-in-c-example"
  - "try-catch-throw-c"
  - "try-catch-throw-c-example"
featuredImage: "/images/exception.jpg"
---

Exception handling in C++ is a well-unschooled topic if you observe initial stages of the learning curve. There are numerous tutorials available online on exception handling in C++. But few explains what you should not do & intricacies around it. So here I am to bridge the gap & show you some intricacies, from where & why you should not throw an exception and C++ exception handling best practices. Along with some newer features introduced for exception handling in [Modern C++](/posts/21-new-features-of-modern-cpp-to-use-in-your-project/) with example.

In the end, we will see the [performance cost of using an exception](#Runtime-cost-of-exceptions-with-quick-benchmark) by a quick benchmark code. Finally, we will close the article with a summary of [Best practices & some C++ Core Guidelines on exception handling](#Best-practices-&-some-CPP-Core-Guidelines-on-exception-handling).

**_Note_**_: I would not cover anything regarding a dynamic exception as it deprecated from C++11 and removed in C++17._

## Terminology/Jargon/Idiom You May Face

- **potentially throwing**: may or may not throw an exception.
- **noexcept**: this is specifier as well as operator depending upon where & how you use it. Will see that [later](#noexcept-specifier-vs-operator).
- **[RAII](/posts/7-advanced-cpp-programming-styles-and-idiom-examples-you-should-know/#RAII)**: **R**esource **A**cquisition **I**s **I**nitialization is a scope-bound resource management mechanism. Which means resource allocation done with the constructor & resource deallocation with the destructor during the defined scope of the object. I know it's a terrible name but very powerful concept.
- **[Implicitly-declared special member functions](https://stackoverflow.com/questions/11671282/implicitly-declared-special-member-functions)**: I think this need not require any introduction.

## 1\. Implement Copy And/Or Move Constructor While Throwing User-Defined Type Object

```cpp
struct demo
{
    demo() = default;
    demo(demo &&) = delete;
    demo(const demo &) = delete;
};

int main()
{
    throw demo{};
    return 0;
}
```

- Upon throw expression, a copy of the exception object created as the original object goes out of the scope during the stack unwinding process.
- During that initialization, we may expect [copy elision](https://en.wikipedia.org/wiki/Copy_elision) (see [this](https://wg21.cmeerw.net/cwg/issue1493)) – omits [copy or move constructors](/posts/move-constructor-assignment-operator-with-shared-ptr/) (object constructed directly into the storage of the target object).
- But even though copy elision may or may not apply you should provide proper copy constructor and/or move constructor which is what [C++ standard mandates(see 15.1)](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2014/n4296.pdf). See below compilation error for reference.

```bash
error: call to deleted constructor of 'demo'
    throw demo{};
          ^~~~~~
note: 'demo' has been explicitly marked deleted here
    demo(demo &&) = delete;
    ^
1 error generated.
compiler exit status 1
```

- Above error stands true till C++14. Since C++17, If the thrown object is a prvalue, the copy/move elision is guaranteed.
- If we catch an exception by value, we may also expect copy elision(compilers permitted to do so, but it is not mandatory). The exception object is an lvalue argument when initializing catch clause parameters.

**TL;DR**  
class used for throwing the exception object needs copy and/or move constructors

## 2\. Be Cautious While Throwing an Exception From the Constructor

```cpp
struct base
{
    base(){cout<<"base\n";}
    ~base(){cout<<"~base\n";}
};

struct derive : base
{
    derive(){cout<<"derive\n"; throw -1;}
    ~derive(){cout<<"~derive\n";}
};

int main()
{
    try{
        derive{};
    }
    catch (...){}
    return 0;
}
```

- When an exception is thrown from a constructor, stack unwinding begins, destructors for the object will only be called, if an object creation is successful. So be caution with dynamic memory allocation here. In such cases, you should use [RAII](/posts/7-advanced-cpp-programming-styles-and-idiom-examples-you-should-know/#RAII).

```
base
derive
~base
```

- As you can see in the above case, the destructor of `derive` is not executed, Because, it is not created successfully.

```cpp
struct base
{
    base() { cout << "base\n"; }
    ~base() { cout << "~base\n"; }
};

struct derive : base
{
    derive() = default;
    derive(int) : derive{}
    {
        cout << "derive\n";
        throw - 1;
    }
    ~derive() { cout << "~derive\n"; }
};

int main()
{
    try{
        derive{0};
    }
    catch (...){}
    return 0;
}
```

- In the case of constructor delegation, it is considered as the creation of object hence destructor of `derive` will be called.

```
base
derive
~derive
~base
```

**TL;DR**  
When an exception is thrown from a constructor, destructors for the object will be called only & only if an object is created successfully

## 3\. Avoid Throwing Exceptions out of a Destructor

```cpp
struct demo
{
    ~demo() { throw std::exception{}; }
};

int main()
{
    try{
        demo d;
    }
    catch (const std::exception &){}
    return 0;
}
```

- Above code seems straight forward but when you run it, it terminates as shown below rather than catching the exception. Reason for this is destructors are by default `noexcept` (i.e. non-throwing)

```bash
$ clang++-7 -o main main.cpp
warning: '~demo' has a non-throwing exception specification but can still
      throw [-Wexceptions]
    ~demo() { throw std::exception{}; }
              ^
note: destructor has a implicit non-throwing exception specification
    ~demo() { throw std::exception{}; }
    ^
1 warning generated.
$
$ ./main
terminate called after throwing an instance of 'std::exception'
  what():  std::exception
exited, aborted
```

- `noexcept(false) will solve our problem as below

```cpp
struct X
{
    ~X() noexcept(false) { throw std::exception{}; } 
};
```

- But don’t do it. Destructors are by default non-throwing for a reason, and we must not throw exceptions in destructors unless we catch them inside the destructor.

**Why you should not throw an exception from a destructor?**

Because destructors are called during stack unwinding when an exception is thrown, and we are not allowed to throw another exception while the previous one is not caught – in such a case `std::terminate` will be called.

- Consider the following example for more clarity.

```cpp
struct base
{
    ~base() noexcept(false) { throw 1; }
};

struct derive : base
{
    ~derive() noexcept(false) { throw 2; }
};

int main()
{
    try{
        derive d;
    }
    catch (...){ }
    return 0;
}
```

- An exception will be thrown when the object `d` will be destroyed as a result of [RAII](/posts/7-advanced-cpp-programming-styles-and-idiom-examples-you-should-know/#RAII). But at the same time destructor of `base` will also be called as it is [sub-object](/posts/memory-layout-of-cpp-object/) of `derive` which will again throw an exception. Now we have two exceptions at the same time which is invalid scenario & `std::terminate` will be called.

There are some type trait utilities like `std::is_nothrow_destructible`, `std::is_nothrow_constructible`, etc. from `#include<type_traits>` by which you can check whether the special member functions are exception-safe or not.

```cpp
int main()
{
    cout << std::boolalpha << std::is_nothrow_destructible<std::string>::value << endl;
    cout << std::boolalpha << std::is_nothrow_constructible<std::string>::value << endl;
    return 0;
}
```

**TL;DR**  
1\. Destructors are by default `noexcept` (i.e. non-throwing).  
2\. You should not throw exception out of destructors because destructors are called during stack unwinding when an exception is thrown, and we are not allowed to throw another exception while the previous one is not caught – in such a case `std::terminate` will be called.

## 4\. Nested Exception Handling Best Practice With std::exception\_ptr( C++11) Example

This is more of a demonstration rather the best practice of the nested exception scenario using `std::exception_ptr`. Although you can simply use `std::exception` without complicating things much but `std::exception_ptr` will provide us with the leverage of handling exception out of `try` / `catch` clause.

```cpp
void print_nested_exception(const std::exception_ptr &eptr=std::current_exception(), size_t level=0)
{
    static auto get_nested = [](auto &e) -> std::exception_ptr {
        try { return dynamic_cast<const std::nested_exception &>(e).nested_ptr(); }
        catch (const std::bad_cast&) { return nullptr; }
    };

    try{
        if (eptr) std::rethrow_exception(eptr);
    }
    catch (const std::exception &e){
        std::cerr << std::string(level, ' ') << "exception: " << e.what() << '\n';
        print_nested_exception(get_nested(e), level + 1);// rewind all nested exception
    }
}
// -----------------------------------------------------------------------------------------------
void func2(){
    try         { throw std::runtime_error("TESTING NESTED EXCEPTION SUCCESS"); }
    catch (...) { std::throw_with_nested(std::runtime_error("func2() failed")); }
}

void func1(){
    try         { func2(); }
    catch (...) { std::throw_with_nested(std::runtime_error("func1() failed")); }
}

int main()
{
    try                             { func1(); }
    catch (const std::exception&)   { print_nested_exception(); }
    return 0;
}
// Will only work with C++14 or above
```

- Above example looks complicated at first, but once you have implemented nested exception handler(i.e. `print_nested_exception`). Then you only need to focus on throwing the exception using `std::throw_with_nested` function.

```bash
exception: func1() failed
 exception: func2() failed
  exception: TESTING NESTED EXCEPTION SUCCESS
```

- The main thing to focus here is `print_nested_exception` function in which we are rewinding nested exception using `std::rethrow_exception` & `std::exception_ptr`.
- `std::exception_ptr` is a [shared pointer](/posts/move-constructor-assignment-operator-with-shared-ptr) like type though dereferencing it is undefined behaviour. It can hold [nullptr](/posts/what-exactly-nullptr-is-in-cpp/) or point to an exception object and can be constructed as:

```cpp
std::exception_ptr e1;                                             // null
std::exception_ptr e2 = std::current_exception();                  // null or a current exception
std::exception_ptr e3 = std::make_exception_ptr(std::exception{}); // std::exception
```

- Once `std::exception_ptr` is created, we can use it to throw or re-throw exceptions by calling `std::rethrow_exception(exception_ptr) as we did above, which throws the pointed exception object.

**TL;DR**  
1\. `std::exception_ptr` extends the lifetime of a pointed exception object beyond a catch clause.  
2\. We may use `std::exception_ptr` to delay the handling of a current exception and transfer it to some other palaces. Though, practical usecase of `std::exception_ptr` is between threads.

## 5\. Use noexcept \`Specifier\` vs \`Operator\` Appropriately

- I think this is an oblivious concept among the other concepts of the C++ exceptions.
- `noexcept` [specifier](https://en.cppreference.com/w/cpp/language/noexcept_spec) & [operator](https://en.cppreference.com/w/cpp/language/noexcept) came in C++11 to replace deprecated(removed from C++17) dynamic exception specification.

```cpp
void func() throw(std::exception);                   // dynamic excpetions, removed from C++17

void potentially_throwing();                         // may throw
void non_throwing() noexcept;                        // "specifier" specifying non-throwing function

void print() {}                                  
void (*func_ptr)() noexcept = print;                 // Not OK from C++17, `print()`should be noexcept too, works in C++11/14

void debug_deep() noexcept(false) {}                 // specifier specifying throw
void debug() noexcept(noexcept(debug_deep())) {}     // specifier & operator, will follow exception rule of `debug_deep`

auto l_non_throwing = []() noexcept {};              // Yeah..! lambdas are also in party
```

### noexcept Specifier

I think this needs no introduction it does what its name suggests. So let's quickly go through some pointers:

- Can use for normal functions, methods, [lambda functions](/posts/learn-lambda-function-in-cpp-with-example/) & function pointer.
- From C++17, function pointer with noexcept can not points to potentially throwing function.
- Finally, don’t use `noexcept` specifier for [virtual functions](/posts/part-1-all-about-virtual-keyword-in-cpp-how-virtual-function-works-internally/) in a base class/interface because it enforces restriction for all overrides.
- Don’t use noexcept unless you really need it. "Specify it when it is useful and correct" - [Google’s cppguide](https://google.github.io/styleguide/cppguide.html#noexcept).

### noexcept Operator & What Is It Use For?

- Added in C++11, `noexcept` operator takes an expression (not necessarily constant) and performs a compile-time check determining if that expression is non-throwing (`noexcept`) or potentially throwing.
- The result of such compile-time check can be used, for example, to add `noexcept`specifier to the same category, higher-level function `(noexcept(noexcept(expr))) or in if [constexpr](/posts/when-to-use-const-vs-constexpr-in-cpp/).
- We can use noexcept operator to check if some class has noexcept constructor, noexcept copy constructor, noexcept move constructor, and so on as follows:

```cpp
class demo
{
public:
    demo() {}
    demo(const demo &) {}
    demo(demo &&) {}
    void method() {}
};

int main()
{
    cout << std::boolalpha << noexcept(demo()) << endl;                        // C
    cout << std::boolalpha << noexcept(demo(demo())) << endl;                  // CC
    cout << std::boolalpha << noexcept(demo(std::declval<demo>())) << endl;    // MC
    cout << std::boolalpha << noexcept(std::declval<demo>().method()) << endl; // Methods
}
// std::declval<T> returns an rvalue reference to a type
```

- You must be wondering why & how this information will be useful?  
    This is more useful when you are using library functions inside your function to suggest compiler that your function is throwing or non-throwing depending upon library implementation.
- If you remove constructor, [copy constructor](/posts/all-about-copy-constructor-in-cpp/) & [move constructor](/posts/move-constructor-assignment-operator-with-shared-ptr/), it will print `true` reason being implicitly-declared special member functions are always non-throwing.

**TL;DR**  
`noexcept` specifier & operator are two different things. `noexcept` operator performs a compile-time check & doesn’t evaluate the expression. While `noexcept` specifier can take only constant expressions that evaluate to either true or false.

## 6\. Move Exception-Safe with std::move\_if\_noexcept

```cpp
struct demo
{
    demo() = default;
    demo(const demo &) { cout << "Copying\n"; }
    // Exception safe move constructor
    demo(demo &&) noexcept { cout << "Moving\n"; }
private:
    std::vector<int>    m_v;
};

int main()
{
    demo obj1;

    if (noexcept(demo(std::declval<demo>()))){  // if moving safe
        demo obj2(std::move(obj1));             // then move it
    }
    else{
        demo obj2(obj1);                        // otherwise copy it
    }

    demo obj3(std::move_if_noexcept(obj1));     // Alternatively you can do this----------------
    return 0;
}
```

- We can use `noexcept(T(std::declval<T>()`) to check if `T`’s move constructor exists and is `noexcept` in order to decide if we want to create an instance of `T` by moving another instance of `T` (using `std::move`).
- Alternatively, we can use `std::move_if_noexcept`, which uses `noexcept` operator and casts to either [rvalue or lvalue](/posts/lvalue-rvalue-and-their-references-with-example-in-cpp/). Such checks are used in `std::vector` and other containers.
- This will be useful while you are processing critical data which you don't want to lose. For example, we have critical data received from the server that we do not want to lose it at any cost while processing. In such a case, we should use `std::move_if_noexcept` which will move ownership of critical data only and only if move constructor is exception-safe.

**TL;DR**  
Move critical object safely with `std::move_if_noexcept`

## 7\. Real Cost of C++ Exception Handling With Benchmark

Despite many benefits, most people still do not prefer to use exceptions due to its overhead. So let's clear it out of the way:

```cpp
static void without_exception(benchmark::State &state){
    for (auto _ : state){
        std::vector<uint32_t> v(10000);
        for (uint32_t i = 0; i < 10000; i++) v.at(i) = i;        
    }
}
BENCHMARK(without_exception);//----------------------------------------

static void with_exception(benchmark::State &state){
    for (auto _ : state){
        std::vector<uint32_t> v(10000);
        for (uint32_t i = 0; i < 10000; i++){
            try{
                v.at(i) = i;
            }
            catch (const std::out_of_range &oor){}
        }
    }
}
BENCHMARK(with_exception);//--------------------------------------------

static void throwing_exception(benchmark::State &state){
    for (auto _ : state){
        std::vector<uint32_t> v(10000);
        for (uint32_t i = 1; i < 10001; i++){
            try{
                v.at(i) = i;
            }
            catch (const std::out_of_range &oor){}
        }
    }
}
BENCHMARK(throwing_exception);//-----------------------------------------
```

- As you can see above, `with_exception` & `without_exception` has only a single difference i.e. exception syntax. But none of them throws any exceptions.
- While `throwing_exception` does the same task except it throws an exception of type `std::out_of_range` in the last iteration.
- As you can see in below bar graph, the last bar is slightly high as compared to the previous two which shows the cost of throwing an exception.
- But the **cost of using exception is zero** here, as the previous two bars are identical.
- I am not considering the optimization here which is the separate case as it trims some of the assembly instructions completely. Also, implementation of compiler & ABI plays a crucial role. But still, it is far better than losing time by setting up a guard(`if(error) strategy) and explicitly checking for the presence of error everywhere.
- While in case of exception, the compiler generates a side table that maps any point that may throw an exception (program counter) to the list of handlers. When an exception is thrown, this list consults to pick the right handler (if any) and the stack unwound. See [this](https://monoinfinito.wordpress.com/series/exception-handling-in-c/) for in-depth knowledge.
- By the way, I am using a [quick benchmark](http://quick-bench.com/qgpMiwVmHomfDmoLsPkb_i-Qw7M) & which internally uses [Google Benchmark](https://github.com/google/benchmark), if you want to explore more.

![](/images/C-exception-bench-mark-without-optimization-1.png)

- First and foremost, remember that using `try` and `catch` doesn't actually decrease performance unless an exception is thrown.
- It's "zero cost" exception handling; no instruction related to exception handling executes until one is thrown.
- But, at the same time, it contributes to the size of executable due to unwinding routines, which may be important to consider for embedded systems.

**TL;DR**  
No instruction related to exception handling is executed until one is thrown so using `try` / `catch` doesn't actually decrease performance.

## Best Practices & Some C++ Core Guidelines on Exception Handling

C++ Exception Handling Best Practices

- **Ideally, you should not throw an exception from the destructor, move constructor or [swap](https://en.wikibooks.org/wiki/More_C%2B%2B_Idioms/Non-throwing_swap) like functions.**
    
- **Prefer [RAII](/posts/7-advanced-cpp-programming-styles-and-idiom-examples-you-should-know/#RAII) idiom for the exception safety because in case of exception you might be left with**
    
    \- data in an invalid state, i.e. data that cannot be further read & used;  
    \- leaked resources such as memory, files, ids, or anything else that needs to be allocated and released;  
    \- corrupted memory;  
    \- broken invariants, e.g. size function returns more elements than actually held in a container.
    
- **Avoid using [raw](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Res-new) [new](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Res-new) [&](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Res-new) [delete](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Res-new). Use solutions from the standard library, e.g. [std::unique_pointer](/posts/understanding-unique-ptr-with-example-in-cpp11/), `std::make_unique`, `std::fstream`, `std::lock_guard`, etc.**
    
- **Moreover, it is useful to split your code into modifying and non-modifying parts, where only the non-modifying part can throw exceptions.**
    
- **Never throw exceptions while owing some resource.**
    

**Some CPP Core Guidelines**

- [E.1: Develop an error-handling strategy early in a design](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Re-design)
- [E.3: Use exceptions for error handling only](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Re-errors)
- [E.6: Use RAII to prevent leaks](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Re-raii)
- [E.13: Never throw while being the direct owner of an object](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Re-never-throw)
- [E.16: Destructors, deallocation, and](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Re-never-fail) [swap](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Re-never-fail) [must never fail](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Re-never-fail)
- [E.17: Don’t try to catch every exception in every function](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Re-not-always)
- [E.18: Minimize the use of explicit](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Re-catch) [try](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Re-catch)[/](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Re-catch)[catch](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Re-catch)
- [26: If you can’t throw exceptions, consider failing fast](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Re-no-throw-crash)
- [E.31: Properly order your](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Re_catch) [catch](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Re_catch)[\-clauses](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Re_catch)
