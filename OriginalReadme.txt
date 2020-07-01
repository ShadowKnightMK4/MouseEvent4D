		MouseEvent program

This directory contains MouseEvent version 4d. MouseEvent
is a program that allows one to control the Windows cursor
by using their keypad. This is an update over the version 4c 
MouseEvent program. 

To run:
	exw.exe mouseevent4.exw
	exwc.exe mouseevent4.exw

Files that make up Mouseevent4
mouseevent4d.exe	- MouseEvent4d.exw - translated to C and compressed via UPX
mouseevent4d.exw	- main MouseEvent program
mouseevent4.e		- responsible for linking to the needed Windows Api
consol.ew		- Install a Consol Control handler
constants.e		- a file that houses (most of) the constants
inireader.e		- a parser that reads ini files - look at loadini.e for 
			- an example of use
loadini.e		- how MouseEvent uses inireader.e
processor.e		- Set our process priority
usermouse.ew		- Turn on the cursor if we have no mouse attached.
mousevent4.dll		- an optional dll that simply blocks GUI apps from seeing the keypad keys
mouseevent4.cpp		- source for mouseevent4.dll
config.ini		- an optional configuration file
zoom_in.wav		- option wav file that is played when one zooms in (increases
			- the shift multipler speed) in the new zoom
			
zoom_out.wav		- optional wav file that is played when one returns to normal zoom
			- (shift multipler decreases)
readme.txt		- The documentation (and the file you are reading now)

Notes and potental problems are listed near the bottom.
Changes over version 4c:
	In the DLL:
		none
	In the main program
			I've added sound for the new SHIFT_MUL mode. If you find sound
			annoying (for example when typing) just disable it
			(HALO_ZOOM_SOUND=0 in the config file) or delete the zoom_in.wav
			and zoom_out.wav files.

			The movement mode in the config file is absolute mode, a mode
			which doesn't allow the mouse to be used. For the old mode,
			(MOUSE_MOVE_MODE=MOUSE_REL in the config file)
		ini files
			added code to detect changes in the config file and to reload
			the config file upon any change (most convenient/ sweet)
			(it uses the FindChangeNotification routines and 
			WaitForSingleObject)
			Technically it just monitors the directory its stored in and
			just reloads the config file on any file size change.
			The idea is one keeps a lightweight text editor open (notepad)
			to the config file and alters it as needed then hits save and the 
			updated configuration is loaded.

			added error checking code in the ini loader so that 
			invalid type for a entry yields the default value (as
			if the type was never in the file) as opposed to rotationally
			causing a type check failure. (For example: misspelling a constant
			in the config file)

			new entries:
			SPEED_CAP - in relative movement mode
				  - under some conditions, Windows will speed the movement
				  - up and this was added to limit the speed to below the
				  - values that tell Windows to speed the mouse up
			SPEED_MUL_STYLE 
			MOUSE_MOVE_MODE - either absolute or relatives mode- see farther down
					- for details on how to set it

					- relative mode has
					- the perk of letting
					- movement from the actual mouse be received
					- is subject to the speed up mentioned above


					- absolute mode
					- doesn't allow other mouse input to be relieved
					- (well it does but it cancels it out) 
					- in my opining is subject to less speed up
	
					- Versions before used relative move and that is 
					- the default if this entry is not in the config 
					- file.
			HALO_ZOOM_SOUND - if true then
					- the wav files zoom_in.wav and zoom_out.wav
					- are played only in halo zoom shift mode

					- if false then they aren't played at all
					- alternatively, just rename or delete the wav files
					- to make it always false.
		
					- also, if you want different sounds, just
					- replace those too files with your own files
					- of the same name. 
					
			MOUSE_ABS_MUL	- because of speed differences between
					- values in relative mode and values in absolute
					- mode, this is also factored in while in absolute
					- mode

			modified entry:
			LOGFILE - a value of "" will cause no log file to be made upon
				- error or message logging - those messages won't be logged
				- note: 'LOGFILE=' (without the '') in theory because 
				- of the ini parser's implementation should do the same as 
				- LOGFILE="" (note: I have not tested this)
				- specifying a file is still the same
			
		mouse related:
			Added a new style of speed changing. I call it, Halo zoom style.
			Its purpose was to counter act the apparently random speed
			differences in cursor movement when using programs.

Changes over version 4:
	In the DLL:
		hooks:
			Found out code didn't block all the keypad0-9 keys, fixed.

	In the main program
		
		hooks:
			Added hook to allow mouseevent4c to shutdown on logoff events and
			computer turn off events.

		process related
			Added possibility of adjusting the priority in the program

			Program now calls Sleep() - the Windows Api directly and not
			the routine in Euphoria itself. The value passed can be changed
			in the ini file.

		mouse related
			Added code to turn the cursor on if it doesn't detect
			a mouse attached to the computer.


		ini files
			Wrote an ini file reader to read a configuration file.
			The result is that one does not have to go through code to
			change the constants. (And allows one to change the configuration
			of it if the program is compiled.)



Ini file variable assigns: Note if a value is missing in 
the config.ini file when the default value listed here is
used instead.

Under [PROCESS]
	PROCESS_PRIORITY - Set the priority of MouseEvent4c
			 - Choices are IDLE_PRIORITY_CLASS,	(screensaver priority)
			 - NORMAL_PRIORITY_CLASS,		(normal program priority)
			 - HIGH_PRIORITY_CLASS and		(system / extra priority)
			 - REALTIME_PRIORITY_CLASS		(program takes priority
								over system critical stuff)
			 - Default is NORMAL_PRIORITY_CLASS
	INSTALL_KEYPAD_BLOCKER - Set whether the mouseevent4.dll is loaded or not
			       - if TRUE the DLL is loaded and GUI apps
			       - are blocked from seeing the keypad keys
			       - If false then the DLL is NOT loaded
			       - Default is TRUE

	RELEASE_CONSOLE	       - Set whether the program releases the console (TRUE)
			       - or not (FALSE)
			       - Default is TRUE
	STEP_SLEEP	       - At the end of MouseEvent4c's code to test
			       - keypad keys, MouseEvent4c will call sleep
			       - and pass this number.
			       - number that are less than 0 will be treated as +1
			       - Default is 1

Under [ERRORS]
	LOGFILE		- Set the name of the file used
			- to log errors and messages to
			- Default current_directory\error.log
			- use an empty string (either LOGFILE= or LOGFILE="")
			- to set it to not produce a log file

	LOGERRORS	- Set wither error messages are logged
			- to LOGFILE (TRUE) or not (FALSE)

	LOGWARNINGS 	- Set wither all other messages are
			- logged to LOGFILE (TRUE) or
			- not (FALSE)
	MESSAGES	- Set how MouseEvent4c displays messages
			- choices are
			SILENT	- show NO messages - error and otherwise
			SHOW_NO_MESSAGES - same as SILENT
			SHOW_ONLYERRORS - show only error messages - 
					- all other messages won't be shown
			SHOW_ERRORS_AND_WARNINGS - Show all messages
			SHOW_ALL	- same as SHOW_ERRORS_AND_WARNINGS
		 	SHOW_WARNINGS	- show only warnings - errors
					- will NOT be shown

			Default is SHOW_ERRORS but I actually
			set my config.ini file MESSAGES value
			to SILENT


Under [MOUSEEVENT_INPUT]
		A briefing on the meaning of these values:
		MouseEvent4c has a variable associated with the
		UP, DOWN, LEFT, and RIGHT directions. Each value
		starts at an initial value of MOUSE_MOVE_OVERFLOW_START

		Each time the keypad key associated  with a direction 
		is pressed. MOUSE_MOVE_OVERFLOW_INC is added to the
		direction's associated variable. When the variable
		is greater that or equal to MOUSE_MOVE_OVERFLOW, a
		mouse move event is triggered and the variable for
		the direction is reset to MOUSE_MOVE_OVERFLOW_START.


MOUSE_MOVE_CLICKS	- Each move event mouse the mouse this many 
			- 'mickeys' / pixels
			- Default is 5
MOUSE_MOVE_OVERFLOW	- The mouse direction variables
			- trigger an event when their
			- value is greater than or equal to
			- this value
			- Default is 50
MOUSE_MOVE_OVERFLOW_START - The mouse direction variables
			  - start at this value and are reset
			  - to this value when a move event
			  - is triggered
			  - Default is 0
MOUSE_MOVE_OVERFLOW_INC   - each time the action key for
			  - a mouse move is pressed
			  - This value is added to the
			  - event's variable

SHIFT_MUL		 - when pressed - mouse move
			 - events move the cursor
			 - MOUSE_MOVE_CLICKS * this

SHIFT_MUL_STYLE 	- if 0 then
			- normal or previous MouseEvent’s version of shift
			- hold shift to double movement speed
			- do not hold shift to have normal movement speed
			- if 1 then
			- a Halo (r) zoom style of shift - let me explain

	- with the Halo shift style mode for MouseEvent4d - these things occur
	- the SHIFT_MUL is halved at start or a config file reload (50 starts at 25), 
	- when the shift key is pressed the multipler returns to what
	  was specified in the file (25 jumps to 50)
	- when pressed again the multipler is doubled (50 goes to 100)
	- when pressed once more the value is back to half [the original] (100 drops to 25)
	- in Halo/Zoom style - SHIFT_MUL is always factored in to the mouse speed
	- the reason I’ve added this is because sometimes I’ve found that the normal shift 
	- style can under  some circumstances be imprecise

HALO_ZOOM_SOUND 	- if 0 then
			- no sound is played when one presses shift
			- if 1 then
			- zoom in is played when the multipler is increased and 
			- zoom out is played when the multipler is decreased
Under [MOUSE_EVENT_ACTIONS]
	This entry contains the key assessments for the
	actions. They are named after what action they perform,
	and their values are the keypad key that triggers the
	action.


	QUIT	- Exit the program
		- Default key VK_KEYPAD1

	MOVE_UP	- Move the cursor up
		- Default key VK_KEYPAD8
	MOVE_DOWN -Move the cursor down
		  - Default key VK_KEYPAD5
	MOVE_LEFT - Move the cursor left
		  - Default key VK_KEYPAD4
	MOVE_RIGHT - Move the cursor right
		   - Default key is VK_KEYPAD6
	LEFTCLICK - This key is treated as the left mouse button
		  - Default key is VK_KEYPAD7
	RIGHTCLICK - This key is treated as the right mouse button
		   - Default is VK_KEYPAD9
	WHEELPLUS - This triggers the mouse wheel to move forward
		  - Default is VK_KEYPAD3
	WHEELMINUS - This triggers the mouse wheel to move backward
		   - Default is VK_KEYPAD2

Notes and some problems:
	If you are in need of hard drive speed you just need the mouseevent4d.exe file.
If you wish to not have the keypad keys constantly being repeated in most windows,
the mouseevent4.dll file. If you which to configure the program from the defaults,
config.ini file. If want some sound indicator for the new zoom/ shift multipler mode,
the 2 wav files.

	Don't use MouseEvent4d with its keypad blocker and Windows's control the mouse
	using the keypad program as from one quick check - they block each other out. 
	The program doesn't crash and you can still exit MouseEvent4d, but use at your
	own risk.

	Make sure the num-pad / num lock key is in on mode or you can't control the mouse
	cursor with this program.

	Sometimes the wheel scroll feature doesn't work. Try clicking in the window
	that has the scroll bar you wish to move, then try the scrolling. If that
	doesn't work trying an actual mouse with a scroll wheel and try again. If that
	still doesn't work, I don't know. It just seems to not work on some computers.
	Sorry.	
	

	MouseEvent4d was designed and programed using Euphoria 3.0.2 on Windows XP.
	It was compiled using the Borland C/C++ 5.5.

	If you are wondering why you can't move the actual mouse to move the crusor at
	the movement you might have MouseEvent4d in absolute mode.

	If you don't like the way the configuration file is set up then modify it to your
	liking.


Legal:
	This program is FREEWARE. I'd appreciate the program being mentioned in any
commercial programs that make any use of MouseEvent code, but this is not required.
This program provided is provided 'as-is', without any express or implied warranty.
In no event will the author be held liable for any damages arising from the use/misuse
of this software. Halo is copyright by Microsoft/Bungie and I did not create it or help
create it nor am I associated with Microsoft or Bungie. I simply was inspired by how 
the zoom in the game was done and wrote something like that for the new mouse speed mode.

	Distribution: Anyone can distribute MouseEvent as long as these 
		conditions are meant. 
	   The package (i.e. the zip file that MouseEvent is downloaded in) has all the
           original files in it. 


