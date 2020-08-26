local Option = {}
Option.__index = Option
setmetatable(Option,Option)
local None = setmetatable({},Option)
--[[
Constructs an Option from a given value, giving a nil will become a "None", and giving any other value becomes that value wrapped within the context of Option
@params
	v:A
		value to be wrapped
@return
	Option[A]
		value wrapped in context of Option
]]
function Option:__call(v)
	if v ~= nil then
		return setmetatable({get = v},Option)
	end
	return None
end
--[[
same functionality as above, provides more traditional "Object.new(...)" syntax
@params
	v:A
		value to be wrapped
@return
	Option[A]
		value wrapped in context of Option
]]
function Option.new(v)
	if v ~= nil then
		return setmetatable({get = v},Option)
	end
	return None
end
--[[
returns an alternative Option if empty, otherwise returns itself
@params
	v:Option[A]
		alternative Option
@return
	Option[A]
		resulting Option
]]
function Option:orElse(v)
	if self == None then 
		return v
	end
	return self
end
--[[
returns an alternative Option if empty, otherwise returns itself
@params
	v:A
		alternative value
@return
	Option[A]
		resulting Option
]]
function Option:getOrElse(v)
	if self == None then 
		return v
	end
	return self.get
end
--[[
Applies a function on the Optional value that returns an Option
@params
	f:A=>Option[B]
		function to be applied
@return
	Option[B]
		resulting Option
]]
function Option:flatMap(f)
	if self == None then return self 
	else return f(self.get) end
end
--[[
Applies a function on the Optional value
@params
	f:A=>B
		function to be applied
@return
	Option[B]
		resulting Option
]]
function Option:map(f)
	if self == None then return self 
	else return Option.new(self.get) end
end
--[[
checks if an Option fulfills a given predicate, if not None is returned
@params
	p:A=>Boolean
		predicate in question
@return
	Option[A]
		resulting Option
]]
function Option:filter(p)
	if self == None then return self 
	else 
		if p(self.get) then
			return self 
		else 
			return None
		end
	end
end
--[[
turns the option into a string None -> "None", and anything else to "Some(...)"
@params
@return
	String
		resulting string
]]
function Option:__tostring()
	if self == None then return "None"
	else return "Some("..tostring(self.get)..")"end
end
--[[
checks whether a Option is empty (=None)
@params
@return
	Boolean
		whether the Option is empty or not
]]
function Option:isEmpty()
	return self==None
end
--[[
checks whether a Option isn't None
@params
@return
	Boolean
		whether an Option isnt None
]]
function Option:isNonEmpty()
	return self~=None
end
--[[
checkers whether an Option contains a value
]]
function Option:contains(v)
	if self == None then return false
	else return self.get == v end
end

return {Option,None}
