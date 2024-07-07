---
title: "Variadic Template C++: Implementing Unsophisticated Tuple"
date: "2020-05-17"
categories: 
  - "cpp"
tags: 
  - "c-11-variadic-templates"
  - "c-forward-variadic-arguments"
  - "c-iterate-over-parameter-pack"
  - "c-tuple-comparison"
  - "c-tuple-example"
  - "c-variadic-function"
  - "c-expansion-statements"
  - "c-how-does-variadic-class-template-works"
  - "c-implementing-std-get-function-for-tuple-class"
  - "c-implementing-tuple-class"
  - "c-iterate-over-tuple-elements-in-c"
  - "c-iterate-variadic-template"
  - "c-named-tuple"
  - "c-parameter-pack"
  - "c-process-a-parameter-pack-with-fold-expression"
  - "c-process-a-parameter-pack-with-recursion"
  - "c-return-tuple"
  - "c-template"
  - "c-template-variable-number-of-arguments"
  - "c-template-variadic-arguments"
  - "c-tuple-get"
  - "c-tuple-implementation"
  - "c-tuple-implementation-example"
  - "c-vararg"
  - "c-variadic"
  - "c-variadic-arguments"
  - "c-variadic-class-template"
  - "c-variadic-constructor"
  - "c-variadic-function-2"
  - "c-variadic-function-template"
  - "c-variadic-parameters"
  - "c-variadic-template-class"
  - "c-variadic-template-example"
  - "c-variadic-template-function"
  - "c-variadic-template-printf"
  - "c-variadic-template-vs-fold-expression"
  - "c-variadic-templates"
  - "c-variadic-templates-unpack"
  - "c11-loop-through-tuple-elements"
  - "c17-loop-through-tuple-elements"
  - "c23-loop-through-tuple-elements"
  - "introduction-to-c-variadic-template"
  - "learning-variadic-template-c"
  - "process-c-parameter-pack"
  - "sizeof-parameter-pack"
  - "std-make-tuple"
  - "stdtuple-size"
  - "tuple-is-not-a-member-of-std"
  - "variadic-templates-c-example"
  - "variadic-templates-c17"
  - "variadic-templates-example"
cover:
    image: /images/Cpp-Template-Vishal-Chovatiya.webp
---

From C++11, [`std::tuple`](https://en.cppreference.com/w/cpp/utility/tuple) is an incredible expansion to [Modern C++](/posts/21-new-features-of-modern-cpp-to-use-in-your-project/), that offers a fixed-size col­lec­tion of het­ero­ge­neous values. Un­for­tu­nately, tu­ples can be somewhat dubious to manage in a conventional fash­ion. But, subsequently released C++ stan­dard in­tro­duced a few fea­tures & helpers that greatly re­duce the nec­es­sary boil­er­plate. So, in this article, I will explain the variadic template in C++ with the help of unsophisticated tuple implementation. And also walks you through a tricky part of tuple i.e. loop through tuple element. In spite of the fact that I have shrouded the variadic template in my prior article i.e. [C++ Template: A Quick UpToDate Look](/posts/cpp-template-a-quick-uptodate-look/). So, my focus here would be a blend of variadic template & tuple implementation with more up to date C++ gauges.

## Motivation

- It is often useful to define class/struct/union/function that accepts a variable number and type of arguments.
- If you have already used C you'll know that `printf` function can accept any number of arguments. Such functions are entirely implemented through macros or [ellipses operator](https://stackoverflow.com/questions/3792761/what-is-ellipsis-operator-in-c). And because of that it has several disadvantages like [type-safety](/posts/cpp-type-casting-with-example-for-c-developers/), cannot accept references as arguments, etc.

## Variadic Class Template: Implementing Tuple Class

- So, let's build our own [ADT](https://en.wikipedia.org/wiki/Abstract_data_type) same as `` [`std::tuple`](https://en.cppreference.com/w/cpp/utility/tuple) `` with the help of variadic template.
- The variadic template in C++ usually starts with the general (empty) definition, that also serves as the base-case for template recursion termination in the later specialisation:

```cpp
template <typename... T>
struct Tuple { };
```

- This already allows us to define an empty structure i.e. `Tuple<> object;`, albeit that isn't very useful yet. Next comes the recursive case specialisation:

```cpp
template<
            typename T, 
            typename... Rest    // Template parameter pack
        >
struct Tuple<T, Rest...> {      // Class parameter pack
    T first;
    Tuple<Rest...> rest;        // Parameter pack expansion

    Tuple(const T& f, const Rest& ... r)
        : first(f)
        , rest(r...) {
    }
};

Tuple<bool>                 t1(false);           // Case 1
Tuple<int, char, string>    t2(1, 'a', "ABC");   // Case 2
```

### How Does Variadic Class Template Works?

To understand variadic class template, consider use case 2 above i.e. `Tuple<int, char, string> t2(1, 'a', "ABC");`

- The declaration first matches against the specialization, yielding a structure with `int first;` and `Tuple<char, string> rest;` data members.
- The rest definition again matches with specialization, yielding a structure with `char first;` and `Tuple<string> rest;` data members.
- The rest definition again matches this specialization, creating its own `string first;` and `Tuple<> rest;` members.
- Finally, this last rest matches against the base-case definition, producing an empty structure.

You can visualize this as follows:

```bash
Tuple<int, char, string>
-> int first
-> Tuple<char, string> rest
    -> char first
    -> Tuple<string> rest
        -> string first
        -> Tuple<> rest
            -> (empty)
```

## Variadic Function Template: Implementing get<>() Function for Tuple Class

- So far we have designed data structure with variable number and type of data members. But still, it isn't useful as there is no mechanism to retrieve data from our Tuple class. So let's design one:

```cpp
template<
            size_t idx, 
            template <typename...> class Tuple, 
            typename... Args
        >
auto get(Tuple<Args...> &t) {
    return GetHelper<idx, Tuple<Args...>>::get(t);
}
```

- As you can see this get function is templatized on the `idx`. So usage can be like `get<1>(t)`, similar to [`std::tuple`](https://en.cppreference.com/w/cpp/utility/tuple). Though, the actual work is done by a static function in a helper class i.e. `GetHelper`.
- Note also the use of a C++14-style `auto` return type that makes our lives significantly simpler as otherwise, we would need quite a complicated expression for the return type.
- So on to the helper class. This time we will need an empty forward declaration and two specializations. First the empty declaration:

```cpp
template<
            size_t idx, 
            typename T
        >
struct GetHelper;
```

- Now the base-case (when `idx==0`). In this specialisation, we just return the first member:

```cpp
template<
            typename T, 
            typename... Rest
        >
struct GetHelper<0, Tuple<T, Rest...>> {
    static T get(Tuple<T, Rest...> &data) {
        return data.first;
    }
};
```

- In the recursive case, we decrement `idx` and invoke the `GetHelper` for the rest member:

```cpp
template<
            size_t idx, 
            typename T, 
            typename... Rest
        >
struct GetHelper<idx, Tuple<T, Rest...>> {
    static auto get(Tuple<T, Rest...> &data) {
        return GetHelper<idx - 1, Tuple<Rest...>>::get(data.rest);
    }
};
```

- To work through an example, suppose we have Tuple data and we need `get<1>(data).
- This invokes `GetHelper<1, Tuple<T, Rest...>>>::get(data) (the 2nd specialization).
- Which in turn invokes `GetHelper<0, Tuple<T, Rest...>>>::get(data.rest).
- And finally returns (by the 1st specialization as now `idx` is 0) `data.rest.first`.

So that's it! Here is the whole functioning code, with some example use in the main function:

```cpp
// Forward Declaration & Base Case -----------------------------------------
template<
            size_t idx,
            typename T
        >
struct GetHelper { };

template <typename... T>
struct Tuple { };
// -------------------------------------------------------------------------

// GetHelper ---------------------------------------------------------------
template<
            typename T,
            typename... Rest
        >
struct GetHelper<0, Tuple<T, Rest...>> { // Specialization for index 0
    static T get(Tuple<T, Rest...> &data) {
        return data.first;
    }
};

template<
            size_t idx,
            typename T,
            typename... Rest
        >
struct GetHelper<idx, Tuple<T, Rest...>> { // GetHelper Implementation
    static auto get(Tuple<T, Rest...> &data) {
        return GetHelper<idx - 1, Tuple<Rest...>>::get(data.rest);
    }
};
// -------------------------------------------------------------------------

// Tuple Implementation ----------------------------------------------------
template<
            typename T,
            typename... Rest
        >
struct Tuple<T, Rest...> {
    T                   first;
    Tuple<Rest...>      rest;

    Tuple(const T &f, const Rest &... r)
        : first(f)
        , rest(r...) {
    }
};
// -------------------------------------------------------------------------


// get Implementation ------------------------------------------------------
template<
            size_t idx, 
            template <typename...> class Tuple, 
            typename... Args
        >
auto get(Tuple<Args...> &t) {
    return GetHelper<idx, Tuple<Args...>>::get(t);
}
// -------------------------------------------------------------------------


int main() {
    Tuple<int, char, string> t(500, 'a', "ABC");
    cout << get<1>(t) << endl;
    return 0;
}
```

## Variadic Template vs Fold Expression

- There is two way to process C++ parameter pack i.e.
    1. Recursion
    2. Fold Expression(From C++17)
- At whatever point conceivable, we should process a parameter pack with fold expression instead of using recursion. Because it has some benefits as:
    - Less code to write
    - Faster code (without optimizations), as you just have a single expression instead of multiple function calls
    - Faster to compile, as you deal with fewer template instantiation

### Processing a Parameter Pack With Recursion

- As we have seen earlier, variadic template starts with empty definition i.e. base case for recursion.

```cpp
void print() {}
```

- Then the recursive case specialisation:

```cpp
template<   
            typename First, 
            typename... Rest                    // Template parameter pack
        >     
void print(First first, Rest... rest) {         // Function parameter pack
    cout << first << endl;
    print(rest...);                             // Parameter pack expansion
} 
```

- This is now sufficient for us to use the print function with variable number and type of arguments. For example:

```cpp
print(500, 'a', "ABC");
```

### Processing a Parameter Pack With Fold Expression

```cpp
template <typename... Args>
void print(Args... args) {
    (void(cout << args << endl), ...);
}
```

- See, no cryptic boilerplate required. Isn’t this solution looks neater?
- There are total 3 types of folding: Unary fold, Binary fold & Fold over a comma. Here we have done left folding over a comma. You can read more about Fold Expression [here](https://www.codingame.com/playgrounds/2205/7-features-of-c17-that-will-simplify-your-code/fold-expressions).

## Loop-Through/Iterate Over Tuple Elements in C++

- If I give you a task to print the elements of tuple, the first thing that comes to your mind is:

```cpp
template <typename... Args>
void print(const std::tuple<Args...> &t) {
    for (const auto &elem : t) // Error: no begin/end iterator
        cout << elem << endl;
}
```

- But, this just can't work. [`std::tuple`](https://en.cppreference.com/w/cpp/utility/tuple) doesn't have `begin` & `end` iterator.
- OK! So, now you might try raw loop right?

```cpp
template <typename... Args>
void print(const std::tuple<Args...>&   t) {
    for (int i = 0; i < sizeof...(Args); ++i)
        cout << std::get<i>(t) << endl;    // Error :( , `i` needs to be compile time constant
}
```

- No! you can't. I know that `std::get<>` works with a number as [non-type template argument](/posts/cpp-template-a-quick-uptodate-look/#Non-Type_Template_Parameter).
- But, that number has to be compile-time constant to make this working. So there are many solutions & we will go through quite enough ones.

### C++11: Loop Through Tuple Elements

```cpp
// Template recursion
template <size_t i, typename... Args>
struct printer  {
    static void print(const tuple<Args...> &t) {
        cout << get<i>(t) << endl;
        printer<i + 1, Args...>::print(t);
    }
};

// Terminating template specialisation
template <typename... Args>
struct printer<sizeof...(Args), Args...> {
    static void print(const tuple<Args...> &) {}
};

template <typename... Args>
void print(const tuple<Args...> &t) {
    printer<0, Args...>::print(t);
}

tuple<int, char, string> t(1, 'A', "ABC");
print(t);
// Note: might not work in GCC, I've used clang
```

- This isn't that complicated as it looks, believe me. If you know recursion & template specialisation, it won't take you more than 30 seconds to figure out what's going on here.
- For our example `tuple<int, char, string> t(1, 'A', "ABC");`, `printer::print()`calls template recursion i,e, `template<size_t i, typename… Args> struct printer{};` each time with incremented non-type template parameter `i`. And when `i == sizeof…(Args)`, our recusion stops by calling template specialization i.e. `template<typename… Args> struct printer<sizeof…(Args), Args…> { };`.

### C++17: Loop Through Tuple Elements

- With C++ 17, it's slightly better because we have Fold Expressions. So, we don't need recursion any more.

```cpp
template <typename... Args>
void print(const std::tuple<Args...> &t) {
    std::apply([](const auto &... args) {
        ((cout << args << endl), ...);
    }, t);
}
```

- [`std::apply`](https://en.cppreference.com/w/cpp/utility/apply) designed as tuple helper that accepts functor or [lambda expression](/posts/learn-lambda-function-in-cpp-with-example/). Though you can do better if wants to dispatch to different implementation according to type, you might use `overloaded` class as:

```cpp
template <class... Ts>
struct overloaded : Ts... {
    using Ts::operator()...;
};

// Deduction guide, google `CTAD for aggregates` for more info
template <class... Ts>
overloaded(Ts...) -> overloaded<Ts...>;   // not needed from C++20

auto f = overloaded {
    [](const int &a)        { cout << "From int: " << a << endl; },
    [](const char &b)       { cout << "From char: " << b << endl; },
    [](const string &c)     { cout << "From string: " << c << endl; },
};

tuple<int, char, string>    t(1, 'A', "ABC");
std::apply([&](const auto &... e) { (f(e), ...); }, t);
```

### C++23: Loop Through Tuple Elements

```cpp
template <typename... Args>
void print(const std::tuple<Args...> &t) {
    for... (const auto &elem : t)
        cout << elem << endl;
}

```

- So, from C++23 we might have [expansion statement](http://wg21.link/p1306) i.e. `for...()` That looks like a loop, though it isn't. It just stencil out each call with scope as:

```cpp
template <typename... Args>
void print(const tuple<Args...> &t) {
    {
        const auto &elem = get<0>(t);
        cout << elem << endl;
    }
    {
        const auto &elem = get<1>(t);
        cout << elem << endl;
    }
    {
        const auto &elem = get<2>(t);
        cout << elem << endl;
    }
}
```

- And it is obvious that there is no `break` & `continue` as it isn't loop.
- It basically works for every standard container which can access by `std::get<>()` For example, a plain array, `std::tuple`, `std::pair`, `std::array`, unexpanded argument packs, constexpr ranges, etc.

## Closing Words

There are still many things missing in our tuple class like [copy constructor](/posts/all-about-copy-constructor-in-cpp-with-example/), [move constructors](/posts/move-constructor-assignment-operator-with-shared-ptr/), some operators and helper classes(like [`std::tuple_size`](https://en.cppreference.com/w/cpp/utility/tuple/tuple_size)). But I hope now you get the idea of how it can be implemented using the variadic template. By the way, implementing those missing things will be a good start for learning variadic template on your own.
