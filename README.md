xmonad-config
=============

<<<<<<< HEAD
XMonad configuration files, scripts, and instructions for Ubuntu (12.04)
=======
XMonad configuration files, scripts, and instructions for Ubuntu (12.04) to use XMonad as a primary desktop with some of the GNOME conveniences underneath (such as working volume control and easy network connection management) 

Simple steps (assuming you have ubuntu and git installed): 

Step 0. Read all of these instructions before you do anything. If you don't understand what something does, look it up. Don't take my word for whether it is/is not safe or will/will not frag your machine. <soapbox>This should be your standard operating procedure before installing or reconfiguring any software. </soapbox>

Step 1. Clone this repo (or just copy the files) wherever you want and change to that directory. 

Step 2. Copy and paste the following into the terminal from your cloned repo or directory, if you trust what I've posted (nothing bad that I can see, but don't take my word for it):

	sudo apt-get update; sudo apt-get install xmonad-contrib xmobar kupfer xcompmgr synaptic gnome-panel hsetroot scrot
	sudo mv xmonad-xstart.desktop /usr/share/xsessions/.
	sudo mv xmonad.start /usr/local/bin/. ; sudo chmod +x /usr/local/bin/xmonad.start
	mkdir -p ~/.xmonad
	mv xmonad.hs ~/.xmonad/.
	mv xmobarrc ~/.xmonad/.
	mkdir -p ~/bin; mv scs ~/bin/. ; chmod +x ~/bin/scs
	git clone https://github.com/jgoerzen/ledmon.git
	cd ledmon; make; mv ledmon ~/bin/ledmon; cd -
	xmonad --recompile

Step 3. If you're in an X session, Logout of your current session, then select "Xmonad (with GNOME panel)" from your display manager, and login there. Things will take a few seconds (or less) to load once you login.

Step 4. When you login, you will (hopefully) see a GNOME panel at the top of the screen and a blank black screen. Don't panic: you can use "feh" or other programs to set a desktop background; I set mine to black for power saving and to keep things uncluttered; you can change this in your xmonad.start script. Alt+Right click on the panel, select properties, then check "Autohide" and click OK, and you will have what I think is the best of both worlds. You may have to dip in and out of the panel once or twice to get it to hide, but it will hide, and you will see your xmobar (black bar with green and orange lettering).  You may (likely) have to re-start XMonad on every login to get it working properly. It's just a reflex for me at this point (Ctrl+Win+R) and it takes a fraction of a second, so I don't care that much, but perfectionists may find it irritating.

Step 5. Open Kupfer (Win+P then type kupfer -- you may have to restart XMonad with a Ctrl+Win+R to get this to work) and set up a keyboard shortcut for it (click the gear) - pick something that doesn't conflict with XMonad, i.e., something that does not include the Windows key. This will give you a quick way to launch programs via a GUI, often with less typing than the run-or-raise prompt. You can also set up any other GNOME-related keyboard shortcuts you want through the GNOME control panel. 

Step 6. Practice. That's right, you will probably need to practice using XMonad. Look up the default keyboard shortcuts (<http://www.haskell.org/haskellwiki/Xmonad#Keybindings_cheatsheets>), then note where they differ in this xmonad.hs file; or change them back to the defaults if you want (it's just two dashes and a recompile away). Once you get the hang of it (maybe an hour or so; less if you are familiar with vim) you will probably either be hooked or never use XMonad again. 

Step 7. Enjoy (or not). After a year of using XMonad all day, every day for a mix of programming, research, writing, video conferences, and email, I find it excruciating to use any other window manager (much less someone else's computer), particularly if I have to get any work done. 		

Notes: 

1. Accept all recommended dependencies in the apt-get commands (synaptic isn't strictly needed, though; it's just a lot more powerful and reliable than Software Center, in my experience). Warning: GHC is MASSIVE; it's kind of funny to me that it takes a 600 MB+ download to get a window manager running that uses < 7 MB of RAM (I'm reading 6.3MB now with 14 windows open on 6 different workspaces--try that with GNOME), but that's the price you pay... It also lets you play around with Haskell, if you're so inclined. 

2. For security, in all the configuration files--and even the commands above--it is recommended to replace ~ with /home/yourusername. 

3. There are some quirks:
	-With the default XMonad and GHC provided in Ubuntu 12.04 and these configuration files, you typically need to restart XMonad on every login to get a working "run or raise" dialog
	-GIMP's main image window doesn't automatically get shifted to the master position. 
	-Sometimes my mouse will freeze; not sure if that's a hardware or software issue (and if software, which program), but I seem to be able to fix it every time by opening a terminal (Window + Enter, using the shortcuts in this configuration) and typing: 
	
		killall gnome-settings-daemon; (gnome-settings-daemon &) 

	then close the window if you don't want to be bothered with the occassional text flashing through it. 

5. I've tried to comment the xmonad.hs file as much as possible where I think that settings or reasons for them aren't necessarily clear. 
>>>>>>> 9e91883
