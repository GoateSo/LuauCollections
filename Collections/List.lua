local List = {}
List.__index = List
local empty = setmetatable({},List)
--starting index of the list
local base = 1
---prepends h to t, and returns the resulting List
--[[
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
---Creates a List from an arbitrary sequence of elements
--[[
@params
	...:A* = sequence of elements
@return
	List[A] = resulting List
]]
local function mkList(...)
	if not (...) then return empty
	else return cons((...),mkList(select(2,...)))end
end
---pretty much an alias for cons(x,self)
--[[
@params
	x:A = element to prepend
@return
	List[A] = resulting List
]]
function List:prepend(x)
	return cons(x,self)
end
---Removes the first instance of a value in the list
--[[
@params
	x:A = element to remove
@return
	List[A] = resulting List
]]
function List:removeFirst(x)
	if self == empty then return self end
	if self.head == x then return self.tail end
	return cons(self.head,self.tail:removeFirst(x))
end
---returns a list of all tails of the list
--[=[
@return
	List[List[A]] = List of all tails of the list
]=]
function List:tails()
	local function go(s, this)
		if this == empty then return empty
		else return cons(this.tail,go(s,this.tail)) end
	end
	return go(empty,self)
end
---creates a list from applying a partial function over its values
--[[
@params
	partial:A=>B? = partial function
@return
	List[B] = resulting List
]]
function List:collect(partial)
	return self:foldr(empty,function(a,s)
		local v = partial(a)
		return v and cons(v,s) or s
	end)
end
---Reverses a List
--[[
@return
	List[A] = resulting List
]]
function List:reverse()
	return self:foldl(empty,function(a,b) return cons(b,a) end)
end
---gets the number of elements in the List
--[[
@return
	Int = number of elements in the List
]]
function List:getLength()
	local t = self.tail
	if self == empty then return 0
	else return 1+t:getLength() end
end
---Get the element at the specified index (base 1 indexed)
--[[
@params
	index:Int = index
@return
	A = value at that index
]]
function List:__call(index)
	if self == empty or index < base  then return nil end
	local h,t = self.head,self.tail
	if index == base then 
		return h
	elseif t == empty then return 
	else
		return t(index-1) 
	end
end
---Updates the value of the list at the given index to a given value
--[[
@params
	index:Int = given index
	newValue:A = replacement vlaue
@return
	List[A] = List with replaced value
]]
function List:update(index,newVal)
	assert(self ~= empty,"attempted to index element beyond size of list")
	if index == base then 
		return cons(newVal,self.tail)
	else
		return cons(self.head,self.tail:update(index-1,newVal))
	end
end
---takes the first n elements of a List, and discards the rest
--[[
@params
	n:Int = amount of elements to take
@return
	List[A] = resulting List
]]
function List:take(n)
	local h,t = self.head,self.tail
	if h and t and n>1 then return cons(h,t:take(n-1))
	elseif h and n == 1 then return cons(h,empty)
	else return empty end
end
---complement to take; discards the first n elements of a List, and takes the rest
--[[
@params
	n:Int = amount of elements to drop
@return
	List[A] = resulting List
]]
function List:drop(n)
	local h,t = self.head,self.tail
	if h and t and n>1 then return t:drop(n-1)
	elseif h and n==1 then return t
	else return empty end
end
---takes a sublist given a starting and ending poing
--[[
@params
	from:Int = starting index
	to:Int = ending index
@return
	List[A] = resulting List
]]
function List:slice(from,to)
	return self:drop(from):take(to)
end
---takes the first n elements of a List which fulfill the given predicate, and discards the rest
--[[
@params
	pred:A=>Bool = predicate to fulfill
@return
	List[A] = resulting List
]]
function List:takeWhile(pred)
	return self:foldr(empty,function(a,ret)
		if pred(a) then return cons(a,ret)
		else return empty end
	end)
end
---discards the first section of a List which fulfill the given predicate, and discards the rest
--[[
@params
	pred: A=>Bool = predicate to fulfill
@return
	List[A] = the resulting List
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
---Splits this list into a prefix/suffix pair according to a predicate.
--[[
@params
	pred:A=>Bool = the predicate in question
@return
	List[A],List[A] = prefix and suffix respectively
]]
function List:span(pred)
	local temp = self:takeWhile(pred)
	return temp,self:dropWhile(pred)
end
---A pair of, first, all elements that satisfy predicate pred and, second, all elements that do not.
--[[
@params
	pred:A=>Bool = predicate to fulfill
@return
	List[A],List[A] = a list of elements that satisfy predicate pred and a list of all elements that do not
]]
function List:partition(pred)
	return unpack(self:foldr({empty,empty},function(a,s)
		if pred(a) then
			return {cons(a,s[1]),s[2]}
		else
			return {s[1],cons(a,s[2])}
		end
	end))
end
---Applies a binary operator(foo) to a start value and all elements of this List, going left to right.
--[[
@params:
	init:B = initial value
	f:(B,A)=>B = binary operation to perform
@return
	B = resulting value
]]
function List:foldl(init,f)
	if not self.head then return init
	else
		local h,t = self.head,self.tail
		return t:foldl(f(init,h),f)
	end
end
---Applies a binary operation to all elements of this List and a start value, going right to left.
--[[
@params
	init:B = initial value
	f:(A,B)=>B = binary operation to perform
@return
	B = resulting value
]]
function List:foldr(init,f)
	if not self.head then return init
	else return f(self.head,self.tail:foldr(init,f)) end
end
---Produces a collection containing cumulative results of applying the operator going left to right.
--[[
@params
	init:B = initial value
	f:(B,A)=>B = binary operation performed on intermediate result
]]
function List:scanl(init,f)
	if self == empty then return mkList(init) end
	return cons(
		init,
		self.tail:scanl(f(init,self.head),f)
	)
end
---Produces a collection containing cumulative results of applying the operator going right to left.
--[[
@params
	init:B = initial value
	f:(A,B)=>B = binary operation performed on intermediate result
]]
function List:scanr(init,f)
	return (self:foldr(init,function(a,ret,v)
		if v == nil then
			v = ret
			ret = mkList(v)
		end
		local nv = f(a,v)
		return cons(nv,ret), nv
	end))
end
---Applies a binary operation to all elements of this List from left -> right , starting at the head of the List
--[[
@params
	f:(A,A)=>A = binary operation to perform
@return
	A = resulting value
]]
function List:reduce(f)
	if not self.head then error("called reduce on empty List")
	elseif self.tail == empty then return self.head
	else return self.tail:foldl(self.head,f) end
end
---Tests whether at least one elements of the List fulfill a predicate
--[[
@params
	pred:A=>Bool = the predicate in question
@return
	Bool = whether any elements fulfilled the predicate
]]
function List:exists(pred)
	return self:foldr(false,function(a,s)
		return pred(a) or s
	end)
end
---Tests whether all elements of the List fulfill a predicate
--[[
@params
	pred:A=>Bool = the predicate in question
@return
	Bool = whether all elements fulfilled the predicate
]]
function List:forall(pred)
	return self:foldr(true,function(a,s)
		return pred(a) and s
	end)
end
---Applies a function on all members of an List, and returns the result
--[[
@params
	f:A=>B =function to apply
@return
	List[B] = resulting List
]]
function List:map(f)
	return self:foldr(empty,function(a,b)
		return cons(f(a),b)
	end)
end
---appends a given List to the current List, by prependin	g all elements of the current List to that List
--[[
@params
	l2:List[A] = List to append
@return
	List[A] = resulting List
]]
function List:append(l2)
	return self:foldr(l2,function(a,b)
		return cons(a,b)
	end)
end
---flattens a higher order List one level
--[=[
(requires self to be a higher order List)
(referring to self's type as "List[List[A]]" for this function)

@self = List[List[A]]
@return
	List[A] = flattened List
]=]
function List:flatten()
	return self:foldr(empty,List.append)
end
---finds the sublist where the head of that sublist is a given value, or if no such sublist exists, the empty list is returned
--[[
@params
	x:A = value to find
@return
	List[A] = resulting List
]]
function List:find(x)
	if self == empty or self.head == x then return self
	else return self.tail:find(x) end
end
---finds the sublist which contains a given value or an alternative if none is found
--[[
@params
	x:A = value to find
	alt:A = alternative value
@return
	A = resulting value
]]
function List:findOrElse(x,alt)
	return self:find(x)==empty and alt or x
end
---Builds a new List by applying a function to all elements of this List and using the elements of the resulting List.
--[[
@params
	f:A=>List[B] = function to apply
@return
	List[B] = resulting List
]]
function List:flatMap(f)
	return self:map(f):flatten()
end
---Takes all members of a List which fulfills a given predicate
--[[
@params
	pred:A=>Bool = predicate in question
@return
	List[A] = resulting List
]]
function List:filter(pred)
	return self:flatMap(function(a)
		if pred(a) then return mkList(a)
		else return empty end
	end)
end
---creates a List that is the result of a binary operation applies on corresponding elements of each List
--[[
@params
	l2:List[B] = List to be zipped with
	f:(A,B)=>C = binary function to be applied
@return
	List[C] = resulting List
]]
function List:zipWith(l2,f)
	if (self == empty or l2 == empty) then return empty
	else
		return self.tail:zipWith(l2.tail,f):prepend(f(self.head,l2.head))
	end
end
---creates a List from this and another List, where the corresponding elements are paired (to the end of the shorter List)
--[[
@params
	l2:List[B] = List to be zipped with
@return
	List[(A,B)] = resulting List
]]
function List:zip(l2)
	return self:zipWith(l2,mkList)
end
---turns a List into a string
--[[
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
	String = the representation of a List as a string
]]
function List:mkString(a,b,c)
	if not c then
		if not b then
			local sep = a or ""
			local r = self:foldl("",function(s,val)
				return s.. tostring(val) ..sep
			end)
			if sep == "" or self.head == nil then 
				return r 
			else 
				return r:sub(1,-2) 
			end
		end
		error("missing ending string for mkstring")
	end
	local almost =  a..self:foldl("",function(s,val) return s..tostring(val)..b end)
	if #b > 0 and self.head then almost = almost:sub(1,-2) end
	return almost..c
end
---turns the List into a string with:
---an inital string: "List:[",
---an inital string: "List:[",
---a seperator: ",",
---and an ending string: "]"
--[[
@return
	String = the representation of a List as a string
]]
function List:__tostring()
	return self:mkString("List:[",",","]")
end
---Groups elements in fixed size Lists by passing a "sliding window" over them
--[=[
@params
	width:Int = amount of elements in each List
	step:Int = the distance between the first elements of successive groups
@return
	List[List[A]]
]=]
function List:sliding(width,step) --width,step
	step = step or 1
	local function go(this,l)
		if this == empty then return empty end
		return cons(this:take(width),go(this:drop(step),l-step))
	end
	return go(self,self:getLength())
end
---compares two lists based on their elements
--[[
@params
	that:List[Any] = List to compare to
@return
	Bool: whether the lists contain the same elements
]]
function List:__eq(that)
	return rawequal(that,self) or self.head == that.head and self.tail == that.tail
end

----------------------------------------------------------------
--						Static Methods
----------------------------------------------------------------

---creates a list from a string of characters
--[[
@params
	str:String = given string
@return
	List[Char] = resulting List
]]
function List.fromString(str)
	if str == "" then return empty
	else return cons(str:sub(1,1),List.fromString(str:sub(2)))end
end
---creates a list from an inclusive range of values
--[[
@params
	min:Int = minimum value in range
	max:Int = maximum value in range
@return
	List[Int] = resulting List
]]
function List.inRange(min,max): List
	assert(min<=max,"lower bound cannot be higher than upper bound")
	return min == max and mkList(min) or cons(min,List.inRange(min+1,max))
end
---@see cons
List.cons = cons
---@see mkList
List.new = mkList
return {mkList,List}
