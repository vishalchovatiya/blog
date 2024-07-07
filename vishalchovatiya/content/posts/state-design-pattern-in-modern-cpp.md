---
title: "State Design Pattern in Modern C++"
date: "2020-04-02"
categories: 
  - "cpp"
  - "design-patterns"
  - "software-engineering"
tags: 
  - "benefits-of-state-design-pattern"
  - "classical-state-design-pattern"
  - "difference-between-switch-case-statement-state-machine-implemented-by-switch-case-syntax"
  - "functional-approach-to-state-design-pattern"
  - "how-to-use-state-pattern-rapidly-correctly"
  - "modular-approach-to-state-design-pattern"
  - "state-design-pattern-c"
  - "state-design-pattern-examples-in-c"
  - "state-design-pattern-in-modern-c"
  - "state-machine"
  - "state-machine-design-pattern-c-example"
  - "state-machine-design-using-stdvisit-stdvariant"
  - "state-pattern-c"
  - "state-pattern-c-example"
  - "state-pattern-cpp"
  - "use-cases-of-state-design-pattern"
featuredImage: "/images/State-Design-Pattern-in-Modern-C-vishal-chovatiya.png"
---

A State Design Pattern is a type of Behavioural Design Pattern that defines objects behaviour(defined as a state) based on some event happens. And that can be the internal or external event. For example, if you design an ATM machine using the State Design Pattern, the external event could be someone inserted debit/credit card & internal event could be a user timeout. So in nutshell, the State Design Pattern in Modern C++ is a **_systematic way to implement certain behaviour on a particular event considering the context_**.

By the way, If you haven’t check out my other articles on Behavioural Design Patterns, then here is the list:

{{% include "/reusable_block/behavioural-design-patterns.md" %}}
{{% include "/reusable_block/design-pattern-prerequisites.md" %}}

## Intent

> **_To implement the object's behaviour determined by its state._**

- A State Design Pattern is to implement the [object](/posts/inside-the-cpp-object-model/)'s behaviour depending upon its state which also clarifies the transition from one state to another state. **_A formalized construct which manages states & transition is called a state machine_**.
- The State Design Pattern solves two main problems:
    1. An object should change its behaviour when its internal state changes.
    2. State-specific behaviour should define independently(i.e. in class). So, adding new states should not affect the behaviour of existing states.

## State Design Pattern Examples in C++

![](/images/State-Design-Pattern-Example-in-C-www_vishalchovatiya_com.png)

- Consider the above simple diagram to model three different states along with respective triggers for the transition. We will first see the classical approach where we implement state transition using polymorphism & then move to Modern & Modular approach which involves [std::variant](https://en.cppreference.com/w/cpp/utility/variant) & [std::visit](https://en.cppreference.com/w/cpp/utility/variant/visit).

### Classical State Design Pattern

```cpp
/* --------------------------------- Events ------------------------------------------ */
enum event { connect, connected, disconnect, timeout };

inline ostream &operator<<(ostream &os, const event &e) {
    switch (e) {
        case event::connect: os << "connect"; break;
        case event::connected: os << "connected"; break;
        case event::disconnect: os << "disconnect"; break;
        case event::timeout: os << "timeout"; break;
    }
    return os;
}
/* ------------------------------------------------------------------------------------- */



struct State {
    virtual unique_ptr<State> on_event(event e) = 0;
};

/* --------------------------------- States ------------------------------------------ */
struct Idle : State {
    unique_ptr<State> on_event(event e);
};

struct Connecting : State {
    unique_ptr<State> on_event(event e);

private:
    uint32_t                    m_trial = 0;
    static constexpr uint8_t    m_max_trial = 3;
};

struct Connected : State {
    unique_ptr<State> on_event(event e);
};
/* ------------------------------------------------------------------------------------- */




/* ------------------------------- Transitions ---------------------------------------- */
unique_ptr<State> Idle::on_event(event e) {
    cout << "Idle -> " << e << endl;
    if (e == event::connect) return make_unique<Connecting>();
    return nullptr;
}

unique_ptr<State> Connecting::on_event(event e) {
    cout << "Connecting -> " << e << endl;
    switch (e) {
        case event::connected: return make_unique<Connected>();
        case event::timeout: return ++m_trial < m_max_trial ? nullptr : make_unique<Idle>();
    }
    return nullptr;
}

unique_ptr<State> Connected::on_event(event e) {
    cout << "Connected -> " << e << endl;
    if (e == event::disconnect) return make_unique<Idle>();
    return nullptr;
}
/* ------------------------------------------------------------------------------------- */

struct Bluetooth {
    unique_ptr<State> m_curr_state = make_unique<Idle>();

    void dispatch(event e) {
        auto new_state = m_curr_state->on_event(e);
        if (new_state)
            m_curr_state = move(new_state);
    }

    template <typename... Events>
    void establish_connection(Events... e) { (dispatch(e), ...); }
};

int main() {
    Bluetooth bl;
    bl.establish_connection(event::connect, event::timeout, event::connected, event::disconnect);
    return EXIT_SUCCESS;
}
/*  
Idle -> connect
Connecting -> timeout
Connecting -> connected
Connected -> disconnect
*/
```

- Two subtle part here to take into the account is
    1. How we modelled triggers(i.e. events) & states, by considering state machine diagram.
    2. And how we have fired steps to establish the connection using [Variadic Template](/posts/variadic-template-cpp-implementing-unsophisticated-tuple/) Method & Fold expression.
- Rest of the code is self-explainable though.

### Functional Approach to State Design Pattern

- State Design Pattern is bizarre design patterns if you look at the classic definition of it. You will see something very different from how we actually build state machines nowadays so it's a completely different paradigm. Now we see more Modern & Functional approach to address this problem.

```cpp
/* --------------------------------- Events ------------------------------------------ */
struct EventConnect { string m_address; };
struct EventConnected { };
struct EventDisconnect { };
struct EventTimeout { };

using Event = variant<EventConnect, EventConnected, EventDisconnect, EventTimeout>;
/* ------------------------------------------------------------------------------------- */


/* --------------------------------- States ------------------------------------------ */
struct Idle { };
struct Connecting {
    string                      m_address;
    uint32_t                    m_trial = 0;
    static constexpr uint8_t    m_max_trial = 3;
};
struct Connected { };

using State = variant<Idle, Connecting, Connected>;
/* ------------------------------------------------------------------------------------- */


/* ------------------------------- Transitions ---------------------------------------- */
struct Transitions {
    optional<State> operator()(Idle &, const EventConnect &e) {
        cout << "Idle -> Connect" << endl;
        return Connecting{e.m_address};
    }

    optional<State> operator()(Connecting &, const EventConnected &) {
        cout << "Connecting -> Connected" << endl;
        return Connected{};
    }

    optional<State> operator()(Connecting &s, const EventTimeout &) {
        cout << "Connecting -> Timeout" << endl;
        return ++s.m_trial < Connecting::m_max_trial ? nullopt : optional<State>(Idle{});
    }

    optional<State> operator()(Connected &, const EventDisconnect &) {
        cout << "Connected -> Disconnect" << endl;
        return Idle{};
    }

    template <typename State_t, typename Event_t>
    optional<State> operator()(State_t &, const Event_t &) const {
        cout << "Unkown" << endl;
        return nullopt;
    }
};

/* ------------------------------------------------------------------------------------- */
template <typename StateVariant, typename EventVariant, typename Transitions>
struct Bluetooth {
    StateVariant m_curr_state;

    void dispatch(const EventVariant &Event)
    {
        optional<StateVariant> new_state = visit(Transitions{}, m_curr_state, Event);
        if (new_state)
            m_curr_state = *move(new_state);
    }

    template <typename... Events>
    void establish_connection(Events... e) { (dispatch(e), ...); }
};

int main() {
    Bluetooth<State, Event, Transitions> bl;
    bl.establish_connection(EventConnect{"AA:BB:CC:DD"},
                            EventTimeout{},
                            EventConnected{},
                            EventDisconnect{});
    return EXIT_SUCCESS;
}
/*
Idle -> Connect
Connecting -> Timeout
Connecting -> Connected
Connected -> Disconnect
*/
```

- A classical approach is not loosely coupled between events & states if you compare the above example. The changes in the sequence of events or adding new events will impact the condition part of states implemented in `on_event()`which violates the [Open-Closed Principle](/posts/open-closed-principle-in-cpp-solid-as-a-rock/).
- But in the case of Functional approach events & states are not related or coupled. Rather it works in combination defined in the transition class. This gives a lot of flexibility along with preserving the [Single Responsibility Principle](/posts/single-responsibility-principle-in-cpp-solid-as-a-rock/) & [Open-Closed Principle](/posts/open-closed-principle-in-cpp-solid-as-a-rock/).

### Modular Approach to State Design Pattern

- We have already seen the Functional approach to State Design Pattern with Modern C++ above which is very practical & scalable. But still, there are some of the devs who are not using C++17 yet.
- So we will consider a modular approach to this by implementing the transition table with different example this time. I'm going to model a phone call & phone can be in several different states. And I'm going to model those states not as entire types but just as members.

```cpp
enum class State { OffHook, Connecting, Connected, OnHold, OnHook };

inline ostream& operator<<(ostream& os, State& s) {
    switch (s) {
        case State::OffHook: os << "off the hook"; break;
        case State::Connecting: os << "connecting"; break;
        case State::Connected: os << "connected"; break;
        case State::OnHold: os << "on hold"; break;
        case State::OnHook: os << "on the hook"; break;
    }
    return os;
}

enum class Trigger { CallDialed, HungUp, CallConnected, PlacedOnHold, TakenOffHold, LeftMessage, StopUsingPhone };

inline ostream& operator<<(ostream& os, Trigger& t) {
    switch (t) {
        case Trigger::CallDialed: os << "call dialed"; break;
        case Trigger::HungUp: os << "hung up"; break;
        case Trigger::CallConnected: os << "call connected"; break;
        case Trigger::PlacedOnHold: os << "placed on hold"; break;
        case Trigger::TakenOffHold: os << "taken off hold"; break;
        case Trigger::LeftMessage: os << "left message"; break;
        case Trigger::StopUsingPhone: os << "putting phone on hook"; break;
    }
    return os;
}

int main() {
    map<State, vector<pair<Trigger, State>>>    transition_table;

    transition_table[State::OffHook] = {
        { Trigger::CallDialed, State::Connecting },
        { Trigger::StopUsingPhone, State::OnHook }
    };

    transition_table[State::Connecting] = {
        { Trigger::HungUp, State::OffHook },
        { Trigger::CallConnected, State::Connected }
    };

    transition_table[State::Connected] = {
        { Trigger::LeftMessage, State::OffHook },
        { Trigger::HungUp, State::OffHook },
        { Trigger::PlacedOnHold, State::OnHold }
    };

    transition_table[State::OnHold] = {
        { Trigger::TakenOffHold, State::Connected },
        { Trigger::HungUp, State::OffHook }
    };

    State currentState{State::OffHook};
    State exitState{State::OnHook};

    for (;;) {
        cout << "The phone is currently " << currentState << endl;
        cout << "Select a trigger:\n";

        uint32_t i = 0;
        for (auto item: transition_table[currentState])
            cout << i++ << ". " << item.first << "\n";

        uint32_t input;
        cin >> input;
        currentState = transition_table[currentState][input].second; // Caution: index out of range not checked
        if (currentState == exitState) break;
    }

    cout << "We are done using the phone"<<endl;

    return EXIT_SUCCESS;
}
/*
The phone is currently off the hook
Select a trigger:
0. call dialed
1. putting phone on hook
0 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< INPUT
The phone is currently connecting
Select a trigger:
0. hung up
1. call connected
1 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< INPUT
The phone is currently connected
Select a trigger:
0. left message
1. hung up
2. placed on hold
0 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< INPUT
The phone is currently off the hook
Select a trigger:
0. call dialed
1. putting phone on hook
1 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< INPUT
We are done using the phone
*/
```

- So as you can see, we have modelled state & triggers as enums with the overloaded streaming operator. A typical phone call process changes the states in the following fashion; if the phone is off the hook; it can connecting; connected to somebody, or it can on-hold. Once connected, you left the message & you put the phone back on the hook when you're done talking.
- Now we need an essential part i.e. triggers to drive the show, you can think of them as events which cause you to transition from one state to another.
- And to connect these states & triggers, we have done its mapping as `std::map` named as `transition_table`. You can consider it as rules of the game.
- So this is how you can very quickly hand-roll your own state machine by simply defining a set of states. Similarly, a set of triggers & transition table which kind of relates the rules for going from one state to another state using a particular trigger. And then you orchestrate that state machine and you get your results.

## Benefits of State Design Pattern

1. The State Design Pattern minimizes conditional complexity, eliminating the need for if/else-if and switch statements in objects that have different behaviour requirements unique to different state transitions.
2. As we have seen, If you are able to represent the [object](/posts/inside-the-cpp-object-model/)'s state machine diagram. It's fairly easy to convert the diagram into the Finite State Machine using Functional & Modular approach.
3. The State Design Pattern also improves Cohesion. Since state-specific behaviours aggregated into the separate classes & placed in one location in the code.
4. Moreover, the State Design Pattern also helps in unit testing as adding new behaviour/states won't affect existing behaviours/states, you do not need to retest the whole system. This is a very helpful case in agile development models.

## Summary by FAQs

**Difference between switch case statement & state machine implemented by switch case syntax.**

Ordinary switch case statement does not handle transition rather it just to particular activity based on case type.

**Most of the object's behaviour determined by its data member. Then why is this a separate design pattern?**

Well in the representation of the Gang of Four the State Design Pattern basically suggests that the state of the system kind of controls the way that it operates and it also ties to this idea of Finite State Machine. And as I said earlier State Design Pattern is a systematic & sophisticated way to implement Finite State Machine.

**Use cases of State Design Pattern.**

ATM machine, Timers, TV remote, Protocols, etc. Basically, anything that reflects different behaviour on different inputs.

**How to use state pattern rapidly & correctly?**

Functional approach seen above is the best way which treats states, events, transitions as a completely separate component.
