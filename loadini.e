-- loadini.e
-- use inireader.e module to parse config.ini

-- include our special ini parser
without trace
include inireader.e

-- set its state
SetValueParse({SV_PURENUMBER_TO_VALUE,SV_NOCASE,SV_LOOKUP_NONQUOTES})

AddVarLookUp("TRUE",1)
AddVarLookUp("FALSE",0)
AddVarLookUp("SILENT",0)
AddVarLookUp("SHOW_NO_MESSAGES",0)
AddVarLookUp("SHOW_ONLYERRORS",1)
AddVarLookUp("SHOW_ERRORS_AND_WARNINGS",2)
AddVarLookUp("SHOW_ONLYWARNINGS",3)
AddVarLookUp("SHOW_ALL",4)

AddVarLookUp("VK_ESCAPE",VK_ESCAPE)

AddVarLookUp("VK_NUMPAD0",VK_NUMPAD0)
AddVarLookUp("VK_NUMPAD1",VK_NUMPAD1)
AddVarLookUp("VK_NUMPAD2",VK_NUMPAD2)
AddVarLookUp("VK_NUMPAD3",VK_NUMPAD3)
AddVarLookUp("VK_NUMPAD4",VK_NUMPAD4)
AddVarLookUp("VK_NUMPAD5",VK_NUMPAD5)
AddVarLookUp("VK_NUMPAD6",VK_NUMPAD6)
AddVarLookUp("VK_NUMPAD7",VK_NUMPAD7)
AddVarLookUp("VK_NUMPAD8",VK_NUMPAD8)
AddVarLookUp("VK_NUMPAD9",VK_NUMPAD9)
AddVarLookUp("VK_SHIFT",VK_SHIFT)
AddVarLookUp("VK_ADD",VK_ADD)
AddVarLookUp("VK_SEPERATOR",VK_SEPERATOR)
AddVarLookUp("VK_SUBTRACT",VK_SUBTRACT)
AddVarLookUp("VK_DECIMAL",VK_DECIMAL)
AddVarLookUp("VK_DIVIDE",VK_DIVIDE)
-- AddVarLookUp("X",X)
AddVarLookUp("NORMAL_PRIORITY_CLASS",NORMAL_PRIORITY_CLASS)
AddVarLookUp("IDLE_PRIORITY_CLASS",IDLE_PRIORITY_CLASS)
AddVarLookUp("HIGH_PRIORITY_CLASS",HIGH_PRIORITY_CLASS)
AddVarLookUp("REALTIME_PRIORITY_CLASS ",REALTIME_PRIORITY_CLASS )

AddVarLookUp("ON",1)
AddVarLookUp("TRUE",1)
AddVarLookUp("OFF",0)
AddVarLookUp("FALSE",0)
AddVarLookUp("DEFAULT",0)

AddVarLookUp("MOUSE_ABS",2)
AddVarLookUp("MOUSE_REL",1)

AddVarLookUp("HALO_ZOOM_STYLE",1)
AddVarLookUp("NORMAL_STYLE",0)

global procedure LoadConfigFile()
	object data,tmp
	atom s
	sequence section
	data = read_whole_ini_file("config.ini")
	trace(1)
	if atom(data) then
		-- revert to default stae
		data = {"",""}
	end if
		s = find("MOUSEEVENT_ACTIONS",data[1])
		if s = 0 then
			-- default 
			VK_UP = VK_NUMPAD8
			VK_DOWN = VK_NUMPAD5
			VK_LEFT = VK_NUMPAD4
			VK_RIGHT = VK_NUMPAD6
			VK_QUIT = VK_NUMPAD1
			VK_LEFTCLICK = VK_NUMPAD7
			VK_RIGHTCLICK = VK_NUMPAD9
			VK_WHEELPLUS = VK_NUMPAD3
			VK_WHEELMINUS = VK_NUMPAD2
		else
			section = data[2][s]
			tmp = find_value("MOVE_UP",section,VK_NUMPAD8)
			if sequence(tmp) then
				VK_UP=  VK_NUMPAD8
			else
				VK_UP = tmp
			end if

			tmp = find_value("MOVE_DOWN",section,VK_NUMPAD5)
			if sequence(tmp) then
				VK_DOWN = VK_NUMPAD5
			else
				VK_DOWN = tmp
			end if

			tmp = find_value("MOVE_LEFT",section,VK_NUMPAD4)
			if sequence(tmp) then
				VK_LEFT = VK_NUMPAD4
			else
				VK_LEFT = tmp
			end if

			tmp = find_value("MOVE_RIGHT",section,VK_NUMPAD6)
			if sequence(tmp) then
				VK_RIGHT = VK_NUMPAD6
			else
				VK_RIGHT = tmp
			end if

			tmp = find_value("QUIT",section,VK_NUMPAD1)
			if sequence(tmp) then
				VK_QUIT = VK_NUMPAD1
			else
				VK_QUIT = tmp
			end if

			tmp = find_value("LEFTCLICK",section,VK_NUMPAD7)
			if sequence(tmp) then
				VK_LEFTCLICK = VK_NUMPAD7
			else
				VK_LEFTCLICK = tmp
			end if

			tmp = find_value("RIGHTCLICK",section,VK_NUMPAD9)
			if sequence(tmp) then
				VK_RIGHTCLICK = VK_NUMPAD9
			else
				VK_RIGHTCLICK = tmp
			end if

			tmp = find_value("WHEELPLUS",section,VK_NUMPAD3)
			if sequence(tmp) then
				VK_WHEELPLUS = VK_NUMPAD3
			else
				VK_WHEELPLUS = tmp
			end if

			tmp = find_value("WHEELMINUS",section,VK_NUMPAD2)
			if sequence(tmp) then
				VK_WHEELMINUS = VK_NUMPAD2
			else
				VK_WHEELMINUS = tmp
			end if
		end if

		s = find("PROCESS",data[1])
		if s = 0 then
			MYPRIORITY = NORMAL_PRIORITY_CLASS
			INSTALL_KEYPAD_BLOCKER = TRUE
			RELEASE_CONSOLE = TRUE
			STEP_SLEEP_COUNT=1
		else
			section = data[2][s]
			tmp =  find_value("PROCESS_PRIORITY",section,NORMAL_PRIORITY_CLASS)

			-- test if we loaded our correct value type (atom in this cae)
			if not atom(tmp) then -- either a misspelling or something different
				MYPRIORITY = NORMAL_PRIORITY_CLASS -- go default
			else
				MYPRIORITY = tmp -- go use value in file
			end if

			tmp = find_value("INSTALL_KEYPAD_BLOCKER",section,1)
			if sequence(tmp) then
				INSTALL_KEYPAD_BLOCKER = TRUE
			else
				INSTALL_KEYPAD_BLOCKER = tmp
			end if


			tmp = find_value("RELEASE_CONSOLE",section,TRUE)
			if sequence(tmp) then
				RELEASE_CONSOLE = TRUE
			else
				RELEASE_CONSOLE = tmp
			end if

			tmp =  find_value("STEP_SLEEP_COUNT",section,1)
			if sequence(tmp) then
				STEP_SLEEP_COUNT = 1
			else
				if tmp < 0 then
					tmp = 1
				end if
				STEP_SLEEP_COUNT = tmp
			end if
		end if

		s = find("MOUSEEVENT_INPUT",data[1])
		if s = 0 then
			MOUSE_MOVE_CLICK = 5
			MOUSE_MOVE_OVERFLOW=50
			MOUSE_MOVE_OVERFLOW_START=0
			MOUSE_MOVE_OVERFLOW_INC= 51
			SHIFT_MUL=4
			SHIFT_MUL_STYLE=NORMAL_STYLE
			MOUSE_MOVE_MODE = DEFAULT
			SPEED_CAP = TRUE
			MOUSE_ABS_MUL=100
		else
			section = data[2][s]
			tmp = find_value("MOUSE_MOVE_CLICKS",section, 5)
			if sequence(tmp) then
				MOUSE_MOVE_CLICK = 5
			else
				MOUSE_MOVE_CLICK = tmp
			end if

			tmp = find_value("MOUSE_MOVE_OVERFLOW",section,50 )
			if sequence(tmp) then
				MOUSE_MOVE_OVERFLOW = 50
			else
				MOUSE_MOVE_OVERFLOW = tmp
			end if

			tmp  = find_value("MOUSE_MOVE_OVERFLOW_START",section,0 )
			if sequence(tmp) then
				MOUSE_MOVE_OVERFLOW_START = 0
			else
				MOUSE_MOVE_OVERFLOW_START = tmp
			end if

			tmp = find_value("MOUSE_MOVE_OVERFLOW_INC",section, 51)
			if sequence(tmp) then
				MOUSE_MOVE_OVERFLOW_INC = 51
			else
				MOUSE_MOVE_OVERFLOW_INC = tmp
			end if


			tmp = find_value("SHIFT_MUL",section,4)
			if sequence(tmp) then
				SHIFT_MUL = 4
			else
				SHIFT_MUL = tmp
			end if

			tmp = find_value("SHIFT_MUL_STYLE",section,NORMAL_STYLE)
			if sequence(tmp) then
				SHIFT_MUL_STYLE = NORMAL_STYLE
			else
				SHIFT_MUL_STYLE = tmp
				if SHIFT_MUL_STYLE = HALO_ZOOM_STYLE then
					SHIFT_MUL_STEP = 1
				end if
			end if

			tmp = find_value("HALO_ZOOM_SOUND",section,FALSE)
			if sequence(tmp) then
				HALO_ZOOM_SOUND = FALSE
			else
				HALO_ZOOM_SOUND = tmp
			end if

			tmp = find_value("MOUSE_MOVE_MODE",section,DEFAULT)
			if sequence(tmp) then
				MOUSE_MOVE_MODE = DEFAULT
			else
				MOUSE_MOVE_MODE = tmp
			end if

			tmp = find_value("SPEED_CAP",section,TRUE)

			if sequence(tmp) then
				SPEED_CAP = TRUE
			else
				SPEED_CAP = tmp
			end if

			tmp = find_value("MOUSE_ABS_MUL",section,100)
			
			if sequence(tmp) then
				MOUSE_ABS_MUL = 100
			else
				MOUSE_ABS_MUL = tmp
			end if

		end if

		s = find("ERRORS",data[1])
		if s =0  then
		    LOGFILE = "error.log"
		    LOGERRORS=TRUE
		    LOGWARNINGS=FALSE
		    MESSAGE_SHOWING=SHOW_ONLYERRORS
		else
		    section = data[2][s]
		    tmp = find_value("LOGFILE",section,"error.log")
		    if atom(tmp) then
			LOGFILE = "error.log"
		    else
			LOGFILE = tmp
		    end if			

		    tmp = find_value("LOGERRORS",section,TRUE)
		    if sequence(tmp) then
			LOGERRORS = TRUE
		    else
			LOGERRORS = tmp
		    end if

		    tmp = find_value("LOGWARNINGS",section,FALSE)
		    if sequence(tmp) then
			LOGWARNINGS = FALSE
		    else
			LOGWARNINGS = tmp
		    end if

		    tmp = find_value("MESSAGES",section,SHOW_ONLYERRORS)
		    if sequence(tmp) then
			MESSAGE_SHOWING = SHOW_ONLYERRORS
		    else
			MESSAGE_SHOWING = tmp
		    end if

		end if
			
end procedure






