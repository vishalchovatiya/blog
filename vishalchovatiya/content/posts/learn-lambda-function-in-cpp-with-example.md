---
title: "All About Lambda Function in C++(From C++11 to C++20)"
date: "2019-09-19"
categories: 
  - "cpp"
tags: 
  - "c-11-lambda"
  - "c-11-lambda-example"
  - "c-11-lambda-expressions"
  - "c-11-lambda-function"
  - "c-anonymous-function"
  - "c-generic-lambda"
  - "c-lambda"
  - "c-lambda-callback"
  - "c-lambda-capture-local-variable"
  - "c-lambda-capture-member-variable"
  - "c-lambda-closure"
  - "c-lambda-example"
  - "c-lambda-expression"
  - "c-lambda-expression-example"
  - "c-lambda-expression-tutorial"
  - "c-lambda-function-as-parameter"
  - "c-lambda-function-example"
  - "c-lambda-function-pointer"
  - "c-lambda-function-tutorial"
  - "c-lambda-parameter"
  - "c-lambda-pass-by-value"
  - "c-lambda-return"
  - "c-lambda-return-type"
  - "c-lambda-return-value"
  - "c-lambda-syntax"
  - "c-lambda-this"
  - "c-lambda-tutorial"
  - "c-lambda-type"
  - "c-pass-lambda-as-parameter"
  - "c-pass-lambda-to-function"
  - "capturing-this-pointer-lambda-function-c"
  - "cpp-lambda"
  - "generic-lambdas"
  - "how-lambda-functions-works-internally"
  - "iife-immediately-invoked-function-expression-in-c"
  - "lambda-as-parameter-c"
  - "lambda-c-11"
  - "lambda-c-example"
  - "lambda-c-tutorial"
  - "lambda-expression-c-11"
  - "lambda-expression-c"
  - "lambda-expression-c-example"
  - "lambda-expression-c-tutorial"
  - "lambda-expression-in-c"
  - "lambda-function-c"
  - "lambda-function-c-example"
  - "lambda-function-c-tutorial"
  - "lambda-function-in-c"
  - "lambda-function-in-cpp"
  - "lambda-syntax-c"
  - "mutable-lambda"
  - "passing-this-to-lambda-c"
  - "type-of-lambda-c"
  - "variadic-generic-lambda"
  - "what-is-a-lambda-function"
featuredImage: "/images/Learn-lambda-function-in-C-with-example.png"
---

Lambda function is quite an intuitive & widely loved feature introduced in C++11. And, there are tons of articles & tutorials already available on the topic. But, there are very few or none of them touched upon things like IIFE, types of lambda and newer updates on lambda by subsequent standard releases. So, I got the opportunity to fill the blank. I will start this article with what is lambda function! And as we move along will show you how it works internally! & different variations of it. My focus here would be to give you a pragmatic overview. If you are in search of deep dive, I would suggest you read [C++ Lambda Story](https://leanpub.com/cpplambda) by [Bartłomiej Filipek](https://www.linkedin.com/in/bartlomiejfilipek/).

Title of this article is a bit misleading. Because **_lambda doesn't always synthesize to function pointer_**. It's an expression (precisely unique closure). But I have kept it that way for simplicity. So from now on, I might use them interchangeably.

## What is lambda function?

A lambda function is short snippets of code that

- not worth naming(unnamed, anonymous, disposable, etc. whatever you can call it),
- and also not reused.

In other words, it's just syntactic sugar. lambda function syntax is defined as:

```cpp
[ capture list ] (parameters) -> return-type  
{   
    method definition
} 
```

- Usually, **_compiler evaluates a return type of a lambda function itself_**. So we don't need to specify a trailing return type explicitly i.e. `-> return-type`.
- But in some complex cases, the compiler unable to deduce the return type and we need to specify that.

## Why Should We Use a Lambda Function?

C++ includes many useful generic functions like `std::for_each`, which can be handy. Unfortunately, they can also be quite cumbersome to use, particularly if the functor you would like to apply is unique to the particular function. Consider the following code for an example:

```cpp
struct print {
	void operator()(int element) {
		cout << element << endl;
	}
};

int main(void) {
	vector<int> v = {1, 2, 3, 4, 5};
	for_each(v.begin(), v.end(), print());
	return EXIT_SUCCESS;
}
```

- If you use `print` once, in that specific place, it seems overkill to be writing a whole class just to do something trivial and one-off.
- However, for this kind of situation inline code would be more suitable & appropriate which can be achieved by lambda function as follows:

```cpp
for_each(v.begin(), v.end(), [](int element) { cout << element << endl; });
```

## How Does Lambda Functions Works Internally?

```cpp
[&i] ( ) { cout << i; }

// is equivalent to

struct anonymous {
    int &m_i;
    anonymous(int &i) : m_i(i) {}
    inline auto operator()() const {
        cout << m_i;
    }
};
```

- The **_compiler generates unique closure as above for each lambda function_**. Finally, the secret revealed. Unique closure is nothing but a class(or struct depending upon compiler developer).
- Capture list will become a constructor argument in closure, If you capture argument as value then corresponding type data member is created within the closure.
- Moreover, you can declare variable/object in the lambda function argument, which will become an argument to call operator i.e. `operator()``

## Benefits of Using a Lambda Function

- Zero cost abstraction. Yes! you read it right. **_lambda doesn't cost you performance & as fast as a normal function_**.
- In addition, code becomes compact, structured & expressive.

## Learning Lambda Expression Syntax

### Capture by Reference/Value

```cpp
int main() {
	int x = 100, y = 200;

	auto print = [&] { // Capturing everything by reference(not recommended though)
		cout << __PRETTY_FUNCTION__ << " : " << x << " , " << y << endl;
	};

	print();
	return EXIT_SUCCESS;
}
/* Output
main()::<lambda()> : 100 , 200
*/
```

- In the above example, I have mentioned `&` in capture list. which captures variable `x` & `y` as reference. Similarly, `=` denotes captured by value, which will create data member of the same type within the closure and copy assignment will take place.
- In addition, the parameter list is optional, **_you can omit the empty parentheses if you do not pass arguments_** to the lambda expression.

### Lambda Capture List

- The following table shows different use cases for the same:

| Syntax | Description |
|--------|-------------|
| `[](){}` | no captures |
| `[=](){}` | captures everything by copy (not recommended) |
| `[&](){}` | captures everything by reference (not recommended) |
| `[x](){}` | captures x by copy |
| `[&x](){}` | captures x by reference |
| `[&, x](){}` | captures x by copy, everything else by reference |
| `[=, &x](){}` | captures x by reference, everything else by copy |

### Passing Lambda as Parameter

```cpp
template <typename Functor>
void f(Functor functor) {
	cout << __PRETTY_FUNCTION__ << endl;
}

/* Or alternatively you can use this
void f(function<int(int)> functor) {
    cout << __PRETTY_FUNCTION__ << endl;
}
*/

int g() {
	static int i = 0;
	return i++;
}

int main() {
	auto lambda_func = [i = 0]() mutable { return i++; };
	f(lambda_func); // Pass lambda
	f(g);			// Pass function
}
/* Output
Function Type : void f(Functor) [with Functor = main()::<lambda(int)>]
Function Type : void f(Functor) [with Functor = int (*)(int)]
*/
```

- As you can see, you can also pass lambda function as an argument to other function just like a normal function.
- So, if you see, here I have declared variable `i` in capture list which will become data member. As a result, every time you call `lambda_func`, it will be returned and incremented.

### Capture Member Variable in Lambda or This Pointer

```cpp
class Example {
	int m_var;
  public:
	Example() : m_var(10) {}
	void func() {
		[=]() { cout << m_var << endl; }(); // IIFE
	}
};

int main() {
	Example e;
	e.func();
	return EXIT_SUCCESS;
}
```

- _`this`_ pointer can also be captured using [this]`, [=]` or [&]`. In any of these cases, class data members(including _private_) can be accessed as you do in a normal method.
- If you see the lambda expression line, I have used extra `() at the end of the lambda function declaration which used to calls it right thereafter declaration. It is called [IIFE](https://stackoverflow.com/questions/44868369/how-to-immediately-invoke-a-c-lambda) (**_Immediately Invoked Function Expression_**).

## Lambda Function Variations in Modern C++

### Generic Lambda(C++14)

```cpp
const auto l = [](auto a, auto b, auto c) {};

// is equivalent to

struct anonymous {
    template <class T0, class T1, class T2>
    auto operator()(T0 a, T1 b, T2 c) const {
    }
};
```

- Generic lambda introduced in C++14 which can captures parameters with `auto` specifier.

### Variadic Generic Lambda(C++14)

```cpp
template <typename... Args>
void print(Args &&... args) {
	(void(cout << forward<Args>(args) << endl), ...);
}

int main() {
	auto variadic_generic_lambda = [](auto &&... param) {
		print(forward<decltype(param)>(param)...);
	};

	variadic_generic_lambda(1, "lol", 1.1);
	return EXIT_SUCCESS;
}
```

- Lambda with [variadic template](/posts/variadic-template-cpp-implementing-unsophisticated-tuple/)(C++11) will be useful in many scenarios like debugging, repeated operation with different data input, etc.

### Mutable Lambda Function(C++11)

- Typically, a lambda's function call operator is const-by-value which means **_lambda requires `mutable`  keyword if you are capturing anything by-value_**.

```cpp
[]() mutable {}

// is equivalent to

struct anonymous {
    auto operator()() { // call operator
    }
};
```

- We have already seen an example of this above. I hope you [noticed](#lambda-as-parameter) it.

### Lambda as a Function Pointer(C++11)

```cpp
auto funcPtr = +[] {};
static_assert(is_same<decltype(funcPtr), void (*)()>::value);
```

- You can force the compiler to generate lambda as a function pointer rather than closure by adding `+` in front of it as above.

### Higher-Order Returning Lambda Functions(C++11)

```cpp
const auto less_than = [](auto x) {
	return [x](auto y) {
		return y < x;
	};
};

int main() {
	auto less_than_five = less_than(5);
	cout << less_than_five(3) << endl;
	cout << less_than_five(10) << endl;
	return EXIT_SUCCESS;
}
```

- Going a bit further, lambda function can also return another lambda function. This will open the doors of endless possibility for customization, code expressiveness & compactibility(BTW, there is no word like this) of code.

### constexpr Lambda Expression(C++17)

Since C++17, a lambda expression can be declared as [constexpr](/posts/when-to-use-const-vs-constexpr-in-cpp/).

```cpp
constexpr auto sum = [](const auto &a, const auto &b) { return a + b; };
/*
    is equivalent to

    constexpr struct anonymous
    {
        template <class T1, class T2>
        constexpr auto operator()(T1 a, T2 b) const
        {
            return a + b;
        }
    };
*/
static_assert(sum(10, 10) == 20);
```

- Even if you don't specify `constexpr` , the function call operator will be  `constexpr` anyway, if it happens to satisfy all [constexpr function requirements](https://en.cppreference.com/w/cpp/language/constexpr).

### Template Lambda Expression(C++20)

- As we saw above in generic lambda function, we can declare parameters as `auto`. That in turn templatized by compiler & deduce the appropriate template type. But there was no way to change this template parameter and use real [C++ template](/posts/c-template-a-quick-uptodate-look/) arguments. For example:

```cpp
template <typename T>
void f(vector<T>&	vec){
	//. . .
}
```

- How do you write the lambda for the above function which takes `std::vector` of type `T`? This was the limitation till C++17, but with C++20 it is possible as below:

```cpp
auto f = []<typename T>(vector<T>&  vec){
    // . . .
};

std::vector<int> v;
f(v);
```

- There are other small changes as well regarding the same that you can read [here](https://en.cppreference.com/w/cpp/language/lambda).

## Parting Words

I hope you enjoyed this article. I have tried to cover most of the fundamentals around lambda function with a couple of unsophisticate & small examples. You should use lambda wherever it strikes in your mind considering code expressiveness & easy maintainability. For example, you can use it in custom deleters for smart pointers, to avoid code repetition & with most of the STL algorithms.

Learn lambda function in C++ with example
