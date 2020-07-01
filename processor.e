include dll.e

constant VALID_PRIORITY = {NORMAL_PRIORITY_CLASS, IDLE_PRIORITY_CLASS, REALTIME_PRIORITY_CLASS, HIGH_PRIORITY_CLASS}
		
type priorityclass(atom x)
	return find(x,VALID_PRIORITY)
end type

global function GetCurrentProcess()
	return c_func(xGetCurrentProcess,{})
end function

global function SetPriorityClass(atom process,priorityclass class)
	return c_func(xSetPriorityClass,{process,class})
end function
