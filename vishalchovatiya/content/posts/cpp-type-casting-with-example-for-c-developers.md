---
title: "C++ Type Casting With Example for C Developers"
date: "2019-09-12"
categories: 
  - "cpp"
tags: 
  - "c-style-casts"
  - "const_cast"
  - "dynamic_cast"
  - "implicit-conversion-c"
  - "reinterpret_cast"
  - "static_cast"
  - "why-do-we-need-typecasting"
cover:
    image: /images/C-type-casting-with-example-for-C-developers.png
---

The typecasting is the feature which makes C++ more type-safe, robust & may convince you to use it over C. But this is also a more underrated topic when you are a newbie or moving from C background. Hence, I come up with an article on it. Here, we will not only see the C++ type casting with example but we will also cover [Why do we need typecasting?](#Why-do-we-need-typecasting) & [C++ type casting cheat codes for C developers](#Cheat-code-for-C-developers-moving-to-C++-on-type-casting) to remember & employ it easily. Although I am not an expert but this is what I have learned so far from various sources & 5+ yrs of industry experience.

In C++, there are 5 different types of casts: C-style casts, `static_cast`, `const_cast`, `dynamic_cast`, and `reinterpret_cast`.

I usually start with "Why do we need it?", but this time first we quickly go through some jargons & I will end this article with [some of CPP core guidelines on typecasting](#Some-of-the-C++-core-guidelines-on-typecasting).

### Jargons You Need to Face

1. **Implicit conversion:** where the compiler automatically typecast. Like `float f = 3;`, here compiler will not complain but directly transform `3` which is of type integer into `float` & assign to `f`.
2. **Explicit conversions**: where the developer uses a casting operator to direct the conversion. All types of manual casting fall under the explicit type conversions category. Like `int * p = (int*)std::malloc(10);`, here we explicitly casting `void*` to `int*`.
3. **`l-value`**: an identifier which represents memory location. For example, variable name, `*ptr` where `ptr` points to a memory location, etc.
4. **`r-value`**: a value which is not `l-value`, `r-value` appear on the right-hand side of the assignment(`=`) operator. Like

```cpp
int a = 5; // 5 = r-value, 
q = p + 5; // p + 5 is r-value
```

Note: Although there are some exceptions & more to learn on [lvalue, rvalue and their references in C++](/posts/lvalue-rvalue-and-their-references-with-example-in-cpp/).

### Why Do We Need Typecasting?

- Data is a representation of the bits(`0`s & `1`s) in memory.
- Data-type is compiler directive which tells the compiler how to store & process particular data.
- `uint32_t a = 5;` by this statement you can presume that 4 bytes will be reserved in your memory & upon execution, it will store `0000 0000 0000 0000 0000 0000 0000 0101` data bits in that memory location. This was plain & simple.
- Let's go a bit further, `float f = 3.0;` this statement will also reserve 4 bytes in memory & store data bits in the form of 1). the sign bit, 2). exponent & 3). mantissa. Recall [how floating-point numbers are stored in memory](/posts/how-floating-point-no-is-stored-memory/).
- But when you write like `float f = 3;`, the compiler will be confused that how to store an integer value in float type of memory.
- So it will **automatically presume(Implicit conversion** here) that you want to store `3.0` rather than `3` which is technically same from the human point of view but it's different when you think from [computer memory perspective](/posts/memory-layout-of-cpp-object/) cause they stored differently.
- There are many such scenarios where you provide data to store in memory which used to represent different data type.
- For example, in the following example, you are trying to assign an object of type `B` into an object of type `A`

```cpp
class A{};
class B{};

int main ()
{
  B b;
  A a = b; 
  return 0;
}
```

- In such scenario compiler can not presume anything & simply throws a compilation error:

```cpp
exit status 1
error: no viable conversion from 'B' to 'A'
  A a = b;
    ^   ~
note: candidate constructor (the implicit copy constructor) not viable: no known conversion from 'B' to 'const A &' for 1st argument
class A{};
      ^
note: candidate constructor (the implicit move constructor) not viable: no known conversion from 'B' to 'A &&' for 1st argument
class A{};
      ^
1 error generated.
```

- But when you define a conversion operator as follows:

```cpp
class B {
public:
  operator A(){
    cout<<"CONVERSION OPERATOR\n";
    return A();
  } 
};
```

- The compiler will simply call this member function & won't throw any error because programmer explicitly mentioning that this is how he/she wants to convert.

### C++ Type Casting With Example for C Developers

### `C-style casts`

```cpp
int main() { 
    float res = 10 / 4;
    cout<<res<<endl;
    return 0; 
}
```

- When you will try to run the above code, you will get `2` as output which we didn't expect. To initialize `res` variable correctly we need to typecast using float as follows:

```cpp
float res = (float)10 / 4;
```

- Now your answer will be `2.5`. This type of casting is very simple & straight forward as it appears.
- You can also write above casting in C++ as:

```cpp
float res = float(10) / 4;
```

- C-style casts can change a data type without changing the underlying memory representation which may lead to garbage results.

### `static_cast`

- If you are C developer like me, then this will be your **best goto C++ cast** which fits in most of the example like:

```cpp
int * p = std::malloc(10);
```

- When you try to compile above code using C compiler it works fine. But C++ compiler is not kind enough. It will throw an error as follows :

```cpp
exit status 1
error: cannot initialize a variable of type 'int *' with an rvalue of type 'void *'
  int * p = std::malloc(10);
        ^   ~~~~~~~~~~
1 error generated.
```

- The first thing that comes to your mind is the C-style cast:

```cpp
int * p = (int*)std::malloc(10);
```

- This will work, but **C-style cast is not recommended in C++.** `static_cast` handles implicit conversions like this. We will primarily use it for converting in places where implicit conversions fail, such as std::malloc.

```cpp
int * p = static_cast<int*>(std::malloc(10));
```

- The main advantage of `static_cast` is that it provides compile-time type checking, making it harder to make an inadvertent error. Let's understand this with C++ example:

```cpp
class B {};
class D : public B {};
class X {};

int main()
{
  D* d = new D;
  B* b = static_cast<B*>(d); // this works
  X* x = static_cast<X*>(d); // ERROR - Won't compile
  return 0;
}
```

- As you can see, there is no easy way to distinguish between the two situations without knowing a lot about all the classes involved.
- Another problem with the C-style casts is that it is too hard to locate. In complex expressions, it can be very hard to see C-style casts e.g. `T(something)` syntax is equivalent to `(T)something`.

### `const_cast`

- Now we will directly jump to example. No theory can explain this better than example.

**1\. Ignore constness**

```cpp
int i = 0;
const int& ref = i;
const int* ptr = &i;

*ptr = 3; // Not OK
const_cast<int&>(ref) = 3;  //OK
*const_cast<int*>(ptr) = 3; //OK
```

- You are allowed to modify `i`, because of the object(`i` here) being assigned to, is not `const`. If you add const qualifier to `i`, code will compile, but its behaviour will be undefined (which can mean anything from "it works just fine" to "the program will crash".)

**2\. Modifying data member using `const` `this` pointer**

- `const_cast` can be used to change non-const class members by a method in which this pointer declared as const. - This can also be useful when overloading member functions based on `const`, for instance:

```cpp
class X
{
public:
    int var;
    void changeAndPrint(int temp) const
    {
        this->var = temp;                    // Throw compilation error
        (const_cast<X *>(this))->var = temp; // Works fine
    }
    void changeAndPrint(int *temp)
    {
        // Do some stuff
    }
};
int main()
{
    int a = 4;
    X x;
    x.changeAndPrint(&a);
    x.changeAndPrint(5);
    cout << x.var << endl;
    return 0;
}
```

**3\. Pass `const` argument to a function which accepts only non-const argument**

- `const_cast` can also be used to pass const data to a function that doesn’t receive const argument. See the following code:

```cpp
int fun(int* ptr) 
{ 
    return (*ptr + 10); 
} 

int main(void) 
{ 
    const int val = 10; 
    cout << fun(const_cast <int *>(&val)); 
    return 0; 
} 
```

**4\. Castaway `volatile` attribute**

- `const_cast` can also be used to cast away `volatile` attribute. Whatever we discussed above in `const_cast` is also valid for `volatile` keyword.

### `dynamic_cast`

- `dynamic_cast` **uses the type checking at runtime** in contrary to `static_cast` which does it at compile time. `dynamic_cast` is more useful when you don't know the type of input which it represents. Let assume:

```cpp
Base* CreateRandom()
{
    if( (rand()%2) == 0 )
        return new Derived1;
    else
        return new Derived2;
}

Base* base = CreateRandom();
```

- As you can see, we don't know which object will be returned by `CreateRandom() at run time but you want to execute `Method1()`of `Derived1` if it returns `Derived1`. So in this scenario, you can use `dynamic_cast` as follows

```cpp
Derived1 *pD1 = dynamic_cast<Derived1 *>(base);
if (pD1){
    pD1->Method1();
}
```

- In case, if the input of `dynamic_cast` does not point to valid data, it will return `nullptr` for pointers or throw a `std::bad_cast` exception for references. In order to work with `dynamic_cast`, your classes must be polymorphic type i.e. must include at least one virtual methods.
- `dynamic_cast` take advantage of `RTTI`([Run Time Type Identification](https://en.wikipedia.org/wiki/Run-time_type_information)) mechanism.

### `reinterpret_cast`

- `reinterpret_cast` **converts between types** by reinterpreting the underlying bit pattern.
- You can use `reinterpret_cast` to cast any pointer or integral type to any other pointer or integral type.
- This can lead to dangerous situations: nothing will stop you from converting an `int` to an `std::string*`.
- You will use `reinterpret_cast` in your embedded systems. A common scenario where `reinterpret_cast` applies is converting between `uintptr_t` and an actual pointer or between:

```cpp
error: static_cast from 'int *' to 'uintptr_t'
      (aka 'unsigned long') is not allowed
        uintptr_t ptr = static_cast<uintptr_t>(p);
                        ^~~~~~~~~~~~~~~~~~~~~~~~~
1 error generated.
```

- Instead, use this:

```cpp
uintptr_t ptr = reinterpret_cast<uintptr_t>(p);
```

I have tried to cover most of the intricacies to clear the main concept behind different typecasting, but still, there might be a chance that I may miss some. So, this is it for C++ type casting with example for C developers. Let's quickly recap:

### Cheat Code for C Developers Moving to C++ on Type Casting

After reading all this you may confuse on what to use & when! That's why I have created this cheat code

- **Avoid C-style casts**. Be sure about what you want while casting.
- Use `static_cast` **wherever you were using C-style cast**.
- Use `dynamic_cast` **with polymorphic classes**. Keep in mind that only use `dynamic_cast` on classes with at least one virtual member in the inheritance hierarchy.
- Use `const_cast` when you need to remove `const` or `volatile` qualifiers.
- Use `reinterpret_cast` when you have no options.

Note: `const_cast` **and** `reinterpret_cast` **should generally be avoided** because they can be harmful if used incorrectly. Don't use it unless you have a very good reason to use them.

### Some of the C++ Core Guidelines on Typecasting

- [P.4: Ideally, a program should be statically (compile-time) type safe](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#p4-ideally-a-program-should-be-statically-type-safe)
- [ES.48: Avoid casts](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Res-casts)
- [ES.49: If you must use a cast, use a named cast](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Res-casts-named)
- [ES.50: Don’t cast away](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Res-casts-const) [`const`](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Res-casts-const)
- [C.146: Use](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Rh-dynamic_cast) [`dynamic_cast`](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Rh-dynamic_cast) [where class hierarchy navigation is unavoidable](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Rh-dynamic_cast)
- [C.147: Use](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Rh-ref-cast) [`dynamic_cast`](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Rh-ref-cast) [to a reference type when failure to find the required class is considered an error](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Rh-ref-cast)
- [C.148: Use](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Rh-ptr-cast) [`dynamic_cast`](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Rh-ptr-cast) [to a pointer type when failure to find the required class is considered a valid alternative](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Rh-ptr-cast)

