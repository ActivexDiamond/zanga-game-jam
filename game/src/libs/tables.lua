
local Tables = {}

function Tables.containsSingleType(t, dataType)
	for _, v in pairs(t) do
		if type(v) ~= dataType then return false end
	end
	return true
end

function Tables.deepConcat(t1, t2)
	for i = 1, #t2 do
		t1[#t1 + 1] = t2[i]
	end
end

function Tables.print(t, s)	
	print(s or "Table:")
	for k, v in ipairs(t) do print('', k, v) end
	for k, v in pairs(t) do
		if type(k) ~= 'number' then print('', k, v) end
	end
end
 
return Tables