local Tree = {}
Tree.__index = Tree
local List,LClass = unpack(require(script.Parent.List))
local emp = setmetatable({type="Leaf"},Tree)
--[[
Constructs a leaf from a given value, if none is given, it defaults to the empty leaf 
@params
	v:A
		value in question
@return
	Tree[A]
		resulting Tree
]]
local function makeLeaf(v)
	return v and setmetatable({value = v,type="Leaf"},Tree) or emp
end
--[[
Constructs a Branch from a given value, and two subtrees
@params
	v:A
		value in question
	l:Tree[A]
		left subtree
	r:Tree[A]
		right subtree
@return
	Tree[A]
		resulting Tree
]]
local function makeBranch(v,l,r)
	l = l or emp
	r = r or emp
	return setmetatable({value = v,left=l,right=r,type="Branch"},Tree)
end
--[[
Gets the maximum depth of the tree 
@params
@return
	Int
		Depth of the Tree
]]
function Tree:getDepth()
	if self==emp then return 0 end
	return self.type == "Leaf" and 1 or 1+math.max(self.left:getDepth(),self.right:getDepth())
end
--[[
Gets the number of elements in the tree (not counting empty leaves)
@params
@return
	Int
		Size of the Tree
]]
function Tree:getSize()
	return self:foldl(0,function(s,a)
		return s+1
	end)
end
--[[
Converts the tree into a string representation
@params
@return
	String
		resulting string
]]
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
--[[
Maps a function to all elements of the tree
@params
	f:A=>B
		function to be applied
@return
	Tree[B]
		resulting value
]]
function Tree:map(f)
	if self==emp then return self end
	local nv = f(self.value)
	return self.type == "Leaf" and makeLeaf(nv) or makeBranch(nv,
		self.left:map(f),
		self.right:map(f)
	)
end
--[[
applies a binary operation on an inital value and all elements of the tree, prioritizing the Leftmost-Deepest node
@params
	init:B
		initial value
	f:(B,A)=>B
		binary operation
@return
	B
		resulting value
]]
function Tree:foldl(init,f)
	if self == emp then return init end
	return self.type == "Leaf" and f(init,self.value) or f(
		self.right:foldl(
			self.left:foldl(init,f),
			f
		),self.value
	)
end
--[[
applies a binary operation on all elements of the tree and the inital value, prioritizing the Rightmost-Deepest node
@params
	init:B
		initial value
	f:(A,B)=>B
		binary operation
@return
	B
		resulting value
]]
function Tree:foldr(init,f)
	if self == emp then return init end
	return self.type == "Leaf" and f(self.value,init) or f(
		self.value,self.left:foldr(
			self.right:foldr(init,f),
			f
		)
	)
end
--[[
Converts a Tree into a List, with Leftmost-Deepest Node as head
@params
@return
	List[A]
		resulting list
]]
function Tree:toList()
	return self:foldr(List(),function(a,s)
		return s:prepend(a)
	end)
end
--[[
Applies a function on all elements of the tree for their side effects, Prioritizes left subtree (leftmost - deepest)
@params
	f:A=>()
		function to be applies
@return
]]
function Tree:forEach(f)
	self:foldl(self,function(s,a)
		f(a)
		return s
	end)
end
--[[
checks type and value equivalence on two trees
@params
	that:Tree[B]
		another tree to compare to
@return
	Boolean
		whether the two are equal
]]
function Tree:__eq(that)
	local veq = self.value == that.value
	if self.type == "Leaf" then
		return that.type == "Leaf" and veq or false
	else
		return that.type == "Branch" and (veq and that.left == self.left and that.right == self.right) or false
	end
end
return {Tree,makeBranch,makeLeaf}
