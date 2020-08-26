# LuauCollections
Random assortment of Collections and Utilities for Roblox based on the members of the Scala standard library
The current fully implemented collections are:

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

## List

Strict List Data Structure

Data is represented as a singularly linked list with the following structure:

	List(1,2,3) = cons(1,cons(2,cons(3,empty)))

where
-empty = the singleton object for the empty List

Time: list prepending is O(1), most other operations are O(n), where n represents the number of elements in the lsit
Space: most operations take constant space, since tails are shared when prepending

## LazyList
