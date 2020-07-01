include dll.e

-- The escape key
global constant VK_ESCAPE = #1B,

-- the keypad
	 VK_NUMPAD0 = #60,
	 VK_NUMPAD1 = #61,
	 VK_NUMPAD2 = #62,
	 VK_NUMPAD3 = #63,
	 VK_NUMPAD4 = #64,
	 VK_NUMPAD5 = #65,
	 VK_NUMPAD6 = #66,
	 VK_NUMPAD7 = #67,
	 VK_NUMPAD8 = #68,
	 VK_NUMPAD9 = #69,
	 VK_MULTIPLY = #6A,
-- extra keypad keys
	 VK_ADD = #6B,
	 VK_SEPERATOR = #6C,
	 VK_SUBTRACT = #6D,
	 VK_DECIMAL = #6E,
	 VK_DIVIDE= #6F,

-- the shift (any) key
	VK_SHIFT = #10
-- 'map'ed key codes

global constant SILENT=0,
		SHOW_NO_MESSAGES = 0,
		SHOW_ONLYERRORS = 1,
		SHOW_ERRORS_AND_WARNINGS = 2,
		SHOW_ONLY_WARNINGS = 3,
		SHOW_ALL = 4
global constant DWORD = C_ULONG,

-- The different mouse events that can be sent to mouse_event()
MOUSEEVENTF_MOVE = #0001,
MOUSEEVENTF_LEFTDOWN = #0002,
MOUSEEVENTF_LEFTUP = #0004,
MOUSEEVENTF_RIGHTDOWN = #0008,
MOUSEEVENTF_RIGHTUP = #0010,
MOUSEEVENTF_MIDDLEDOWN = #0020,
MOUSEEVENTF_MIDDLEUP = #0040,
MOUSEEVENTF_XDOWN = #0080,
MOUSEEVENTF_XUP = #0100,
MOUSEEVENTF_WHEEL = #0800,
MOUSEEVENTF_VIRTUALDESK = #4000,
MOUSEEVENTF_ABSOLUTE = #8000


global constant CTRL_C_EVENT = 0,

		CTRL_BREAK_EVENT = 1,
		CTRL_CLOSE_EVENT = 2,
		CTRL_LOGOFF_EVENT = 5,
		CTRL_SHUTDOWN_EVENT = 6


global constant SW_MOUSEPRESENT = 19,
		 SM_CMOUSEBUTTONS = 43


global constant NORMAL_PRIORITY_CLASS      = #00000020,
		IDLE_PRIORITY_CLASS        = #00000040,
		HIGH_PRIORITY_CLASS        = #00000080,
		REALTIME_PRIORITY_CLASS    = #00000100
-- FindXXXXChangeNotify routine constants
global constant FILE_NOTIFY_CHANGE_SIZE         =#00000008,
	        FILE_NOTIFY_CHANGE_LAST_WRITE   =#00000010

global constant INVALID_HANDLE_VALUE = #FFFFFFFF


-- WaitForSingleObject constants
global constant	 WAIT_OBJECT_0 = 0,
		 WAIT_TIMEOUT = 258,
		 WAIT_FAILED = INVALID_HANDLE_VALUE

-- constant used with SystemParametersInfo
global constant SPI_GETMOUSE = 3

-- constant used with GetSystemMetrics
global constant SM_MOUSEPRESENT = 19

-- flag setting values
global constant TRUE = 1,
		FALSE = 0,
		ON = TRUE,
		OFF = FALSE

-- mouse movement style values
global constant MOUSE_ABS = 2,
		MOUSE_REL = 1,
		DEFAULT = 0

-- shift styles
global constant HALO_ZOOM_STYLE = 1,
		NORMAL_STYLE = 0