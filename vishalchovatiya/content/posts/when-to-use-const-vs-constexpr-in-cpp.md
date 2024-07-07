---
title: "When to Use const vs constexpr in C++"
date: "2019-09-12"
categories: 
  - "cpp"
tags: 
  - "c-11-constexpr"
  - "c-const-vs-constexpr"
  - "c-constexpr"
  - "c-constexpr-class"
  - "c-constexpr-class-member"
  - "c-constexpr-constructor"
  - "c-constexpr-example"
  - "c-constexpr-function"
  - "c-constexpr-method"
  - "c-if-constexpr"
  - "c-static-constexpr"
  - "compile-time"
  - "const"
  - "const-vs-constexpr"
  - "constexpr"
  - "constexpr-c"
  - "constexpr-class"
  - "constexpr-cpp"
  - "constexpr-visual-studio"
  - "constexpr-vs-const"
  - "expr-c"
  - "static-constexpr"
  - "when-to-use-const-vs-constexpr-in-c"
---

While introducing myself to [Modern C++](/posts/21-new-features-of-modern-cpp-to-use-in-your-project/) & its new features introduced in C++11 & C++14, I have completely neglected this keyword `constexpr`. Initially, I was confused about when to use const vs constexpr in C++ & how this `constexpr` works & differ with `const`. So, I have studied this from different sources & here is the consolidation of it:

### Primitive constexpr Variables

```cpp
int varA = 3;
const int varB = 5;
constexpr int varC = 7;
```

- All of the above variable having a value which is known at compile time. `varA` is a normal scenario while `varB` & `varC` will not take further value or assignment. `varB` & `varC` are fixed at compile time if we have defined them like above.
- But, `varB` is not the right way(in some situation) of declaring the constant value at compile time. For example, if I declare them as follows:

```cpp
int getRandomNo()
{
  return rand() % 10;
}

int main()
{
    const int varB = getRandomNo();       // OK
    constexpr int varC = getRandomNo();   // not OK! compilation error

    return 0;
}
```

- Value of `varB` would not anymore compile time. While statement with `varC` will throw compilation error. **_The reason is constexpr will always accept a strictly compile-time value._**

### constexpr Functions

```cpp
constexpr int sum(int x, int y)
{
    return x + y;
}

int main()
{
    const int result = sum(10, 20);     // Here, you can use constexpr as well
    cout << result;
    return 0;
}
```

- `constexpr` specifies that the value of an object, variable and a function can be evaluated strictly at compile-time. And an expression can use in other constant expressions.

```asm
+--------------------------------+-----------------------------------+
|   int result = sum(10, 20);    |  const int result = sum(10, 20);  |
+--------------------------------+-----------------------------------+
|  main:                         |     main:                         |
|  ....                          |     ....                          |
|  ....                          |     ....                          |
|  ....                          |     ....                          |
|        subl    $20, %esp       |           subl    $20, %esp       |
|        subl    $8, %esp        |           movl    $30, -12(%ebp)  | <-- Direct 
|        pushl   $20             |           subl    $8, %esp        |     result 
|        pushl   $10             |           pushl   $30             |     substitution
|        call    _Z3sumii        |           pushl   $_ZSt4cout      |
|        addl    $16, %esp       |           call    _ZNSolsEi       |
|        movl    %eax, -12(%ebp) |     ....                          |
|        subl    $8, %esp        |     ....                          |
|        pushl   -12(%ebp)       |     ....                          |
|        pushl   $_ZSt4cout      |                                   |
|        call    _ZNSolsEi       |                                   |
|  ....                          |                                   |
|  ....                          |                                   |
|  ....                          |                                   |
+--------------------------------+-----------------------------------+
```

- If you observe above code, you can see that when you catch result as `const` or `constexpr`, call to the function `sum` is not there in assembly rather compiler will execute that function by itself at compile time & substitute the result with function.
- By specifying `constexpr`, we suggest compiler to evaluate the function `sum` at compile time.

### constexpr Constructors

```cpp
class INT
{
    int _no;

public:
    constexpr INT(int no) : _no(no) {}
    constexpr int getInt() const { return _no; }
};
int main()
{
    constexpr INT obj(INT(5).getInt());
    cout << obj.getInt();
    return 0;
}
```

- Above code is simple & self-explanatory. If it isn't to you, then play with it [here](https://godbolt.org/).

### const vs constexpr in C++

- They serve different purposes. `constexpr` is mainly for optimization while `const` is for practically `const` objects like the value of `Pi`.
- `const` & `constexpr` both can be applied to member methods. Member methods are made `const` to make sure that there are no accidental changes by the method. On the other hand, the idea of using `constexpr` is to compute expressions at compile time so that time can be saved when the code is running.
- `const` can only be used with non-static member function whereas `constexpr` can be used with member and non-member functions, even with constructors but with condition that argument and return type must be of literal types. You read about more limitations [here](https://en.cppreference.com/w/cpp/language/constexpr).

### Where to Use What?

- Where you need a value not often & calculating it would be a bit complex, then that is the place you need constexpr. Otherwise, things are fine with an older buddy `const`. For example, Fibonacci number, factorial, etc.

```cpp
constexpr unsigned int factorial(unsigned int n)
{
    return (n <= 1) ? 1 : (n * factorial(n - 1));
}

static constexpr auto magic_value = factorial(5);
```

- Often programmer would suggest using **_constexpr instead of a macro_**.
- Sometimes you have an expression, that evaluated down to a constant, while maintaining good readability and allowing slightly more complex processing than just setting a constant to a number. For example:

```cpp
template< typename Type > 
constexpr Type max( Type a, Type b ) 
{ 
    return a < b ? b : a; 
}
```

Its a pretty simple choice there but it does mean that if you call `max` with constant values, it is explicitly calculated at compile time and not at runtime.

- Another good example is converting units like

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

int main()
{
    cout << 1_KB << endl;
    cout << hex << 1_MB << endl;
}
```

Here you can use `constexpr`.
