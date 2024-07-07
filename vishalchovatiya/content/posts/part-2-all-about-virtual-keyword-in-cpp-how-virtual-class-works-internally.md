---
title: "Part 2: All About Virtual Keyword in C++: How Does Virtual Base Class Works Internally?"
date: "2019-09-11"
categories: 
  - "cpp"
tags: 
  - "all-about-virtual-keyword-in-c"
  - "class-virtual-method-c"
  - "complications-of-virtual-base-class"
  - "define-virtual-base-class-in-c"
  - "define-virtual-classes-in-c-plus-plus"
  - "definition-of-virtual-base-class-in-c"
  - "definition-of-virtual-classes-in-c-plus-plus"
  - "example-of-virtual-base-class-in-c"
  - "explain-virtual-base-class"
  - "explain-virtual-base-class-in-c"
  - "explain-virtual-base-class-with-example"
  - "explain-virtual-base-class-with-example-in-c"
  - "handling-of-virtual-function-in-the-virtual-base-class"
  - "handling-of-virtual-functions-in-the-virtual-base-class"
  - "how-does-virtual-base-class-addressing-works-internally"
  - "how-virtual-class-addressing-works-internally"
  - "how-virtual-class-works-internally"
  - "invariant-region-and-shared-region-in-virtual-base-class"
  - "need-of-virtual-base-class-in-c"
  - "virtual-base-class"
  - "virtual-base-class-example"
  - "virtual-base-class-example-in-c"
  - "virtual-base-class-in-c"
  - "virtual-base-class-in-c-plus-plus"
  - "virtual-base-class-in-c-2"
  - "virtual-base-class-in-c-definition"
  - "virtual-base-class-in-c-example"
  - "virtual-base-class-in-c-program"
  - "virtual-base-class-in-c-with-example"
  - "virtual-base-class-in-c-with-example-program"
  - "virtual-base-class-in-cpp"
  - "virtual-base-class-program-in-c"
  - "virtual-class"
  - "virtual-class-c"
  - "virtual-class-in-c-plus-plus"
  - "virtual-class-in-c-sharp"
  - "virtual-class-in-c"
  - "virtual-classes-in-c-plus-plus"
  - "virtual-inheritance-in-c"
  - "what-is-virtual-base-class-in-c-plus-plus"
  - "what-is-virtual-class"
  - "why-do-we-need-a-virtual-class"
  - "why-do-we-need-virtual-inheritance-in-c"
  - "why-we-need-a-virtual-class"
featuredImage: "/images/memory-layout-of-C-objects.png"
---

In [PART 1](/posts/part-1-all-about-virtual-keyword-in-cpp-how-virtual-function-works-internally/) of "All About Virtual Keyword in C++" series, we have discussed "How Does Virtual Function Works Internally?". So, in this article, I will discuss "How Does Virtual Base Class Works Internally?". I am iterating the same thing which I have mentioned in the earlier article as well that implementation of a virtual mechanism is purely compiler dependent. So, there is no C++ standard is defined for such dynamic dispatch. Hence, here I am discussing the general approach.

As usual, before learning anything new I usually start with “Why do we need it in the first place?”

## Why Do We Need a Virtual Class/Inheritance?

- When we use inheritance, we basically extending a derived class with base class functionality. In other words, the base class object would be treated as [sub-object](/posts/memory-layout-of-cpp-object/) in the derived class.
- As a result, this would create a problem in multiple inheritances if base class sharing the same mutual class as [sub-object](/posts/memory-layout-of-cpp-object/) in the top-level hierarchy and you want to access its property.

### Problem

- I know above statement is a bit complex. So, let see an example.

```cpp
class Top { public: int t; };
class Left : public Top { public: int l; };
class Right : public Top { public: int r; };
class Bottom : public Left, public Right { public: int b; };
```

- The above class hierarchy/inheritance results in the "diamond" which looks like below:

```
    Top
   /   \
Left   Right
   \   /
   Bottom
```

- An instance of `Bottom` will be made up of `Left`, which includes `Top`, and `Right` which also includes `Top`. So, we have two sub-object of `Top`. This will create ambiguity as follows:

```cpp
Bottom *bot = new Bottom;
bot->t = 5; // is this Left's `t` or Right's `t` data member ??
```

- This was by far the simplest reason for the need of the virtual base class. And consider the following scenarios as an example:

```cpp
Top   *t_ptr1 = new Left;
Top   *t_ptr2 = new Right; 
```

- These both will work fine as `Left` or `Right` object memory layout has `Top` subobject. You can see the memory layout of the `Bottom` object below for clear understanding.

```
|                      |
|----------------------|  <------ Bottom bot;   // Bottom object 
|    Left::Top::t      |
|----------------------|
|    Left::l           |
|----------------------|
|    Right::Top::t     |
|----------------------|
|    Right::r          |
|----------------------|
|    Bottom::b         |
|----------------------|
|                      |
```

- Now, what happens when we upcast a `Bottom` pointer?

```cpp
Left  *left = new Bottom;
```

- This will work fine as `Bottom` object memory layout starts with `Left` subobject.
- However, what happens when we upcast to `Right`?

```cpp
Right  *right = new Bottom;
```

- For this to work, we have to adjust the `right` pointer value to make it point to the corresponding section of the `Bottom` layout:

```
|                      |
|----------------------|
|    Left::Top::t      |
|----------------------|
|    Left::l           |
|----------------------|  <------ right;
|    Right::Top::t     |
|----------------------|
|    Right::r          |
|----------------------|
|    Bottom::b         |
|----------------------|
|                      |
|                      |
```

- After this adjustment, we can access the `Bottom` through the `right` pointer as a normal `Right` object.
- But, what would happen if we do

```cpp
Top* Top = new Bottom;
```

- This statement is ambiguous: the compiler will complain

```cpp
error: `Top' is an ambiguous base of `Bottom'
```

- Although you can use force [typecasting/C-style-cast](/posts/cpp-type-casting-with-example-for-c-developers/) as follows:

```cpp
Top* topL = (Left*) Bottom;
Top* topR = (Right*) Bottom;
```

### Solution

- **_Virtual inheritance uses to solve such kind of diamond problems_**. When you specify virtual while inheriting your classes, you're telling the compiler that you only want a single instance.

```cpp
class Top { public: int t; };
class Left : virtual public Top { public: int l; };
class Right : virtual public Top { public: int r; };
class Bottom : public Left, public Right { public: int b; };
```

- This means that there is only one "instance" of `Top` included in the hierarchy. Hence

```cpp
Bottom *bot = new Bottom;
bot->t = 5; // no longer ambiguous
```

- So, this may seem more obvious and simpler from a programmer's point of view. But from the compiler's point of view, this is vastly more complicated.
- But an interesting question is how this `bot->t` will be addressed & handle by the compiler? Ok, this is the time to move on to next point.

## How Does Virtual Base Class Addressing Works Internally?

- A class containing one or more virtual base class as a subobject, such as `Bottom`, is divided into two regions:
    1. **_Invariant region_**
    2. **_Shared region_**
- Data within the invariant region remains at a fixed offset(which decided in compilation step) from the start of the object regardless of subsequent derivations. So members within the invariant region can access directly. In our case, its `Left` & `Right` & `Bottom`.
- Additionally, the shared region represents the virtual base class subobjects whose location within the shared region fluctuates with an order of derivation & subsequent derivation. So members within the shared region need to accessed indirectly.
- As the name suggests, an **_invariant region placed at the start_** of objects memory layout and the **_shared region placed at the end_**.
- The **_offset of the shared region updated in the virtual table_**. The code necessary for this augmented by the compiler at the time of object construction. See below image for reference.

```
|                        |          
|------------------------| <------ Bottom bot;   // Bottom object           
|    Left::l             |          
|------------------------|               |------------------| 
|    Left::_vptr_Left    |-------|       |  offset of Top   | // offset starts 
|------------------------|       |-------|------------------|       // from left subobject = 20
|    Right::r            |               |    ...           |
|------------------------|               |------------------|  
|    Right::_vptr_Right  |-------|       
|------------------------|       |       |------------------| 
|    Bottom::b           |       |       |  offset of Top   | // offset starts 
|------------------------|       |-------|------------------|       // from right subobject = 12                       
|    Top::t              |               |    ...           |                                    
|------------------------|               |------------------|                                            
|                        |       
```

- Now coming back to our interesting question i.e. "How this `bot->t` will be addressed?"

```cpp
Bottom *bot = new Bottom;
bot->t = 5;
```

- Above code will probably be transformed into

```cpp
Bottom *bot = new Bottom;
(bot + _vptr_Left[-1])->t = 5; // If you haven't got this, then consider the above memory map
```

- So, as you can see addressing of [virtual base class](http://www.avabodh.com/cxxin/virtualbase.html) is done through the offset(of the base class) stored in the virtual table.

## Handling of Virtual Functions in the Virtual Base Class

- Handling of the virtual functions in the virtual base class is the same as we have discussed in our previous [article](/posts/part-1-all-about-virtual-keyword-in-cpp-how-virtual-function-works-internally/) with multiple inheritances. There is nothing special about it.

## Summary

As I mentioned earlier this seems straight forward from the programmer's point of view. But from the compiler’s point of view, it is complicated. And, there are many other [Complications of Using the Virtual Base Class](/posts/complications-of-using-the-virtual-base-class/) which I have discussed in a separate article. Let's summaries few take away points:

- There is no C++ standard on dynamic dispatch implementation & it only states behaviour
- The virtual class needed to avoid the diamond problem
- The object having virtual base class as subobject has memory layout divided in two regions:
    1. Invariant region: non-virtual classes
    2. Shared region: virtual classes
- Shared region i.e. virtual base class subobject placed at the end of memory layout.
- The addresses of the data members in the virtual base class resolved using offset(of virtual base class) store in the virtual table.
