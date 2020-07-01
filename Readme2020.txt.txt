-- 7/1/20
	The OriginalReadme.txt is the almost the one I wrote over a decade ago. Thing in there can be out of date but the
documentation for settings can be useful. This app is slightly modified in which a Windows Message Pump is done with PeekMessage() and DispatchMessage() to 
prevent Explorer freezing if the code is ran in a 64bit environment. When certain Security related software such as Norton
Antivirus has the focus, this app can't interact with it and does not work until the focus is away.

	This is a rather ancient piece of coding I wrote because my PS2 port mouse would come loose easy
and I got tired of restarting Windows to get it to work again. It was made in the Windows XP area long ago when Windows was
primarily 32-bit.  This app does not play terribly well in 64-bit mode but is functional. Modern Windows also prevents certain
software work working with each other for security purposes. It should work ok with 32-bit versionf of Windows and/or older
versions that don't implement modern security.

	You will need to pick up a copy of the Euphoria Interpreter at www.rapideuphoria.com to use the source. To run this 
software run "exw.exe mouseevent4d.exw"  The EXW file is the main entry point for this code. The version this code targets is version 3.0
but it likely can run in the 4.0 version found the https://openeuphoria.org/ site.  The exw.exe app is the Euphoria interpreter.

	There are 2 wave files that aren't included in the this download, "zoom_in.wav" and "zoom_out.wav." The zoom in one
plays in the 'halo' zoom mode when increasing the mouse speed. The zoom out plays when the mouse speed is reset. Originally
they were recording of the Halo 1 sniper zoom I made a long time ago; however, for this public github upload I don't thing that
uploading those with it is a good idea. The code will run ok without them, but should you wish to get audio feedback when 
changing mouse speed, add two .WAV (ideally small) files to the folder this software is in with those names.

	The current config file is set to absolute mode which means that it tracks the mouse and is revents any change to the 
mouse position when moving the mouse unless something like Norton Antivirus has focus. To turn that off, edit the config file
to use the relative mode rather than the absolute mode.

	There are a lot of settings to adjust in the config file (config.ini). Each one has (with exception of
the keyboard assigments) are documented in what they do. If you want to dig some in how the software interperets the config file
look at inireader.ew for the code that reads the file and loadini.ew for the code that configures the software from said file.


Controls:
	Ensure Num Lock is on. All numbers hear are keypad numbers rather than the ones at the top of the keyboard.


	8 moves the mouse up.
	4 mouses the mouse left.
	6 mouses the mouse right.
	5 mouse the mouse down.
	7 is mapped as the left mouse button
	9 is mapped as the right mouse button
	2 is wheel scroll down
	3 is wheel scroll up
	1 exits the app

	Shift in the 'halo' mode toggles between 3 speeds.


Liscense:
		See License.txt for current one







