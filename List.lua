local List = {}
List.__index = List
local empty = setmetatable({},List)
--[[
prepends h to t, and returns the resulting List
@params
	h (head): A
		element to be prepended
	t (tail): List[A]
		List to be prepended to
@return
	List[A]
		resulting List
]]
local function cons(h,t)
	return setmetatable({head = h,tail = t},List)
end
--[[
creates a List from an arbitrary sequence of elements
@params
	...:A*
		sequence of elements 
@return
	List[A]
		resulting List
]]
local function mkList(...) 
	if not (...) then return empty
	else return cons((...),mkList(select(2,...)))end
end
--[[
pretty much an alias for cons(x,self)
@params
	x:A
		element to prepend
@return
	List[A]
		resulting List
]]
function List:prepend(x)
	return cons(x,self)
end
--[[
Reverses a List
@params
@return
	List[A]
		resulting List
]]
function List:reverse()
	return self:foldl(setmetatable({},List),function(a,b) return cons(b,a) end)
end
--[[
gets the number of elements in the List
@params
@return
	Int
		number of elements in the List
]]
function List:getLength()
	local t = self.tail
	if self == empty then return 0
	else return 1+t:getLength() end
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
function List:__call(n)
	if self == empty or n < 1  then return nil end
	local h,t = self.head,self.tail
	if n == 1 then return h
	elseif t == empty then return nil
	else return t(n-1) end
end
--[[
takes the first n elements of a List, and discards the rest
@params
	n:Number
		amount of elements to take
@return
	List[A]
		resulting List
]]

function List:take(n)
	local h,t = self.head,self.tail
	if h and t and n>1 then return cons(h,t:take(n-1))
	elseif h and n == 1 then return cons(h,empty)
	else return empty end
end
--[[
complement to take, discards the first n elements of a List, and takes the rest
@params
	n:Number
		amount of elements to drop
@return
	List[A]
		resulting List
]]
function List:drop(n)
	local h,t = self.head,self.tail
	if h and t and n>1 then return t:drop(n-1)
	elseif h and n==1 then return t
	else return empty end
end
--[[
takes the first n elements of a List which fulfill the given predicate, and discards the rest
@params
	pred:A=>Bool
		the predicate in question
@return
	List[A]
		resulting List
]]
function List:takeWhile(pred)
	return self:foldr(empty,function(a,ret)
		if pred(a) then return cons(a,ret)
		else return empty end
	end)
end
--[[
discards the first section of a List which fulfill the given predicate, and discards the rest
@params
	pred:A=>Bool
		the predicate in question
@return
	List[A]
		the resulting List
]]
function List:dropWhile(pred)
	local h,t = self.head,self.tail
	if h then
		if pred(h) then
			return t:dropWhile(pred)
		end
		return self
	end
	return empty
end
--[[
Applies a binary operator(foo) to a start value and all elements of this List, going left to right.
@params:
	init: B
		initial value
	f: (B,A) => B
		binary operation to perform
@return
	 B
		resulting value
]]
function List:foldl(init,f) 
	    if not self.head then return init
	else 
		local h,t = self.head,self.tail
		return t:foldl(f(h,init),f)
	end
end
--[[
Applies a binary operation to all elements of this List and a start value, going right to left.
@params
	init: B
		initial value 
	f: (A,B) => B
		binary operation to perform
@return
	B
		resulting value
]]
function List:foldr(init,f)
	if not self.head then return init 
	else return f(self.head,self.tail:foldr(init,f)) end 
end
--[[
Applies a binary operation to all elements of this List from left -> right , starting at the head of the List
@params
	f: (A,A) => A
		binary operation to perform
@return
	A
		resulting value
]]
function List:reduce(f)
	if not self.head then error("called reduce on empty List") 
	elseif self.tail == empty then return self.head
	else return self.tail:foldl(self.head,f) end
end
--[[
Tests whether at least one elements of the List fulfill a predicate
@params
	pred:A=>Bool
		the predicate in question
@return
	Bool
		whether any elements fulfilled the predicate
]]
function List:exists(pred)
	return self:foldr(false,function(a,s)
		return pred(a) or s
	end)
end
--[[
Tests whether all elements of the List fulfill a predicate
@params
	pred:A=>Bool
		the predicate in question
@return
	Bool
		whether all elements fulfilled the predicate
]]
function List:forall(pred)
	return self:foldr(true,function(a,s)
		return pred(a) and s
	end)
end
--[[
Gets the length of a List
@params
@return
	Int
		Length of the List
]]
function List:getLength()
	return self:foldl(0,function(a,s)
		return s+1
	end)
end
--[[
Applies a function on all members of an List, and returns the result
@params
	f:A=>B
		function to apply
@return
	List[B]
		resulting List
]]
function List:map(f)
	return self:foldr(empty,function(a,b)
		return b:prepend(f(a))
	end)
end
--[[
appends a given List to the current List, by prepending all elements of the current List to that List
@params
	l2:List[A]
		List to append
@return
	List[A]
		resulting List
]]
function List:append(l2)
	return self:foldr(l2,function(a,b)
		return b:prepend(a)
	end)
end
--[=[
flattens a higher order List one level
(requires self to be a higher order List)
(referring to self's type as "List[List[A]]" for this function)

@self: List[List[A]]
@params
@return
	List[A]
		flattened List
]=]
function List:flatten()
	return self:foldr(empty,List.append)
end
--[[
Builds a new List by applying a function to all elements of this List and using the elements of the resulting List.
@params
	f:A=>List[B]
		function to apply
@return
	List[B]
		resulting List
]]
function List:flatmap(f)
	return self:map(f):flatten()
end
--[[
Takes all members of a List which fulfills a given predicate
@params
	pred:A=>Bool
		predicate in question
@return
	List[A]
		resulting List
]]
function List:filter(pred)
	return self:flatmap(function(a)
		if pred(a) then return mkList(a)
		else return empty end
	end)
end
--[[
creates a List that is the result of a binary operation applies on corresponding elements of each List 
@params
	l2:List[B]
		List to be zipped with
	f:(A,B) => C
		binary function to be applied
@return
	List[C]
		resulting List
]]
function List:zipWith(l2,f)
	if (self == empty or l2 == empty) then return empty 
	else 
		return self.tail:zipWith(l2.tail,f):prepend(f(self.head,l2.head)) 
	end 
end
--[[
creates a List from this and another List, where the corresponding elements are paired (to the end of the shorter List)
@params
	l2:List[B]
		List to be zipped with
@return
	List[(A,B)] (its just a two element (strict) List, it's not actually a proper pair type)
		resulting List
]]
function List:zip(l2)
	return self:zipWith(l2,mkList)
end
--[[
turns a List into a string

impl1:
	@params
		a:String (initial string)
			string that goes at the start of the finished string
		b:String (seperator)
			string that seperates elements of the List
		c:String (ending string)
			string that goes at the end of the finished string
impl2:
	@params
		a:String (seperator)
			string that seperates elements of the List
		(start and end become empty strings)
impl3:
	@params
		(all inferred as empty string)
@return
	String
		the representation of a List as a string
]]
function List:mkString(a,b,c)
	if not c then
		if not b then
			local sep = a or ""
			local r = self:foldl("",function(s,a)
				return s..tostring(a)..sep
			end)
			if sep == "" or not self.head then return r else return r:sub(1,-2) end
		end
		error("missing ending string for mkstring")
	end
	local almost =  a..self:foldl("",function(a,s) return s..tostring(a)..b end)
	if #b > 0 and self.head then almost = almost:sub(1,-2) end
	return almost..c
end
--[[
turns the List into a string with: 
	an inital string: "List:["
	a seperator: ","
	an ending string: "]"
@params
@return 
	String
		the representation of a List as a string
]]
function List:__tostring()
	return self:mkString("List:[",",","]")
end


return {mkList,List}
