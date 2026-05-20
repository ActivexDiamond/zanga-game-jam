local overload = {}

function overload.selectArg(t, ...)
	local i, p = 1, tonumber(t:sub(1, 1))
	if type(p) == 'number' then
		i, t = p, t:sub(2, -1)
	end
	
	if t == 's' then t = 'string'
	elseif t == 'n' then t = 'number'
	elseif t == 'f' then t = 'function'
	elseif t == 't' then t = 'table'
	elseif t == 'ni' then t = 'nil'
	elseif t == 'th' then t = 'thread'
	elseif t == 'u' then t = 'userdata' end
	for k, v in ipairs({...}) do
		if type(v) == t then i = i - 1; if i == 0 then return v end end
	end
end

setmetatable(overload, {__call = overload.selectArg})

return overload