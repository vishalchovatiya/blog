---
title: "Mediator Design Pattern in Modern C++"
date: "2020-04-03"
categories: 
  - "cpp"
  - "design-patterns"
  - "software-engineering"
tags: 
  - "benefits-of-mediator-design-pattern"
  - "mediator-design-pattern-c-example"
  - "mediator-design-pattern-example-in-c"
  - "mediator-design-pattern-in-c"
  - "mediator-design-pattern-in-modern-c"
  - "mediator-design-pattern-pros-and-cons"
  - "mediator-design-pattern-use-case"
  - "mediator-pattern-c"
  - "mediator-vs-facade-design-pattern"
  - "mediator-vs-observer-design-pattern"
  - "senders-receivers-patterns"
  - "when-to-use-mediator-pattern"
featuredImage: "/images/Mediator-Design-Pattern-in-Modern-C-vishal-chovatiya.png"
---

In software engineering, Behavioural Design Patterns deal with the assignment of responsibilities between objects & encapsulating behaviour in an object to delegate requests. In this article of the Behavioural Design Patterns, we're going to take a look at Mediator Design Pattern in Modern C++. And the motivation behind the Mediator Design Pattern is **_to provide proper communication between components by letting the components be aware(or unaware also, depending upon use case) of each other's presence or absence in the system_**.

By the way, If you haven’t check out my other articles on Behavioural Design Patterns, then here is the list:

{{% include "/reusable_block/behavioural-design-patterns.md" %}}
{{% include "/reusable_block/design-pattern-prerequisites.md" %}}

## Intent

> **_To facilitates communication between objects_**.

- Mediator implements functionality that dictates \`how a set of objects interact with each other\`. It also promotes [loose coupling](https://en.wikipedia.org/wiki/Loose_coupling) by keeping objects from referring to each other explicitly. And lets you vary their interaction independently.

## Mediator Design Pattern Example in C++

- The classic & most suitable example of Mediator Design Pattern would be a chat room where your components(most likely people) may go in and out of the system at any time.
- Therefore, it makes no sense for the different participants to have direct references to one another because those references can go dead at any time.
- So the solution here is to have all of the components refer to some sort of central component which facilitates the communication and that component happens to be the mediator.

```cpp
struct ChatRoom {
    virtual void broadcast(string from, string msg) = 0;
    virtual void message(string from, string to, string msg) = 0;
};

struct Person {
    string              m_name;
    ChatRoom*           m_room{nullptr};
    vector<string>      m_chat_log;

    Person(string n) : m_name(n) {}

    void say(string msg) const { m_room->broadcast(m_name, msg); }
    void pm(string to, string msg) const { m_room->message(m_name, to, msg); }
    void receive(string from, string msg) {
        string s{from + ": \"" + msg + "\""};
        cout << "[" << m_name << "'s chat session]" << s << "\n";
        m_chat_log.emplace_back(s);
    }
};

struct GoogleChat : ChatRoom
{
    vector<Person*>     m_people;

    void broadcast(string from, string msg) {
        for (auto p : m_people)
            if (p->m_name != from)
                p->receive(from, msg);
    }

    void join(Person *p) {
        string join_msg = p->m_name + " joins the chat";
        broadcast("room", join_msg);
        p->m_room = this;
        m_people.push_back(p);
    }

    void message(string from, string to, string msg) {
        auto target = find_if(begin(m_people), end(m_people),
        [&](const Person *p) {
            return p->m_name == to;
        });

        if (target != end(m_people)) (*target)->receive(from, msg);
    }
};

int main() {
    GoogleChat room;

    Person john{"John"};
    Person jane{"Jane"};
    room.join(&john);
    room.join(&jane);
    john.say("hi room");
    jane.say("oh, hey john");

    Person simon{"Simon"};
    room.join(&simon);
    simon.say("hi everyone!");

    jane.pm("Simon", "glad you found us, simon!");

    return EXIT_SUCCESS;
}
/*  
[John's chat session]room: "Jane joins the chat"
[Jane's chat session]John: "hi room"
[John's chat session]Jane: "oh, hey john"
[John's chat session]room: "Simon joins the chat"
[Jane's chat session]room: "Simon joins the chat"
[John's chat session]Simon: "hi everyone!"
[Jane's chat session]Simon: "hi everyone!"
[Simon's chat session]Jane: "glad you found us, simon!"
*/
```

- So the takeaway from the above example is that you have a central component. In this case, it's the `GoogleChat` and every person of the chatroom has a reference or pointer to that `GoogleChat`. Thus, they all communicate exclusively through that point or so they don't communicate directly.
- They don't have any references or pointers to one another but still, they can send messages for example in this case I'm using the name of a person which has the kind of key for actually message passing and the chat room is the mediator who actually takes care of the glue. The thing which kind of binds everything together.

## Benefits of Mediator Design Pattern

1. You can replace any component in the system without affecting other component & system.
2. Mediator Design Pattern reduces the complexity of communication between the different components in a system. Thus promoting loose coupling & less number of [subclasses](/posts/memory-layout-of-cpp-object/).
3. As to overcome the limitation of the [Observer Design Pattern](/posts/observer-design-pattern-in-modern-cpp/) which works in a one-to-many relationship, Mediator Design Pattern can be employed for a many-to-many relationship.

## Summary by FAQs

**Mediator vs Facade Design Pattern?**

Mediator pattern can be seen as a multiplexed facade pattern. In mediator, instead of working with an interface of a single object, you are making a multiplexed interface among multiple objects to provide smooth transitions.

**Mediator vs Observer Design Pattern?**

- [Observer Design Pattern](/posts/observer-design-pattern-in-modern-cpp/) = one-to-many relationship  
- Mediator Design Pattern = many-to-many relationship  
Due to centralized control of communication, maintenance of the system designed using Mediator Design Pattern is easy.

**Senders & Receivers Patterns**

Chain of Responsibility, Command, Mediator, and Observer, address how you can decouple senders and receivers, but with different trade-offs. Chain of Responsibility passes a sender request along a chain of potential receivers. Command normally specifies a sender-receiver connection with a subclass. Mediator has senders and receivers reference each other indirectly. Observer defines a very decoupled interface that allows for multiple receivers to be configured at run-time.
