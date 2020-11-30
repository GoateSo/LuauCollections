local l = unpack(require(script.Parent.List))
local LazyList = {}
LazyList.__index = LazyList
local empty = setmetatable({h = function () end,t = function() end},LazyList)

---destructively get the head of the list
--[[
@params
	this:LazyList[A] = LazyList in question
@return
	A? = head of the list, nil if empty
]]
local function getH(this)
	local h = this.h
	if type(h) == "function" then
		this.h = h()
	end
	return this.h
end
---destructively get the tail of the list
--[[
@params
	this:LazyList[A] = LazyList in question
@return
	LazyList[A]? = Tail of the list, nil if empty
]]
local function getT(this)
	local t = this.t
	if type(t) == "function" then
		this.t = t()
	end
	return this.t
end
---destructively get both the head and the tail of the list
--[[
@params
	this:LazyList[A] = LazyList in question
@return
	A?= head of the list, nil if empty 
	LazyList? = Tail of the list, nil if empty
]]
local function getHT(this)
	return getH(this),getT(this)
end
---NON-DESTRUCTIVELY get both the head and the tail of the list
--[[
@params
	this:LazyList[A] = LazyList in question
@return
	A? = head of the list, nil if empty 
	LazyList? = Tail of the list, nil if empty
]]
local function nonDestr(this)
	if this == empty then return end
	local h = type(this.h)=="function" and this.h() or this.h
	local t = type(this.t)=="function" and this.t() or this.t
	return h,t
end
---prepends h to t, and returns the resulting LazyList
--[[
@params
	h (head): =>A = element to be prepended (represented as a thunk)
	t (tail): =>LazyList[A] = LazyList to be prepended to (represented as a thunk)
@return
	LazyList[A] = resulting LazyList
]]
local function cons(h,t) -- h and t being functions
	return setmetatable({h = h,t = t},LazyList)
end
---creates a LazyList from an arbitrary sequence of elements
--[[
(results the empty LazyList if no arguments are provideed, as opposed to creating a new LazyList w/ 0 elements in it)
@params
	...:A* = sequence of elements 
@return
	LazyList[A] = resulting LazyList
]]
local function mkList(...)
	local h,t  = (...),{select(2,...)}
	if not h then return empty
	else return cons(function() return h end, function() return mkList(unpack(t)) end) end
end
---pretty much an alias for cons(_,self), except wraps both in thunks
--[[
@params
	x:A = element to prepend
@return
	LazyList[A] = resulting LazyList
]]
function LazyList:prepend(x)
	return cons(function() return x end, function() return self end)
end
---evaluates (if not evaluated) the head of the LazyList and returns the value
--[[
@return
	A? = resulting value
]]
function LazyList:head()
	return getH(self)
end
---evaluates (if not evaluated) the head of the LazyList and returns the value
--[[
@return
	LazyList[A]? = resulting LazyList
]]
function LazyList:tail()
	return getT(self)
end
---more user friendly wrapper for cons, and alternative to prepend which automatically wraps the head in a thunk
--[[
@params 
	h:A = the head
	t: =>LazyList[A] = the tail
@return
	LazyList[A] = the resulting LazyList
]]
function LazyList.cons(h,t)
	return cons(function() return h end,t)
end
---constrcts a LazyList of numbers from (greater than or equal to) a given number, preferably an integer
--[[
@params 
	min:Int = minimum value
@return
	LazyList[Int] = the resulting LazyList
]]
function LazyList.from(min)
	return LazyList.unfold(min-1,function(s)
		return s+1,s+1
	end)
end
---constrcts a LazyList of numbers within an inclusive range
--[[
@params 
	min:Int = minimum value
	max:Int = maximum value
@return
	LazyList[Int] = the resulting LazyList
]]
function LazyList.inRange(min,max)
	assert(min >= max,"empty range, if intentional, simply provide no arguments to standard lazylist constructor")
	return LazyList.unfold(min-1,function(s)
		if s+1 <= max then
			return s+1,s+1
		end
	end)
end
---gets the number of elements in the LazyList
--[[
@return
	Int = number of elements in the list
]]
function LazyList:getLength()
	return self:foldl(0,function(s,_)
		return s+1
	end)
end
---Get the element at the specified index (base 1 indexed)
--[[
@params
	Int = index
@return
	A = value at that index
]]
function LazyList:__call(n)
	if self == empty or n < 1 then return nil end
	local h,t = getHT(self)
	if n == 1 then return h
	elseif t == empty then return nil
	else return t(n-1) end
end
---Updates the value of the list at the given index to a given value
--[[
@params
	index:Int = given index
	newValue:A = replacement vlaue
@return
	LazyList[A] = LazyList with replaced value
]]
function LazyList:update(index,newVal)
	assert(self ~= empty,"attempted to index element beyond size of list")
	if index == 1 then
		return cons(newVal,self:tail())
	else
		return cons(self:head(),self:tail():update(index-1,newVal))
	end
end
---forces evaluation on all elements, and turns it into a (strict) List
--[[
@return
	List[A] = resulting List
]]
function LazyList:toList()
	local h,t = getHT(self)
	if h and t then return t:toList():prepend(h)
	else return l() end
end
---takes the first n elements of a LazyList, and discards the rest
--[[
@params
	n:Number = amount of elements to take
@return
	LazyList[A] = resulting LazyList
]]
function LazyList:take(n)
	local h,t = nonDestr(self)
	if h and t and n>1 then return cons(function() return h end, function() return t:take(n-1) end)
	elseif h and n == 1 then return cons(function() return h end, function() return empty end)
	else return empty end
end
---complement to take, discards the first n elements of a LazyList, and takes the rest
--[[
@params
	n:Number = amount of elements to drop
@return
	LazyList[A] = resulting LazyList
]]
function LazyList:drop(n)
	local h,t = nonDestr(self)
	if h and t and n>1 then return t:drop(n-1)
	elseif h and n == 1 then return t
	else return self end
end
---Applies a binary operator(foo) to a start value and all elements of this LazyList, going left to right.
--[[
@params:
	init: B = initial value
	f: (B,=>A) => B = binary operation to perform
@return
	 B = resulting value
]]
function LazyList:foldl(init,f)
	local h,t = getHT(self)
	if not h then return init end
	return t:foldl(
		f(init,function() return h end),
		f
	)
end
---Applies a binary operation to all elements of this LazyList and a start value, going right to left.
--[[
@params
	init:B = initial value 
	f:(A,=>B)=>B = binary operation to perform
@return
	B = resulting value
]]
function LazyList:foldr(init,f)
	local h,t = getHT(self)
	if h then
		return f(
			h,
			function() return t:foldr(init,f) end
		)
	end
	return init
end
---non destructive version of the above function
local function ndFoldr(self,init,f)
	local h,t = nonDestr(self)
	if h then
		return f(
				h,
			function() return ndFoldr(t,init,f) end
		)
	end
	return init
end
---applies a binary operation to an initial value and values of the list going left -> right, and returning a list of the intermediate values
--[[
@params
	init:B = initial value
	f:(B,=>A)=>B = binary operation to perform
@return
	LazyList[B] = list of intermediate values
]]
function LazyList:scanl(init,f)
	if self == empty then return mkList(init) end
	return cons(
		function() return init end,
		function() return self:tail():scanl(f(init,self:head()),f) end
	)
end
---applies a binary operation to an initial value and values of the list going left -> right, and returning a list of the intermediate values
--[[
@params
	init:B = initial value
	f:(A,=>B)=>B = binary operation to perform
@return
	LazyList[B] = list of intermediate values
]]
function LazyList:scanr(init,f)
	return self:foldr({init,mkList(init)},function(a,p0)
		local v = f(a,function() return p0()[1] end)
		return {v,cons(
			function() return v end,
			function() return p0()[2] end
		)}
	end)[2]
end
---Tests whether at least one elements of the LazyList fulfill a predicate
--[[
@params
	pred:A=>Bool = the predicate in question
@return
	Bool = whether any elements fulfilled the predicate
]]
function LazyList:exists(pred)
	return self:foldr(false,function(a,b)
		return pred(a) or b()	
	end)
end
---Tests whether all elements of the LazyList fulfill a predicate
--[[
@params
	pred:A=>Bool = the predicate in question
@return
	Bool = whether all elements fulfilled the predicate
]]
function LazyList:forall(pred)
	return self:foldr(true,function(a,b)
		return pred(a) and b()	
	end)
end
---takes the first n elements of a LazyList which fulfill the given predicate, and discards the rest
--[[
@params
	pred:A=>Bool = the predicate in question
@return
	LazyList[A] = resulting LazyList
]]
function LazyList:takeWhile(pred)
	return ndFoldr(self,empty,function(a,b)
		if pred(a) then return cons(function() return a end,function() return b() end)
		else return empty end
	end)
end
---discards the first section of a LazyList which fulfill the given predicate, and discards the rest
--[[
@params
	pred:A=>Bool = the predicate in question
@return
	LazyList[A] = the resulting LazyList
]]
function LazyList:dropWhile(pred)
	local h,t = nonDestr(self)
	if h and t then
		if pred(h) then
			return t:dropWhile(pred)
		end
		return self
	else 
		return empty
	end
end
---Applies a function on all members of an LazyList, and returns the result
--[[
@params
	f:A=>B = function to apply
@return
	LazyList[B] = resulting LazyList
]]
function LazyList:map(f)
	return ndFoldr(self,empty,function(a,b)
		return cons(function() return f(a) end, function() return b() end)
	end)
end
---Takes all members of a LazyList which fulfills a given predicate
--[[
@params
	pred:A=>Bool = predicate in question
@return
	LazyList[A] = resulting LazyList
]]
function LazyList:filter(p)
	return  ndFoldr(self,empty,function(a,b)
		if p(a) then return cons(function() return a end, function() return b() end)
		else return b() end
	end)
end
---appends a given LazyList to the current LazyList, by prepending all elements of the current LazyList to that LazyList
--[[
@params
	l2:LazyList[A] = LazyList to append
@return
	LazyList[A] = resulting LazyList
]]
function LazyList:append(l2)
	return ndFoldr(self,l2,function(a,b)
		return cons(function() return a end, function() return b() end)
	end)
end
---Builds a new LazyList by applying a function to all elements of this LazyList and using the elements of the resulting LazyList.
--[[
@params
	f:A=>LazyList[B] = function to apply
@return
	LazyList[B]
		resulting LazyList
]]
function LazyList:flatMap(f)
	return ndFoldr(self,empty,function(a,b)
		return f(a):append(b())
	end)
end
---creates a LazyList that is the result of a binary operation applies on corresponding elements of each LazyList
--[[ 
@params
	that:LazyList[B] = List to be zipped with
	f:(A,B) => C = binary function to be applied
@return
	LazyList[C] = resulting LazyList
]]
function LazyList:zipWith(that,f)
	return LazyList.unfold({self,that},function(s)
		local l1,l2 = s[1],s[2]
		local h1,t1,h2,t2 = nonDestr(l1),nonDestr(l2)
		if h1 and h2 and t1 and t2 then return f(h1,h2),{t1,t2}
		else return nil end
	end)
end
---Splits a LazyList into two LazyLists, depending on whether an element fulfills a given predicate
--[[
@params
	pred:A=>Bool = predicate in question
@return
	LazyList[A] = resulting LazyList where all elements fulfill the predicate (result if one were to call filter)
	LazyList[A] = resulting LazyList where all elements do not fulfill the predicate
]]
function LazyList:partition(pred)
	return self:filter(pred),self:filter(function(x) return not pred(x) end)
end
--- creates a LazyList from this and another LazyList, where the corresponding elements are paired (to the end of the shorter List)
--[[
@param l2:LazyList[B] = LazyList to be zipped with
@return LazyList[(A,B)] resulting LazyList
]]
function LazyList:zip(l2)
	return self:zipWith(l2,function(a,b)
		return l(a,b)
	end)
end
--- Turns a lazy list into a string,
--- stops at the first non-evaluated value of the lazy list, and represents the rest as the string "<?>" 
--[[ 
@usage displays current state of the lazy list (what is evaluated)
@return
]]
function LazyList:__tostring()
	local function go(list)
		local h = list.h
		if not h then return "" end
		if type(h) == "function" then return "<?>" end
		local t = list.t
		return h..","..go(type(t) == "function" and t() or t)
	end
	return "LazyList("..go(self)..")"
end
---constructs a LazyList from an initial state and a state action, will terminate once the state action returns nil
--[[
@params
	init:S = initial state
	func:S => (A?,S) = the state action
@return
	LazyList[A] = Resulting LazyList
]]
function LazyList.unfold(init,func)
	if init == nil then return empty 
	else 
		local a,new = func(init)
		return cons(function() return a end,function() return LazyList.unfold(new,func) end) 
	end
end

return {mkList,LazyList}
