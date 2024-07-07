---
title: "Complications of Using the Virtual Base Class"
date: "2019-09-12"
categories: 
  - "cpp"
tags: 
  - "complications-of-virtual-base-class"
  - "double-pointer-hack"
  - "downcasting"
  - "pointer-equivalence"
featuredImage: "/images/memory-layout-of-C-objects.png"
---

In the previous article about [How Does Virtual Base Class Works Internally?](/posts/part-2-all-about-virtual-keyword-in-cpp-how-virtual-class-works-internally/) we have seen address resolution of virtual base class & why it's needed. But I have not discussed Complications of Using the Virtual Base Class. Which we will see in this article. This is going to be a bit complex & clumsy then learning the internal working of the virtual base class. But if you are not tired, then read forward.

I am re-posting the previous example here to refresh some memory:

```cpp
class Top { public: int t; };
class Left : virtual public Top { public: int l; };
class Right : virtual public Top { public: int r; };
class Bottom : public Left, public Right { public: int b; };
```

- Class diagram

```bash
    Top
   /   \
Left   Right
   \   /
   Bottom
```

## Complications of Downcasting While Using the Virtual Base Class

- As we have seen, [casting](/posts/cpp-type-casting-with-example-for-c-developers/) of the object `Bottom` to `Right`(in other words, upcasting) requires adding offset to a pointer. One might be tempted to think that downcasting can then simply be implemented by subtracting the same offset.
- This process is not easy for the compiler as it seems. To understand this, let us go through an example.

```cpp
class AnotherBottom : public Left, public Right
{
public:
   int ab1;
   int ab2;
};
```

- `Bottom` & `AnotherBottom` have the same inheritance hierarchy except for their own data members. Now consider the following code.

```cpp
Bottom* bottom1 = new Bottom();
AnotherBottom* bottom2 = new AnotherBottom();
Top* top1 = bottom1;
Top* top2 = bottom2;
Left* left = static_cast<Left*>(top1);
```

- Following is memory layout for `Bottom` & `AnotherBottom`

```
       |                        |                 |                        |
       |------------------------|<---- Bottom     |------------------------|<---- AnotherBottom
       |    Left::l             |                 |    Left::l             |
       |------------------------|                 |------------------------|
       |    Left::_vptr_Left    |                 |    Left::_vptr_Left    |
       |------------------------|                 |------------------------|
       |    Right::r            |                 |    Right::r            |
       |------------------------|                 |------------------------|
       |    Right::_vptr_Right  |                 |    Right::_vptr_Right  |
       |------------------------|                 |------------------------|
       |    Bottom::b           |                 |    AnotherBottom::ab1  |
top1-->|------------------------|                 |------------------------|
       |    Top::t              |                 |    AnotherBottom::ab2  |
       |------------------------|       top2----->|------------------------|  
       |                        |                 |    Top::t              |
                                                  |------------------------|
                                                  |                        |
```

- Now consider how to implement the `static_cast` from `top1` to `left`, while taking into account that we do not know whether `top1` is pointing to an object of type `Bottom` or an object of type `AnotherBottom`. It can't be done! The necessary offset depends on the runtime type of `top1` (20 for `Bottom` and 24 for `AnotherBottom`). The compiler will complain:

```cpp
error: cannot convert from a pointer to base class 'Top' to a pointer to derived class 'Left' because the base is virtual
```

- Since we need runtime information, we need to use a [dynamic\_cast](/posts/cpp-type-casting-with-example-for-c-developers/) instead:

```cpp
Left* left = dynamic_cast<Left*>(top1);
```

- However, the compiler is still unhappy:

```cpp
error: cannot dynamic_cast 'top1' (of type 'class Top*')to type 'class Left*' (source type is not polymorphic)
```

- The problem is that a dynamic\_cast (as well as the use of `typeid`) needs [runtime type information](https://en.wikipedia.org/wiki/Run-time_type_information) about the object pointed to by `top1`. The compiler did not include that because it did not think that was necessary. To force the compiler to include that, we can add a virtual destructor to `Top`:

```cpp
class Top
{
public:
   virtual ~Top() {} // This line creates magic for us
   int t;
};
```

- Thus, for a downcasting object having virtual base class we need to have at least one [virtual function](/posts/part-1-all-about-virtual-keyword-in-cpp-how-virtual-function-works-internally/) in the virtual base class.

## **Double Pointer Hack**

- For below code:

```cpp
Bottom* b = new Bottom();
Right* r = b;
```

- We already know that the value of `b` gets adjusted by 8 bytes before it is assigned to `r` so that it points to the `Right` section of the `Bottom` object). Thus, we can legally assign a `Bottom*` to a `Right*`. What about `Bottom**` and `Right**`?

```cpp
Bottom** bb = &b;
Right** rr = bb;
```

- Should the compiler accept this? A quick test will show that the compiler will complain:

```cpp
error: invalid conversion from `Bottom**' to `Right**'
```

- Why? Suppose the compiler would accept the assignment of `bb` to `rr`. We can visualise the result as:

```
  |----------| --------> |---------|         |                        | 
  |    bb    |           |    b    | ------> |------------------------|<---- Bottom
  |----------|    /----> |---------|         |    Left::l             |            
                 /                           |------------------------|            
                /                            |    Left::_vptr_Left    |            
  |----------| /         |---------| ------> |------------------------|            
  |    rr    |           |    r    |         |    Right::r            |            
  |----------|           |---------|         |------------------------|            
                                             |    Right::_vptr_Right  |            
                                             |------------------------|            
                                             |    Bottom::b           |            
                                             |------------------------|            
                                             |    Top::t              |            
                                             |------------------------|           
                                             |                        |        
```

- So, `bb` and `rr` both point to `b`, and `b` and `r` point to the appropriate sections of the `Bottom` object. Now consider what happens when we assign to `*rr` (note that the type of `*rr` is `Right*`, so this assignment is valid):

```cpp
*rr = b;    
```

- This is essentially the same assignment as the assignment to `r` above. Thus, the compiler will implement it the same way! In particular, it will adjust the value of `b` by 8 bytes before it assigns it to `*rr`. But `*rr` pointed to `b`! If we visualise the result again:

```
  |----------| --------> |-----------|           |                        | 
  |    bb    |           |     b     |           |------------------------|<---- Bottom 
  |----------|    /----> |-----------|\          |    Left::l             |              
                 /                     \         |------------------------|              
                /                       \        |    Left::_vptr_Left    |              
  |----------| /         |-----------|---\-----> |------------------------|              
  |    rr    |           |     r     |           |    Right::r            |              
  |----------|           |-----------|           |------------------------|              
                                                 |    Right::_vptr_Right  |              
                                                 |------------------------|              
                                                 |    Bottom::b           |              
                                                 |------------------------|              
                                                 |    Top::t              |              
                                                 |------------------------|           
                                                 |                        |  
```

- This is correct as long as we access the `Bottom` object through `*rr`, but as soon as we access it through `b` itself, all memory references will be off by 8 bytes — obviously a very undesirable situation.
- So, in summary, even if `*a` and `*b` are related by some subtyping relation, `**a` and `**b` are not.

## **Constructors of Virtual Bases**

- The compiler must guarantees that the constructor for all virtual bases of a class gets invoked, and get invoked **only once**. If you don't explicitly call the constructors of your virtual base class (independent of how far up the tree they are), the compiler will automatically insert a call to their default constructors.
- This can lead to some unexpected results. Consider the same class hierarchy again we have been considering so far, extended with constructors:

```cpp
class Top
{
public:
   Top() { a = -1; } 
   Top(int _a) { a = _a; } 
   int a;
};

class Left : virtual public Top
{
public:
   Left() { b = -2; }
   Left(int _a, int _b) : Top(_a) { b = _b; }
   int b;
};

class Right : virtual public Top
{
public:
   Right() { c = -3; }
   Right(int _a, int _c) : Top(_a) { c = _c; }
   int c;
};

class Bottom : public Left, public Right
{
public:
   Bottom() { d = -4; } 
   Bottom(int _a, int _b, int _c, int _d) : Left(_a, _b), Right(_a, _c) 
    { 
      d = _d; 
    }
   int d;
};
```

- What would you expect this to output:

```cpp
Bottom bottom(1,2,3,4);
printf("%d %d %d %d %d\n", bottom.Left::a, bottom.Right::a, bottom.b, bottom.c, bottom.d);
```

- You would probably get

```cpp
-1 -1 2 3 4
```

- I know you were expecting different. But if you trace the execution of the constructors, you will find

```cpp
Top::Top()
Left::Left(1,2)
Right::Right(1,3)
Bottom::Bottom(1,2,3,4)
```

- As explained above, the compiler has inserted a call to the default constructor in `Bottom`, before the execution of the other constructors. Then when Left tries to call its base class constructor(`Top`), we find that `Top` has already been initialised and the constructor does not get invoked.
- To avoid this situation, you should explicitly call the constructor of your virtual base(s):

```cpp
Bottom(int _a, int _b, int _c, int _d): Top(_a), Left(_a,_b), Right(_a,_c) 
{ 
   d = _d; 
}
```

**Pointer Equivalence**

- Once again assuming the same (virtual) class hierarchy, would you expect this to print “Equal”?

```cpp
Bottom* b = new Bottom(); 
Right* r = b;

if(r == b)
   printf("Equal!\n");
```

- Bear in mind that the two addresses are not actually equal (`r` is off by 8 bytes). However, that should be completely transparent to the user; so, the compiler actually subtracts the 8 bytes from `r` before comparing it to `b`; thus, the two addresses are considered equal.
- Although, this also stands true for the following code.

```cpp
class base1{};
class base2{};
class derived : public base1, public base2{};

derived *d = new derived();
base2 *b2 = d;

if(b2 == d)
   printf("Equal!\n");
```

## Reference

- [http://www.avabodh.com/cxxin/virtualbase.html](http://www.avabodh.com/cxxin/virtualbase.html)
- [https://stackoverflow.com/questions/21558/in-c-what-is-a-virtual-base-class](https://stackoverflow.com/questions/21558/in-c-what-is-a-virtual-base-class)
- [https://web.archive.org/web/20160413064252/http://www.phpcompiler.org/articles/virtualinheritance.html](https://web.archive.org/web/20160413064252/http://www.phpcompiler.org/articles/virtualinheritance.html)
- Book: Inside C++ Object Model By Lippman
