---
title: "What Exactly nullptr Is in C++?"
date: "2019-11-30"
categories: 
  - "cpp"
tags: 
  - "c-11-nullptr"
  - "c-check-nullptr"
  - "c-if-nullptr"
  - "c-nullptr"
  - "c-reference-nullptr"
  - "can-i-convert-nullptr-to-bool"
  - "conversion-to-bool-from-nullptr_t"
  - "cpp-nullptr"
  - "how-is-nullptr-defined"
  - "if-nullptr"
  - "is-null-in-c-equal-to-nullptr-from-c11"
  - "is-nullptr-a-keyword-or-an-instance-of-a-type-stdnullptr_t"
  - "null-nullptr"
  - "null-vs-nullptr-c"
  - "nullptr"
  - "nullptr-cpp"
  - "nullptr-in-c"
  - "nullptr-vs-null"
  - "nullptr_t-is-comparable"
  - "qt-nullptr"
  - "reinterpret_cast-on-nullptr"
  - "return-nullptr-c"
  - "sizeofnullptr_t"
  - "template-argument-is-of-type-stdnullptr_t"
  - "this-was-nullptr-c"
  - "typecasting-on-nullptr_t"
  - "use-cases-of-nullptr"
  - "what-are-the-advantages-of-using-nullptr"
  - "what-exactly-nullptr-is-in-c"
  - "when-was-nullptr-introduced"
featuredImage: "/images/What-exactly-nullptr-is-in-C-vishal-chovatiya.png"
---

The answer to "What exactly nullptr is in C++?" would be a piece of cake for experienced C++ eyes & for those who are aware of [Modern C++](/posts/21-new-features-of-modern-cpp-to-use-in-your-project/) i.e. keyword. But `nullptr` is more than just a keyword in C++ & to explain that, I have written this article. But before jump-into it, we will see issues with `NULL` & then we'll dive into the unsophisticated implementation of  `nullptr` & some use-cases of `nullptr`.

## Why do we need nullptr?

**_To distinguish between an integer 0(zero) i.e. NULL & actual null of type pointer._**

## nullptr vs NULL

- `NULL` is `0`(zero) i.e. **integer constant zero** with [C-style typecast](/posts/cpp-type-casting-with-example-for-c-developers/) to `void*`, while `nullptr` is [prvalue](/posts/lvalue-rvalue-and-their-references-with-example-in-cpp/) of type `nullptr_t` which is **_[integer literal](https://en.cppreference.com/w/cpp/language/integer_literal)_** **_evaluates to zero_**.
- For those of you who believe that `NULL` is same i.e. `(void*)0` in C & C++. I would like to clarify that no it's not:

[NULL - cppreference.com](http://en.cppreference.com/w/c/types/NULL) (C)

[NULL - cppreference.com](http://en.cppreference.com/w/cpp/types/NULL) (C++)

- C++ requires that macro `NULL` to be defined as an integral constant expression having the value of `0`. So unlike in C, `NULL` cannot be defined as `(void *)0` in the C++ standard library.

## Issues with NULL

### **Implicit conversion**

```cpp
char *str = NULL; // Implicit conversion from void * to char *
int i = NULL;     // OK, but `i` is not pointer type
```

### **Function calling ambiguity**

```cpp
void func(int) {}
void func(int*){}
void func(bool){}
 
func(NULL);     // Which one to call?
```

Compilation produces the following error:

```bash
error: call to 'func' is ambiguous
    func(NULL);
    ^~~~
note: candidate function void func(bool){}
                              ^
note: candidate function void func(int*){}
                              ^
note: candidate function void func(int){}
                              ^
1 error generated.
compiler exit status 1
```

### **Constructor overload**

```cpp
struct String
{
    String(uint32_t)    {   /* size of string */    }
    String(const char*) {       /* string */        }
};

String s1( NULL );
String s2( 5 ); 
```

- In such cases, you need explicit cast (i.e., `String s((char*)0)).

## Implementation of unsophisticated nullptr

- `nullptr` is a subtle example of [Return Type Resolver](/posts/7-advanced-cpp-concepts-idiom-examples-you-should-know/#Return-Type-Resolver) idiom to automatically deduce a null pointer of the correct type depending upon the type of the instance it is assigning to.
- Consider the following simplest & unsophisticated `nullptr` implementation:

```cpp
struct nullptr_t 
{
    void operator&() const = delete;  // Can't take address of nullptr

    template<class T>
    inline operator T*() const { return 0; }

    template<class C, class T>
    inline operator T C::*() const { return 0; }
};

nullptr_t nullptr;
```

- If the above code seems strange & weird to you(although it should not), then I would suggest you go through my earlier article on [advanced C++ concepts](/posts/7-advanced-cpp-concepts-idiom-examples-you-should-know/#Return-Type-Resolver). The magic here is just the templatized conversion operator.
- If you are into a more authoritative source, then, here is a [concrete implementation of nullptr from LLVM header](https://github.com/llvm-mirror/libcxx/blob/master/include/__nullptr).

## Use-cases of nullptr

```cpp
struct C { void func(); };

int main(void)
{
    int *ptr = nullptr;                // OK
    void (C::*method_ptr)() = nullptr; // OK

    nullptr_t n1, n2;
    n1 = n2;
    //nullptr_t *null = &n1;           // Address can't be taken.
}
```

- As shown in the above example, when `nullptr` is being assigned to an integer pointer, a `int` type instantiation of the templatized conversion function is created. And same goes for method pointers too.
- This way by leveraging [C++ template](/posts/c-template-a-quick-uptodate-look/) functionality, we are actually creating the appropriate type of null pointer every time we do, a new type assignment.
- As `nullptr` is an [integer literal](https://en.cppreference.com/w/cpp/language/integer_literal) with value zero, you can not able to use its address which we accomplished by deleting & operator.

### Function calling clarity with nullptr

```c
void func(int)   { /* ... */}
void func(int *) { /* ... */}
void func(bool)  { /* ... */}

func(nullptr);
```

- Now, `func( int* ) will be called as `nullptr` will implicitly be deduced to `int*`.

### Typecasting on nullptr\_t

- A cast of `nullptr_t` to an integral type needs a `reinterpret_cast`, and has the same semantics as a cast of `(void*)0` to an integral type.
- Casting `nullptr_t` to an integral type holds true as long as destination type is large enough. Consider this:

```cpp
// int ptr_not_ok = reinterpret_cast<int>(nullptr); // Not OK
long ptr_ok = reinterpret_cast<long long>(nullptr); // OK
```

- A `reinterpret_cast` cannot convert `nullptr_t` to any pointer type. Use `static_cast` instead.

```cpp
void func(int*)    { /*...*/ }
void func(double*) { /*...*/ }

func(nullptr);                            // compilation error, ambiguous call!

// func(reinterpret_cast<int*>(nullptr)); // error: invalid cast from type 'std::nullptr_t' to type 'int*'
func(static_cast<int*>(nullptr));         // OK
```

- `nullptr` is implicitly convertible to any pointer type so explicit conversion with `static_cast` is only valid.

### nullptr\_t is comparable

```cpp
int *ptr = nullptr;
if (ptr == 0);          // OK
if (ptr <= nullptr);    // OK        

int a = 0;
if (a == nullptr);      // error: invalid operands of types 'int' and 'std::nullptr_t' to binary 'operator=='
```

From [Wikipedia article](https://en.wikipedia.org/wiki/C%2B%2B11#Null_pointer_constant):  
- …null pointer constant: `nullptr`. It is of type `nullptr_t`, which is implicitly convertible and comparable to any pointer type or pointer-to-member type.  
- It is not implicitly convertible or comparable to integral types, except for `bool`.

```cpp
const int a = 0;
if (a == nullptr); // OK

const int b = 5;
if (b == nullptr); // error: invalid operands of types 'const int' and 'std::nullptr_t' to binary 'operator=='
```

### Template-argument is of type std::nullptr\_t

```cpp
template <typename T>
void ptr_func(T *t) {}

ptr_func(nullptr);         // Can not deduce T
```

- As discussed earlier, [Return Type Resolver](/posts/7-advanced-cpp-concepts-idiom-examples-you-should-know/#Return-Type-Resolver) needs an assignee to deduce the type.

```cpp
template <typename T>
void val_func(T t) {}

val_func(nullptr);         // deduces T = nullptr_t
val_func((int*)nullptr);   // deduces T = int*, prefer static_cast though
```

### Conversion to bool from nullptr\_t

From [cppreference](https://en.cppreference.com/w/cpp/language/implicit_conversion#Boolean_conversions) :  
- In the context of a [direct-initialization](https://en.cppreference.com/w/cpp/language/direct_initialization), a `bool` object may be initialized from a prvalue of type [`std::nullptr_t`](https://en.cppreference.com/w/cpp/types/nullptr_t), including `nullptr`. The resulting value is false. However, this is not considered to be an implicit conversion.

- The conversion is only allowed for [direct-initialization](http://en.cppreference.com/w/cpp/language/direct_initialization), but not [copy-intialization](http://en.cppreference.com/w/cpp/language/copy_initialization), which including the case for passing an argument to a function by value. e.g.

```cpp
bool b1 = nullptr; // Not OK
bool b2 {nullptr}; // OK

void func(bool){}
 
func(nullptr);     // Not OK, need to do func(static_cast<bool>(nullptr));
```

### Misc

```cpp
typeid(nullptr);                            // OK
throw nullptr;                              // OK
char *ptr = expr ? nullptr : nullptr;       // OK
// char *ptr1 = expr ? 0 : nullptr;         // Not OK, types are not compatible
static_assert(sizeof(NULL) == sizeof(nullptr_t));
```

## Summary by FAQs

**When was `nullptr` introduced?**

C++11

**Is `nullptr` a keyword or an instance of a type `std::nullptr_t`?**

Both `true` and `false` are keywords & literals, as they have a type ( `bool` ). `nullptr` is a _pointer literal_ of type `std::nullptr_t`, & it's a prvalue (i.e. pure [rvalue](/posts/lvalue-rvalue-and-their-references-with-example-in-cpp/), you cannot take the address of it using `&`). [For more](https://stackoverflow.com/questions/1282295/what-exactly-is-nullptr).

**What are the advantages of using nullptr?**

- No function calling ambiguity between overload sets.  
- You can do [template specialization](/posts/c-template-a-quick-uptodate-look/) with `nullptr_t`.  
- Code will become more safe, intuitive & expressive. `if (ptr == nullptr);` rather than `if (ptr == 0);`.

**Is `NULL` in C++ equal to `nullptr` from C++11?**

Not at all. The following line does not even compile:  
  
`cout<<is_same_v<nullptr, NULL><<endl;`

**Can I convert `nullptr` to bool?**

Yes. But only if you [direct-initialization](http://en.cppreference.com/w/cpp/language/direct_initialization). i.e. `bool is_false{nullptr};`. Else need to use `static_cast`.

**How is `nullptr` defined?**

It's just the templatized conversion operator known as [Return Type Resolver](/posts/7-advanced-cpp-concepts-idiom-examples-you-should-know/#Return-Type-Resolver).

What exactly nullptr is in C++?

## References

You can find similar resources [here](https://en.wikibooks.org/wiki/More_C%2B%2B_Idioms/nullptr), [here](https://stackoverflow.com/questions/1282295/what-exactly-is-nullptr/), and in [nullptr proposal(N2431)](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2007/n2431.pdf); however, this post will walk you through the ins and outs of the spec step-by-step in a more friendly way so that you come away with a full understanding of the concept without any needless confusion

