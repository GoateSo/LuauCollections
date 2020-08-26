# LuauCollections
Random assortment of Collections and Utilities for Roblox

## Option

Options represent an Optional value (hence their name), and are represented by either a Some
```scala
Some(value)
```
or a None
```scala
None
```
They are useful for implementing partial functions, and allow for quick chaining of multiple operations, for example:
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



## LazyList
