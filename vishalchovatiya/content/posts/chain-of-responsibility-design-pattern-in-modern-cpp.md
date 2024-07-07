---
title: "Chain of Responsibility Design Pattern in Modern C++"
date: "2020-04-03"
categories: 
  - "cpp"
  - "design-patterns"
  - "software-engineering"
tags: 
  - "advantages-and-disadvantages-of-chain-of-responsibility-design-pattern"
  - "benefits-of-chain-of-responsibility-design-pattern"
  - "boost-example-for-chain-of-responsibility-design-pattern"
  - "chain-of-responsibility-c"
  - "chain-of-responsibility-command-design-pattern"
  - "chain-of-responsibility-design-pattern-cpp"
  - "chain-of-responsibility-design-pattern-in-c"
  - "chain-of-responsibility-design-pattern-in-c-2"
  - "chain-of-responsibility-design-pattern-in-modern-c"
  - "chain-of-responsibility-design-pattern-pros-and-cons"
  - "chain-of-responsibility-design-pattern-python"
  - "chain-of-responsibility-design-pattern-use-case"
  - "chain-of-responsibility-design-pattern-vs-decorator"
  - "chain-of-responsibility-pattern-c"
  - "chain-of-responsibility-vs-command-pattern"
  - "classic-examples-for-chain-of-responsibility-design-pattern-in-c"
  - "launch-and-leave"
  - "when-should-i-use-chain-of-responsibility-design-pattern"
  - "when-to-use-chain-of-responsibility-pattern"
cover:
    image: /images/Chain-of-Responsibility-Design-Pattern-in-Modern-C-vishal-chovatiya.png
---

Chain of Responsibility is a Behavioural Design Pattern that **_provides facility to propagate event/request/command/query to the chain of loosely coupled objects_**. Chain of Responsibility Design Pattern in Modern C++ lets you pass requests along a chain of handlers & upon receiving a request, each handler decides either to process the request or to forward it to the next handler in the chain.

By the way, If you haven’t check out my other articles on Behavioural Design Patterns, then here is the list:

{{% include "/reusable_block/behavioural-design-patterns.md" %}}
{{% include "/reusable_block/design-pattern-prerequisites.md" %}}

## Intent

> **_To provide the chance to handle the request by more than one object/component._**

- Chain of Responsibility Design Pattern is a chain of loosely coupled objects who all get a chance to process command/query. And they may have some sort of default processing implementation and/or they can also terminate the processing chain and thereby preventing propagation of the event to the rest of the objects.
- In other words, its **_processing pipeline where you just launch-and-leave_**.

## Classic Examples for Chain of Responsibility Design Pattern in C++

- A typical use-case for Chain of Responsibility is the login process. That requires a certain number of steps to complete successfully like user name, password, captcha, etc. to matched properly. Consider the following traditional example for the same:

```cpp
struct Authentication {
	Authentication*     m_next{nullptr};

	virtual bool authenticate() = 0;
	void next_authentication(Authentication *nextAuth) { m_next = nextAuth; }
};

struct UserName : Authentication {
	string      m_name;

	UserName(string name) : m_name(name){}
	bool is_valid_user_name() { return true; }
	bool authenticate() {
		if(!is_valid_user_name()) {
			cout << "Invalid user name" << endl;
            return false;
		}
        else if(m_next) return m_next->authenticate();
        return true;
	}
};

struct Password : Authentication {
	string      m_password;

	Password(string password) : m_password(password){}
	bool is_valid_password() { return true; }
	bool authenticate() {
        if(!is_valid_password()) {
			cout << "Invalid password" << endl;
            return false;
		}
        else if(m_next) return m_next->authenticate();
        return true;
	}
};

int main() {
	Authentication *login{new UserName("John")};
	login->next_authentication(new Password("password"));
	login->authenticate();
	return EXIT_SUCCESS;
}
```

- I know this is not a very good example but sufficient to convey an idea of Chain of Responsibility. As you can see above, Login is a single process which requires multiple subprocesses to be carried out like username & password authentication.
- So in our case `login->authenticate();` fires the chain of responsibility to verify each step required for login one-by-one.
- You can also add more steps in the login process, for example, to add captcha, create captcha class inherited with `Authentication` & add that class object pointer in the login's next authentication chain as we did for `UserName` & `Password`.
- Now before we move on to the more sophisticated implementations I just wanted to mention the fact that this particular implementation of a chain of responsibility seems quite artificial. Because essentially what's happening here is you're building a singly linked list so the question is well why not just use a `std::list` or a `std::vector`. It's certainly a very valid concern. But as I mentioned earlier, this is how people used to build chain irresponsibilities.

## Boost Example for Chain of Responsibility Design Pattern

- What you going to see now is a modern way of implementing the Chain of Responsibility Design Pattern that is known as [Event Broker](https://en.wikipedia.org/wiki/Broker_pattern). Which is actually a combination of several design patterns like [Command](/posts/command-design-pattern-in-modern-cpp/), [Mediator](/posts/mediator-design-pattern-in-modern-cpp/) & [Observer](/posts/observer-design-pattern-in-modern-cpp/).

```cpp
#include <iostream>
#include <string>
using namespace std;
#include <boost/signals2.hpp>
//using namespace boost::signals2;

struct Query {                          // Command
    int32_t     m_cnt{0};
};

struct EventObserver {                  // Observer
    boost::signals2::signal<void(Query &)>       m_handlers;
};

struct ExampleClass : EventObserver {   // Mediator
    void generate_event() { 
        cout << "Event generated" << endl;
        Query   q;
        m_handlers(q); 
        cout << endl;
    }
};

struct BaseHandler {
    ExampleClass&       m_example;
};

struct Handler_1 : BaseHandler {
    boost::signals2::connection      m_conn;

    Handler_1(ExampleClass &example) : BaseHandler{example}
    {
        m_conn = m_example.m_handlers.connect([&](Query &q) {
            cout << "Serving by Handler_1 : count = " << ++q.m_cnt << endl;
        });
    }
    ~Handler_1() { m_conn.disconnect(); }
};

struct Handler_2 : BaseHandler {
    boost::signals2::connection      m_conn;

    Handler_2(ExampleClass &example) : BaseHandler{example}
    {
        m_conn = m_example.m_handlers.connect([&](Query &q) {
            cout << "Serving by Handler_2 : count = " << ++q.m_cnt << endl;
        });
    }
    ~Handler_2() { m_conn.disconnect(); }
};

int main() {
    ExampleClass example;
    Handler_1 applyThisHandlerOn{example};

    example.generate_event();       // Will be served by Handler_1

    { 
        Handler_2 TemporaryHandler{example};
        example.generate_event();   // Will be served by Handler_1 & Handler_2
    }

    example.generate_event();       // Will be served by Handler_1
    return EXIT_SUCCESS;
}
/*
Event generated
Serving by Handler_1 : count = 1

Event generated
Serving by Handler_1 : count = 1
Serving by Handler_2 : count = 2

Event generated
Serving by Handler_1 : count = 1
*/
```

- So as you can see, we have `ExampleClass` which generates an event & having `boost::signal2` as an observer. We have `Query`(i.e. [Command Design Pattern](/posts/command-design-pattern-in-modern-cpp/)) to pass between all the register handlers.
- Then we have handler arrangement which registers the [lambda function](/posts/learn-lambda-function-in-cpp-with-example/) to handle the event in constructor & same will be de-register in the destructor.
- In main, we have facilitated the ad-hoc registration of handlers just by declaring objects which process the `Query` passed in `ExampleClass::generate_event()` Handler automatically de-registers itself when it goes out of scope thanks to [RAII](https://en.cppreference.com/w/cpp/language/raii).

## Benefits of Chain of Responsibility Design Pattern

1. Decouples the sender & receiver as we saw a more sophisticated approach using [Mediator](/posts/mediator-design-pattern-in-modern-cpp/) & [Command Design Pattern](/posts/command-design-pattern-in-modern-cpp/).
2. Simplifies code as the object which is generating event does not need to know the chain structure & command/query.
3. Enhances flexibility of object assigned duties. By changing the members within the chain or change their order, allow dynamically adding or deleting responsibility.
4. Increase extensibility as adding a new handler is very convenient.

## Summary by FAQs

**Can I use(or Difference) Chain of Responsibility Design Pattern over Decorator?**

- When you in need of multiple Decorator.  
- While you want to add new functionality dynamically.  
- When you want a change of order in functionality configurable.  
- For example, you created Decorator of `WalkingAnimal` & `BarkingAnimal` of `Animal`, and now you want both combined at run-time. In such case Chain of Responsibility would be the right choice.

**When should I use Chain of Responsibility Design Pattern?**

- When there is more than one object to service a request.  
- These objects & its order determined at run time on the basis of request type.  
- When you do not want to bind request & handler tightly.
