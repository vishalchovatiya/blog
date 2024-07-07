---
title: "Single Responsibility Principle in C++ | SOLID as a Rock"
date: "2020-04-07"
categories: 
  - "cpp"
  - "design-patterns"
  - "design-principles"
  - "software-engineering"
tags: 
  - "benefits-of-single-responsibility-principle"
  - "expressiveness"
  - "how-do-you-implement-the-single-responsibility-principle-in-the-c-sharp-class-design"
  - "intent-single-responsibility-principle"
  - "maintainability"
  - "motivation-violating-the-single-responsibility-principle"
  - "reusability"
  - "single-responsibility-principle-class"
  - "single-responsibility-principle-code-examples"
  - "single-responsibility-principle-cohesion"
  - "single-responsibility-principle-design-pattern"
  - "single-responsibility-principle-example"
  - "single-responsibility-principle-in-c-2"
  - "single-responsibility-principle-in-c"
  - "single-responsibility-principle-in-c-3"
  - "solution-single-responsibility-principle-example-in-c"
  - "srp-solid"
  - "yardstick-to-craft-srp-friendly-software-in-c"
cover:
    image: /images/Single-Responsibility-Principle-in-C-SOLID-as-a-Rock-vishal-chovatiya.webp
---

This article is the first part of a five-part series about SOLID as Rock design principle series. The SOLID design principles focus on developing software that is easy to maintainable, reusable & extendable. In this article, we will see an example of the **S**ingle **R**esponsibility **P**rinciple in C++ along with its benefits & generic guideline.

By the way, If you want to directly jumps to other design principles, then below is the quick links:

{{% include "/reusable_block/solid-design-principles.md" %}}
{{% include "/reusable_block/design-pattern-prerequisites.md" %}}

## Intent

> **_A class should have only one reason to change_**

In other words, SRP states that classes should be cohesive to the point that it has a single responsibility, where responsibility defines as "a reason for the change."

## Motivation: Violating the Single Responsibility Principle

```cpp
class Journal {
	string          m_title;
	vector<string>  m_entries;

public:
	explicit Journal(const string &title) : m_title{title} {}
	void add_entries(const string &entry) {
		static uint32_t count = 1;
		m_entries.push_back(to_string(count++) + ": " + entry);
	}
	auto get_entries() const { return m_entries; }
	void save(const string &filename) {
		ofstream ofs(filename); 
		for (auto &s : m_entries) ofs << s << endl;
	}
};

int  main() {
    Journal journal{"Dear XYZ"};
    journal.add_entries("I ate a bug");
    journal.add_entries("I cried today");
    journal.save("diary.txt");
    return EXIT_SUCCESS;
}
```

- Above C++ example seems fine as long as you have a single domain object i.e. `Journal`. but this is not usually the case in a real-world application.
- As we start adding domain objects like `Book`, `File`, etc. you have to implement save method for everyone separately which is not the actual problem.
- The real problem arises when you have to change or maintain `save` functionality. For instance, some other day you will no longer save data on files & adopted database. In this case, you have to go through every domain [object implementation](/posts/inside-the-cpp-object-model/) & need to change code all over which is not good.
- Here, we have violated the Single Responsibility Principle by providing `Journal` class two reason to change i.e.
    - Things related to `Journal`
    - Saving the `Journal`
- Moreover, code will also become repetitive, bloated & hard to maintain.

## Solution: Single Responsibility Principle Example in C++

- As a solution what we do is a **_[separation of concerns](https://en.wikipedia.org/wiki/Separation_of_concerns)_**.

```cpp
class Journal {
	string          m_title;
	vector<string>  m_entries;

public:
	explicit Journal(const string &title) : m_title{title} {} 
	void add_entries(const string &entry) {
		static uint32_t count = 1;
		m_entries.push_back(to_string(count++) + ": " + entry);
	} 
	auto get_entries() const { return m_entries; }

	//void save(const string &filename)
	//{
	//	ofstream ofs(filename); 
	//	for (auto &s : m_entries) ofs << s << endl;
	//}
};

struct SavingManager {
	static void save(const Journal &j, const string &filename) {
		ofstream ofs(filename);
		for (auto &s : j.get_entries())
			ofs << s << endl;
	}
};

SavingManager::save(journal, "diary.txt");
```

- `Journal` should only take care of entries & things related to the journal.
- And there should be one separate central location or entity which does the work of saving. In our case, its `SavingManager`.
- As your `SavingManager` grows, you have all the saving related code will be at one place. You can also templatize it to accept more domain [object](/posts/memory-layout-of-cpp-object/)s.

## Benefits of Single Responsibility Principle

### \=> Expressiveness

- When the class only does one thing, its interface usually has a small number of methods which is more expressive. Hence, It also has a small number of data members.
- This improves your development speed & makes your life as a software developer a lot easier.

### \=> Maintainability

- We all know that requirements change over time & so does the design/architecture. The more responsibilities your class has, the more often you need to change it. If your class implements multiple responsibilities, they are no longer independent of each other.
- Isolated changes reduce the breaking of other unrelated areas of the software.
- As programming errors are inversely proportional to complexity, being easier to understand makes the code less prone to bugs & easier to maintain.

### \=> Reusability

- If a class has multiple responsibilities and only one of those needs in another area of the software, then the other unnecessary responsibilities hinder reusability.
- Having a single responsibility means the class should be reusable without or less modification.

## Yardstick to Craft SRP Friendly Software in C++

- SRP is a double-edged sword. Be too specific & you will end up having hundreds of ridiculously interconnected classes, that could easily be one.
- You should not use SOLID principles when you feel you are over-engineering. If you boil down the Single Responsibility Principle, the generic idea would be like this:

**_The SRP is about limiting the impact of change. So, gather together the things that change for the same reasons. Separate those things that change for different reasons._**

- Adding more to this, If your class constructor has more than 5-6 parameters then it means either you are not followed SRP or you are not aware of builder design pattern.

## Conclusion

The SRP is a widely quoted justification for refactoring. This is often done without a full understanding of the point of the SRP and its context, leading to fragmentation of codebases with a range of negative consequences. Instead of being a one-way street to minimally sized classes, the SRP is actually proposing a balance point between aggregation and division.
