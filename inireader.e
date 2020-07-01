
-- This file reads and parses a super set of the .ini file format
-- This is what the parser of the ini file does.
-- Accepts and discards: a line made up of only space. any spaces before and after text.
-- Accepts comments that are set up like this:
--      // this is a comment
--      -- This is a comment



-- A note: the parser is EXTREMLY lax in parsing.


-- It will accept stuff like
-- [SECTION]
--  VAR=
--  =Hello


-- In the case of VAR= - its value will be an empty sequence.
-- In =Hello case, the hello is the value and an empty sequence is the var's name.



-- Also to modify how it parses values call SetValueParse() and pass a sequence of these
-- SV_NONE              -- the the variables are returned as is 
--SV_PURENUMBER_TO_VALUE        -- if a value is a number or hex number (preceded by 0x or #)
			-- it is automaticly converted to a number

-- SV_LOOKUP_NONQUOTES  -- If a nonquoted string is encounted - its looked up
			-- in the database created via calls to AddVarLookUp()
			-- If it found something - this value is returned and if 
			-- it found nothing - the nonquoted string is returned
-- SV_NOCASE            -- AnYtHiNg is the same as anything or AnyThing, ect...

-- note: passed {} to SetValueParse() is the same as {SV_NONE} to it, and all values that

-- are not SV_NONE take priority over SV_NONE meaning
-- {SV_NONE,anything,ect...} = {anything,ect...}

without trace
include get.e

include wildcard.e

global constant SV_NONE = 0,
		SV_PURENUMBER_TO_VALUE = 1,
		SV_LOOKUP_NONQUOTES = 2,
		SV_NOCASE = 3

sequence val_actions val_actions = {SV_NONE}
sequence lookup_names,
	 lookup_values

	 lookup_names = {}
	 lookup_values = {}




global procedure SetValueParse(sequence new_actions)
	sequence r
	if not length(new_actions) or equal(new_actions,{SV_NONE}) then
		val_actions = {}
	else
		r = {}
		for i =1 to length(new_actions) do
			if not equal(new_actions[i],SV_NONE) then
				r = append(r,new_actions[i])
			end if
		end for
		val_actions = r
	end if
end procedure
without trace
function ltrim(object x)
    if atom(x) then
	return x
    end if
	for wrk = 1 to length(x) do
		if not find(x[wrk],"\r\t\n ") then
			if length(x) = wrk then
				 return {x[$]}
			else
				return x[wrk..$]
			end if
		end if
			
	end for
	return ""
end function

function rtrim(object x)
    if atom(x) then
	return x
    end if
	for wrk = length(x) to 1 by -1 do
		if not find(x[wrk],"\r\t\n ") then
			if wrk = 1 then
				 return {x[1]}
			else
				return x[1..wrk]
			end if
		end if
	end for
	return ""
end function

function checksum(object x)
	atom ret
	ret = 0 
	if atom(x) then
		return x
	else
		for i = 1 to length(x) do
			ret += xor_bits(x[i],i)
		end for
	end if
	return ret
end function

global procedure AddVarLookUp(sequence name,object val)
	atom s,f
	if find(SV_NOCASE,val_actions) then
		name = upper(name)
	end if
	name = ltrim(rtrim(name))
	if sequence(val) then
		val = ltrim(rtrim(val))
	end if
	s = checksum(name)
	f = find(s,lookup_names)
	if f then
		lookup_values[f] = val
	else
		lookup_names  = append(lookup_names,s)
		lookup_values = append(lookup_values,val)
	end if
end procedure

function find_val(sequence val)
	atom f
	atom s
	if find(SV_NOCASE,val_actions) then
		val = upper(val)
	end if
	val = ltrim(rtrim(val))
	s = checksum(val)
	f = find(s,lookup_names) 
	return f
end function

function pure_number(sequence str)
    integer c
    atom wrk
    if length(str) then
	wrk = 1
	while wrk <= length(str) do
	    c = str[wrk]
	    if wrk = 1 then
		if not find(c,"0123456789")  then
		    if c = '#' then
			-- ok
		    elsif c = '0' then
			wrk += 1
			c = str[wrk]
			if wrk > length(str) then
			    return 1
			else
			    if c != 'x' then
				return 0
			    end if
			end if
		    else
			return 0
		    end if
		end if
	    else
		if not find(c,"0123456789") then
		    return 0
		end if
	    end if
	    wrk += 1
	end while
    end if
    return 1
end function
-- receives ltrim(rtrim(val)) for extract_assign
function translate(sequence val)
	atom f
	sequence tmp
	if not length(val_actions) then
		return val
	end if 
	if pure_number(val) then
		if find(SV_PURENUMBER_TO_VALUE,val_actions) then
			if match("0x",val) then
				tmp = value(val[3..$])
				return tmp[2]
			else
			    tmp = value(val)
			    return tmp[2]
			end if 
		end if
		return val
	else
		if length(val) >= 2 then
			if val[1] = '\"' and val[$] = '\"' then
				return val[2..$-1]
			else
				f = find_val(val)
				if f then
					return lookup_values[f]
				else
					return val
				end if
			end if
		else
			return val
		end if
	end if
end function
function extract_assign(sequence str)
	atom s
	sequence var
	object val
	var = ""
	val = ""

	for wrk = 1 to length(str) do
		if str[wrk] = '=' then
			s = wrk+1
			exit
		end if
		var &= str[wrk]
	end for

	var = rtrim(var)

	for wrk = s to length(str) do
		val = append(val,str[wrk])
	end for

	val = ltrim(rtrim(val))
	val = translate(val)
	return {var,val}
end function


global function extract_section(sequence name,sequence read_whole_file_ret)
	sequence data
	atom f
	data = read_whole_file_ret
	f = find(name,read_whole_file_ret[1])
	if f then
		return read_whole_file_ret[2]
	end if
	return 0
end function

global function find_value(sequence name,sequence section_data,object fail)
	for i = 1 to length(section_data) do
		if equal(section_data[i][1],name) then
			return section_data[i][2]
		end if
	end for
	return fail
end function

global function read_whole_ini_file(sequence name)
	atom fn
	sequence section_datas,section_names,current_section_data,current_section_name
	sequence tmp
	object line
	section_datas = {}
	section_names = {}
	current_section_data = {}
	current_section_name = {}
	fn = open(name,"r")
	if fn = -1 then
		return -1
	else
	    
		while 1 do
			line = rtrim(ltrim(gets(fn)))
			if find(SV_NOCASE,val_actions) then
				line = upper(line)
			end if
			if atom(line) then
				if length(current_section_name) then
				    section_names = append(section_names,current_section_name)
				    section_datas = append(section_datas,current_section_data)
				end if
				exit
			else
				if length(line) >= 2 then
					if find(line[1..2],{"//","--"}) then
						-- comment
					else
					 if equal(line[1],'[') and equal(line[$],']') then
					    if length(current_section_name) = 0 then
						current_section_name = line[2..$-1]
						current_section_data = ""
					    else
						section_names = append(section_names,current_section_name)
						section_datas = append(section_datas,current_section_data)
						current_section_data = {}
						current_section_name = line[2..$-1]
					    end if
					 elsif find('=',line) then
						    tmp = extract_assign(line)
						    current_section_data = append(current_section_data,tmp)
					 else
						return -1
					 end if
					end if
				elsif length(line) < 2 then

				end if
				
			end if
		end while               
		close(fn)
		 
		return {section_names,section_datas}
	end if
end function

