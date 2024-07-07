---
title: "Regex C++"
date: "2020-07-16"
categories: 
  - "cpp"
tags: 
  - "boost-regex-example"
  - "boost-regex-examples"
  - "boost-regex-tutorial"
  - "c-11-regex"
  - "c-programming-regex"
  - "c-regex-library"
  - "c-regex-posix"
  - "c-boost-regex"
  - "c-pattern-matching-example"
  - "c-regex-digit"
  - "c-regex-example"
  - "c-regex-find-all-matches"
  - "c-regex-groups"
  - "c-regex-online"
  - "c-regex-parser"
  - "c-regex-pattern"
  - "c-regex-search"
  - "c-regex-syntax"
  - "c-regex-tester"
  - "c-regex-tutorial"
  - "c-regular-expression"
  - "c-regular-expression-example"
  - "c-regular-expression-syntax"
  - "c-regular-expression-tutorial"
  - "c-std-regex-example"
  - "difference-between-stdregex_match-stdregex_search"
  - "finding-files-in-a-directory-c-regex"
  - "finding-lines-containing-or-not-containing-certain-words-from-a-file-c-regex"
  - "geeks-for-geeks-regex-c"
  - "inverted-match-with-stdregex_token_iterator"
  - "libboost-regex"
  - "regex-c-cheat-sheet"
  - "regex-c"
  - "regex-c-gfg"
  - "regex-c-tutorial"
  - "regex-cpp"
  - "regex-generator-c"
  - "regex-in-c-example-2"
  - "regex-in-c-programming"
  - "regex-in-c"
  - "regex-in-c-example"
  - "regex-library-c"
  - "regex-search-c"
  - "regex-split-c"
  - "regex_match-example-c"
  - "regular-expression-c-example"
  - "regular-expression-c-tutorial"
  - "regular-expression-cpp"
  - "regular-expression-in-c-example"
  - "regular-expression-in-c-example-2"
  - "regular-expression-in-cpp"
  - "splitting-a-string-with-delimiter-c-regex"
  - "sregex_token_iterator"
  - "stdregex-stdregex_error-example"
  - "stdregex_iterator-example"
  - "stdregex_match-example"
  - "stdregex_replace-example"
  - "stdregex_search-example"
  - "stdregex_token_iterator-example"
  - "string-to-regex-c"
  - "trim-whitespace-from-a-string-c-regex"
  - "use-regex-in-c"
  - "using-regex-c"
  - "validating-email-address-with-regex-hackerrank-c"
cover:
    image: /images/Regex-C-Regular-Expression.webp
---

Regular expressions (or regex in short) is a much-hated & underrated topic so far with Modern C++. But at the same time, correct use of regex can spare you writing many lines of code. If you have spent quite enough time in the industry. And not knowing regex then you are missing out on 20-30% productivity. In that case, I highly recommend you to learn regex, as it is one-time investment(something similar to **_learn once, write anywhere_** philosophy).

Initially, In this article, I have decided to include regex-in-general also. But it doesn't make sense, as there is already people/tutorial out there who does better than me in teaching regex. But still, I left a small section to address [Motivation](/posts/regex-c/#Motivation) & [Learning Regex](/posts/regex-c/#Learning_Regex). For the rest of the article, I will be focusing on functionality provided by C++ to work with regex. And if you are already aware of regex, you can use the above mind-map as a refresher.

**_Pointer:_** The C++ standard library offers several different "flavours" of regex syntax, but the default flavour (the one you should always use & I am demonstrating here) was borrowed wholesale from the standard for [ECMAScript](https://www.wikiwand.com/en/ECMAScript).

## Motivation

- I know its pathetic and somewhat confusing tool-set. Consider the below regex pattern for an example that extract time in 24-hour format i.e. HH:MM.

```regex
\b([01]?[0-9]|2[0-3]):([0-5]\d)\b
```

- I mean! **_Who wants to work with this cryptic text?_**
- And whatever running in your mind is 100% reasonable. In fact, **_I have procrastinated learning regex twice due to the same reason_**. But, believe me, all the ugly looking things are not that bad.
- The way(**↓**) I am describing here won't take more than 2-3 hours to learn regex that too intuitively. And After learning it you will see the compounding effect with return on investment over-the-time.

## Learning Regex

- Do not google much & try to analyse which tutorial is best. In fact, don't waste time in such analysis. Because there is no point in doing so. At this point in time(well! if you don't know the regex) what really matters is "Getting Started" rather than "What Is Best!".
- **_Just go to [https://regexone.com](https://regexone.com/) without much overthinking_**. And complete all the lessons. Trust me here, I have explored many articles, [courses](https://www.udemy.com/course/regex-academy-an-introduction-to-text-parsing-sorcery/)(<=this one is free, BTW) & books. But this is best among all for getting started without losing motivation.
- And after it, if you still have an appetite to solve more problem & exercises. Consider the below links:
    1. [Exercises on regextutorials.com](http://regextutorials.com/)
    2. [Practice problem on regex by hackerrank](https://www.hackerrank.com/domains/regex)

## [std::regex](https://en.cppreference.com/w/cpp/regex/basic_regex) & [std::regex\_error](https://en.cppreference.com/w/cpp/regex/regex_error) Example

```cpp
int main() {
	try {
		static const auto r = std::regex(R"(\)"); // Escape sequence error
	} catch (const std::regex_error &e) {
		assert(strcmp(e.what(), "Unexpected end of regex when escaping.") == 0);
		assert(e.code() == std::regex_constants::error_escape);
	}
	return EXIT_SUCCESS;
}
```

- You see! I am using [raw string literals](https://en.cppreference.com/w/cpp/language/string_literal). You can also use the normal string. But, in that case, you have to use a double backslash for an escape sequence.
- The current implementation of `std::regex` is slow(as it needs regex interpretation & data structure creation at runtime), bloated and unavoidably require heap allocation(not allocator-aware). So, **_beware if you are using `std::regex` in a loop_**(see [C++ Weekly - Ep 74 - std::regex optimize by Jason Turner](https://www.youtube.com/watch?v=7hfSyxNxFfo)). Also, there is only a single member function that I think could be of use is [std::regex::mark_count()](https://en.cppreference.com/w/cpp/regex/basic_regex/mark_count) which returns a number of capture groups.
- Moreover, if you are using multiple strings to create a regex pattern at run time. Then you may need [exception handling](/posts/7-best-practices-for-exception-handling-in-cpp-with-example/) i.e. `std::regex_error` to validate its correctness.

## [std::regex\_search](https://en.cppreference.com/w/cpp/regex/regex_search) Example

```cpp
int main() {
    const string input = "ABC:1->   PQR:2;;;   XYZ:3<<<"s;
    const regex r(R"((\w+):(\w+);)");
    smatch m;

    if (regex_search(input, m, r)) {
        assert(m.size() == 3);
        assert(m[0].str() == "PQR:2;");                // Entire match
        assert(m[1].str() == "PQR");                   // Substring that matches 1st group
        assert(m[2].str() == "2");                     // Substring that matches 2nd group
        assert(m.prefix().str() == "ABC:1->   ");      // All before 1st character match
        assert(m.suffix().str() == ";;   XYZ:3<<<");   // All after last character match

        // for (string &&str : m) { // Alternatively. You can also do
        //     cout << str << endl;
        // }
    }
    return EXIT_SUCCESS;
}
```

- `smatch` is the specializations of [std::match\_results](https://en.cppreference.com/w/cpp/regex/match_results) that stores the information about matches to be retrieved.

## [std::regex\_match](https://en.cppreference.com/w/cpp/regex/regex_match) Example

- Short & sweet example that you may always find in every regex book is email validation. And that is where our `std::regex_match` function fits perfectly.

```cpp
bool is_valid_email_id(string_view str) {
	static const regex r(R"(\w+@\w+\.(?:com|in))");
	return regex_match(str.data(), r);
}

int main() {
	assert(is_valid_email_id("vishalchovatiya@ymail.com") == true);
	assert(is_valid_email_id("@abc.com") == false);
	return EXIT_SUCCESS;
}
```

- I know this is not full proof email validator regex pattern. But my intention is also not that.
- Rather you should wonder why I have used `std::regex_match`! not `std::regex_search`! The rationale is simple **_`std::regex_match` matches the whole input sequence_**.
- Also, Noticeable thing is _**static regex object to avoid constructing ("compiling/interpreting") a new regex object every time**_ the function entered.
- The irony of **_above tiny code snippet is that it produces around 30k lines of assembly_** that too with `-O3` flag. And that is ridiculous. But don't worry this is already been brought to the ISO C++ community. And soon we may get some updates. Meanwhile, we do have other alternatives (mentioned at the end of this article).

## Difference Between [std::regex\_match](https://en.cppreference.com/w/cpp/regex/regex_match) & [std::regex\_search](https://en.cppreference.com/w/cpp/regex/regex_search)?

- You might be wondering why do we have two functions doing almost the same work? Even I had the doubt initially. But, after reading the description provided by cppreference over and over. I found the answer. And to explain that answer, I have created the example(obviously with the help of StackOverflow):

```cpp
int main() {
	const string input = "ABC:1->   PQR:2;;;   XYZ:3<<<"s;
	const regex r(R"((\w+):(\w+);)");
	smatch m;

	assert(regex_match(input, m, r) == false);

	assert(regex_search(input, m, r) == true && m.ready() == true && m[1] == "PQR");

	return EXIT_SUCCESS;
}
```

- **_`std::regex_match` only returns `true` when the entire input sequence has been matched,_** while **_`std::regex_search` will succeed even if only a sub-sequence matches the regex._**

## [std::regex\_iterator](https://en.cppreference.com/w/cpp/regex/regex_iterator) Example

- `std::regex_iterator` is helpful when you need very detailed information about matches & sub-matches.

```cpp
#define C_ALL(X) cbegin(X), cend(X)

int main() {
	const string input = "ABC:1->   PQR:2;;;   XYZ:3<<<"s;
	const regex r(R"((\w+):(\d))");

	const vector<smatch> matches{
		sregex_iterator{C_ALL(input), r},
		sregex_iterator{}
	};

	assert(matches[0].str(0) == "ABC:1" 
		&& matches[0].str(1) == "ABC" 
		&& matches[0].str(2) == "1");

	assert(matches[1].str(0) == "PQR:2" 
		&& matches[1].str(1) == "PQR" 
		&& matches[1].str(2) == "2");

	assert(matches[2].str(0) == "XYZ:3" 
		&& matches[2].str(1) == "XYZ" 
		&& matches[2].str(2) == "3");

	return EXIT_SUCCESS;
}
```

- Earlier(in C++11), there was a limitation that using `std::regex_interator` is not allowed to be called with a temporary regex object. Which has been rectified with overload from C++14.

## [std::regex\_token\_iterator](https://en.cppreference.com/w/cpp/regex/regex_token_iterator) Example

- `std::regex_token_iterator` is the utility you are going to use 80% of the time. It has a slight variation as compared to `std::regex_iterator`. The **_difference between `std::regex_iterator` & `std::regex_token_iterator` is_**
    - **_`std::regex_iterator` points to match results._**
    - **_`std::regex_token_iterator` points to sub-matches._**
- In `std::regex_token_iterator`, each iterator contains only a single matched result.

```cpp
#define C_ALL(X) cbegin(X), cend(X)

int main() {
	const string input = "ABC:1->   PQR:2;;;   XYZ:3<<<"s;
	const regex r(R"((\w+):(\d))");

	// Note: vector<string> here, unlike vector<smatch> as in std::regex_iterator
	const vector<string> full_match{
		sregex_token_iterator{C_ALL(input), r, 0}, // Mark `0` here i.e. whole regex match
		sregex_token_iterator{}
	};
	assert((full_match == decltype(full_match){"ABC:1", "PQR:2", "XYZ:3"}));

	const vector<string> cptr_grp_1st{
		sregex_token_iterator{C_ALL(input), r, 1}, // Mark `1` here i.e. 1st capture group
		sregex_token_iterator{}
	};
	assert((cptr_grp_1st == decltype(cptr_grp_1st){"ABC", "PQR", "XYZ"}));

	const vector<string> cptr_grp_2nd{
		sregex_token_iterator{C_ALL(input), r, 2}, // Mark `2` here i.e. 2nd capture group
		sregex_token_iterator{}
	};
	assert((cptr_grp_2nd == decltype(cptr_grp_2nd){"1", "2", "3"}));

	return EXIT_SUCCESS;
}
```

### Inverted Match With [std::regex\_token\_iterator](https://en.cppreference.com/w/cpp/regex/regex_token_iterator)

```cpp
#define C_ALL(X) cbegin(X), cend(X)

int main() {
	const string input = "ABC:1->   PQR:2;;;   XYZ:3<<<"s;
	const regex r(R"((\w+):(\d))");

	const vector<string> inverted{
		sregex_token_iterator{C_ALL(input), r, -1}, // `-1` = parts that are not matched
		sregex_token_iterator{}
	};
	assert((inverted == decltype(inverted){
							"",
							"->   ",
							";;;   ",
							"<<<",
						}));

	return EXIT_SUCCESS;
}
```

## [std::regex\_replace](https://en.cppreference.com/w/cpp/regex/regex_replace) Example

```cpp
string transform_pair(string_view text, regex_constants::match_flag_type f = {}) {
	static const auto r = regex(R"((\w+):(\d))");
	return regex_replace(text.data(), r, "$2", f);
}

int main() {
	assert(transform_pair("ABC:1, PQR:2"s) == "1, 2"s);

	// Things that aren't matched are not copied
	assert(transform_pair("ABC:1, PQR:2"s, regex_constants::format_no_copy) == "12"s);
	return EXIT_SUCCESS;
}
```

- You see in 2nd call of transform\_pair, we passed flag `std::regex_constants::format_no_copy` which suggest do not copy thing that isn't matched. There are many such useful flags under [std::regex_constant](https://en.cppreference.com/w/cpp/regex/match_flag_type).
- Also, we have constructed the fresh string holding the results. But what if we do not want a new string. Rather wants to append the results directly to somewhere(probably container or stream or already existing string). Guess what! the standard library has covered this also with overloaded `std::regex_replace` as follows:

```cpp
int main() {
	const string input = "ABC:1->   PQR:2;;;   XYZ:3<<<"s;
	const regex r(R"(-|>|<|;| )");

    // Prints "ABC:1     PQR:2      XYZ:3   "
	regex_replace(ostreambuf_iterator<char>(cout), C_ALL(input), r, " ");

	return EXIT_SUCCESS;
}
```

## Use Cases

### Splitting a String With Delimiter

- Although `std::strtok` is best suitable & optimal candidate for such a task. But just to demonstrate how you can do it with regex:

```cpp
#define C_ALL(X) cbegin(X), cend(X)

vector<string> split(const string& str, string_view pattern) {
    const auto r = regex(pattern.data());
    return vector<string>{
        sregex_token_iterator(C_ALL(str), r, -1),
        sregex_token_iterator()
    };
}

int main() {
    assert((split("/root/home/vishal", "/")
                == vector<string>{"", "root", "home", "vishal"}));
    return EXIT_SUCCESS;
}
```

### Trim Whitespace From a String

```cpp
string trim(string_view text) {
	static const auto r = regex(R"(\s+)");
	return regex_replace(text.data(), r, "");
}

int main() {
	assert(trim("12   3 4      5"s) == "12345"s);
	return EXIT_SUCCESS;
}
```

### Finding Lines Containing or Not Containing Certain Words From a File

```cpp
string join(const vector<string>& words, const string& delimiter) {
    return accumulate(next(begin(words)), end(words), words[0],
            [&delimiter](string& p, const string& word)
            {
                return p + delimiter + word;
            });
}

vector<string> lines_containing(const string& file, const vector<string>& words) {
    auto prefix = "^.*?\\b("s;
    auto suffix = ")\\b.*$"s;

    //  ^.*?\b(one|two|three)\b.*$
    const auto pattern = move(prefix) + join(words, "|") + move(suffix);

    ifstream        infile(file);
    vector<string>  result;

    for (string line; getline(infile, line);) {
        if(regex_match(line, regex(pattern))) {
            result.emplace_back(move(line));
        }
    }

    return result;
}

int main() {
   assert((lines_containing("test.txt", {"one","two"})
                                        == vector<string>{"This is one",
                                                          "This is two"}));
    return EXIT_SUCCESS;
}
/* test.txt
This is one
This is two
This is three
This is four
*/
```

- Same goes for finding lines that are not containing words with the pattern `^((?!(one|two|three)).)*$`.

### Finding Files in a Directory

```cpp
namespace fs = std::filesystem;

vector<fs::directory_entry> find_files(const fs::path &path, string_view rg) {
    vector<fs::directory_entry> result;
    regex r(rg.data());
    copy_if(
        fs::recursive_directory_iterator(path),
        fs::recursive_directory_iterator(),
        back_inserter(result),
        [&r](const fs::directory_entry &entry) {
            return fs::is_regular_file(entry.path()) &&
                   regex_match(entry.path().filename().string(), r);
        });
    return result;
}

int main() {
    const auto dir        = fs::temp_directory_path();
    const auto pattern    = R"(\w+\.png)";
    const auto result     = find_files(fs::current_path(), pattern);
    for (const auto &entry : result) {
        cout << entry.path().string() << endl;
    }
    return EXIT_SUCCESS;
}
```

## Tips For Using Regex-In-General

- Use raw string literal for describing the regex pattern in C++.
- Use the regex validating tool like [https://regex101.com](https://regex101.com). What I like about [regex101](https://regex101.com/) is code generation & time-taken(will be helpful when optimizing regex) feature.
- Also, try to add generated explanation from validation tool as a comment exactly above the regex pattern in your code.
- Performance:
    - If you are using alternation, try to arrange options in high probability order like `com|net|org`.
    - Try to use lazy quantifiers if possible.
    - Use non-capture groups wherever possible.
    - Disable Backtracking.
    - Using the negated character class is more efficient than using a lazy dot.

## Parting Words

It's not just that you will use regex with only C++ or any other language. I myself use it mostly on IDE(in vscode to analyse log files) & on Linux terminal. But, bear in mind that overusing regex gives the feel of cleverness. And, it's a great way to make your co-workers (and anyone else who needs to work with your code) very angry with you. Also, regex is overkill for most parsing tasks that you'll face in your daily work.

The regexes really shine for complicated tasks where hand-written parsing code would be just as slow anyway; and for extremely simple tasks where the readability and robustness of regular expressions outweigh their performance costs.

One more notable thing is current regex implementation(till 19th June 2020) in standard libraries have performance & code bloating issues. So choose wisely between Boost, CTRE and Standard library versions. Most probably you might go with the Hana Dusíková's work on [Compile Time Regular Expression](https://github.com/hanickadot/compile-time-regular-expressions). Also, her CppCon talk from [2018](https://www.youtube.com/watch?v=QM3W36COnE4&list=WL&index=9&t=0s) & [2019](https://www.youtube.com/watch?v=8dKWdJzPwHw)'s would be helpful especially if you plan to use regex in embedded systems.
