---
title: "Understanding unique_ptr with Example in C++11"
date: "2019-09-15"
categories: 
  - "cpp"
tags: 
  - "assign-pointer-to-unique_ptr"
  - "auto_ptr"
  - "boost-unique_ptr"
  - "boost-unique_ptr-example"
  - "c-11-unique_ptr"
  - "c-pass-unique_ptr-as-argument"
  - "c-pimpl-unique_ptr"
  - "c-unique_ptr"
  - "c-unique_ptr-example"
  - "c-unique_ptr-vector"
  - "c-using-unique_ptr"
  - "c-vector-of-unique_ptr"
  - "c11"
  - "keyword-ideas"
  - "nderstanding-unique_ptr"
  - "pass-unique_ptr-to-function"
  - "pass-unique_ptr-to-lambda"
  - "push_back-unique_ptr"
  - "understanding-unique_ptr-with-example-in-c11"
  - "unique_ptr"
  - "unique_ptr-c"
  - "unique_ptr-c-11"
  - "unique_ptr-c-example"
  - "unique_ptr-cplusplus"
  - "unique_ptr-example"
  - "unique_ptr-example-c"
  - "unique_ptr-in-c"
  - "unique_ptr-tutorial"
  - "unique_ptr-with-example"
featuredImage: "/images/20-new-features-of-Modern-C-to-use-in-your-project.png"
---

The smart pointers are a really good mechanism to manage dynamically allocated resources. In this article, we will see unique\_ptr with example in C++11. But we don't discuss standard smart pointers from a library. Rather, we implement our own smart pointer equivalent to it. This will give us an idea of inside working of smart pointers.

### Brief

Prior to C++11, the standard provided `std::auto_ptr`. Which had some limitations. But from C++11, standard provided many smart pointers classes. Understanding unique\_ptr with example in C++ requires an understanding of move semantics which I have discussed [here](/posts/lvalue-rvalue-and-their-references-with-example-in-cpp/) & [here](/posts/move-constructor-assignment-operator-with-shared_ptr/).

But before all these nuisances, we will see "Why do we need smart pointer in 1st place?":

### Why do we need smart pointers?

```cpp
void func()
{
    Resource *ptr = new Resource;

    int x;
    std::cout << "Enter an integer: ";
    std::cin >> x;

    if (x == 0)
        throw 0; // the function returns early, and ptr won't be deleted!

    if (x < 0)
        return; // the function returns early, and ptr won't be deleted!

    // do stuff with ptr here

    delete ptr;
}
```

- In the above code, the early `return` or `throw` statement, causing the function to terminate without variable `ptr` being deleted.
- Consequently, the memory allocated for variable `ptr` is now leaked (and leaked again every time this function is called and returns early).
- These kinds of issues occur because pointer variables have no inherent mechanism to clean up after themselves.
- Following class cleans-up automatically when sources are no longer in use:

### `smart_ptr` aka `std::auto_ptr` from C++98

```cpp
template<class T>
class smart_ptr
{
    T* m_ptr;
public:
    smart_ptr(T* ptr=nullptr):m_ptr(ptr){}

    ~smart_ptr()
    {
        delete m_ptr;
    }

    T& operator*() const { return *m_ptr; }
    T* operator->() const { return m_ptr; }
};
```

- Now, let's go back to our `func()`example above, and show how a smart pointer class can solve our challenge:

```cpp
class Resource
{
public:
    Resource() { std::cout << "Resource acquired\n"; }
    ~Resource() { std::cout << "Resource destroyed\n"; }
};

void func()
{
    smart_ptr<Resource> ptr(new Resource); // ptr now owns the Resource

    int x;
    std::cout << "Enter an integer: ";
    std::cin >> x;

    if (x == 0)
        throw 0;

    if (x < 0)
        return;

    // do stuff with ptr here

    // dont care about deallocation
}

int main()
{
    try{
      func();
    }
    catch(int val){}

    return 0;
}
```

- Output

```bash
Resource acquired
Hi!
Resource destroyed
```

- Note that even in the case where the user enters zero and the function terminates early, the `Resource` is still properly deallocated.
- Because of the `ptr` variable is a local variable. `ptr` destroys when the function terminates (regardless of how it terminates). And because of the `smart_ptr` destructor will clean up the `Resource`, we are assured that the `Resource` will be properly cleaned up.
- There is still some problem with our code. Like:

```cpp
int main()
{
    smart_ptr<Resource> res1(new Resource);
    smart_ptr<Resource> res2(res1); // Alternatively, don't initialize res2 and then assign res2 = res1;

    return 0;
}
```

- Output

```bash
Resource acquired
Resource destroyed
Resource destroyed
```

- In this case destructor of our `Resource` object will be called twice which can crash the program.
- What if, instead of having our copy constructor and assignment operator copy the pointer ("copy semantics"), we instead transfer/move ownership of the pointer from the source to the destination object? This is the core idea behind move semantics. Move semantics means the class will transfer ownership of the object rather than making a copy.
- Let's update our `smart_ptr` class to show how this can be done:

```cpp
template<class T>
class smart_ptr
{
    T* m_ptr;
public:
    smart_ptr(T* ptr=nullptr) :m_ptr(ptr) {}

    ~smart_ptr()
    {
        delete m_ptr;
    }

    // copy constructor that implements move semantics
    smart_ptr(smart_ptr& a) // note: not const
    {
        m_ptr = a.m_ptr; // transfer our dumb pointer from the source to our local object
        a.m_ptr = nullptr; // make sure the source no longer owns the pointer
    }

    // assignment operator that implements move semantics
    smart_ptr& operator=(smart_ptr& a) // note: not const
    {
        if (&a == this)
            return *this;

        delete m_ptr; // make sure we deallocate any pointer the destination is already holding first
        m_ptr = a.m_ptr; // then transfer our dumb pointer from the source to the local object
        a.m_ptr = nullptr; // make sure the source no longer owns the pointer
        return *this;
    }

    T& operator*() const { return *m_ptr; }
    T* operator->() const { return m_ptr; }
};

class Resource
{
public:
    Resource() { std::cout << "Resource acquired\n"; }
    ~Resource() { std::cout << "Resource destroyed\n"; }
};

int main()
{
    smart_ptr<Resource> res1(new Resource);
    smart_ptr<Resource> res2(res1);

    return 0;
}
```

- Output

```bash
Resource acquired
Resource destroyed
```

### `std::auto_ptr`, and why to avoid it

- What we have seen above as `smart_ptr` is basically an `std::auto_ptr` which was introduced in C++98, was C++'s first attempt at a standardized smart pointer.
- However, `std::auto_ptr` (and our `smart_ptr` class) has a number of problems that make using it dangerous.

1. Because `std::auto_ptr` implements move semantics through the copy constructor and assignment operator, passing an `std::auto_ptr` by value to a function will cause your resource to get moved to the function parameter (and be destroyed at the end of the function when the function parameters go out of scope). Then when you go to access your `std::auto_ptr` argument from the caller (not realizing it was transferred and deleted), you're suddenly dereferencing a null pointer. Crash!
2. `std::auto_ptr` always deletes its contents using non-array delete. This means `std::auto_ptr` won't work correctly with dynamically allocated arrays, because it uses the wrong kind of deallocation. Worse, it won't prevent you from passing it a dynamic array, which it will then mismanage, leading to memory leaks.

- Because of the above-mentioned shortcomings, `std::auto_ptr` has been deprecated in C++11, and it should not used. In fact, `std::auto_ptr` slated for complete removal from the standard library as part of C++17!
- Overriding the copy semantics to implement move semantics leads to weird edge cases and inadvertent bugs. Because of this, in C++11, the concept of "move" formally defined. And "move semantics" added to the language to properly differentiate copying from moving. In C++11, `std::auto_ptr` has been replaced by a bunch of other types of "move-aware" smart pointers: `std::scoped_ptr`, `std::unique_ptr`, `std::weak_ptr`, and `std::shared_ptr`.
- We'll also explore the two most popular of these: `std::unique_ptr` (which is a direct replacement for `std::auto_ptr`) and `std::shared_ptr`.

### std::unique\_ptr with example in C++11

- `std::unique_ptr` is the C++11 replacement for `std::auto_ptr`. It is used to manage use to manage any dynamically allocated object not shared by multiple objects. That is, `std::unique_ptr` should completely own the object it manages, not share that ownership with other classes.
- We can convert our `smart_ptr` we designed above into `std::unique_ptr`. And for that one thing, we can do is delete the copy constructor & assignment operator so that no one can copy smart pointer.
- As we are not allowing a copy of smart pointer we can't pass our smart pointer to any function by value or return by value. And this is not good design.
- To pass or return by value, we can add move constructor & move assignment operator, so that while passing or returning by value, we would have to transfer ownership through move semantics. This way we can also ensure single ownership throughout the lifetime of the object.

```cpp
template<class T>
class smart_ptr
{
    T* m_ptr;
public:
    smart_ptr(T* ptr = nullptr) : m_ptr(ptr){}

    ~smart_ptr()
    {
        delete m_ptr;
    }

    // Copy constructor
    smart_ptr(const smart_ptr& a) = delete;

    // Move constructor
    smart_ptr(smart_ptr&& a) : m_ptr(a.m_ptr)
    {
        a.m_ptr = nullptr;
    }

    // Copy assignment
    smart_ptr& operator=(const smart_ptr& a) = delete;

    // Move assignment
    smart_ptr& operator=(smart_ptr&& a)
    {        
        if (&a == this)
            return *this;

        delete m_ptr;

        m_ptr = a.m_ptr;
        a.m_ptr = nullptr;

        return *this;
    }

    T& operator*() const { return *m_ptr; }
    T* operator->() const { return m_ptr; }
};

class Resource
{
public:
    Resource() { std::cout << "Resource acquired\n"; }
    ~Resource() { std::cout << "Resource destroyed\n"; }
};

smart_ptr<Resource> func(smart_ptr<Resource> temp) 
{
  // Do something
  return temp;
}

int main()
{
    smart_ptr<Resource> res1(new Resource);
    // smart_ptr<Resource> res3 = res1; // Won't compile, as copy contructor is deleted
    smart_ptr<Resource> res3 = func(std::move(res1)); // calls move semantics

    return 0;
}
```

- Output

```bash
Resource acquired
Resource destroyed
```

- This is not the exact implementation of `std::unique_ptr` as there is deleter, implicit cast to bool & other security features included in an actual implementation, but this gives you a bigger picture of how `std::unique_ptr` is implemented.

### References

- [https://www.learncpp.com/cpp-tutorial/15-1-intro-to-smart-pointers-move-semantics/](https://www.learncpp.com/cpp-tutorial/15-1-intro-to-smart-pointers-move-semantics/)
- [https://stackoverflow.com/questions/106508/what-is-a-smart-pointer-and-when-should-i-use-one](https://stackoverflow.com/questions/106508/what-is-a-smart-pointer-and-when-should-i-use-one)
- [https://docs.microsoft.com/en-us/cpp/cpp/smart-pointers-modern-cpp?view=vs-2017](https://docs.microsoft.com/en-us/cpp/cpp/smart-pointers-modern-cpp?view=vs-2017)
