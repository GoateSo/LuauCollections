local Tree = {}
Tree.__index = Tree
local List,LClass = unpack(require(script.Parent.List))
local emp = setmetatable({type="Leaf"},Tree)
local function makeLeaf(v)
	return setmetatable({value = v,type="Leaf"},Tree)
end
local function makeBranch(v,l,r)
	l = l or emp
	r = r or emp
	return setmetatable({value = v,left=l,right=r,type="Branch"},Tree)
end
function Tree:getDepth()
	if self==emp then return 0 end
	return self.type == "Leaf" and 1 or 1+math.max(self.left:getDepth(),self.right:getDepth())
end
function Tree:getSize()
	return self:foldl(0,function(s,a)
		return s+1
	end)
end
function Tree:__tostring()
	local function prep(n)
		return ("           "):rep(n)
	end
	local function go(self,n)
		local se = prep(n)
		local ne = prep(n+1) 
		if self.type == "Leaf" then return self.value and tostring(self.value) or "" end
		local temp = ("%s : {\n%s%s,\n%s%s\n%s}"):format(tostring(self.value),ne,go(self.left,n+1),ne,go(self.right,n+1),se)
		return temp:gsub(",\n"..ne.."\n","\n")
	end
	return go(self,0)
end
function Tree:map(f)
	if self==emp then return self end
	local nv = f(self.value)
	return self.type == "Leaf" and makeLeaf(nv) or makeBranch(nv,
		self.left:map(f),
		self.right:map(f)
	)
end
function Tree:foldl(init,f)
	if self == emp then return init end
	return self.type == "Leaf" and f(init,self.value) or f(
		self.right:foldl(
			self.left:foldl(init,f),
			f
		),self.value
	)
end
function Tree:foldr(init,f)
	if self == emp then return init end
	return self.type == "Leaf" and f(self.value,init) or f(
		self.value,self.left:foldr(
			self.right:foldr(init,f),
			f
		)
	)
end
function Tree:toList()
	return self:foldr(List(),function(a,s)
		return s:prepend(a)
	end)
end
function Tree:forEach(f)
	self:foldl(self,function(s,a)
		f(a)
		return s
	end)
end
return {Tree,makeBranch,makeLeaf}
