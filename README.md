# LuauCollections
Random assortment of Collections and Utilities for Roblox based partially on the members of the Scala standard library
The current fully implemented collections & utilities are:

+ BinaryTree
+ Either
+ LazyList
+ List
+ Option

##  how are they useful?
the above features allow for easy and intuitive representations for relatively complex problems, for example, getting the first N prime numbers

```lua
--doesnt work 
local nums = LazyListClass.from(2)
local function sieve(list)
    if list == LazyList() then return LazyList() end
    local h,t = list:head(),list:tail()
    local function nonFac(x)
        return x%h ~=0
    end
    return LazyListClass.cons(h,function() return sieve(t:filter(nonFac)) end)
end
print(sieve(nums):take(5)) --> List:[2,3,5,7,11]
```

or letting code fail meaningfully without the need for exceptions or excessive usage of pcall

```lua
local function nonZero(x)
  return x~=0
end
local function f(x)
   return 100/x
end
print(Right(10):filterOrElse(nonZero,"cannot divide by zero"):map(f)) --> Right(10)
print(Right(0):filterOrElse(nonZero,"cannot divide by zero"):map(f))  --> Left(cannot divide by zero)
```
