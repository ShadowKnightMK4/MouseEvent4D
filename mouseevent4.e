without trace
without warning
without profile
include machine.e
include get.e
include dll.e
include wildcard.e
include msgbox.e

constant EXIT_MSG = "exiting MouseHook.exe",
	 MSG_TITLE = "MouseHook.exe"
sequence exit_list
exit_list = {}

-- some constants for mutex
constant ERROR_INVALID_HANDLE = 6,
	 ERROR_ALREADY_EXISTS = 183,

	 MYMUTEX = "MouseEvent program build using Euphoria 3.0.2; ALPHA BETA DELTA GAMMA OMEGA 123"
global procedure show_message(sequence title)
    atom fn
	if not length(LOGFILE) then
		return
	end if
    if LOGWARNINGS then
	fn = open(LOGFILE,"r")
	if fn = -1 then
	    fn = open(LOGFILE,"wb")
	else
	    close(fn)
	    fn = open(LOGFILE,"ab")
	end if
	if fn != -1 then
	    printf(fn,"Error: %s\r\n",{title})
	    close(fn)
	end if
    end if
    if find(MESSAGE_SHOWING,{SILENT,SHOW_ONLYERRORS}) then
	return
    end if
    if message_box(title,MSG_TITLE,MB_OK + MB_TASKMODAL) then
	
    end if
end procedure

global procedure exit_app(integer n)
	for wrk = 1 to length(exit_list) do
		call_proc(exit_list[wrk],{})
	end for
	show_message(EXIT_MSG)
	abort(n)
end procedure 

global procedure show_error(sequence title)
    atom fn
    if find(MESSAGE_SHOWING,{SHOW_ONLYERRORS,SHOW_ERRORS_AND_WARNINGS}) then
	if message_box(title,MSG_TITLE,MB_OK + MB_ICONERROR + MB_TASKMODAL) then
	
	end if
    end if
    if LOGERRORS then
	fn = open(LOGFILE,"r")
	if fn = -1 then
	    fn = open(LOGFILE,"wb")
	else
	    close(fn)
	    fn = open(LOGFILE,"ab")
	end if
	if fn != -1 then
	    printf(fn,"Error: %s\r\n",{title})
	    close(fn)
	end if
    end if
exit_app(1)
end procedure



atom mem,

	use_dll -- if true then mouseevent4 installs
		-- the hook that blocks the keypad keys 1 through 9 from being seen by app
		-- if false then  mouveevent4 doesn't

-- the dlls
global atom mouseevent4_dll, -- my dll: mouseevent4.dll
	kernel32_dll, -- system dll: kernel32.dll
	user32_dll,  -- system dll: user32.dll
	winmm_dll, -- sytem dll: winmm.dll

-- stuff from mouseevent4.dll
	hook_var, -- We set this to the value returned by SetWindowsHook
	keyboard_hook, -- This is not actuall called by us but we pass its address to SetWindowsHook

-- stuff from kernel32.dll
	GetProcAddress_func,
	CreateMutex_func,
	CloseHandle_func,
	GetLastError_func,
	xSetConsoleCtrlHandler,
	xSetPriorityClass,
	xGetCurrentProcess,
	xSleep,
	xFindFirstChangeNotification,
	xFindNextChangeNotification,
	xFindCloseChangeNotification,
	xWaitForSingleObject,

-- stuff from user32.dll
	SetWindowsHookEx_func,
	UnhookWindowsHookEx_func,
	GetKeyState_func,
	mouse_event_func,
	GetForegroundWindow_func,
	GetClassNameA_func,
	SystemParametersInfoA_func,
        xGetSystemMetrics,
	xShowCursor,
  	xGetMessage_Func,
	xPeekMessage_Func,
	DefWindowProcA_Func,
	DispatchMessage_Func,

-- stuff from winmm.dll
	xPlaySoundA_func
atom mutex


global atom ABORTNOW
ABORTNOW = 0

global function DispatchMessage(atom lpMsgStruct)
	return c_func(DispatchMessage_Func, {lpMsgStruct})
end function

global function GetMessage(atom lpMsgStruct, atom hWnd, atom Low, atom High)
	return c_func(xGetMessage_Func, {lpMsgStruct, hWnd, Low, High})
end function

global function DefWindowProcA(atom lpMsgStruct, atom hWnd, atom Low, atom High)
	return c_func(DefWindowProcA_Func, {lpMsgStruct, hWnd, Low, High})
end function

global function NoWaitGetMessage(atom lpMsgBuff)
	return c_func(	xPeekMessage_Func, {lpMsgBuff, 0, 0, 0, 1}) 
end function
function CreateMutex(atom security_attributes_ptr,atom initial_owner,sequence name)
    atom nameptr,ret
     
    nameptr = allocate_string(name)
ret = c_func(CreateMutex_func,{security_attributes_ptr,initial_owner,nameptr})
    free(nameptr)
    return ret
end function

global function GetLastError()
	atom i
    i = c_func(GetLastError_func,{})
	return i
end function

function CloseHandle(atom handle)
    return c_func(CloseHandle_func,{handle})
end function

include console.ew -- module that links to some usefull console routines.
include processor.e -- moudle that allows mouseevent4 to lower is priority


function console_HandlerRoutine(atom signalType)
	if signalType = CTRL_LOGOFF_EVENT then
		for wrk = 1 to length(exit_list) do
			call_proc(exit_list[wrk],{})
		end for
		abort(1)

		return TRUE
	elsif signalType = CTRL_SHUTDOWN_EVENT then
		for wrk = 1 to length(exit_list) do
			call_proc(exit_list[wrk],{})
		end for
		abort(1)
		ABORTNOW = TRUE
		return TRUE
	else
		return FALSE
	end if
end function

global constant cmd = command_line()

global procedure link_dlls()
mouseevent4_dll = 0

if INSTALL_KEYPAD_BLOCKER = TRUE then
	mouseevent4_dll = open_dll("mouseevent4.dll")
else
	mouseevent4_dll = 0
end if
 

kernel32_dll = open_dll("kernel32.dll")

	if not kernel32_dll then
		show_error("Error: Unable to link to required dll, kernel32.dll!\r\n")
	else
		
		GetProcAddress_func = define_c_func(kernel32_dll,"GetProcAddress",{C_ULONG,C_POINTER},C_ULONG)
		CreateMutex_func = define_c_func(kernel32_dll,"CreateMutexA",{C_POINTER,C_INT,C_POINTER},C_ULONG)
		CloseHandle_func = define_c_func(kernel32_dll,"CloseHandle",{C_ULONG},C_INT)
		GetLastError_func = define_c_func(kernel32_dll,"GetLastError",{},C_ULONG)
		xSetConsoleCtrlHandler = define_c_func(kernel32_dll,"SetConsoleCtrlHandler",{C_POINTER,C_INT},C_INT)
		xSetPriorityClass = define_c_func(kernel32_dll,"SetPriorityClass",{C_ULONG,C_ULONG},C_INT)
		xGetCurrentProcess = define_c_func(kernel32_dll,"GetCurrentProcess",{},C_ULONG)
		xWaitForSingleObject = define_c_func(kernel32_dll,"WaitForSingleObject",{C_ULONG,C_ULONG},C_ULONG)
		xFindFirstChangeNotification = define_c_func(kernel32_dll,"FindFirstChangeNotificationA",{C_ULONG,C_INT,C_ULONG},C_ULONG)
		xFindNextChangeNotification = define_c_func(kernel32_dll,"FindNextChangeNotification",{C_ULONG},C_INT)
		xFindCloseChangeNotification = define_c_func(kernel32_dll,"FindCloseChangeNotification",{C_ULONG},C_INT)


		
		if xSetPriorityClass = -1 then
			show_error("Error: Unable to find routine: SetPriorityClass in kernel32.dll\r\n")
		end if
		
		if xGetCurrentProcess = -1 then
			show_error("Error: Unable to find routine: GetCurrentProcess in kernel32.dll\r\n")
		end if

		
		if GetProcAddress_func = -1 then
			show_error("Error: Unable to find routine: GetProcAddess in kernel32.dll\r\n")
		end if
	    
		if GetLastError_func = -1 then
			show_error("Error: Unable to find routine: GetLastError in kernel32.dll\r\n")
		end if
		
		if CreateMutex_func = -1 then
			show_error("Error: Unable to find routine: CreateMutexA in kernel32.dll\r\n")
		end if
		if CloseHandle_func = -1 then
			show_error("Error: Unable to find routine: CloseHandle in kernel32.dll\r\n")
		end if
		
		if xSetConsoleCtrlHandler =-1 then
		    show_error("Error: Unable to find routine: SetConsoleCtrlHandler in kernel32.dll\r\n")
		end if

		if xWaitForSingleObject = -1 then
			show_error("Error: Unable to find routine: WaitForSingleObject in kernel32.dll\r\n")
		end if

		if xFindFirstChangeNotification = -1 then
			show_error("Error: Unable to find routine: FindFirstChangeNotification in kernel32.dll\r\n")
		end if

		if xFindNextChangeNotification = -1 then
			show_error("Error: Unable to find routine: FindNextChangeNotification in kernel32.dll\r\n")
		end if

		if xFindCloseChangeNotification = -1 then
			show_error("Error: Unable to find routine: FindCloseChangeNotification in kernel32.dll\r\n")
		end if
	end if


xSleep = define_c_func(kernel32_dll,"Sleep",{C_ULONG},C_INT)

if not mouseevent4_dll then
	--  show_error("Error: Unable to link to required dll, mouseevent4.dll!\r\n")
	use_dll = FALSE
else
	
	hook_var = define_c_var(mouseevent4_dll,"_thehook")
	if hook_var = 0 then
			show_error("Error: Unable to find variable: _thehook in mouseevent4.dll\r\n")
	end if

	mem = allocate_string("myKeyboard_hook")
	keyboard_hook = c_func(GetProcAddress_func,{mouseevent4_dll,mem})
	if keyboard_hook = 0 then
			free(mem)
			show_error("Error: Unable to find routine: myKeyboard_hook in mouseevent4.dll\r\n")
	end if
	free(mem)

	use_dll = TRUE
end if



mutex =  CreateMutex(NULL, 1, MYMUTEX)
if mutex then
    if GetLastError() = ERROR_ALREADY_EXISTS then
	if CloseHandle(mutex) then end if
	    show_error("Can only run one instance of Remote Mouse 4 at one time")
	    exit_app(0)
    end if
else
    show_error("Error in starting Remote Mouse 4")
end if

	winmm_dll = open_dll("winmm.dll")
	if not winmm_dll then
		show_error("Error: Unable to link to dll, winmm.dll. Sounds will not be played\r\n")
	else
		xPlaySoundA_func = define_c_func( winmm_dll,"PlaySoundA",{C_ULONG,C_ULONG,C_ULONG},C_INT)
	end if

	user32_dll = open_dll("user32.dll")

	if not user32_dll then
		show_error("Error: Unable to link to required dll, user32.dll!\r\n")
	else
		UnhookWindowsHookEx_func = define_c_func(user32_dll,"UnhookWindowsHookEx",{C_ULONG},C_INT)
		SetWindowsHookEx_func = define_c_func(user32_dll,"SetWindowsHookExA",{C_INT,C_ULONG,C_ULONG,C_ULONG},C_ULONG)
		GetKeyState_func = define_c_func(user32_dll,"GetAsyncKeyState",{C_INT},C_SHORT)
		mouse_event_func = define_c_proc(user32_dll,"mouse_event",{DWORD,DWORD,DWORD,DWORD,DWORD})

		-- links to different routine than on named here
		GetForegroundWindow_func = define_c_func(user32_dll,"GetForegroundWindow",{},C_ULONG)
		GetClassNameA_func =define_c_func(user32_dll,"GetClassNameA",{C_ULONG,C_ULONG,C_LONG},C_INT)

		SystemParametersInfoA_func = define_c_func(user32_dll,"SystemParametersInfoA",{C_UINT,C_UINT,C_UINT,C_UINT},C_INT)
                xGetSystemMetrics = define_c_func(user32_dll,"GetSystemMetrics",{C_INT},C_INT)
	        xShowCursor = define_c_func(user32_dll,"ShowCursor",{C_INT},C_INT)
		xGetMessage_Func = define_c_func(user32_dll, "GetMessageA", {C_INT, C_INT, C_INT, C_INT}, C_INT)
		DefWindowProcA_Func = define_c_func(user32_dll, "DefWindowProcA", {C_INT, C_INT, C_INT, C_INT}, C_INT)
		xPeekMessage_Func = define_c_func(user32_dll, "PeekMessageA" ,{C_INT, C_INT, C_INT, C_INT, C_INT}, C_INT)
		if UnhookWindowsHookEx_func = -1 then
			show_error("Error: Unable to find routine: UnhookWindowsHookEx in user32.dll\r\n")
		end if


		if xPeekMessage_Func = -1 then
			show_error("Error: Unable to find routine: PeekMessageA in user32.dll\r\n")
		end if

		if xGetMessage_Func = -1 then
			show_error("Error: Unable to find routine: GetMessageA in user32.dll\r\n")
		end if
		if GetKeyState_func = -1 then
			show_error("Error: Unable to find routine: GetKeyState in user32.dll\r\n")
		end if

		if mouse_event_func = -1 then
			show_error("Error: Unable to find routine: mouse_event in user32.dll\r\n")
		end if

		if SetWindowsHookEx_func = -1 then
			show_error("Error: Unable to find routine: SetWindowsHookExA in user32.dll\r\n")
		end if
	
		if GetForegroundWindow_func = -1 then
			show_error("Error: Unable to find routine: GetForegroundWindow in user32.dll\r\n")
		end if

		if GetClassNameA_func = -1 then
			show_error("Error: Unable to find routine: GetClassNameA in user32.dll\r\n")
		end if

		if SystemParametersInfoA_func = -1 then
			show_error("Error: Unable to find routine: SystemParametersInfoA in user32.dll\r\n")
		end if

		if xShowCursor = -1 then
			show_error("Error: Unable to find routine: ShowCursor in user32.dll\r\n")
		end if

		if xGetSystemMetrics = -1 then
			show_error("Error: Unable to find routine: GetSystemMetrics in user32.dll\r\n")
		end if


	end if

end procedure

constant hook_kinds = {2}
type hook_type(atom x)
	return find(x,hook_kinds)
end type

function SetWindowsHookEx(hook_type hook,atom routine_addr,
				atom module_handle, atom thread_handle)
	return c_func(SetWindowsHookEx_func,{hook,routine_addr,module_handle,thread_handle})
end function

function UnhookWindowsHookEx(atom hook_handle)
	return c_func(UnhookWindowsHookEx_func,{hook_handle})
end function

global function GetKeyState(atom keycode)
	return c_func(GetKeyState_func,{keycode})
end function


global procedure mouse_event(object flags,atom dx,atom dy,atom dwData,atom dwExtraInfo)
atom t
t = 0
    if sequence(flags) then
	for wrk = 1 to length(flags) do
	    t = or_bits(t,flags[wrk])
	 end for
	 flags = t
    end if
    c_proc(mouse_event_func,{flags,dx,dy,dwData,dwExtraInfo})
end procedure

atom MyHook
MyHook = 0
-- entry point for activating the system hook.
-- The system hook simply supresses the keys that this app uses so that you won't be
-- repeating the same key over and over.
global procedure ActiveHook()
	if use_dll = FALSE then
		return
	end if
	MyHook = SetWindowsHookEx(2,keyboard_hook,mouseevent4_dll, NULL)
	if not MyHook then
		show_message("Unable to activate My Hook resource!\r\n")
	end if
	-- place it so that my routine sees it
	poke4(hook_var,MyHook)
end procedure

global procedure ReleaseHook()
	if use_dll = FALSE then
		return
	end if
	if MyHook = 0 then
		return
	end if
	if not UnhookWindowsHookEx(MyHook) then
		show_message("Unable to release My Hook resource!\r\n")
	end if
end procedure

atom callback callback = 0
global procedure ActiveConsoleHook()
    atom result
callback = call_back(routine_id("console_HandlerRoutine"))
    result = SetConsoleCtrlHandler(callback,TRUE)
end procedure

global procedure ReleaseConsoleHook()
    atom result
    result = SetConsoleCtrlHandler(callback,FALSE)
end procedure

global procedure add_on_exit(integer id)
    exit_list &= id
end procedure

global procedure ReleaseMutex()
    if not CloseHandle(mutex) then
	show_message("Unable to relase my mutex resource!\r\n")
    end if
end procedure


include windowclass.ew
include changenotify.ew
include systeminfo.ew
include usermouse.ew
