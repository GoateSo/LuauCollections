local Option,None = unpack(require(script.Parent.Option))
local Either = {}
Either.__index = Either

local function mkLeft(v)
	return setmetatable({value = v,type = "Left"},Either)
end
local function mkRight(v)
	return setmetatable({value = v,type = "Right"},Either)
end
function Either:__tostring()
	return self.type.."("..tostring(self.value)..")"
end
function Either:flatMap(f)
	return self.type == "Left" and self or f(self.value)
end
function Either:map(f)
	return self.type == "Left" and self or mkRight(f(self.value))
end
function Either:filterOrElse(pred,alt)
	if self.type == "Left" then return mkLeft(alt) end
	return pred(self.value) and self or mkLeft(alt)
end
function Either:swap()
	return self.type == "Left" and mkRight(self.value) or mkLeft(self.value)
end
function Either:getOrElse(alt)
	return self.type == "Left" and alt or self.value
end
function Either:toOption()
	return self.type == "Left" and None or Option(self.value)
end
function Either.fromPCall(succ,res)
	return succ and mkRight(res) or mkLeft(res:gsub("^.-%d+: ",""))
end
function Either:bimap(f,g)
	if self.type == "Left" then  
		return f(self.value) 
	else 
		return g(self.value)
	end
end
function Either:recover(f) 
	if self.type == "Left" then
		return mkRight(f(self.value))
	end	
	return self
end
function Either:recoverWith(f) 
	if self.type == "Left" then
		f(self.value)
	end	
	return self
end
function Either:__eq(that)
	return self.type == that.type and self.value == that.value
end
return {Either,mkLeft,mkRight}
