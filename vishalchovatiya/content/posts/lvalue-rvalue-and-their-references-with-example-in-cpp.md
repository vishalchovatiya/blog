---
title: "Lvalue Rvalue and Their References With Example in C++"
date: "2019-09-15"
categories: 
  - "cpp"
tags: 
  - "c-11-rvalue"
  - "c-11-rvalue-reference"
  - "c-rvalue"
  - "c-rvalue-reference"
  - "lvalue"
  - "lvalue-reference"
  - "move-constructor"
  - "move-semantics"
  - "rvalue"
  - "rvalue-and-lvalue-reference-c"
  - "rvalue-reference"
  - "rvalue-reference-c"
  - "rvalue-reference-in-c"
cover:
    image: /images/20-new-features-of-Modern-C-to-use-in-your-project.png
---

This topic might be a piece of cake for every experienced C++ veteran. But I remember back in the days when I was a novice & introducing myself with [Modern C++](/posts/21-new-features-of-modern-cpp-to-use-in-your-project/), I was really irritated by C++ compiler messages saying this is lvalue & that is rvalue kind of jargons. And even if you are not using C++, you may have faced compiler error in C language saying _"lvalue required as left operand of assignment"_.

So I was getting difficulties in understanding this un-schooled topic "lvalue rvalue and their references with example in C++" until I have googled a bit for the same. This is my habit to preserve knowledge in term of an article. So here is a bit about things I had learned so far. I always start with "Why do we need that?" So let's start from there.

## Why Do We Need Lvalue & Rvalue Kind of Jargons?

- If you are using C++ prior to C++11 then you don't need these jargons to write code. But yes it is still useful to understand compilation errors.
- The compiler sees things by expression & to evaluate expression it identify operand & operation. Let's understand this by example:

```cpp
uint32_t a = 5;
```

- Here compiler identifies `a` & `5` as [operand](https://en.wikipedia.org/wiki/Operand) and `=`(assignment) as operation. Furthermore, compiler divides operand in subcategory named as `rvalues`, `lvalues`, `xvalues`, `glvalues`, and `prvalues` to distinguish between them(see heading [image](http://secureservercdn.net/160.153.137.218/bkh.972.myftpupload.com/wp-content/uploads/20-new-features-of-Modern-C-to-use-in-your-project.png) for hierarchy). This different value type tells the compiler about the source, destination, the scope of information, etc.
- In the above expression `a` is lvalue as it indicates destination memory where rvalue i.e. `5` will be stored.
- When you compile & see above statement in assembly, it would probably look like :

```asm
...
movl    $5, -4(%ebp)
...
```

- Here, `(%ebp) is current frame pointer which pulls down by 4 bytes which indicate [space allocated by the compiler for a variable in a stack](/posts/how-c-program-convert-into-assembly/). And `movl` instruction store `5` to that memory location directly.
- This is straight forward as long as we are using primitive data types like `int`, `double`, `char`, etc. So compiler will store raw value directly in instruction code itself like in our case its `$5`. After the execution of that instruction, `$5` is not used, so it has an expression scope, in other words, it is temporary.
- But when we use class & struct which are the user-defined type, things get bit complex & compiler introduce temporary object instead of directly storing the value in instruction code itself.

**TL;DR**  
We need this kind of jargons to understand compilation error & to see things from a compilers perspective. And yes! if you are using C++11 or above, you need to understand these jargons to write robust, fast & optimize code.

## Lvalue Rvalue and Their References With Example

### **What Are Lvalue & Rvalue?**

- lvalue & rvalue is compiler identifiers to evaluate the expression.
- Any compiler identifier which represents memory location is an lvalue.
- Any compiler identifier which represents data value on the right-hand side of an [assignment operator](/posts/2-wrong-way-to-learn-copy-assignment-operator-in-cpp-with-example/)(=) is rvalue.

### **Examples of Lvalue**

- There are two types of lvalue modifiable & non-modifiable(which are `const`).

1. **Modifiable lvalue**:

| Expression | Explanation |
|------------|-------------|
| `a = 1;` | `a` is lvalue as it represents memory |
| `int b = a;` | `b` & `a` is an lvalue, when `a` is assigned to `b`. It becomes an implicit rvalue because a copy of `a` is stored in `b`, not `a` itself |
| `struct S* ptr = &obj;` | `ptr` is lvalue |
| `arr[20] = 5;` | location index 20 in `arr` is lvalue |
| `int *pi = &i;` <br> `*pi = 10;` | `i` is lvalue as it is addressable. `*pi` is lvalue as it points to `i` |
| `class MyClass {}; MyClass X;` | `X` is lvalue as it represents the memory of user-defined type |

2. **Non-modifiable lvalue**:

| Expression | Explanation |
|------------|-------------|
| `const int a=1;` | `a` is non-modifiable lvalue |
| `const int *p=&a;` | `p` is non-modifiable lvalue |

### **Examples of Rvalue**

| Expression | Explanation |
|------------|-------------|
| `int a = 1;` | `1` is rvalue |
| `int b = a;` | `a` is implicit rvalue in this case (as discussed in the 2nd point of "Examples of lvalue") |
| `q = p + 5;` | `p + 5` is an rvalue |
| `int result = getInteger();` | The value returned by `getInteger()` is rvalue |
| `class cat {}; c = cat();` | `cat()` is an rvalue |

- rvalue could be a function on the right-hand side of = assignment operator which eventually evaluate to object(primitive or user-defined).
- rvalues are typically evaluated for their values, have expression scope (they die at the end of the expression they are in) most of the time, and cannot be assigned to. For example:

```cpp
5 = a; // invalid
getInt() = 2; // invalid
```

### Lvalue Rvalue References With Example

**lvalue reference**

- An lvalue reference is a reference that binds to an lvalue.
- lvalue references are marked with one ampersand `&`.

```cpp
int x = 5;
int &lref = x; // lvalue reference initialized with lvalue x
```

- Prior to C++11, only one type of reference existed in C++, and so it was just called a “reference”. However, in C++11, it’s sometimes called an lvalue reference.
- lvalue references can only be initialized with modifiable lvalues.

```cpp
const int a = 5;
int &ref = a; // Invalid & error will be thrown by compiler
```

**Exception**

- We cannot bind lvalue reference to an rvalue

```cpp
int &a = 5; // error: lvalue cannot be bound to rvalue 5
```

However, we can bind an rvalue to a const lvalue reference ([const](/posts/when-to-use-const-vs-constexpr-in-cpp/) reference):

```cpp
const int &a = 5;  // Valid
```

- In this case, the compiler converts `5` into lvalue first & then it assigns memory location to a const reference.

**rvalue reference**

- This is by far the most useful & bit complex thing you will learn.
- An rvalue reference is a reference that binds to an rvalue. rvalue references are marked with two ampersand `&&`.

```cpp
int &&rref = 5; // rvalue reference initialized with rvalue 5
```

- rvalues references cannot be initialized with lvalues i.e.

```cpp
int a = 5;
int &&ref = a; // Invalid & error will be thrown by compiler
```

- rvalue references are more often used as function parameters. This is most useful for function overloads when you want to have different behaviour for lvalue and rvalue arguments.

```cpp
void fun(const int &lref) // lvalue arguments will select this function
{
    std::cout << "lvalue reference to const\n";
}

void fun(int &&rref) // rvalue arguments will select this function
{
    std::cout << "rvalue reference\n";
}

int main()
{
    int x = 5;
    fun(x); // lvalue argument calls lvalue version of function
    fun(5); // rvalue argument calls rvalue version of function

    return 0;
}
```

## Why Do We Need Rvalue References?

- If you observe the [copy constructor](/posts/all-about-copy-constructor-in-cpp-with-example/?preview=true&_thumbnail_id=1695) & [copy assignment operator](/posts/2-wrong-way-to-learn-copy-assignment-operator-in-cpp-with-example/) prototype, it always takes `const` reference object as an argument. Because their primary work is to copy the object. And while copying we don't want to modify the object we have provided on the right-hand side of the expression.
- But there are some scenarios where we don't care about the right-hand side object we have provided to copy from. For example:

```cpp
class IntArray{
    int *m_arr;
    int m_len;
public:
    IntArray(int len) : m_len(len), m_arr(new int[len]){}
    ~IntArray(){delete [] m_arr;}

    // Copy Constructor
    IntArray(const IntArray& rhs){
      m_arr = new int[rhs.m_len];
      m_len = rhs.m_len;

      for(int i=0;i<m_len;i++)
        m_arr[i] = rhs.m_arr[i];
    }
};

IntArray func()
{
    IntArray obj(5);    
    // process obj    
    return obj;
}

int main()
{
  IntArray arr = func();   
  return 0;
}

// Note: use "-fno-elide-constructors" option while compiling otherwise it will create copy elision 
```

- By observing this code we conclude that `obj` is not useful after the return of `func() function. But when you return an [object](/posts/inside-the-cpp-object-model/) by the value it will invoke copy constructor & which will copy all the content from `obj` to `arr`(declared in `main()` by allocating new resource for `arr`. And when `obj` goes out of scope it will deallocate its resources.
- Rather than allocating new resources & copying data into it why don't we simply use those existing `obj`'s resources? Let's do that:

### Move Constructor

```cpp
IntArray(IntArray&& rhs){
    m_arr = rhs.m_arr;
    m_len = rhs.m_len;

    rhs.m_arr = nullptr; // To prevent code crashing 
}
```

- I have just modified copy constructor code as above which accept rvalue reference as an argument rather than lvalue so that our overloaded copy constructor will only be called when there is an rvalue is used on the right-hand side.
- Which simply means this constructor will only be called when right-hand side object is temporary or programmer is no longer care about that object.
- The implementation simply took ownership of resources from `obj` to `arr` and set right-hand side object's pointer to `NULL` so that its destructor won't deallocate resource which it is no longer owning.
- In fact, this is move constructor, not a copy constructor. Whose primary task is to take/move ownership of resources.
- Consider following move constructor prototype for more solid understanding:

## Catching Rvalue Reference

```cpp
IntArray(IntArray&& rhs)
{
    ...
}
```

- The message of this code is this: "The object that `rhs` binds to is YOURS. Do whatever you like with it, no one will care anyway." It's a bit like giving a copy to `IntArray` but without making a copy.

**Why do we need move constructor?**

This can be interesting for two purposes:  
- improving performance (as we are not allocating new resources & transferring content).  
- taking over ownership (since the object the reference binds to has been abandoned by the caller).

- I know you might be thinking that why just we don't modify copy constructor by removing `const` keyword from it. Let's do that as well

```cpp
IntArray(IntArray& rhs){
}
```

- Compilation error

```bash
exit status 1
error: no matching constructor for initialization of 'IntArray'
  IntArray arr = func();
           ^     ~~~~~~
note: candidate constructor not viable: expects an lvalue for 1st argument
    IntArray(IntArray& rhs){
    ^
1 error generated.
```

- If you see the `note` above, our overloaded copy constructor asking for lvalue. What we are doing is providing rvalue. As when we return an object by value, temporary(which falls under rvalue category) object will be created and supplied to our copy constructor. And as we have already seen above lvalue reference cannot bind to rvalue object.
- Don't think about changing your copy constructor's argument as `const` lvalue reference, I know we have seen that its exception & we can bind `const` lvalue reference to rvalue/temporary object. But in that case, you can not move/transfer resource as it is `const`.

So, this is it for "lvalue rvalue and their references with example", in the [next](/posts/understanding-unique-ptr-with-example-in-cpp11/) article we will design [smart pointer](/posts/move-constructor-assignment-operator-with-shared-ptr/) using rvalue reference & other concepts gained here.
