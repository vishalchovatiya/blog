---
title: "How Floating-Point No Is Stored in Memory?"
date: "2019-09-15"
categories: 
  - "c-language"
  - "cpp"
tags: 
  - "exponent"
  - "exponent-calculation"
  - "floating-point-error"
  - "floating-point-exceptions"
  - "floating-point-multiplication"
  - "floating-point-number-memory-layout"
  - "floating-point-numbers"
  - "floating-point-overflow"
  - "floating-point-representation"
  - "how-float-and-double-are-stored-in-c"
  - "how-floating-point-numbers-are-stored-in-memory-in-java"
  - "mantissa"
  - "nan"
  - "nan-representation-in-computer-memory"
  - "overflow-and-underflow-in-floating-point-numbers"
  - "positive-negative-infinity-representation-in-computer-memory"
  - "rounding-in-floating-point"
  - "sign"
  - "significand"
  - "where-the-decimal-point-is-stored"
  - "why-do-we-need-nan"
  - "zero-representation-in-computer-memory"
featuredImage: "/images/how-floating-point-numbers-stored-in-memory.png"
---

This article is just a simplification of the IEEE 754 standard. Here, we will see how floating-point no stored in memory, floating-point exceptions/rounding, etc. But if you will want to find more authoritative sources then go for

1. [What Every Computer Scientist Should Know About Floating-Point Arithmetic](http://docs.oracle.com/cd/E19957-01/806-3568/ncg_goldberg.html)
2. [https://en.wikipedia.org/wiki/IEEE\_754-1985](https://en.wikipedia.org/wiki/IEEE_754-1985)
3. [https://en.wikipedia.org/wiki/Floating\_point](https://en.wikipedia.org/wiki/Floating_point).

**Floating-point numbers stored by encoding significand & the exponent (along with a sign bit)**

- Above line contains 2-3 abstract terms & I think you will unable to understand the above line until you read further.

## Floating Point Number Memory Layout

```
+-+--------+-----------------------+
| |        |                       |
+-+--------+-----------------------+
 ^    ^                ^
 |    |                |
 |    |                +-- significand(width- 23 bit) 
 |    |
 |    +------------------- exponent(width- 8 bit) 
 |
 +------------------------ sign bit(width- 1 bit)
```

A typical single-precision 32-bit floating-point memory layout has the following fields :

1. sign
2. exponent
3. significand(AKA mantissa)

### Sign

- The high-order bit indicates a sign.
- `0` indicates a positive value, `1` indicates negative.

### Exponent

- The next 8 bits are used for the exponent which can be positive or negative, but instead of reserving another sign bit, they're encoded such that `1000 0000` represents `0`, so `0000 0000` represents `-128` and `1111 1111` represents `127`.
- How does this encoding work? go to [exponent bias](https://en.wikipedia.org/wiki/Exponent_bias) or see it in next point practically.

### Significand

- The remaining 23-bits used for the significand(AKA mantissa). Each bit represents a negative power of 2 countings from the left, so:

```
01101 = 0 * 2^-1 + 1 * 2^-2 + 1 * 2^-3 + 0 * 2^-4 + 1 * 2^-5 
      = 0.25 + 0.125 + 0.03125 
      = 0.40625
```

OK! We are done with basics.

## Let's Understand Practically

- So, we consider very famous float value `3.14`(PI) example.
- **Sign**: Zero here, as PI is positive!

### Exponent calculation

- `3` is easy: `0011` in binary
- The rest, `0.14`

```
0.14 x 2 = 0.28, 0

0.28 x 2 = 0.56, 00

0.56 x 2 = 1.12, 001

0.12 x 2 = 0.24, 0010

0.24 x 2 = 0.48, 00100

0.48 x 2 = 0.96, 001000

0.96 x 2 = 1.92, 0010001

0.92 x 2 = 1.84, 00100011

0.84 x 2 = 1.68, 001000111

And so on . . .
```

- So, `0.14 = 001000111...`If you don't know how to convert decimal no in binary then refer this [float to binary](http://stackoverflow.com/questions/3954498/how-to-convert-float-number-to-binary).
- Add `3`,  `11.001000111... with exp  0 (3.14 * 2^0)
- Now shift it (normalize it) and adjust the exponent accordingly  `1.1001000111... with exp +1 (1.57 * 2^1)
- Now you only have to add the bias of `127` to the exponent `1` and store it(i.e. `128` = `1000 0000`)  `0     1000 0000     1100 1000 111...`
- Forget the top `1` of the mantissa (which is always supposed to be `1`, except for some special values, so it is not stored), and you get:  `0     1000 0000     1001 0001 111...`
- So our value of `3.14` would be represented as something like:

```
    0 10000000 10010001111010111000011
    ^     ^               ^
    |     |               |
    |     |               +--- significand = 0.7853975
    |     |
    |     +------------------- exponent = 1
    |
    +------------------------- sign = 0 (positive)

```

- The number of bits in the exponent determines the range (the minimum and maximum values you can represent).

### Summing up Significand

- If you add up all the bits in the significand, they don't total `0.7853975`(which should be, according to 7 digit precision). They come out to `0.78539747`.
- There aren't quite enough bits to store the value exactly. we can only store an approximation.
- The number of bits in the significand determines the precision.
- 23-bits gives us roughly 6 decimal digits of precision. 64-bit floating-point types give roughly 12 to 15 digits of precision.

 **Strange! But Fact**

- Some values cannot represent exactly no matter how many bits you use. Just as values like 1/3 cannot represent in a finite number of decimal digits, values like 1/10 cannot represent in a finite number of bits.
- Since values are approximate, calculations with them are also approximate, and rounding errors accumulate.

## Let's See Things Working

```c
#include <stdio.h>
#include <string.h>

/* Print binary stored in plain 32 bit block */ 
void intToBinary(unsigned int n)
{
        int c, k;
        for (c = 31; c >= 0; c--)
        {
                k = n >> c;
                if (k & 1)  printf("1");
                else        printf("0");
        }
        printf("\n");
}

int main(void) 
{
        unsigned int m;
        float f = 3.14;

        /* See hex representation */
        printf("f = %a\n", f);  


        /* Copy memory representation of float to plain 32 bit block */
        memcpy(&m, &f, sizeof (m));     
        intToBinary(m);

        return 0;
}
```

- This [C code](/posts/how-c-program-converted-into-assembly/) will print binary representation of float on the console.

```
f = 0x3.23d70cp+0
01000000010010001111010111000011
```

## Where the Decimal Point Is Stored?

- The decimal point not explicitly stored anywhere.
- As I wrote a line `Floating-point numbers stored by encoding significand & the exponent (along with a sign bit), but you don't get it the first time. Don't worry 99% people don't get it first, including me.

## A Bit More About Representing Numbers

- According to `IEEE 754-1985` worldwide standard, you can also store zero, negative/positive infinity and even \`NaN\`(Not a Number). Don't worry if you don't know what is `NaN`, I will explain shortly(But be worried, if you don't know infinity).

### Zero Representation

- sign = 0 for positive zero, 1 for negative zero.
- exponent = 0.
- fraction = 0.

### Positive & Negative Infinity Representation

- sign = 0, for positive infinity, 1 for negative infinity.
- exponent = all 1 bits.
- fraction = all 0 bits.

### NaN Representation

- sign = either 0 or 1.
- exponent = all 1 bits.
- fraction = anything except all 0 bits (since all 0 bits represents infinity)

## Why Do We Need `NaN` ?

- Some operations of floating-point arithmetic are invalid, such as dividing by zero or taking the square root of a negative number.
- The act of reaching an invalid result called a floating-point exception(next point). An exceptional result is represented by a special code called a `NaN`, for "Not a Number".

## Floating-Point Exceptions

- The `IEEE 754-1985` standard defines five exceptions that can occur during a floating-point calculation named as

1. **Invalid Operation**: occurs due to many causes like multiplication of infinite with zero or infinite, division of infinite by zero or infinite & vice-versa, square root of operand less than zero, etc.
2. **Division by Zero**: occurs when "as its name sounds"
3. **Overflow**: This exception raised whenever the result cannot represent a finite value in the precision format of the destination.
4. **Underflow**: The underflow exception raised when an intermediate result is too small to calculate accurately, or if the operation’s result rounded to the destination precision too small to normalized
5. **Inexact**: raised when a rounded result not exact.

## Rounding in Floating-Point

- As we saw floating-point numbers have a limited number of digits, they cannot represent all real numbers accurately: when there are more digits than the format allows, the leftover ones are omitted - the number is rounded.
- There are 4 rounding modes :

1\. Round to Nearest: rounded to the nearest value with an even (zero) least significant bit, which occurs 50% of the time.  
2\. Round toward 0 – simply truncate the extra digits.  
3\. Round toward +∞ – rounding towards positive infinity.  
4\. Round toward −∞ – rounding towards negative infinity.

## Misc points

- In older time, embedded system processors do not use floating-point numbers as they don't have such hardware capabilities.
- So there is some alternative to a floating-point number, called Fixed Point Numbers.
- A fixed-point number is usually used in special-purpose applications on embedded processors that can only do integer arithmetic, but decimal fixed point('.') is manipulated by software library.
- But nowadays, the microcontroller has separate FPU's too, like STM32F series.
