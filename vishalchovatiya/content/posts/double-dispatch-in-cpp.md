---
title: "Double Dispatch in C++: Recover Original Type of the Object Pointed by Base Class Pointer"
date: "2020-04-11"
categories: 
  - "cpp"
tags: 
  - "base-class-pointer-to-derived-class-object-c"
  - "base-class-reference-derived-class-object-c"
  - "benefits-of-double-dispatch-mechanism"
  - "c-double-dispatch-polymorphism"
  - "double-dispatch-c"
  - "double-dispatch-c-definition"
  - "double-dispatch-c-example"
  - "double-dispatch-c-stack-overflow"
  - "double-dispatch-in-c"
  - "double-dispatch-in-modern-c-using-stdvariant-stdvisit"
  - "double-dispatch-pattern-c"
  - "double-dispatch-polymorphism-c"
  - "double-dispatch-visitor-pattern-c"
  - "dual-dispatch-in-c"
  - "exploiting-polymorphism-instead-of-double-dispatch"
  - "how-does-double-dispatch-mechanism-work"
  - "more-functional-modular-approach-to-double-dispatch"
  - "motivation-for-double-dispatch"
  - "problems-with-the-single-dispatch-approach"
  - "recover-original-type-of-the-object-pointed-by-base-class-pointer"
  - "run-time-type-identification-double-dispatch"
  - "single-dispatch"
  - "usecase-of-double-dispatch-mechanism"
  - "visitor-pattern-c"
  - "what-is-double-dispatch-in-c"
featuredImage: "/images/double-dispatch-in-C-visitor-design-pattern-www_vishalchovatiya_com.png"
---

Double Dispatch in C++ is a mechanism that dispatches **_a function call to different concrete functions depending on the runtime types of two objects involved in the call_**.  In more simple words, its function calling using two different virtual tables of respective two objects. I know this sounds cryptic, but don't worry I will come to double dispatch solution after trying most of the naive solution so that you will come away with the full understanding of concept without having needless confusions.

## Motivation

- At first, a pointer to a base class made sense; you didn’t need to know the actual derived class. So you decided to expose a single collection of base class pointers to your clients like so:

```cpp
struct Animal {
    virtual const char *name() = 0;
};

using AnimalList = vector<Animal*>;
```

- As you added your first few classes, your assumptions were validated; you never needed to know the actual type.

```cpp
struct Cat : Animal {
    const char *name() { return "Cat"; }
};

struct Dog : Animal {
    const char *name() { return "Dog"; }
};
```

- But the requirements change.
- One day the client came to you and said "I’m trying to model a person that is afraid of dogs, so they run away when they see one. But they love cats, so they try to pet them when they see them."
- Dammit. Now your assumptions are wrong. You do need to know the type. And you’re under pressure to meet a deadline.

## Run-Time Type Identification

- Then you thought "Well there’s only two types of animals, this isn’t so bad". So you wrote code like this:

```cpp
struct Person {
    void ReactTo(Animal *_animal) {
        if (dynamic_cast<Dog *>(_animal))
            RunAwayFrom(_animal);
        else if (dynamic_cast<Cat *>(_animal))
            TryToPet(_animal);
    }

    void RunAwayFrom(Animal *_animal) { cout << "Run Away From " << _animal->name() << endl; }
    void TryToPet(Animal *_animal) { cout << "Try To Pet " << _animal->name() << endl; }
};
```

- Then the client said that if the `Animal` was a `Horse`, they wanted to try to ride it.

```cpp
void Person::ReactTo(Animal *_animal) {
    if (dynamic_cast<Dog *>(_animal))
        RunAwayFrom(_animal);
    else if (dynamic_cast<Cat *>(_animal))
        TryToPet(_animal);
    else if (dynamic_cast<Horse *>(_animal))
        TryToRide(_animal);
}
```

- You see this is going crazy. At some point in future, you might not like working with your own code. We've all been there. Nonetheless, the trend continued for some time until you may found yourself with a mess like this:

```cpp
void Person::ReactTo(Animal *_animal) {
    if (dynamic_cast<Dog *>(_animal) || dynamic_cast<Gerbil *>(_animal)) {
        if (dynamic_cast<Dog *>(_animal) && dynamic_cast<Dog>()->GetBreed() == DogBreed.Daschund) // Daschund's are the exception
            TryToPet(_animal);
        else
            RunAwayFrom(_animal);
    }
    else if (dynamic_cast<Cat *>(_animal) || dynamic_cast<Pig *>(_animal))
        TryToPet(_animal);
    else if (dynamic_cast<Horse *>(_animal))
        TryToRide(_animal);
    else if (dynamic_cast<Lizard *>(_animal))
        TryToFeed(_animal);
    else if (dynamic_cast<Mole *>(_animal))
        Attack(_animal)
    // etc.
}
```

- This list is getting pretty long, you thought to yourself one day. All these [dynamic_cast<>()](/posts/cpp-type-casting-with-example-for-c-developers/) seem wrong, and they're kind of slow as well. So on a side note of refactorization, you come up with a solution which identifies `typeid()`, this is a bit faster than [`dynamic_cast<>()`](/posts/cpp-type-casting-with-example-for-c-developers/) but still, it's not optimum performance.

## Exploiting Polymorphism

- As someone from your senior/mentor suggests you to use an enum with polymorphic methods to identify type & you wrote following code:

```cpp
enum class AnimalType { Dog, Cat };

struct Animal {
    virtual const char *name() = 0;
    virtual AnimalType type() = 0;
};

struct Cat : Animal {
    const char *name() { return "Cat"; }
    AnimalType type() { return AnimalType::Cat; }
};

struct Dog : Animal {
    const char *name() { return "Dog"; }
    AnimalType type() { return AnimalType::Dog; }
};

struct Person {
    void ReactTo(Animal *_animal) {
        if (_animal->type() == AnimalType::Cat)
            TryToPet(_animal);
        else if (_animal->type() == AnimalType::Dog)
            RunAwayFrom(_animal);
    }

    void RunAwayFrom(Animal *_animal) { cout << "Run Away From " << _animal->name() << endl; }
    void TryToPet(Animal *_animal) { cout << "Try To Pet " << _animal->name() << endl; }
};

int main() {
    Person p;

    Animal *animal_0 = new Dog;
    p.ReactTo(animal_0);

    Animal *animal_1 = new Cat;
    p.ReactTo(animal_1);
    return 0;
}
```

- You may get the performance improvement, but still, you will be left with a long list of `if/else-if`.

## More Functional & Modular Approach

```cpp
using PersonMethodPtr = void (Person::*)(Animal *);
using ReactionHash = unordered_map<AnimalType, PersonMethodPtr>;

void Person::ReactTo(Animal *_animal)
{
    static const ReactionHash reactionFunctions{
        {AnimalType::Cat, &TryToPet},
        {AnimalType::Dog, &RunAwayFrom},
        // etc.
    };

    reactionFunctions[_animal->type()](_animal);
}

```

- But here you are indirectly writing your own [virtual table](/posts/part-1-all-about-virtual-keyword-in-cpp-how-virtual-function-works-internally/)(a very bad virtual table) which may not provide any performance gain at all, thanks to the overhead of hashing & lookup. Moreover, you are paying a little extra in memory to store your lookup table.

## Single-Dispatch

- So rather than keeping any identifier for each type or RTTI, we can use a middle man to route function call to appropriate behaviour.

```cpp
struct Animal {
    virtual string name() = 0;
    virtual void Visit(class ReactVisitor *visitor) = 0;
};

struct ReactVisitor {
    class Person *person = nullptr;
};

struct Person {
    void ReactTo(Animal *_animal) {
        ReactVisitor visitor{this};
        _animal->Visit(&visitor);
    }

    void RunAwayFrom(Animal *_animal) { cout << "Run Away From " << _animal->name() << endl; }

    void TryToPet(Animal *_animal) { cout << "Try To Pet " << _animal->name() << endl; }
};

struct Cat : public Animal {
    string name() { return "Cat"; }
    void Visit(ReactVisitor *visitor) { visitor->person->TryToPet(this); }
};

struct Dog : public Animal {
    string name() { return "Dog"; }
    void Visit(ReactVisitor *visitor) { visitor->person->RunAwayFrom(this); }
};

int main() {
    Person p;
    vector<Animal*> animals = {new Dog, new Cat};
    
    for(auto&& animal : animals)
        p.ReactTo(animal);    
    
    return 0;
}
```

- To keep the middle man to a route function call, we have to add `visit(ReactVisitor *)` method which accepts middle man i.e. `ReactVisitor` as a parameter. Then we add appropriate behaviour to each type of `Animal` i.e. `Dog` & `Cat`.

### Problems With the Single Dispatch Approach

1. Why should the `Dog` class dictate how a `Person` reacts to it? We have leaked implementation details of the `Person` class and therefore have violated encapsulation.
2. What if the `Person` class has other behaviours they want to implement? Are we really going to add a new [virtual method](/posts/part-1-all-about-virtual-keyword-in-cpp-how-virtual-function-works-internally/) on the base class for each of them?

The solution to the above problem will lead us to use Double-Dispatch Mechanism.

## Double Dispatch in C++

- We can overcome the shortcoming of Single-Dispatch by adding one more layer of indirection(i.e. `AnimalVisitor`).

```cpp
/* -------------------------------- Added Visitor Classes ------------------------------- */
struct AnimalVisitor {
    virtual void Visit(struct Cat *) = 0;
    virtual void Visit(struct Dog *) = 0;
};

struct ReactVisitor : AnimalVisitor {
    ReactVisitor(struct Person *p) : person{p} {}
    void Visit(struct Cat *c);
    void Visit(struct Dog *d);
    struct Person *person = nullptr;
};
/* --------------------------------------------------------------------------------------- */


struct Animal {
    virtual string name() = 0;
    virtual void Visit(struct AnimalVisitor *visitor) = 0;      
};
struct Cat : Animal {
    string name() { return "Cat"; }
    void Visit(AnimalVisitor *visitor) { visitor->Visit(this); } // 2nd dispatch <<---------
};
struct Dog : Animal {
    string name() { return "Dog"; }
    void Visit(AnimalVisitor *visitor) { visitor->Visit(this); } // 2nd dispatch <<---------
};


struct Person {
    void ReactTo(Animal *_animal) {
        ReactVisitor visitor{this};
        _animal->Visit(&visitor);   // 1st dispatch <<---------
    }
    void RunAwayFrom(Animal *_animal) { cout << "Run Away From " << _animal->name() << endl; }
    void TryToPet(Animal *_animal) { cout << "Try To Pet " << _animal->name() << endl; }
};

/* -------------------------------- Added Visitor Methods ------------------------------- */
void ReactVisitor::Visit(Cat *c) { // Finally comes here <<-------------
    person->TryToPet(c);
}
void ReactVisitor::Visit(Dog *d) { // Finally comes here <<-------------
    person->RunAwayFrom(d);
}
/* --------------------------------------------------------------------------------------- */

int main() {
    Person p;
    for(auto&& animal : vector<Animal*>{new Dog, new Cat})
        p.ReactTo(animal);
    return 0;
}
```

- As you can see above, rather depending directly on `ReactVisitor`, we have taken `AnimalVisitor` as one more layer of indirection. And `visit(AnimalVisitor *)` method in `Cat` & `Dog` class accept `AnimalVisitor` as a parameter.
- This gives us two benefits, i). we do not have to write person's behaviour in `Cat` & `Dog` class, so we are not breaking the rule of encapsulation, and ii). we are clubbing the reaction of Person in a separate class(i.e. `ReactVisitor`), so we are encouraging the [Single Responsibility Principle](/posts/single-responsibility-principle-in-cpp-solid-as-a-rock/).

## How does Double Dispatch Mechanism work?

I know so things are getting complex, but it is reasonably complex I would say. Function stack frame & single image of function calling chain with code snippet will simplify it a lot.

![](/images/double-dispatch-cpp-stack-frame-vishal-chovatiya.gif)

- From `Person::ReactTo`, we call `Animal::visit`, which will dispatch to the appropriate overridden visit i.e. either `Cat::visit` or `Dog::visit`.
- From the overridden `Cat::visit(AnimalVisitor*)`, we call `AnimalVisitor::visit`, which will again dispatch to the appropriate overridden i.e. either `ReactionVisitor::visit(Cat*) or `ReactionVisitor::visit(Dog*)`.

## Alternate Approach to Double Dispatch in Modern C++ using std::variant & std::visit

```cpp
struct Animal {
    virtual string name() = 0;
};

struct Cat : Animal {
    string name() { return "Cat"; }
};

struct Dog : Animal {
    string name() { return "Dog"; }
};

struct Person {
    void RunAwayFrom(Animal *animal) { cout << "Run Away From " << animal->name() << endl; }
    void TryToPet(Animal *animal) { cout << "Try To Pet " << animal->name() << endl; }
};

struct ReactVisitor {
    void operator()(Cat *c) { person->TryToPet(c); }
    void operator()(Dog *d){ person->RunAwayFrom(d); }
    Person *person = nullptr;
};

using animal_ptr = std::variant<Cat*, Dog*>;

int main() {
    Person p;
    ReactVisitor rv{&p};

    for(auto&& animal : vector<animal_ptr>({new Dog, new Cat}))
        std::visit(rv, animal);

    return 0;
}
```

- So for those of you who are not familiar with the `std::variant`, you can consider it as a union. And line `std::variant<Cat*, Dog*>`, suggest that you can use/assign/access either `Cat*` or `Dog*` at a time.
- And [Modern C++](/posts/21-new-features-of-modern-cpp-to-use-in-your-project/) provide us `std::visit` which accept callable i.e. `ReactVisitor` in our case having overloaded function operator for each type and `std::variant`. You also make use of [lambda functions](/posts/learn-lambda-function-in-cpp-with-example/) rather using functor i.e. `ReactVisitor`.

## Benefits of Double Dispatch Mechanism

1. Adhering [Single Responsibility Principle](/posts/single-responsibility-principle-in-cpp-solid-as-a-rock/) meaning separating type-specific logic in the separate entity/class. In our case, `ReactVisitor` only handles the reaction for different Animal types.
2. Adhering [Open-Closed Principle](/posts/open-closed-principle-in-cpp-solid-as-a-rock/) meaning new functionality can be added without touching any class headers once we inserted `visit()` method for hierarchy, For example, if you want to add `sound()`method for each different Animal, you can create `SoundVisitor` & rest of the edit goes as same `ReactVisitor`.
3. This will be much useful when you already have done the unit-testing for your entire hierarchy, and now you do not want to touch that & wants to add new functionality.
4. Performance over `dynamic_cast`, `typeid()`and check for `enum`/`string` comparison.

## Usecase of Double Dispatch Mechanism

1. Sorting a mixed set of objects: You can implement filtering with double-dispatch. E.g., "Give me all the`Cats` from a `vector<Animal*>`".
2. You can add additional functionality to the whole inheritance hierarchy without modifying it over & over E.g. if you want to add `sound()`method for each different Animal, you can create `SoundVisitor` & rest of the edit goes as same `ReactVisitor`.
3. Event handling systems that use both the event type and the type of the receptor object in order to call the correct event handling routine.
4. [Adaptive collision algorithms](https://en.wikipedia.org/wiki/Double_dispatch#Double_dispatch_in_C++) usually require that collisions between different objects be handled in different ways. A typical example is in a game environment where the collision between a spaceship and an asteroid is computed differently from the collision between a spaceship and a space station.

## Conclusion

Each solution has its advantages and issues, and choosing one depends on the exact needs of your project. C++ presents unique challenges in designing such high-level abstractions because it's comparatively rigid and statically typed. Abstractions in C++ also tend to strive to be as cheap as possible in terms of runtime performance and memory consumption, which adds another dimension of complexity to the problem.

## Reference

This article becomes by-product while I was writing about classic [Visitor Design Pattern](/posts/double-dispatch-visitor-design-pattern-in-modern-cpp/) because without double dispatch mechanism in C++ classic visitor doesn't exist. Most of the credit for this article & images goes to [Andy G](https://gieseanw.wordpress.com/2018/12/29/reuse-double-dispatch/). The code snippets you see in this article is simplified not sophisticated.
