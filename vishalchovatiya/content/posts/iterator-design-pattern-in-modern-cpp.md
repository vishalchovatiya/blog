---
title: "Iterator Design Pattern in Modern C++"
date: "2020-04-03"
categories: 
  - "cpp"
  - "design-patterns"
  - "software-engineering"
tags: 
  - "advantages-and-disadvantages-of-iterator-design-pattern"
  - "benefits-of-iterator-design-pattern"
  - "binary-tree-iterator"
  - "binary-tree-iterator-with-c20-co-routines"
  - "boost-iterator-facade-example"
  - "iterator-design-pattern-c"
  - "iterator-design-pattern-c-code"
  - "iterator-design-pattern-c-example"
  - "iterator-design-pattern-cpp"
  - "iterator-design-pattern-examples-in-c"
  - "iterator-design-pattern-implementation-in-c"
  - "iterator-design-pattern-in-c"
  - "iterator-design-pattern-in-modern-c"
  - "iterator-design-pattern-real-world-example"
  - "what-is-the-purpose-of-iterator-design-pattern"
cover:
    image: /images/Iterator-Design-Pattern-in-Modern-C-vishal-chovatiya.png
---

Iterator Design Pattern in Modern C++ is a heavily used pattern i.e. **_provides facility to traverse data containers sophistically_**. For simplicity, you can consider a pointer moving across an array, but the real magic comes when you get to the next element of a container, in that case, you need not know anything about how the container is constructed(like sequential(not necessarily be contiguous), associative or hashed). This is handled by the iterator.

By the way, If you haven’t check out my other articles on Behavioural Design Patterns, then here is the list:

{{% include "/reusable_block/behavioural-design-patterns.md" %}}
{{% include "/reusable_block/design-pattern-prerequisites.md" %}}

## Intent

> **_To facilitate the traversal of data structure._**

- Iterator is a core functionality of various containers provided in the standard C++ library. There are lots of cases where you're using iterators without really knowing what you're using them. For instance, if you use a [range-based for-loop](/posts/21-new-features-of-modern-cpp-to-use-in-your-project/#Range-based-for-loops) what you're essentially using is begin, end & operator++ but you don't see any of it.
- Another example is coroutines that's also something where you have a method which returns a generator but the generator actually gives you the ability to iterate itself and you don't see the iterators explicitly in this case either.

## Iterator Design Pattern Examples in C++

- A typical example to illustrate iterator is to use single dimensional array & traverse it using pointer(with the same [type](/posts/cpp-type-casting-with-example-for-c-developers/) as the element of the array). But this is a very simple & straight forward scenario where you can not imagine how important iterators are? So we will see the example of basic associative container i.e. Binary Tree.

### Binary Tree Iterator

```cpp
template<typename T>
struct BinaryTree;

template<typename T>
struct Node {
    T                   m_value = T();
    Node<T>*            m_parent{nullptr};
    Node<T>*            m_left{nullptr};
    Node<T>*            m_right{nullptr};
    BinaryTree<T>*      m_tree{nullptr};

    Node(const T& v): m_value(v) {}
    Node(const T& v, Node<T> *const l, Node<T> *const r): m_value(v), m_left(l), m_right(r) {
        this->m_left->m_tree = this->m_right->m_tree = m_tree;
        this->m_left->m_parent = this->m_right->m_parent = this;
    }
    ~Node() { delete m_left; delete m_right; }

    void set_tree(BinaryTree<T> *t) {
        m_tree = t;
        if (m_left) m_left->set_tree(t);
        if (m_right) m_right->set_tree(t);
    }
};

template<typename T>
struct BinaryTree {
    Node<T>*        m_root = nullptr;

    BinaryTree(Node<T> *const r) : m_root{r} {
        m_root->set_tree(this);
    }
    ~BinaryTree() { delete m_root; }

    /* ---------------------------- Iterator Implementation ----------------------------- */

    template<typename U>
    struct PreOrderIterator {
        Node<U> *current;

        PreOrderIterator(Node<U> *c): current(c) {}

        bool operator!=(const PreOrderIterator<U>& rhs) { return current != rhs.current; }

        PreOrderIterator<U>& operator++() {
            if (current->m_right) {
                current = current->m_right;
                while (current->m_left)
                    current = current->m_left;
            } else {
                Node<T> *p = current->m_parent;
                while (p && current == p->m_right) {
                    current = p;
                    p = p->m_parent;
                }
                current = p;
            }
            return *this;
        }

        Node<U>& operator*() { return *current; }
    };

    using iterator = PreOrderIterator<T>;

    iterator begin() {
        Node<T> *n = m_root;

        if (n)
            while (n->m_left)
                n = n->m_left;
        return iterator{n};
    }

    iterator end() { return iterator{nullptr}; }
    /* ---------------------------------------------------------------------------------- */
};

int main() {
    //         me
    //        /  \
    //   mother   father
    //      / \
    //   m'm   m'f

    BinaryTree<string> family {
        new Node<string>{"me",
            new Node<string>{"mother",
                new Node<string>{"mother's mother"},
                new Node<string>{"mother's father"}
            },
            new Node<string>{"father"}
        }
    };

    for_each(begin(family), end(family), // Works with STL algo
    [](auto&& n) {
        cout << n.m_value << endl;
    });

    for (const auto& it: family) // Works with range-based for loop as well
        cout << it.m_value << endl;

    return EXIT_SUCCESS;
}
/*  
mother's mother
mother
mother's father
me
father
mother's mother
mother
mother's father
me
father
*/
```

- The most difficult thing in the above example is implementing `PreOrderIterator::operator++`. So when we're traversing the tree in pre-order. What's happening is every time somebody calls plus-plus we need to move to the subsequent elements of the tree and this is a particularly tricky operation.
- So as you can see because we don't have any way of asynchronously yielding the elements. It becomes a really ugly chunk of code. I mean I can go through this particular implementation. But essentially it's just the preorder traversal as we use to do.

### Binary Tree Iterator with C++20 Co-routines

- In a previous example, I've deliberately skipped talking about how the traversal was actually implemented. Because if you go up and look at the `PreOrderIterator::operator++`, you can see that it's a lot of manipulations around the `current` pointer & is very ugly.
- If you ever came across recursive pre-order traversal, you know that it is very intuitive & concise as follows:

```cpp
void pre_order(root) { 
    if (root == NULL) return;    
    cout << *root << endl;
    pre_order(root->left);
    pre_order(root->right);
} 
```

- Now the problem here for not having recursion is that you simply have an operator plus-plus. That gets executed at a time and you need to somehow preserve the state between those consecutive executions.
- But there was no way of suspending execution and then resuming till C++20. Because if you could do that, you could write a proper recursive algorithm that people could actually read. And instead, we have this monstrosity which I'm not going to go through.
- Since C++20, we have a feature in C++ by which we can write above algorithm in an idiomatic way where you can actually read the algorithm and it looks like the algorithm that reflects what you read in Wikipedia or computer science books and the way this is made possible is thanks to C++ coroutines\[TODO\].

```cpp
#include <iostream>
#include <experimental/coroutine>
using namespace std;

/* Note:
include file https://github.com/lewissbaker/cppcoro/blob/master/include/cppcoro/generator.hpp
if you are not able to use `experimental::generator`.
I have used clang 9.0.0 with cppcoro library for compilation
*/

template<typename T>
struct BinaryTree;

template<typename T>
struct Node {
    T                   m_value = T();
    Node<T>*            m_parent{nullptr};
    Node<T>*            m_left{nullptr};
    Node<T>*            m_right{nullptr};
    BinaryTree<T>*      m_tree{nullptr};

    Node(const T& v): m_value(v) {}
    Node(const T& v, Node<T> *const l, Node<T> *const r): m_value(v), m_left(l), m_right(r) {
        this->m_left->m_tree = this->m_right->m_tree = m_tree;
        this->m_left->m_parent = this->m_right->m_parent = this;
    }
    ~Node() { delete m_left; delete m_right; }

    void set_tree(BinaryTree<T> *t) {
        m_tree = t;
        if (m_left) m_left->set_tree(t);
        if (m_right) m_right->set_tree(t);
    }
};

template<typename T>
struct BinaryTree {
    Node<T> *root = nullptr;

    BinaryTree(Node<T> *const r) : root{r} {
        root->set_tree(this);
    }
    ~BinaryTree() { delete root; }

    /* ------------------------------- C++ co-routines -------------------------------- */
    experimental::generator<Node<T>*> pre_order() { return pre_order_impl(root); }

    experimental::generator<Node<T>*> pre_order_impl(Node<T>* node) {
        if (node) {
            for (auto x : pre_order_impl(node->m_left))
                co_yield x;
            for (auto y : pre_order_impl(node->m_right))
                co_yield y;
            co_yield node;
        }
    }
    /* ---------------------------------------------------------------------------------- */
};

int main() {
    //         me
    //        /  \
    //   mother   father
    //      / \
    //   m'm   m'f

    BinaryTree<string> family {
        new Node<string>{"me",
            new Node<string>{"mother",
                new Node<string>{"mother's mother"},
                new Node<string>{"mother's father"}
            },
            new Node<string>{"father"}
        }
    };

    for (auto it: family.pre_order())
        cout << it->m_value << endl;

    return EXIT_SUCCESS;
}
/*
mother's mother
mother's father
mother
father
me
*/
```

- If you are unable to understand `pre_order_impl`, I would suggest you go through [this talk](https://www.youtube.com/watch?v=ZTqHjjm86Bw&t=1431s). After that `pre_order_impl` would be self explainable.
- Moreover, I have compiled above snipped using [cppcoro library](https://github.com/lewissbaker/cppcoro) with clang 9.0.0 on [wandbox](https://wandbox.org/).

### Boost Iterator Facade Design Pattern in C++

- If you have gone through my [Facade Design Pattern](/posts/facade-design-pattern-in-modern-cpp/) article, you know that the first word in the above title i.e. Facade pronounces as \`fa;sa;d\`.
- Boost Iterator Facade is quite simply a very useful base class that you can add to an iterator very quickly and intuitively i.e. define the operations which make up that iterator. And to explain that I have taken a simple singly-linked list example as below:

```cpp
#include <iostream>
#include <string>
#include <algorithm>
#include <boost/iterator/iterator_facade.hpp>
using namespace std;

struct Node {
    string      m_value;
    Node*       m_next = nullptr;

    Node(const string& v): m_value(v) {}
    Node(const string &v, Node *const parent): m_value(v) { parent->m_next = this; }
};

struct ListIterator: boost::iterator_facade<ListIterator, Node, boost::forward_traversal_tag> {
    Node*       m_current;

    ListIterator(Node *const c = nullptr): m_current(c) {}

	friend class boost::iterator_core_access;

    void increment() { m_current = m_current->m_next; }
    bool equal(const ListIterator &other) const { return other.m_current == m_current; };
    Node& dereference() const { return *m_current; }
};

int main() {
    Node alpha { "alpha" };
    Node beta { "beta", &alpha };
    Node gamma { "gamma", &beta };

    for_each(ListIterator{&alpha}, ListIterator{}, 
	[ ](const Node& n) {
		cout << n.m_value << endl;
	});

    return EXIT_SUCCESS;
}
```

- Some quick things to note here:
    - Inheritance mention the type of traversal by `boost::forward_traversal_tag`.
    - We have some override methods like `increment()`, `equal()`, `dereference()`, etc.

You can read more about it in boost [Iterator Facade Documentation](https://www.boost.org/doc/libs/1_65_0/libs/iterator/doc/iterator_facade.html).

## Benefits of Iterator Design Pattern

1. Maintains good cohesion which means code is easier to understand, use & test since the iterator uses the [Single Responsibility Principle](/posts/single-responsibility-principle-in-cpp-solid-as-a-rock/) and [Open-Closed Principle](/posts/open-closed-principle-in-cpp-solid-as-a-rock/).
2. Loose coupling between data structures & algorithm as an algorithm does not have to know the way of traversal & even underlying data structure in some cases.
3. You can extend the Iterators to traverse collection & collection of the collections.
4. You can combine the Visitor & Iterator Design Pattern to traverse & execute some operation over the collection of different types.

## Summary by FAQs

**What is the purpose of Iterator Design Pattern?**

To abstract away the underlying structure in which the data are kept for traversal & operations.

**How do I use Iterator for traversing the collection of the collections?**

[Composite design pattern](/posts/composite-design-pattern-in-modern-cpp/)
