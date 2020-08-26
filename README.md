# LuauCollections
Random assortment of Collections and Utilities for Roblox based on the members of the Scala standard library
The current fully implemented collections are:
## Conventions
### Typing
- Any usage of uppercase `A` in type descriptions refers to the type of the values inside current Object (eg: `LList[A]`)
- Any usage of `=>X` where X is some type in type descriptions is an alias of `()=>X`, which takes no parameters, and yields a value of type X
- Any usage of `X*` where X is some type in type descriptions represents a sequence of 0+ values of type X
### Casing
- methods and fields are in lowerCamelCase
- objects themselves are in PascalCase
### Method Documentation
- 1 tab : name of parameter & type of parameter/return
- 2 tabs: description of parameter/return value
## Option

Options represent an Optional value (hence their name), and are represented by either a Some
```scala
Some(value)
```
or a None
```scala
None
```
They are useful for implementing partial function returns, allow for quick chaining of multiple operations, and reduce boilerplate when it comes to validating whether arguments passed to a partial function are valid, for example:
```lua
local function f(x)
  return x*10
end
local function g(x)
    assert(x~=0,"dividing by 0")
    return 100/x
end
local function p(x)
    return x~=0
end
print(Option(0):map(f):filter(p):map(g))  --> None (as opposed to an assertion error)
print(Option(10):map(f):filter(p):map(g)) --> Some(1)
```

> Module exports a table of 2 values, the first being the Option object itself, the second being the None object

## List

Strict List Data Structure

Data is represented as a singularly linked list with the following structure:

	 List(1,2,3) = cons(1,cons(2,cons(3,empty)))

where: empty = the singleton object for the empty List

Time: list prepending is O(1), most other operations are O(n), where n represents the number of elements in the List

Space: most operations take constant space, since tails are shared when prepending

Lists work based on an assumption that they are immutable objects, as for example:
```
x <- LList(1,2,3)
y <- x:prepend(0)
```
both mutates `x` and mutates `y`, which is not ideal with mutable lists.

> Module exports a table of 2 values, the first being the List constructor, the second being the object itself

## LazyList

LazyList (Stream) data structure:

Where the evaluation of the head\* and tail are deferred until needed.
Allows for the construcion of LazyLists of infinite size (using the stream building function "unfold"), for example, the fibonacci sequence:
```lua
local function fibs()
    return LazyList.unfold({0,1},function(s)
        return s[1],{s[2],s[1]+s[2]}
    end)
end
```
> Module exports a table of 2 values, the first being the LazyList constructor, the second being the object itself

\*: wrapping the evaluation of the head in a function is rather useless due to lua strictly evaluating the value, at the moment, it is more for consistency with the tail, which is deferred via being wrapped in a function. 

Another feature of note is the requirement that the 2nd parameter of the function passed to "foldl" be treated as a function, this too is also useless, but kept in for consistency with "foldr".

these feature might be subject to removal in the near future to better reflect the behavior of Scala.Collection.Immutable.LazyList

LazyLists share the same assumption of immutability and structure as strict lists, although it's in the form:

	 LazyList(1,2,3) = cons(=>1,=>cons(=>2,=>cons(=>3,=>empty)))
	
where =>x is an alias for ()=>x (see conventions) 
