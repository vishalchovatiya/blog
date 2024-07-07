---
title: "Inside the C++ Object Model"
date: "2019-09-11"
categories: 
  - "cpp"
tags: 
  - "c-code-transform"
  - "class-code-transformed-into-sequential-code"
  - "constructor-code-synthesize-c"
  - "default-member-functions-created-by-the-compiler-inside-the-c-object-model"
  - "default-implicitly-declared-member-functions"
  - "how-c-object-used-in-function"
  - "how-c-object-used-internally"
  - "implicitly-declared-member-functions-c"
  - "inside-c-object-model"
  - "inside-the-c-object-model"
  - "inside-the-c-object-model-pdf"
  - "oops"
  - "this-pointer"
  - "where-virtual-table-code-will-be-inserted-c"
featuredImage: "/images/memory-layout-of-C-objects.png"
---

This article is the collection of concept I have acquired while introducing myself to C++ by googling here & there. This material is also not in order. I have just collected the answer to my quick question. And write it down here. But one thing I can assure you is that once you go through this article. You can connect many broken thought of understanding on what runs "Inside the C++ object model". And why people call it as it runs C internally.

**_Note:_** In addition, here I have not considered name mangling & other compiler attributes for simplicity. Also not shown how object memory layout created. So, I have discussed it [here](/posts/memory-layout-of-cpp-object/). Code augmentation depends on compiler implementation, there is no such standard define.

### Default Member-Functions Created by the Compiler Inside the C++ Object Model

Suppose you have declared class like:

```cpp
 class Thing {}; 
```

- The compiler will probably synthesize this class as:

```cpp
class Thing {
public:
    Thing();                        // default constructor
    Thing(const Thing&);            // copy c'tor
    Thing& operator=(const Thing&); // copy-assign
    ~Thing();                       // d'tor
    // C++11:
    Thing(Thing&&);                 // move c'tor
    Thing& operator=(Thing&&);      // move-assign
};  
```

- So by default compiler will generate:
    1. default constructor
    2. copy constructor
    3. copy-assign operator
    4. destructor
    5. move constructor
    6. move-assign operator

Note: This stands true till C++ 14.

- The **_compiler creates all default/implicitly-declared member-functions when it needed_**. A compiler cannot create default member-functions when it's no use.

### How C++ Object Model Used in Function?

- Given the following function, where `class X` defines a copy constructor, [virtual destructor](/posts/part-3-all-about-virtual-keyword-in-c-how-virtual-destructor-works/), and [virtual function](/posts/part-1-all-about-virtual-keyword-in-cpp-how-virtual-function-works-internally/) `foo()`

```cpp
X foobar()
{
    X xx;
    X *px = new X;

    // foo() is virtual function
    xx.foo();
    px->foo();

    delete px;
    return xx;
}; 
```

- The probable compiler transformation would be:

```cpp
void foobar(X &result) {
	X::X(&result);		  // Constructor call, NRVO
	px = _new(sizeof(X)); // expand X *px = new X;
	if (px != 0)
		px->X::X();

	foo(&result);		 // xx.foo(): replaced xx with result
	(*px->_vtbl[2])(px); // px->foo(): using dynamic dispatch

	// Expand delete px;
	if (px != 0) {
		(*px->_vtbl[1])(px); // Virtual destructor
		_delete(px);
	}
	// replace named return statement
	// no need to destroy local object xx
	return;
};
```

- This is how the object-oriented paradigm converted into the [procedure-oriented paradigm](/posts/how-c-program-convert-into-assembly/).

### How Class/Object-Oriented Code Transformed Into Sequential Code?

- Let's take the following example to understand it:

```cpp
struct foo
{
    int m_var;

public:
    void print()
    {
        cout << m_var << endl;
    }
};
```

- The compiler treats this as :

```cpp
struct foo
{
    int m_var;
};

void foo::print(foo *this)
{
    std::cout.operator<<(this->m_var).operator<<(std::endl);
}
```

- As you can see above, [objects](/posts/memory-layout-of-cpp-object/) & methods are a separate entity. An object only represents data members.
- Therefore, all the methods in class/struct contain implicit `this` pointer as the first argument using which all non-static data members are accessed.
- Static data members are not part of class/struct. Because it usually resides in a data segment of memory layout. So it accesses directly(or using segment registers).
- So this is the reason if you print the size of the above class. Hence, It prints 4 because all methods are a separate entity which operates on the object by using implicit `this` pointer.

### How & Where Constructor Code Transform/Synthesize With Inheritance & Composition Class?

```cpp
class Foo 
{ 
public: 
  Foo(){cout<<"Foo"<<endl;} 
  ~Foo(){cout<<"~Foo"<<endl;} 
};

class base 
{ 
public: 
  base(){cout<<"base"<<endl;}
  ~base(){cout<<"~base"<<endl;}
};

class Bar /* : public base */
{ 
  Foo foo; 
  char *str; 
public: 
  Bar()
  {
    cout<<"Bar"<<endl;
    str = 0;
  }
  ~Bar(){cout<<"~Bar"<<endl;}
};
```

- Compiler augmented `Bar` constructor would look like:

```cpp
Bar::Bar()
{
  foo.Foo::Foo(); // augmented compiler code
  
  cout<<"Bar"<<endl; // explicit user code
  str = 0; // explicit user code
}
```

- Similarly, multiple class member objects require a constructor initialization. The language specifies that the constructors would be invoked in the order of member declaration within the class. This is accomplished by the compiler.
- But, if an object member does not define a default constructor, a non-trivial default constructor synthesizes by a compiler for respective classes.
- Moreover, in the case of inheritance, the constructor calling sequence starts from base(top-down) to derived manner. Constructor synthesis & augmentation remain same as above.
- So in the above case, if you derive `Bar` from `Base` then constructor calling sequence would be `Base` -> `Foo` -> `Bar`.

### How & Where Destructor Code Transform/Synthesize With Inheritance & Composition Class?

- In case of the destructor, calling sequence is exactly the reverse that of a constructor. Like in the above case it would be `Bar` -> `Foo` -> `Base`. Synthesis & augmentation remain same as above. Access and all other things remain the same.

### How & Where Virtual Table Code Will Be Inserted?

- The virtual table code will be inserted by the compiler before & after the user-written code in constructor & destructor. That too on demand of user implementation.
- Additionally, for the question "How virtual table code will be inserted", my answer is "this is purely compiler dependent". C++ standard only mandates behaviour. Although this would not be complex. It probably would look like:

```cpp
 this->_vptr[0] = type_info("class_name"); 
```

- By the way, I have written a more detailed article on virtual keyword [here](/posts/part-1-all-about-virtual-keyword-in-cpp-how-virtual-function-works-internally/).

### Reference

- [https://stackoverflow.com/questions/3734247/what-are-all-the-member-functions-created-by-compiler-for-a-class-does-that-hap](https://stackoverflow.com/questions/3734247/what-are-all-the-member-functions-created-by-compiler-for-a-class-does-that-hap)
- [Book: Inside C++ Object Model By Lippman](https://www.amazon.in/Inside-Object-Model-Stanley-Lippman/dp/0201834545)
