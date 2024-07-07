---
title: "Interpreter Design Pattern in Modern C++"
date: "2020-04-03"
categories: 
  - "cpp"
  - "design-patterns"
  - "software-engineering"
tags: 
  - "benefits-of-interpreter-design-pattern"
  - "interpreter-design-pattern-example-in-c"
  - "interpreter-design-pattern-in-c"
  - "interpreter-design-pattern-in-modern-c"
  - "interpreter-design-pattern-real-world-example"
  - "lexing-parsing"
  - "use-cases-of-interpreter-design-pattern"
  - "what-are-the-design-components-of-interpreter-design-pattern"
  - "what-problems-can-the-interpreter-design-pattern-solve"
  - "what-solution-does-the-interpreter-design-pattern-describe"
cover:
    image: /images/Interpreter-Design-Pattern-in-Modern-C-vishal-chovatihya.png
---

Interpreter Design Pattern is a Behavioural Design Pattern which is **_a component that processes structured text data by turning it into separate lexical tokens([lexing](https://stackoverflow.com/questions/2842809/lexers-vs-parsers)) and then interpreting sequences of tokens([parsing](https://stackoverflow.com/questions/2842809/lexers-vs-parsers))_**. In this article, we will see the Interpreter Design Pattern in Modern C++.

By the way, If you haven’t check out my other articles on Behavioural Design Patterns, then here is the list:

{{% include "/reusable_block/behavioural-design-patterns.md" %}}
{{% include "/reusable_block/design-pattern-prerequisites.md" %}}

## Intent

> **_To process structured text data by tokenizing & parsing._**

- Interpreters are everywhere, and especially for us(i.e.programmers), we are dealing with it every day. The front end of almost every compiler is an interpreter. Which parse the textual input & turn it into some sort of meaningful [object-oriented representation](/posts/memory-layout-of-cpp-object/).
- Even all mathematical expression is required to be interpreted first. For example, 3 - (4/5) is a candidate for interpretation before processing. In which minus & division is operation whereas 3, 4 & 5 are operand having priority context defined by brackets.

## Interpreter Design Pattern Example in C++

- In the following example, we're going to take a look at the interpretation process by looking at how to tokenize, parse and indeed evaluate simple numeric expressions.
- And to do so we have divided the example into two parts i.e. i). tokenizing & ii). parsing though it really depends on the kind of data that you work with but considering the general case here.
- So in the first part, we will process simple mathematical expression which is of type string & convert it into some sort of object-oriented representation i.e. tokens, the sequence of tokens more specifically.

### Lexing

```cpp
struct Token {
    enum Type { integer, plus, minus, lparen, rparen };
    Type        m_type;
    string      m_text;

    Token(Type typ, const string& txt): m_type(typ), m_text(txt) {}

    friend ostream& operator<<(ostream& os, const Token& o) { return os << "`" << o.m_text << "`"; }
};

vector<Token> lex(const string& input) {
    vector<Token>   result;

    for (auto curr = begin(input); curr != end(input); ++curr) {
        switch (*curr) {
			case '+': result.emplace_back(Token::plus, "+"); break;
			case '-': result.emplace_back(Token::minus, "-"); break;
			case '(': result.emplace_back(Token::lparen, "("); break;
			case ')': result.emplace_back(Token::rparen, ")"); break;
			default: // number
				auto first_not_digit = find_if(curr, end(input), [](auto c) {
					return !isdigit(c);
				});
				string integer = string(curr, first_not_digit);

				result.emplace_back(Token::integer, integer);
				curr = --first_not_digit;
        }
    }
    return result;
}

int main() {
    auto tokens = lex("(13-4)-(12+1)");

    for (auto& t: tokens)
        cout << t << " ";	// Output: `(` `13` `-` `4` `) `-` `(` `12` `+` `1` `)

    return EXIT_SUCCESS;
}
```

- As you can see in the above example, we are creating the collection of tokens i.e. `+`, `-`, `(`, `)` & numbers as a part of the 1st step to evaluate the expression `(13-4)-(12+1)`.

### Parsing

```cpp
struct Element {
    virtual int eval() const = 0;
};

struct Integer : Element {
    int   m_value;
    explicit Integer(const int v) : m_value(v) {}
    int eval() const { return m_value; }
};

struct BinaryOperation : Element {
    enum Type { addition, subtraction }   m_type;
    shared_ptr<Element>                   m_lhs, m_rhs;

    int eval() const {
        if (m_type == addition) return m_lhs->eval() + m_rhs->eval();
        return m_lhs->eval() - m_rhs->eval();
    }
};

shared_ptr<Element> parse(const vector<Token> &tokens) {
    auto result = make_unique<BinaryOperation>();

    for (auto curr_token = begin(tokens); curr_token != end(tokens); ++curr_token) {
        switch (curr_token->m_type) {
            /* ----------------- Normal Expression ----------------- */
        case Token::integer:
            if (!result->m_lhs) result->m_lhs = make_shared<Integer>(stoi(curr_token->m_text));
            else result->m_rhs = make_shared<Integer>(stoi(curr_token->m_text));
            break;

        case Token::plus: result->m_type = BinaryOperation::addition; break;
        case Token::minus: result->m_type = BinaryOperation::subtraction; break;
            /* ----------------------------------------------------- */

            /* ------------------- Sub Expression ------------------ */
        case Token::lparen:
            auto rparen = find_if(curr_token, end(tokens), [](auto& token) {
                return token.m_type == Token::rparen;
            });

            vector<Token>   subexpression(curr_token + 1, rparen);
            if (!result->m_lhs) result->m_lhs = parse(subexpression);
            else result->m_rhs = parse(subexpression);

            curr_token = rparen;
            break;
            /* ----------------------------------------------------- */
        }
    }
    return result;
}

int main() {
	string expression{"(13-4)-(12+1)"};

    auto tokens = lex(expression);

    auto parsed = parse(tokens);
    cout << expression << " = " << parsed->eval() << endl; // Output: (13-4)-(12+1) = -4
    return EXIT_SUCCESS;
}
```

- You may be thinking that the parsing algorithm is bit complex, but if you eliminate smart pointer, code would become easy to consume. You can divide the parsing algorithm in two-part:
    1. **Normal Expression**: i.e. 13-4 which is easily parsed by 1st three cases of the switch statement `Token::plus`, `Token::minus` & `Token::integer`.
    2. **Sub-expression**: i.e. expression starting from parenthesis. For example, `(13-4)` where I am extracting the content within parenthesis & again providing it to `parse()`as it is a recurring problem.
- At the end of parsing, you will form the following tree structure:

```
// (13-4)-(12+1) 
                  BinaryOperation(subtraction)
                        /              \
                       /                \
BinaryOperation(subtraction)         BinaryOperation(addition)
       /      \                              /      \
      /        \                            /        \
Integer(13)    Integer(4)             Integer(12)   Integer(1)
```

- When we call `parsed->eval()` in the main function, polymorphic overloaded `eval()`for all the nodes [type](/posts/cpp-type-casting-with-example-for-c-developers/)(i.e. `Integer` or `BinaryOperation`) in the above tree will be called recursively. An evaluation of an expression happens in the bottom-up approach.

## Benefits of Interpreter Design Pattern

1. It's easy to change and extend the grammar. Because classes used to represent grammar rules i.e. `+`, `-`, etc., we can use inheritance to change or extend the grammar. For example, to extend the above example for multiplication operator, you need to add one more case in switch case & a bit of modification in `BinaryOperation` class.
2. Implementing the grammar is easy, too. As each symbol represents a token that essentially a class. To add a new symbol you need to create a new class.

## Summary by FAQs

**Use cases of Interpreter Design Pattern.**

Programming language compilers, interpreters, IDEs, Document readers like HTML, XML, PDF, etc.A regular expression is a very subtle example of Interpreter.

**What problems can the Interpreter Design Pattern solve?**

Interpreter Design Pattern is used to interpret domain languages which can be anything from a simple calculator to a C++ parser.

**What solution does the Interpreter Design Pattern describe?**

Tokenizing symbols & parsing it as a tree.
