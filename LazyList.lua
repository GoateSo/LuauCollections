local l,lc = unpack(require(script.Parent.List))
local LazyList = {}
LazyList.__index = LazyList
local empty = setmetatable({head = function () end,tail = function() end},LazyList)

--[[
prepends h to t, and returns the resulting LazyList
@params
	h (head): =>A
		element to be prepended (represented as a thunk)
	t (tail): =>LList[A]
		LazyList to be prepended to (represented as a thunk)
@return
	LList[A]
		resulting LazyList
]]
local function cons(h,t) -- h and t being functions
	return setmetatable({head = h,tail = t},LazyList)
end
--[[
creates a LazyList from an arbitrary sequence of elements
@params
	...:A*
		sequence of elements 
@return
	LList[A]
		resulting LazyList
]]
local function mkList(...)
	local h,t  = (...),{select(2,...)}
	if not h then return empty
	else return cons(function() return h end, function() return mkList(unpack(t)) end) end
end
--[[
pretty much an alias for cons(_,self)
@params
	x:A
		element to prepend
@return
	LList[A]
		resulting LazyList
]]
function LazyList:prepend(x)
	return cons(function() return x end, function() return self end)
end
--[[
gets the number of elements in the list
@params
@return
	Int
		number of elements in the list
]]
function LazyList:getLength()
	return self:foldl(0,function(s,a)
		return s+1
	end)
end
--[[
Get the element at the specified index (base 1 indexed)
@params
	Int
		index
@return
	A
		value at that index
]]
function LazyList:__call(n)
	if self == empty or n < 1 then return nil end
	local h,t = self.head(),self.tail()
	if n == 1 then return h
	elseif t == empty then return nil
	else return t(n-1) end
end
--[[
forces evaluation on all elements, and turns it into a (strict) List
@params
@return
	List[A]
		resulting List
]]
function LazyList:toList()
	local h,t = self.head(),self.tail()
	if h and t then return t:toList():prepend(h)
	else return l() end
end
--[[
takes the first n elements of a LazyList, and discards the rest
@params
	n:Number
		amount of elements to take
@return
	LList[A]
		resulting LazyList
]]
function LazyList:take(n)
	local h,t = self.head(),self.tail()
	if h and t and n>1 then return cons(function() return h end, function() return t:take(n-1) end)
	elseif h and n == 1 then return cons(function() return h end, function() return empty end)
	else return empty end
end
--[[
complement to take, discards the first n elements of a LazyList, and takes the rest
@params
	n:Number
		amount of elements to drop
@return
	LList[A]
		resulting LazyList
]]
function LazyList:drop(n)
	local h,t = self.head(),self.tail()
	if h and t and n>1 then return t:drop(n-1)
	elseif h and n == 1 then return t
	else return self end
end
--[[
Applies a binary operator(foo) to a start value and all elements of this LazyList, going left to right.
@params:
	init: B
		initial value
	foo: (B,=>A) => B
		binary operation to perform
@return
	 B
		resulting value
]]
function LazyList:foldl(init,foo)
	local h,t = self.head(),self.tail()
	if not h then return init end
	return t:foldl(
		foo(init,function() return h end),
		foo
	)
end
--[[
Applies a binary operation to all elements of this LazyList and a start value, going right to left.
@params
	init: B
		initial value 
	foo: (A,=>B) => B
		binary operation to perform
@return
	B
		resulting value
]]
function LazyList:foldr(init,foo)
	local function fr(self,init_f,foo)
		local h,t = self.head(),self.tail()
		if h and t then 
			return foo(
				h,
				function() return fr(t,init_f,foo) end
			)
		else return init_f() end		
	end
	return fr(self,function() return init end,foo)
end
--[[
Tests whether at least one elements of the LazyList fulfill a predicate
@params
	pred:A=>Bool
		the predicate in question
@return
	Bool
		whether any elements fulfilled the predicate
]]
function LazyList:exists(pred)
	return self:foldr(false,function(a,b)
		return pred(a) or b()	
	end)
end
--[[
Tests whether all elements of the LazyList fulfill a predicate
@params
	pred:A=>Bool
		the predicate in question
@return
	Bool
		whether all elements fulfilled the predicate
]]
function LazyList:forall(pred)
	return self:foldr(true,function(a,b)
		return pred(a) and b()	
	end)
end
--[[
takes the first n elements of a LazyList which fulfill the given predicate, and discards the rest
@params
	pred:A=>Bool
		the predicate in question
@return
	LList[A]
		resulting LazyList
]]
function LazyList:takeWhile(pred)
	return self:foldr(empty,function(a,b)
		if pred(a) then return cons(function() return a end,function() return b() end)
		else return empty end
	end)
end
--[[
discards the first section of a LazyList which fulfill the given predicate, and discards the rest
@params
	pred:A=>Bool
		the predicate in question
@return
	LList[A]
		the resulting LazyList
]]
function LazyList:dropWhile(pred)
	local h,t = self.head(),self.tail()
	if h and t then
		if pred(h) then
			return t:dropWhile(pred)
		end
		return self
	else 
		return empty
	end
end
--[[
Applies a function on all members of an LazyList, and returns the result
@params
	f:A=>B
		function to apply
@return
	LList[B]
		resulting LList
]]
function LazyList:map(f)
	return self:foldr(empty,function(a,b)
		return cons(function() return f(a) end, function() return b() end)
	end)
end
--[[
Takes all members of a LazyList which fulfills a given predicate
@params
	pred:A=>Bool
		predicate in question
@return
	LList[A]
		resulting LazyList
]]
function LazyList:filter(p)
	return self:foldr(empty,function(a,b)
		if p(a) then return cons(function() return a end, function() return b() end)
		else return b() end
	end)
end
--[[
appends a given LList to the current LList, by prepending all elements of the current LazyList to that LazyList
@params
	l2:LList[A]
		LazyList to append
@return
	LList[A]
		resulting LazyList
]]
function LazyList:append(l2)
	return self:foldr(l2,function(a,b)
		return cons(function() return a end, function() return b() end)
	end)
end
--[[
Builds a new LazyList by applying a function to all elements of this LazyList and using the elements of the resulting LazyList.
@params
	f:A=>LList[B]
		function to apply
@return
	LList[B]
		resulting LazyList
]]
function LazyList:flatMap(f)
	return self:foldr(empty,function(a,b)
		return f(a):append(b())
	end)
end
--[[
creates a LazyList that is the result of a binary operation applies on corresponding elements of each LazyList 
@params
	l2:LList[B]
		List to be zipped with
	f:(A,B) => C
		binary function to be applied
@return
	LList[C]
		resulting LazyList
]]
function LazyList:zipWith(l2,f)
	return LazyList.unfold({self,l2},function(s)
		local l1,l2 = s[1],s[2]
		local h1,t1,h2,t2 = l1.head(),l1.tail(),l2.head(),l2.tail()
		if h1 and h2 and t1 and t2 then return f(h1,h2),{t1,t2}
		else return nil end
	end)
end
--[[
Splits a LazyList into two LazyLists, depending on whether an element fulfills a given predicate
@params
	pred:A=>Bool
		predicate in question
@return
	LList[A]
		resulting LazyList where all elements fulfill the predicate (result if one were to call filter)
	LList[A]
		resulting LazyList where all elements do not fulfill the predicate
]]
function LazyList:partition(pred)
	return self:filter(pred),self:filter(function(x) return not pred(x) end)
end
--[[
creates a LazyList from this and another LazyList, where the corresponding elements are paired (to the end of the shorter List)
@params
	l2:LList[B]
		LazyList to be zipped with
@return
	LList[(A,B)] (its just a two element (strict) List, it's not actually a proper pair type)
		resulting LazyList
]]
function LazyList:zip(l2)
	return self:zipWith(l2,function(a,b)
		return l(a,b)
	end)
end
--[[
constructs a LazyList from an initial state and a state action, will terminate once the state action returns nil
@params
	init:S
		initial state
	func:S => (A?,S)
		the state action
@return
	LList[A]
		Resulting LazyList
]]
function LazyList.unfold(init,func)
	if init == nil then return empty 
	else 
		local a,new = func(init)
		return cons(function() return a end,function() return LazyList.unfold(new,func) end) 
	end
end

return {mkList,LazyList}
