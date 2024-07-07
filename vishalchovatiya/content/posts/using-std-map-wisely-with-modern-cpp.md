---
title: "Using std::map Wisely With Modern C++"
date: "2020-07-08"
categories: 
  - "cpp"
  - "stl"
tags: 
  - "c-map-check-if-key-exists"
  - "c-map-class"
  - "c-map-comparator"
  - "c-map-data-structure"
  - "c-map-empty"
  - "c-map-end"
  - "c-map-examples"
  - "c-map-find-example"
  - "c-map-function"
  - "c-map-get-value-by-key"
  - "c-map-greater"
  - "c-map-in-map"
  - "c-map-initialization"
  - "c-map-iterator"
  - "c-map-iterator-first"
  - "c-map-loop"
  - "c-map-methods"
  - "c-map-of-classes"
  - "c-map-of-lists"
  - "c-map-of-maps"
  - "c-map-of-objects"
  - "c-map-of-vectors"
  - "c-map-performance"
  - "c-map-reduce"
  - "c-map-reserve"
  - "c-map-struct-as-key"
  - "c-map-struct-key"
  - "c-map-template"
  - "c-map-template-example"
  - "c-map-to-vector"
  - "c-map-usage"
  - "c-map-vector"
  - "c-map-with-custom-comparator"
  - "c-remove_if-map"
  - "c-std-hash-map"
  - "c-stl-map"
  - "c-stl-map-example"
  - "c-vector-to-map"
  - "can-i-modify-associated-values-in-stdmap-also"
  - "const-map-c"
  - "cpp-std-map"
  - "cpp-std-map-example"
  - "cppreference-map"
  - "difference-between-operator-vs-insert-vs-at"
  - "map-c-stl"
  - "map-std-c"
  - "multimap-stl"
  - "ok-then-how-do-i-modify-stdmap-keys"
  - "ordered-map-c"
  - "static-map-c"
  - "std-hash-map"
  - "std-map-c"
  - "std-map-vector"
  - "std-unsorted-map"
  - "stdmap-example"
  - "stdmap-find"
  - "stdmap-insert"
  - "stdmapat"
  - "stdmapcontainsc20"
  - "stdmapextractc17"
  - "stdmapinsert"
  - "stdmapinsert-with-hintc11-17"
  - "stdmapinsert_or_assignc17"
  - "stdmapmergec17"
  - "stdmapoperator"
  - "stdmaptry_emplacec17"
  - "stl-c-map"
  - "unordered_map-c"
  - "what-if-the-node-with-a-particular-key-does-not-exist"
featuredImage: "/images/std-map-C.webp"
---

[std::map](https://en.cppreference.com/w/cpp/container/map) and its siblings([std::multimap](https://en.cppreference.com/w/cpp/container/multimap), [std::unordered_map](https://en.cppreference.com/w/cpp/container/unordered_map)/[multimap](https://en.cppreference.com/w/cpp/container/unordered_multimap)) used to be my favourite containers when I was doing competitive programming. In fact, I still like them(though using less frequently nowadays). And with [Modern C++](/posts/21-new-features-of-modern-cpp-to-use-in-your-project/), we now have more reasons to use `std::map`. That's why I have decided to address this topic by writing an article summarizing these new features. So, without much gibberish, let's dive-in directly.

## [std::map::contains](https://en.cppreference.com/w/cpp/container/map/contains)(C++20)

- `std::map::contains` member function is a good step towards code expressiveness. And I am also tire of writing :

```cpp
if (auto search = freq_of.find(2); search != freq_of.end()) {
	cout << "Found" << endl;
}
// Where assume, freq_of = map<uint32_t, uint32_t>{{3, 1}, {1, 1}, {2, 1}};
```

- Rather, from C++20, you can write:

```cpp
if (freq_of.contains(2)) {
	cout << "Found" << endl;
}
```

> **_The code we write is written first for human consumption & only secondarily for the computer to understand._**  **\- John Sonmez**

## [std::map::try\_emplace](https://en.cppreference.com/w/cpp/container/map/try_emplace)(C++17)

- While inserting into the map, we have 2 different possibilities:
    1. The key doesn't exist yet. Create a fresh key-value pair.
    2. The key does exist already. Take the existing item and modify it.
- A typical approach to insert an element in `std::map` is by using `operator[ ]`, `std::map::insert` or `std::map::emplace` . But, in all of these cases, we have to bear the cost of default/specialized constructor or assignment call. And the worst part is if an item already exists, we have to drop the freshly created item.

```cpp
int main() {
    vector v{3, 4, 5, 8, 7, 3, 5, 2, 4};
    map<uint32_t, uint32_t> freq_of;

    for (const auto &n : v) {
        if (const auto &[it, inserted] = freq_of.emplace(n, 1); !inserted) {
            it->second++;  // Exists already
        }
    }

    assert(freq_of[3] == 2);

    return EXIT_SUCCESS;
}
```

- Instead:

```cpp
if (const auto &[it, inserted] = freq_of.try_emplace(n, 1); !inserted) {
    it->second++;
}
```

- But, since C++17, there is this **_`std::map::try_emplace` method that creates items only if the key doesn't exist yet_**. This boosts the performance in case objects of that type are expensive to create.
- Although the above example hasn't showcased the expensive to create items. But, yes! whenever you encounter such a situation, must be known how to handle it with `std::map::try_emplace`.

## [std::map::insert\_or\_assign](https://en.cppreference.com/w/cpp/container/map/insert_or_assign)(C++17)

- When you have to insert element anyhow. For the sake of convenience, you use [std::map::operator[ ]](https://en.cppreference.com/w/cpp/container/map/operator_at). Which is OK( and [dangerous](https://devblogs.microsoft.com/oldnewthing/20190227-00/?p=101072))! Unless you have any constraint on insertion or assignment.
- For example, while counting the frequency of elements with the added constraint that when an element is repeated(i.e. assigned) you have to remove all the element lesser than the current one.
- In such a situation, `std::map::operator[ ]` isn't feasible. Rather, `std::map::insert_or_assign` is more appropriate and returns more information than [`std::map::operator[ ]`](`std::map::operator[ ]`). It also does not require default-constructibility of the mapped type. Consider the following example for the same.

```cpp
int main() {
	vector v{8, 3, 9, 5, 8};
	map<uint32_t, uint32_t> freq_of;

	for (auto &&n : v) {
		const auto &[it, is_inserted] = freq_of.insert_or_assign(n, 1);

		if (!is_inserted) { // remove all lesser element then current one if repeated
			freq_of.erase(begin(freq_of), it);
		}
	}
	
	assert((freq_of == decltype(freq_of){
						   {8, 1},
						   {9, 1},
					   }));

	return EXIT_SUCCESS;
}
```

## [std::map::insert](https://en.cppreference.com/w/cpp/container/map/insert) With Hint(C++11/17)

- Looking up items in an `std::map` takes `O(log(n))` time. This is the same for inserting new items. Because the position where to insert them must looked up. Naive insertion of `M` new items would thus take `O(M * log(n))` time.
- In order to make this more efficient, `std::map` insertion functions accept an optional insertion hint parameter. The insertion hint is basically an iterator, which points near the future position of the item that is to be inserted. If the hint is correct, then we get amortized `O(1)` insertion time.
- This is quite useful from a performance point of view when the insertion sequence of items is somewhat predictable. For example:

```cpp
int main() {
	map<uint32_t, string> m{{2, ""}, {3, ""}};
	auto where(end(m));

	for (const auto &n : {8, 7, 6, 5, 4, 3, 2, 1}) { // Items in non-incremental order
		where = m.insert(where, {n, ""});
	}

	// How it is not done!
	// m.insert(end(m), {0, ""});

	for (const auto &[key, value] : m) {
		cout << key << " : " << value << endl;
	}

	return EXIT_SUCCESS;
}
```

- A **_correct hint will point to an existing element, which is greater than the element to be inserted_** so that the newly inserted key will be just before the hint. If this does not apply for the hint the user provided during insertion, the insert function will fall back to a nonoptimized insertion, yielding `O(log(n)) performance again.
- For the above example, the first insertion, we got the end iterator of the map, because we had no better hint to start with. After installing an 8 in the tree, we knew that installing 7 will insert a new item just in front of the 8, which qualified it to be a correct hint. This applies to 6 as well, if put into the tree after inserting the 7, and so on. This is why it is possible to use the iterator, which was returned in the last insertion for the next insertion.
- You can play around the above example to justify the performance gain with [quick-benchmark](https://quick-bench.com/q/gF1CXbPkzjOzLxKfRG7X-Uv8lfw).

_**Note:** It is important to know that before C++11, insertion hints were considered correct when they pointed before the position of the newly inserted item._

## [std::map::merge](https://en.cppreference.com/w/cpp/container/map/merge)(C++17)

- Same as [std::list:splice](https://en.cppreference.com/w/cpp/container/list/splice), which transfers the elements from one list to another. we have `std::map::merge` which can merge the two same type of `std::map`.

```cpp
int main() {
	map<uint32_t, string> fruits{{5, "grapes"}, {2, "tomoto"}};
	map<uint32_t, string> person{{2, "mickel"}, {10, "shree"}};
	map<uint32_t, string> fruits_and_persons;

	fruits_and_persons.merge(fruits);
	assert(fruits.size() == 0);

	fruits_and_persons.merge(person);
	assert(person.size() == 1);
	assert(person.at(2) == "mickel"); // Won't overwrite value at 2 i.e.`mickel`

	assert((fruits_and_persons == decltype(fruits){
									  {2, "tomoto"},
									  {5, "grapes"},
									  {10, "shree"},
								  }));

	return EXIT_SUCCESS;
}
```

- The thing here to note is what happens when there are duplicates! **_The duplicated elements are not transferred. They're left behind in the right-hand-side map_**.

## [std::map::extract](https://en.cppreference.com/w/cpp/container/map/extract)(C++17)

- Unlike `std::map::merge` that transfers the elements in bulk, **_`std::map::extract` along with `std::map::insert` transfers element piecewise_**. But what is the more compelling application of `std::map::extract` is modifying keys.
- As we know, for `std::map` keys are always unique and sorted. Hence, It is crucial that users cannot modify the keys of map nodes that are already inserted. In order to prevent the user from modifying the key items of perfectly sorted map nodes, the [const](/posts/when-to-use-const-vs-constexpr-in-cpp/) qualifier is added to the key type.
- This kind of restriction is perfectly valid because it makes harder for the user to use `std::map` the wrong way. But what if we really need to change the keys of some map items?
- Prior to C++17, we had to remove & reinsert the items in order to change the key. The downside of this approach is memory allocation & deallocation, which sounds bad in terms of performance. But, from C++17, we can remove & reinsert std::map nodes without any reallocation of memory.

```cpp
int main() {
	map<int, string> race_scoreboard{{1, "Mickel"}, {2, "Shree"}, {3, "Jenti"}};
	using Pair = map<int, string>::value_type;

	{
		auto Jenti(race_scoreboard.extract(3));
		auto Mickel(race_scoreboard.extract(1));

		swap(Jenti.key(), Mickel.key());

		auto [it, is_inserted, nh] = race_scoreboard.insert(move(Jenti)); // nh = node handle
		assert(*it == Pair(1, "Jenti") && is_inserted == true && nh.empty());

		race_scoreboard.insert(move(Mickel));
	}

	assert((race_scoreboard == decltype(race_scoreboard){
								   {1, "Jenti"},
								   {2, "Shree"},
								   {3, "Mickel"},
							   }));

	return EXIT_SUCCESS;
}
```

- Consider the above example of the racing scoreboard where you have employed `std::map` to imitate the racing position. And after a while, Jenti took the lead & Mickel left behind. In this case, how we have switched the keys(position on a race track) of those players.
- `std::map::extract` comes in two flavours:

```cpp
node_type extract(const_iterator position);
node_type extract(const key_type& x);
```

- In the above example, we used the second one, which accepts a key and then finds & extracts the map node that matches the key parameter. The first one accepts an iterator, which implies that it is faster because it doesn't need to search for the item.

### What If the Node With a Particular Key Does Not Exist?

- If we try to extract an item that doesn't exist with the second method (the one that searches using a key), it **_returns an empty `node_type` instance i.e. node handle_**. The `empty()`member method or overloaded bool operator tells us that whether a `node_type` instance is empty or not.

### OK! Then How Do I Modify std::map Keys?

- After extracting nodes, we were able to modify their keys **_using the `key()`method_**, which gives us non-const access to the key, although keys are usually [const](/posts/when-to-use-const-vs-constexpr-in-cpp/).
- Note that in order to reinsert the nodes into the map again, we had to move them into the insert function. This makes sense because the extract is all about avoiding unnecessary copies and allocations. Moreover, while we move a `node_type` instance, this does not result in actual moves of any of the container values.

### Can I Modify Associated Values in std::map Also?

- Yes! You can **_use the accessor methods `nh.mapped()`**(instead of `nh.key()` to manipulate the pieces of the entry in a `std::map` (or `nh.value()`for the single piece of data in an element of a `std::set`). Thus you can extract, manipulate, and reinsert a key without ever copying or moving its actual data.

### But What About Safety?

- If you extract a node from a map and then throw an [exception](/posts/7-best-practices-for-exception-handling-in-cpp-with-example/) before you've managed to re-insert it into the destination map.
- A node handle's destructor is called and will correctly clean up the memory associated with the node. So, technically **_`std::map::extract` by-default(without insert) will act as [std::map::erase](https://en.cppreference.com/w/cpp/container/map/erase)_**!

### There Is More! Interoperability

- Map nodes that have been extracted using the `std::map::extract` are actually very versatile. **_We can extract nodes from a map instance and insert it into any other map or even multimap instance_**.
- It does also work between [unordered\_map](https://en.cppreference.com/w/cpp/container/unordered_map) and [unordered\_multimap](https://en.cppreference.com/w/cpp/container/unordered_multimap) instances, as well as with [set](https://en.cppreference.com/w/cpp/container/set)/[multiset](https://en.cppreference.com/w/cpp/container/multiset) and respective [unordered\_set](https://en.cppreference.com/w/cpp/container/unordered_set)/[unordered\_multiset](https://en.cppreference.com/w/cpp/container/unordered_multiset).
- In order to move items between different map/set structures, the types of key, value and allocator need to be identical.

## Difference Between operator\[ \] vs insert() vs at()

This is trivial for experienced devs but, still I want to go over it quickly.

### [std::map::operator\[ \]](https://en.cppreference.com/w/cpp/container/map/operator_at)

- **Operation**: find-or-add; try to find an element with the given key inside the map, and if it exists it will return a reference to the stored value. If it does not, it will create a new element inserted in place with default initialization and return a reference to it.
- **Applicability**:
    - Not usable for `const std::map`, as it will create the element if it doesn't exist.
    - Not suitable for value type that does not default constructible and assignable(in layman term, doesn't have default constructor & copy/move constructor).
- **When key exists**: Overwrites it.

### [std::map::insert](https://en.cppreference.com/w/cpp/container/map/insert)

- **Operation**: insert-or-nop; accepts a value\_type (`std::pair`) and uses the key(first member) and to insert it. As`std::map` does not allow for duplicates, if there is an existing element it will not insert anything.
- **Applicability**:
    - Liberty in calling insert different ways that require the creation of the value\_type externally and the copy of that object into the container.
    - Highly applicable when item insertion sequence is somewhat predictable to gain the performance.
- **When key exists**: Not modify the state of the map, but instead return an iterator to the element that prevented the insertion.

### [std::map::at](https://en.cppreference.com/w/cpp/container/map/at)

- **Operation**: find-or-throw; returns a reference to the mapped value of the element with key equivalent to input key. If no such element exists, an [exception](/posts/7-best-practices-for-exception-handling-in-cpp-with-example/) of type [std::out\_of\_range](https://en.cppreference.com/w/cpp/error/out_of_range) is thrown.
- **Applicability**:
    - Not recommended using `at()`when accessing const maps and when element absence is a logic error.
    - Yes, it's better to use `std::map::find()`when you're not sure element is there. Because, throwing and catching [std::logic\_error](https://en.cppreference.com/w/cpp/error/logic_error) exception will not be a very elegant way of programming, even if we don't think about performance.
- **When key exists**: returns a reference to mapped value.

## Parting Words

If you see the table of content for this article above, more than half of the member functions are around inserting the elements into the map. To the newbie, this is the reason for anxiety(or standard committee would say modernness). But if you account for the new features & complexity of language those are pretty much justified. BTW, this modernness doesn't stop here, we do have other specialization also available for map like [std::swap](https://en.cppreference.com/w/cpp/container/map/swap2)(C++17), [std::erase\_if](https://en.cppreference.com/w/cpp/container/map/erase_if)(C++20) & bunch of comparison operators.
