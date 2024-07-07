---
title: "Move Constructor & Assignment Operator With std::shared_ptr"
date: "2019-09-15"
categories: 
  - "cpp"
tags: 
  - "c-how-to-move-constructor"
  - "c-move-constructor-explained"
  - "c-move-constructor-tutorial"
  - "c-why-use-move-constructor"
  - "how-move-constructor-works"
  - "how-move-constructor-works-c"
  - "how-to-call-move-constructor"
  - "how-to-invoke-move-constructor"
  - "how-to-use-move-constructor-c"
  - "implementing-our-shared_ptr-with-move-constructor-and-assignment-operator"
  - "lvalue-reference-and-rvalue-reference"
  - "move-assignment"
  - "move-constructor"
  - "move-constructor-and-assignment-operator-with-shared_ptr"
  - "move-constructor-and-move-assignment-operator"
  - "move-constructor-c-example"
  - "move-constructor-c-header"
  - "move-constructor-how-to-use"
  - "move-constructor-in-c-example"
  - "move-constructor-in-c-geeksforgeeks"
  - "move-constructor-lvalue-rvalue"
  - "move-constructor-rvalue"
  - "move-constructor-stack-overflow"
  - "move-constructor-unique_ptr"
  - "move-constructor-with-swap"
  - "move-constructor-with-unique_ptr"
  - "move-copy-constructor-example"
  - "shared_ptr"
  - "syntax-for-move-constructor"
  - "unique_ptr"
  - "use-case-or-benefit-of-stdmove-move-constructor-c11"
  - "what-is-move-constructor-in-cpp"
  - "when-does-the-move-constructor-and-move-assignment-operator-get-called"
  - "when-is-move-constructor-called-c"
  - "why-do-we-need-move-constructor"
featuredImage: "/images/20-new-features-of-Modern-C-to-use-in-your-project.png"
---

In an earlier [article](/posts/understanding-unique-ptr-with-example-in-cpp11/), we have seen how move constructor & move assignment operators helped us in creating our own `unique_ptr`. Here we will use move constructor & assignment operator to implement unsophisticated shared\_ptr.

## Implementing Our shared\_ptr with Move Constructor & Assignment Operator

- In some cases, we have a requirement where a single resource is represented by multiple pointers. We can not accomplish this by `std::unique_ptr`. To accomplish this, we can add a new variable to our smart pointer class which keeps track of reference count at the real-time. And when the reference count goes to zero which means nobody is using that resource, we will deallocate that resource.
- Unlike `std::unique_ptr`, which is designed to singly own and manage a resource, `std::shared_ptr` is meant to solve the case where you need multiple smart pointers co-owning a resource.

```cpp
template<class T>
class smart_ptr
{
    T* m_ptr;
    uint32_t *m_refCount;
public:
    smart_ptr(T* ptr = nullptr):m_ptr(ptr)
    {
        if(m_ptr)
            m_refCount = new uint32_t(1);
        else
            m_refCount = nullptr;    
    }

    ~smart_ptr()
    {
        if(m_refCount != nullptr){
            (*m_refCount)--;
            if((*m_refCount) == 0){
                delete m_ptr;
                delete m_refCount;
            }
        } 
    }

    // Copy constructor
    smart_ptr(const smart_ptr& a)
    {
        m_ptr = a.m_ptr;
        m_refCount = a.m_refCount;
        (*m_refCount)++;
    }

    // Move constructor
    smart_ptr(smart_ptr&& a): m_ptr(a.m_ptr), m_refCount(a.m_refCount)
    {
        a.m_ptr = nullptr;
        a.m_refCount = nullptr;
    }

    // Copy assignment
    smart_ptr& operator=(const smart_ptr& a)
    {
        m_ptr = a.m_ptr;
        m_refCount = a.m_refCount;
        (*m_refCount)++;
        return *this;
    }

    // Move assignment
    smart_ptr& operator=(smart_ptr&& a)
    {
        if (&a == this)
            return *this;

        delete m_ptr;
        delete m_refCount;

        m_ptr = a.m_ptr;
        a.m_ptr = nullptr;

        m_refCount = a.m_refCount;
        a.m_refCount = nullptr;

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
    Resource *res = new Resource;
    smart_ptr<Resource> ptr1(res);
    {
        smart_ptr<Resource> ptr2(ptr1); 
            auto ptr3 = func(ptr1);     
        std::cout << "Killing one shared pointer\n";    
    }
    std::cout << "Killing another shared pointer\n";

    return 0;
}
```

- Unlike `std::unique_ptr`, which uses a single pointer internally, `std::shared_ptr` uses two pointers internally. One pointer points at the managed resource. The other points at a "control block", which is a dynamically allocated object that tracks of a bunch of stuff, including how many `std::shared_ptr` are pointing at the resource.
- Here I have only used a single variable to keep track of references pointing to resource for simplicity. The actual implementation is a bit bulky for more feature & security purpose.

## A bit about move constructor & move assignment operator

**When does the move constructor & move assignment operator get called?**

The move constructor and move assignment are called when those functions have been defined, and the argument for construction or assignment is an `r-value`. Most typically, this `r-value` will be a literal or temporary value.

- In most cases, a move constructor and move assignment operator will not be provided by default, unless the class does not have any defined copy constructors, copy assignment, move assignment, or destructors. However, the default move constructor and move assignment do the same thing as the default copy constructor and copy assignment (**make copies, not do moves**).

### `l-value` reference & `r-value` reference

- I have already written a separate [article](/posts/lvalue-rvalue-and-their-references-with-example-in-cpp/) for that.

## std::move

- In C++11, `std::move` is a standard library function that serves a single purpose -- **to convert its argument into an `r-value`**.
- Once you start using [move semantics](https://stackoverflow.com/questions/3106110/what-is-move-semantics) more regularly, you'll start to find cases where you want to invoke move semantics, but the objects you have to work with are `l-values`, not `r-values`.

### Use case or benefit of std::move

- Consider the following `swap()`function as an example:

```cpp
template<class T>
void swap(T& a, T& b) 
{ 
  T tmp { a }; // invokes copy constructor
  a = b; // invokes copy assignment
  b = tmp; // invokes copy assignment
}

int main()
{
    std::string x{ "abc" };
    std::string y{ "de" };

    swap(x, y);

    return 0;
}
```

- Above `swap()`function makes 3 copies. That leads to a lot of excessive string creation and destruction, which is slow.
- However, doing copies isn't necessary here. All we're really trying to do is swap the values of `a` and `b`, which can be accomplished just as well using 3 moves instead! So if we switch from copy semantics to move semantics, we can make our code more performant.

```cpp
template<class T>
void swap(T& a, T& b) 
{ 
  T tmp { std::move(a) }; // invokes move constructor
  a = std::move(b); // invokes move assignment
  b = std::move(tmp); // invokes move assignment
}
```

- `std::move` can also be useful when sorting an array of elements. Many sorting algorithms (such as selection sort and bubble sort) work by swapping pairs of elements. Here we can use move semantics, which is more efficient.
