--[[
For all implicit instances of self, let self's type = Either[E,A]
]]
local Option,None = unpack(require(script.Parent.Option))
local Either = {}
Either.__index = Either
---Creates an Either with a given Left value
--[[
@params
	v:E = Value for Left
@return
	Either[E,A] = resulting Either
]]
local function mkLeft(v)
	return setmetatable({value = v,type = "Left"},Either)
end
---Creates an Either with a given Right value
--[[
@params
	v:A = Value for Right
@return
	Either[E,A] = resulting Either
]]
local function mkRight(v)
	return setmetatable({value = v,type = "Right"},Either)
end
---turns an Either into a string Left(v) -> "Left(v)", Right(v) -> "Right(v)"
--[[
@return
	String = resulting string
]]
function Either:__tostring()
	return self.type.."("..tostring(self.value)..")"
end
---Applies a function which returns an Either to the wrapped value 
--[[
@params
	f:A=>Either[B,C] = function to be applied
@return
	Either[B,C] = resulting Either
]]
function Either:flatMap(f)
	return self.type == "Left" and self or f(self.value)
end
---Applies a function to the wrapped value , if Right
--[[
@params
	f:A=>B = function to be applied
@return
	Either[E,B] = resulting Either
]]
function Either:map(f)
	return self.type == "Left" and self or mkRight(f(self.value))
end
---Checks if the wrapped Right value follows a given predicate, if not, return Left with alternate value
--[[
@params
	pred:A=>Boolean = predicate in question
	alt:E = alternate value
@return
	Either[E,A] = resulting Either
]]
function Either:filterOrElse(pred,alt)
	if self.type == "Left" then return mkLeft(alt) end
	return pred(self.value) and self or mkLeft(alt)
end
--[[
swaps the parity of the Either, Left->Right, Right->Left
@return
	Either[A,E] = resulting Either
]]
function Either:swap()
	return self.type == "Left" and mkRight(self.value) or mkLeft(self.value)
end
--[[
if Left, then return the alternate value, otherwise, return the wrapped value
@params
	alt:A = alternate value
@return
	A = resulting value
]]
function Either:getOrElse(alt)
	return self.type == "Left" and alt or self.value
end
---converts the Either into an option:
---Left(v)  -> None,
---Right(v) -> Some(v)
--[[
@return
	Option[A] = resulting Option
]]
function Either:toOption()
	return self.type == "Left" and None or Option(self.value)
end
---creates an Either from the results of a PCall 
---success -> Right(res),
---failure -> Left(res)
--[[
@params
	succ:Boolean = whether the PCall succeded
	res: String|A = return of the PCall
@return
	Either[String,A] = resulting Either
]]
function Either.fromPCall(succ,res)
	return succ and mkRight(res) or mkLeft(res:gsub("^.-%d+: ",""))
end
---If Left, applies one function to the wrapped value, otherwise, apply the other
--[[
@params
	f:E=>B = function to apply to Left
	g:A=>C = function to apply to Right
@return
	Either[B,C] = resulting Either
]]
function Either:bimap(f,g)
	if self.type == "Left" then  
		return mkLeft(f(self.value)) 
	else 
		return mkRight(g(self.value))
	end
end
---If Left, applies a function to recover the Either, and change it into a Right
--[[
@params
	f:E=>B = function to apply to Left
@return
	Either[E,B] (Right[B]) = resulting Right Either
]]
function Either:recover(f) 
	if self.type == "Left" then
		return mkRight(f(self.value))
	end	
	return self
end
---Applies a function which returns an Either value to the wrapped value if the Either contains a Left Value, otherwise nothing is done
--[[
@params
	f:E=>Either[B,C] = function to apply to left
@return
	Either[B,C] (Right[C]) = resulting either
]]
function Either:recoverWith(f) 
	if self.type == "Left" then
		f(self.value)
	end	
	return self
end
--[[
Checks type and value equality for two Eithers
@params
	that:Either[B,C] = other Either to compare to
@return
	Boolean = whether the two are equivalent
]]
function Either:__eq(that)
	return self.type == that.type and self.value == that.value
end
return {Either,mkLeft,mkRight}
