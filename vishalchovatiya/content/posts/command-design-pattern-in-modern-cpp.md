---
title: "Command Design Pattern in Modern C++"
date: "2020-04-03"
categories: 
  - "cpp"
  - "design-patterns"
  - "software-engineering"
tags: 
  - "benefits-of-command-design-pattern"
  - "c-command-design-pattern"
  - "command-design-pattern-cpp"
  - "command-design-pattern-in-c-2"
  - "command-design-pattern-in-c"
  - "command-design-pattern-in-modern-c"
  - "command-message-pattern"
  - "command-pattern-c"
  - "command-pattern-polymorphism"
  - "design-pattern-for-sequence-of-operations"
  - "design-principles-of-command-pattern"
  - "difference-between-command-memento-design-pattern"
  - "trivial-command-design-pattern-example-in-c"
  - "what-is-the-important-aspect-of-the-command-design-pattern"
  - "what-is-the-reason-behind-using-the-command-design-pattern"
featuredImage: "/images/Command-Design-Pattern-in-Modern-C-vishal-chovatiya.png"
---

In software engineering, Behavioural Design Patterns deal with the assignment of responsibilities between objects which in turn make the interaction between the objects easy & loosely coupled. In this article of the Behavioural Design Patterns, we're going to take a look at Command Design Pattern in Modern C++ which **_encapsulate all the details related to operation into a separate object_**. Command Design Pattern is widely used in sophisticated software. In fact, you might be using it every day without even knowing that. For example, whenever you press `Ctrl + Z`(i.e. undo/redo), you are likely firing the object arrangements organised as a Command Pattern.

By the way, If you haven’t check out my other articles on Behavioural Design Patterns, then here is the list:

{{% include "/reusable_block/behavioural-design-patterns.md" %}}
{{% include "/reusable_block/design-pattern-prerequisites.md" %}}

## Intent

> **_To decouples the sender & receiver by creating a separate object for a set of operations._**

- The Command Design Pattern is quite simply an [object](/posts/inside-the-cpp-object-model/) to represent instructions or set of instructions which also facilitates the support of undo-able operations & query/request customization.
- There is one thing that I want to mention which isn't directly related to the subject of the Command Design Pattern. But still, let me clarify that Command & Query are two different aspects.
    - Command: Asking for action or change e.g. renaming a file.
    - Query: Asking for information(doesn't cause any mutation) e.g. list all the file in the current directory.
- So, this idea of [command query separation](https://en.wikipedia.org/wiki/Command%E2%80%93query_separation) is something that used in a lot of things like distributed databases for example. Where you basically split your system into separate components and separate means of sending commands. I just wants to make this point so that you don't get confuse later on. Because GoF mentions command & query as the same thing.

## Trivial Command Design Pattern Example in C++

```cpp
struct walk {
    void operator()() { cout << "walk" << endl; }
};

struct jog {
    void operator()() { cout << "jog" << endl; }
};

struct run {
    void operator()() { cout << "run" << endl; }
};

struct macroCommand : vector<function<void()>> {
    void operator()() { 
        for (auto &&f : *this) 
            f();
    }
};

void doIt(function<void()> f) {
    f();
}

int main() {
    doIt(walk{});
    doIt(jog{});
    doIt(run{});

    macroCommand cardio_workout;
    cardio_workout.push_back(walk{});
    cardio_workout.push_back(jog{});
    cardio_workout.push_back(run{});
    cardio_workout();
    return EXIT_SUCCESS;
}
```

- I know its silly example with overloaded call operator(i.e functor), but consider it a good start especially for `macroCommand`.

## Practical Approach to Command Design Pattern

- Following is a practical example of the Command Design Pattern with a very familiar scenario of bank account:

```cpp
struct BankAccount {
    int32_t     m_balance;

    void deposit(int32_t amount) { m_balance += amount; }
    void withdraw(int32_t amount) { m_balance -= amount; }
};

struct Command {
    virtual void execute() = 0;
};

struct BankAccountCommand : Command {
    enum class Action : bool { deposit, withdraw };
    BankAccount&      m_ac;
    Action            m_action;
    int32_t           m_amount;

    BankAccountCommand(BankAccount& ac, Action a, int32_t amnt)
    : m_ac(ac), m_action(a), m_amount(amnt) {}

    void execute() {
        (m_action == Action::deposit) ? m_ac.deposit(m_amount) : m_ac.withdraw(m_amount);
    }
};


int main() {
    BankAccount ba1{1000};
    BankAccount ba2{1000};

    vector<BankAccountCommand> commands{
        BankAccountCommand{ba1, BankAccountCommand::Action::withdraw, 200},
        BankAccountCommand{ba2, BankAccountCommand::Action::deposit, 200}
    };

    for (auto& cmd : commands)
        cmd.execute();

    cout << ba1.m_balance << endl;
    cout << ba2.m_balance << endl;

    return EXIT_SUCCESS;
}
```

- As you can see `BankAccount` class with minimalistic implementation having some amount of starting balance. We do also have `deposit()` & `withdraw()`methods but rather than using those methods directly we will create a separate entity `BankAccountCommand` backed by abstract class `Command`.
- And in the `main()`, we have carried out the money transfer of `200` from one bank account to another. Each command has reference to particular `BankAccount` so it knows on which account to operate on.
- So this idea of keeping every single command that invokes on a bank account gives us interesting possibilities.
    1. One of those possibilities is to implement undo(as you find in Microsoft office applications by pressing `Ctrl + Z`) functionality so when you want to roll back one of these commands you can actually get it done easily.
    2. Another possibility is you can create code more abstract in a way which works like a recorded macro. Think about the implementation of macros in a Microsoft Office application for example. That is a sequence of commands that gets recorded one after another. And you can sort of playback all the commands one after another. And you can also undo them all in reverse order with a single invocation.
- Following is an improved example incorporating above two possibilities with Composite Design Pattern:

```cpp
struct BankAccount {
  int32_t       m_balance;

  void deposit(int32_t amount) { m_balance += amount; }
  void withdraw(int32_t amount) { m_balance -= amount; }
};

struct Command {
  virtual void execute() = 0;
  virtual void undo() = 0;
};

struct BankAccountCommand : Command {
    enum class Action : bool { deposit, withdraw };
    BankAccount&      m_ac;
    Action            m_cmd;
    int32_t           m_amount;

    BankAccountCommand(BankAccount& ac, Action a, int32_t amnt) : m_ac(ac), m_cmd(a), m_amount(amnt) {}

    void execute() {
        (m_cmd == Action::deposit) ? m_ac.deposit(m_amount) : m_ac.withdraw(m_amount);
    }

    void undo() {
        (m_cmd == Action::deposit) ? m_ac.withdraw(m_amount) : m_ac.deposit(m_amount);
    }
};

struct CompositeBankAccountCommand : vector<BankAccountCommand>, Command
{
    CompositeBankAccountCommand(const initializer_list<value_type>& items)
    : vector<BankAccountCommand>(items) {}

    void execute() { 
        for(auto& cmd : *this) 
            cmd.execute(); 
    }
    void undo() { 
        for(auto& cmd : *this) 
            cmd.undo(); 
    }
};

int main()
{
    BankAccount ba1{1000};
    BankAccount ba2{1000};

    CompositeBankAccountCommand commands{
        BankAccountCommand{ba1, BankAccountCommand::Action::withdraw, 200},
        BankAccountCommand{ba2, BankAccountCommand::Action::deposit, 200}
    };

    commands.execute();
    commands.undo();

    cout << ba1.m_balance << endl;
    cout << ba2.m_balance << endl;

    return EXIT_SUCCESS;
}
```

## Benefits of Command Design Pattern

1. Command Design Pattern decouples operand & operation. Thus facilitates extensions to add a new command is easy and without changing the existing code.
2. By queueing commands, you can also define a rollback functionality in the system as we did above.
3. It also allows us to create a macro with a bunch of commands can fire together in a single invocation.
4. As the Command Design Pattern has a separate structure to store a set of operations, we have the leverage to schedule it.

## Summary by FAQs

**What is the important aspect of the Command Design Pattern?**

1\. Interface separation: the invoker is isolated from the receiver.  
2\. Time separation: stores a ready-to-go set of instructions that can be scheduled.

**What is the reason behind using the Command Design Pattern?**

- Decouple the sender & receiver of the command  
- Implement the callback mechanism  
- Implement undo and redo functionality  
- Maintain a history of commands

**Difference between Command & Memento Design Pattern?**

Command Design Pattern represents request token  
Memento Design Pattern represents the internal state of an [object](/posts/inside-the-cpp-object-model/) at a particular time  
Polymorphism is important to Command, but not to Memento.
