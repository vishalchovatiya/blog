#pragma once

#include <algorithm>
#include <iostream>
#include <map>
#include <prettyprint.hpp>
#include <set>
#include <sstream>
#include <string>
#include <tuple>
#include <vector>
// #include "BigInt.hpp" // https://faheel.github.io/BigInt/

using namespace std;

#define DEBUG(X) cout << #X << " = " << X << endl;
#define ALL(X) begin(X), end(X)

using u64 = uint64_t;
using u32 = uint32_t;
using u8 = uint8_t;

using s64 = int64_t;
using s32 = int32_t;
using s8 = int8_t;

u64 set_bit(u64 n, u64 k) { return (n | (1 << (k - 1))); }
u64 clear_bit(u64 n, u64 k) { return (n & (~(1 << (k - 1)))); }
u64 toggle_bit(u64 n, u64 k) { return (n ^ (1 << (k - 1))); }

#define letter_to_number(lowercase_char) (lowercase_char - 'a')