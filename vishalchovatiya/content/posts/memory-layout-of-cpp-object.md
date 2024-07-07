---
title: "Memory Layout of C++ Object in Different Scenarios"
date: "2019-09-11"
categories: 
  - "cpp"
tags: 
  - "c-objects-memory-layout"
  - "c-class-memory-layout"
  - "c-dump-object-memory"
  - "c-object-model"
  - "c-virtual-table-memory-layout"
  - "c-vtable"
  - "how-are-objects-laid-out-in-memory"
  - "layout-of-an-object-with-virtual-function-and-static-data-member"
  - "layout-of-c-object-with-inheritance"
  - "layout-of-object-having-virtual-inheritance"
  - "memory-allocation-in-inheritance"
  - "memory-allocation-in-inheritance-in-c"
  - "memory-foot-print-of-c-object"
  - "memory-layout-for-multiple-and-virtual-inheritance"
  - "memory-layout-of-an-object-with-multiple-inheritances-and-virtual-function"
  - "memory-layout-of-c-object"
  - "memory-layout-of-simple-and-non-polymorphic-object-in-c"
  - "multiple-inheritance"
  - "objective-c-object-memory-layout"
  - "related-to-memory-layout-of-c-objects"
  - "virtual-function"
  - "virtual-inheritance"
  - "virtual-table"
  - "vptr"
  - "when-vtable-is-created-in-c"
  - "when-vtable-is-created-in-memory"
featuredImage: "/images/memory-layout-of-C-objects.png"
---

In this article, we will see the memory layout of different C++ Object. And how different storage & access specifiers affect this memory footprint. I am not going to discuss compiler augmented code, name mangling & working of any C++ mechanism related to memory as it is compiler & architecture-dependent. To keep this further simple, I have considered the standard [stack growth direction](/posts/how-c-program-convert-into-assembly/) i.e. downwards. And with the same, data members are represented inverted in memory(thanks to Thomas Vermeilh for pointing that out), that too I have ignored for simplicity. Although if you want to play around with the same, you can refer to this [link](https://godbolt.org/z/NTZ5Z5).

So, in nutshell, it's just all about **_"How different objects are laid out in memory?"_**

### Memory Layout of Simple & Non-Polymorphic Object in C++

```cpp
class X {
    int     x;
    float   xx;

public:
    X() {}
    ~X() {}

    void printInt() {}
    void printFloat() {}
};
```

- Memory layout:

```
      |                        |          
      |------------------------| <------ X class object memory layout
      |        int X::x        |
      |------------------------|  stack segment
      |       float X::xx      |       |   
      |------------------------|       |
      |                        |      \|/
      |                        |    
      |                        |
------|------------------------|----------------
      |         X::X()         | 
      |------------------------|       |   
      |        X::~X()         |       |
      |------------------------|      \|/
      |      X::printInt()     |  text segment
      |------------------------|
      |     X::printFloat()    |
      |------------------------|
      |                        |            
```

- In conclusion of the above example, only data members got the space in the stack. That too as the same order of their declarations. Because this is guaranteed by most of the compilers, apparently.
- In addition, all other methods, constructor, destructor & [compiler augmented code](/posts/inside-the-cpp-object-model/) goes into the [text segment](/posts/how-c-program-stored-in-ram-memory/). These methods are then called & passed `this` pointer implicitly of calling object in its 1st argument which we have already discussed in [Inside The C++ Object Model](/posts/how-cpp-object-used-internally-in-the-executable/).

### Layout of an Object With Virtual Function & Static Data Member

```cpp
class X {
    int         x;
    float       xx;
    static int  count;

public:
    X() {}
    virtual ~X() {}

    virtual void printAll() {}
    void printInt() {}
    void printFloat() {}
    static void printCount() {}
};
```

- Memory layout:

```
      |                        |          
      |------------------------| <------ X class object memory layout
      |        int X::x        |
stack |------------------------|
  |   |       float X::xx      |                      
  |   |------------------------|      |-------|--------------------------|
  |   |         X::_vptr       |------|       |       type_info X        |
 \|/  |------------------------|              |--------------------------|
      |           o            |              |    address of X::~X()    |
      |           o            |              |--------------------------|
      |           o            |              | address of X::printAll() |
      |                        |              |--------------------------|
      |                        |
------|------------------------|------------
      |  static int X::count   |      /|\
      |------------------------|       |
      |           o            |  data segment           
      |           o            |       |
      |                        |      \|/
------|------------------------|------------
      |        X::X()          | 
      |------------------------|       |   
      |        X::~X()         |       |
      |------------------------|       | 
      |      X::printAll()     |      \|/ 
      |------------------------|  text segment
      |      X::printInt()     |
      |------------------------|
      |     X::printFloat()    |
      |------------------------|
      | static X::printCount() |
      |------------------------|
      |                        |
```

- As you can see above, all non-static data members got the space into the stack with the same order of their declaration which we have already seen in the previous example.
- And static data member got the space into the data segment of memory. Which access with scope resolution operator(i.e. `::`). But after compilation, there is nothing like scope & namespace. Because, its just name mangling performed by the compiler, everything referred by its absolute or relative address. You can read more about name mangling in C++ [here](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=2&cad=rja&uact=8&ved=2ahUKEwjloqrohPToAhXDILcAHU4eC4kQFjABegQIDhAD&url=https%3A%2F%2Fwww.ibm.com%2Fsupport%2Fknowledgecenter%2Fssw_ibm_i_72%2Frzarg%2Fname_mangling.htm&usg=AOvVaw1JsTeSnCRnH6Cm-FjtqOUq).
- Moreover, static methods go into the text segment and called with the scope resolution operator. Except for `this` pointer which is not passed in its argument.
- For virtual keyword, the compiler automatically inserts pointer(`_vptr`) to a virtual table into the object memory representation. So it transforms direct function calling in an indirect call(i.e. dynamic dispatch which I have discussed in [How Does Virtual Function Works Internally?](/posts/part-1-all-about-virtual-keyword-in-cpp-how-virtual-function-works-internally/)). Usually, virtual table created statically per class in the data segment, but it also depends on compiler implementation.
- In a virtual table, 1st entry points to a [`type_info`](http://www.cplusplus.com/reference/typeinfo/type_info/) object which contains information related to current class & DAG([Directed Acyclic Graph](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=9&cad=rja&uact=8&ved=2ahUKEwjO_sWYgPToAhU4yzgGHfyzAGkQFjAIegQIARAB&url=https%3A%2F%2Fen.wikipedia.org%2Fwiki%2FDirected_acyclic_graph&usg=AOvVaw1mxaV0fpCPG1RAZSFIC5oJ)) of other base classes if it is derived from them.
- I have not mentioned the data type of `_vptr` because the standard does not mention(even I don't know that).

### Layout of C++ Object With Inheritance

```cpp
class X {
    int     x;
    string str;

public:
    X() {}
    virtual ~X() {}

    virtual void printAll() {}
};

class Y : public X {
    int     y;

public:
    Y() {}
    ~Y() {}

    void printAll() {}
};
```

- Memory layout:

```
      |                              |          
      |------------------------------| <------ Y class object memory layout
      |          int X::x            |
stack |------------------------------|
  |   |              int string::len |
  |   |string X::str ----------------|
  |   |            char* string::str |         
 \|/  |------------------------------|      |-------|--------------------------|
      |           X::_vptr           |------|       |       type_info Y        |
      |------------------------------|              |--------------------------|
      |          int Y::y            |              |    address of Y::~Y()    |
      |------------------------------|              |--------------------------|
      |               o              |              | address of Y::printAll() |
      |               o              |              |--------------------------|
      |               o              |              
------|------------------------------|--------
      |           X::X()             | 
      |------------------------------|       |   
      |           X::~X()            |       |
      |------------------------------|       | 
      |         X::printAll()        |      \|/ 
      |------------------------------|  text segment
      |           Y::Y()             |
      |------------------------------|
      |           Y::~Y()            |
      |------------------------------|
      |         Y::printAll()        |
      |------------------------------|
      |      string::string()        |
      |------------------------------|
      |      string::~string()       |
      |------------------------------|
      |      string::length()        |
      |------------------------------|
      |               o              |
      |               o              |
      |               o              |
      |                              |
```

- In the inheritance model, a base class & data member classes are a subobject of a derived class. So, a resultant memory map looks like the above diagram.
- Virtual table with all overridden virtual functions and code to assign `_vptr` with the virtual table is generated in the constructor of the class by the compiler. I have written more on this topic in the [virtual function series](/posts/part-1-all-about-virtual-keyword-in-cpp-how-virtual-function-works-internally/).

### Memory Layout of an Object With Multiple Inheritances & Virtual Function

```cpp
class X {
public:
    int     x;
    
    virtual ~X() {}
    virtual void printX() {}
};

class Y {
public:
    int     y;
    
    virtual ~Y() {}
    virtual void printY() {}
};

class Z : public X, public Y {
public:
    int     z;
    
    ~Z() {}
    void printX() {}
    void printY() {}
    void printZ() {}
};
```

- Memory layout:

```
      |                              |          
      |------------------------------| <------ Z class object memory layout
stack |          int X::x            |         
  |   |------------------------------|                  |--------------------------|      
  |   |          X:: _vptr           |----------------->|       type_info Z        |
  |   |------------------------------|                  |--------------------------|
 \|/  |          int Y::y            |                  |    address of Z::~Z()    |
      |------------------------------|                  |--------------------------|
      |          Y:: _vptr           |------|           |   address of Z::printX() |
      |------------------------------|      |           |--------------------------|
      |          int Z::z            |      |           |--------GUARD_AREA--------|    
      |------------------------------|      |           |--------------------------|
      |              o               |      |---------->|       type_info Z        |
      |              o               |                  |--------------------------|
      |              o               |                  |    address of Z::~Z()    |
      |                              |                  |--------------------------|
------|------------------------------|--------- |   address of Z::printY() |
      |           X::~X()            |       |          |--------------------------|  
      |------------------------------|       |          
      |          X::printX()         |       |        
      |------------------------------|       |         
      |           Y::~Y()            |      \|/        
      |------------------------------|  text segment
      |          Y::printY()         |                
      |------------------------------|                
      |           Z::~Z()            |                
      |------------------------------|                
      |          Z::printX()         |                
      |------------------------------|                
      |          Z::printY()         |                
      |------------------------------|                
      |          Z::printZ()         |                
      |------------------------------|                
      |               o              |                
      |               o              |                
      |                              |                
```

- In multiple inheritance hierarchy, an exact number of the virtual table pointer(`_vptr`) created will be N-1, where N represents the number of classes.
- Now, the rest of the things will be easy to understand for you, I guess so.
- If you try to call a method of class `Z` using any base class pointer, then it will call using the respective virtual table. As an example:

```cpp
Y *y_ptr = new Z;
y_ptr->printY(); // OK
y_ptr->printZ(); // Not OK, as virtual table of class Y doesn't have address of printZ() method
```

- In the above code, `y_ptr` will point to subobject of class Y within the complete `Z` object.
- As a result, call to any method for say `y_ptr->printY();` using `y_ptr` will be resolved like:

```cpp
 ( *y_ptr->_vtbl[ 2 ] )( y_ptr )
```

- You must be wondering why I have passed `y_ptr` as an argument here. It's because of an implicit `this` pointer, you can learn about it [here](/posts/how-cpp-object-used-internally-in-the-executable/).

### Layout of Object Having Virtual Inheritance

```cpp
class X { int x; };
class Y : public virtual X { int y; };
class Z : public virtual X { int z; };
class A : public Y, public Z { int a; };
```

- Memory layout:

```
                  |                |          
 Y class  ------> |----------------| <------ A class object memory layout
sub-object        |   Y::y         |          
                  |----------------|             |------------------| 
                  |   Y::_vptr_Y   |------|      |    offset of X   | // offset(20) starts from Y 
 Z class  ------> |----------------|      |----> |------------------|     
sub-object        |   Z::z         |             |       .....      |     
                  |----------------|             |------------------|  
                  |   Z::_vptr_Z   |------|       
                  |----------------|      |        
 A sub-object --> |   A::a         |      |      |------------------| 
                  |----------------|      |      |    offset of X   | // offset(12) starts from Z
 X class -------> |   X::x         |      |----> |------------------|          
 shared           |----------------|             |       .....      |           
 sub-object       |                |             |------------------|           
```

- Memory representation of derived class having one or more virtual base class divides into two regions:
    1. an invariant region
    2. a shared region
- Data within the invariant region remains at a fixed offset from the start of the object regardless of subsequent derivations.
- However, shared region contains a virtual base class and it fluctuates with subsequent derivation & order of derivation. I have discussed more on this in [How Does Virtual Inheritance Works?](/posts/part-2-all-about-virtual-keyword-in-cpp-how-virtual-class-works-internally/).
