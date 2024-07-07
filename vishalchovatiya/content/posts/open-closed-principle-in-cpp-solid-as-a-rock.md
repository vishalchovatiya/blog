---
title: "Open Closed Principle in C++ | SOLID as a Rock"
date: "2020-04-07"
categories: 
  - "cpp"
  - "design-patterns"
  - "design-principles"
  - "software-engineering"
tags: 
  - "ciple-extensibility1"
  - "flexibility1"
  - "intent-open-closed-principle1"
  - "ion-for-extensibility-benefits-of-open-closed-prin1"
  - "le-example-in-c-adding-the-level-of-abstract1"
  - "le-open-closed-principle-code-e1"
  - "maintainability1"
  - "motivation-violating-the-ope1"
  - "n-closed-principle-solution-open-closed-princip1"
  - "open-closed-principle-c1"
  - "open-closed-principle-in-c1"
  - "open-closed-principle-in-cpp1"
  - "software-open-closed-princip1"
  - "xamples-open-closed-principle-in-c1"
  - "yardstick-to-craft-open-closed-principle-friendly-software-in-c"
featuredImage: "/images/Open-Closed-Principle-in-C-SOLID-as-a-Rock-vishal-chovatiya.webp"
---

This is the second part of a five-part article series about SOLID as Rock design principle. The SOLID design principles, when combined together, make it easy for a programmer to craft software that is easy to maintain, reuse & extend. **O**pen-**C**losed **P**rinciple(OCP) is the second principle in this series which I will discuss here with minimalistic example in [Modern C++](/posts/21-new-features-of-modern-cpp-to-use-in-your-project/) along with its benefits & generic guideline.

By the way, If you haven't gone through my previous articles on design principles, then below is the quick links:

{{% include "/reusable_block/solid-design-principles.md" %}}
{{% include "/reusable_block/design-pattern-prerequisites.md" %}}

## Intent

> **_classes should be open for extension, closed for modification_**

- This literally means you should be able to extend a classes behaviour, without modifying it. This might seems weird to you & may raise a question that how can you change the behaviour of a class without modifying it?
- But there are many answers to this in [object-oriented design](/posts/memory-layout-of-cpp-object/) like [dynamic polymorphism](/posts/part-1-all-about-virtual-keyword-in-cpp-how-virtual-function-works-internally/), [static polymorphism](/posts/7-advanced-cpp-concepts-idiom-examples-you-should-know/#CRTP), [C++ template](/posts/c-template-a-quick-uptodate-look/), etc.

## Motivation: Violating the Open Closed Principle

```cpp
enum class COLOR { RED, GREEN, BLUE };
enum class SIZE { SMALL, MEDIUM, LARGE };

struct Product {
    string  m_name;
    COLOR   m_color;
    SIZE    m_size;
};

using Items = vector<Product*>;
#define ALL(C)  begin(C), end(C)

struct ProductFilter {
    static Items by_color(Items items, const COLOR e_color) {
        Items result;
        for (auto &i : items)
            if (i->m_color == e_color)
                result.push_back(i);
        return result;
    }
    static Items by_size(Items items, const SIZE e_size) {
        Items result;
        for (auto &i : items)
            if (i->m_size == e_size)
                result.push_back(i);
        return result;
    }
    static Items by_size_and_color(Items items, const SIZE e_size, const COLOR e_color) {
        Items result;
        for (auto &i : items)
            if (i->m_size == e_size && i->m_color == e_color)
                result.push_back(i);
        return result;
    }
};

int main() {
    const Items all{
        new Product{"Apple", COLOR::GREEN, SIZE::SMALL},
        new Product{"Tree", COLOR::GREEN, SIZE::LARGE},
        new Product{"House", COLOR::BLUE, SIZE::LARGE},
    };

    for (auto &p : ProductFilter::by_color(all, COLOR::GREEN))
        cout << p->m_name << " is green\n";

    for (auto &p : ProductFilter::by_size_and_color(all, SIZE::LARGE, COLOR::GREEN))
        cout << p->m_name << " is green & large\n";

    return EXIT_SUCCESS;
}
/*
Apple is green
Tree is green
Tree is green & large
*/
```

- So we have a bunch of products & we filtered it by some of its attributes. There is nothing wrong with the above code as far as the requirement is fixed(which will never be the case in software engineering).
- But just imagine the situations: You already shipped the code to the client. Later on, requirement changes & some new filters are required. In this case, you again need to modify the class & add new filter methods.
- This is a problematic approach because we have 2 attributes(i.e. color & size) & need to implement 3 function(i.e. color, size & its combination), one more attributes & need to implement 8 functions. You see where this is going.
- You need to go again & again in the existing implemented code & have to modify it which may break other parts of code as well. This is not a scalable solution.
- The open-closed principle states that your system should be open to extension but should be closed for modification. Unfortunately what we are doing here is modifying the existing code which is a violation of OCP.

## Solution: Open Closed Principle Example in C++

There is more than one way to achieve OCP. Here I am demonstrating the popular one i.e. interface design or abstraction level. So here is our scalable solution:

### Adding the level of abstraction for extensibility

```cpp
template <typename T>
struct Specification {
    virtual ~Specification() = default;
    virtual bool is_satisfied(T *item) const = 0;
};

struct ColorSpecification : Specification<Product> {
    COLOR e_color;
    ColorSpecification(COLOR e_color) : e_color(e_color) {}
    bool is_satisfied(Product *item) const { return item->m_color == e_color; }
};

struct SizeSpecification : Specification<Product> {
    SIZE e_size;
    SizeSpecification(SIZE e_size) : e_size(e_size) {}
    bool is_satisfied(Product *item) const { return item->m_size == e_size; }
};

template <typename T>
struct Filter {
    virtual vector<T *> filter(vector<T *> items, const Specification<T> &spec) = 0;
};

struct BetterFilter : Filter<Product> {
    vector<Product *> filter(vector<Product *> items, const Specification<Product> &spec) {
        vector<Product *> result;
        for (auto &p : items)
            if (spec.is_satisfied(p))
                result.push_back(p);
        return result;
    }
};

// ------------------------------------------------------------------------------------------------
BetterFilter bf;
for (auto &x : bf.filter(all, ColorSpecification(COLOR::GREEN)))
    cout << x->m_name << " is green\n";
```

- As you can see we do not have to modify `filter` method of `BetterFilter`. It can work with all kind of `specification` now.

### For two or more combined specifications

```cpp
template <typename T>
struct AndSpecification : Specification<T> {
    const Specification<T> &first;
    const Specification<T> &second;

    AndSpecification(const Specification<T> &first, const Specification<T> &second)
    : first(first), second(second) {}

    bool is_satisfied(T *item) const { 
        return first.is_satisfied(item) && second.is_satisfied(item); 
    }
};

template <typename T>
AndSpecification<T> operator&&(const Specification<T> &first, const Specification<T> &second) {
    return {first, second};
}

// -----------------------------------------------------------------------------------------------------

auto green_things = ColorSpecification{COLOR::GREEN};
auto large_things = SizeSpecification{SIZE::LARGE};

BetterFilter bf;
for (auto &x : bf.filter(all, green_things && large_things))
    cout << x->m_name << " is green and large\n";

// warning: the following will compile but will NOT work
// auto spec2 = SizeSpecification{SIZE::LARGE} &&
//              ColorSpecification{COLOR::BLUE};
```

- `SizeSpecification{SIZE::LARGE} && ColorSpecification{COLOR::BLUE}` will not work. Experienced C++ eyes can easily recognize the reason. Though temporary object creation is a hint here. If you do so, you may get the error of [pure virtual function](/posts/part-1-all-about-virtual-keyword-in-cpp-how-virtual-function-works-internally/) as follows:

```bash
pure virtual method called
terminate called without an active exception
The terminal process terminated with exit code: 3
```

- For more than two specifications, you can use a variadic template.

## Benefits of Open Closed Principle

### \=> Extensibility

"When a single change to a program results in a cascade of changes to dependent modules, that program exhibits the undesirable attributes that we have come to associate with 'bad' design. The program becomes fragile, rigid, unpredictable and unreusable. The open-closed principle attacks this in a very straightforward way. It says that you should design modules that never change. When requirements change, you extend the behaviour of such modules by adding new code, not by changing old code that already works."  
— [Robert Martin](https://en.wikipedia.org/wiki/Robert_C._Martin)

### \=> Maintainability

- The main benefit of this approach is that an interface introduces an additional level of abstraction which enables loose coupling. The implementations of an interface are independent of each other and don’t need to share any code.
- Thus, you can easily cope-up with client's keep changing requirements. Very useful in agile methodologies.

### \=> Flexibility

- The open-closed principle also applies to plugin and middleware architecture. In that case, your base software entity is your application core functionality.
- In the case of plugins, you have a base or core module that can be plugged with new features & functionality through a common gateway interface. A good example of this is web browser extensions.
- Binary compatibility will also be in-tact in subsequent releases.

## Yardstick to Craft Open Closed Principle Friendly Software in C++

- In the SRP, you make a judgement about decomposition and where to draw encapsulation boundaries in your code. In the OCP, you make a judgement about what in your module you will make abstract and leave to your module’s consumers to make concrete, and what concrete functionality to provide yourself.
- There are many design patterns that help us to extend code without changing it. For instance, the [Decorator pattern](/posts/decorator-design-pattern-in-modern-cpp/) helps us to follow Open Close principle. Also, the [Factory Method](/posts/factory-design-pattern-in-modern-cpp/), [Strategy pattern](/posts/strategy-design-pattern-in-modern-cpp/) or the [Observer pattern](/posts/observer-design-pattern-in-modern-cpp/) might be used to design an application easy to change with minimum changes in the existing code.

## Conclusion

Keep in mind that classes can never be completely closed. There will always be unforeseen changes which require a class to be modified. However, if changes can be foreseen, such as seen above i.e. `filters`, then you have a perfect opportunity to apply the OCP to be future-ready when those change requests come rolling in.
