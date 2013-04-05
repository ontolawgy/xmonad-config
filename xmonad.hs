{-# OPTIONS_GHC -W -fwarn-unused-imports -fno-warn-missing-signatures #-}
{-# LANGUAGE NoMonomorphismRestriction #-}
import XMonad
import XMonad.Core
import Data.List
import Data.Maybe
import System.Exit
import System.IO

import XMonad.Actions.CycleWS
import XMonad.Actions.CopyWindow(copy)
import XMonad.Actions.DynamicWorkspaces
import XMonad.Actions.GridSelect
import XMonad.Actions.UpdatePointer()
import XMonad.Actions.Warp
import XMonad.Actions.WindowMenu
import XMonad.Actions.WindowGo

import XMonad.Config.Gnome

import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ICCCMFocus
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.SetWMName

import XMonad.Layout.Decoration
import XMonad.Layout.DecorationMadness
import XMonad.Layout.IndependentScreens
import XMonad.Layout.MultiColumns
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Tabbed
import XMonad.Layout.TabBarDecoration
import XMonad.Layout.ZoomRow


import XMonad.ManageHook

import XMonad.Prompt
import XMonad.Prompt.Man
import XMonad.Prompt.RunOrRaise
import XMonad.Prompt.Shell

import XMonad.Util.EZConfig
import XMonad.Util.Font
import XMonad.Util.Run
import XMonad.Util.Themes

import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import Graphics.X11
--End imports

-- Borders
--
--- | Width of the window border in pixels.
----
myBorderWidth :: XMonad.Dimension
myBorderWidth = 1
--
---- | Border colors for unfocused and focused windows, respectively.
myNormalBorderColor  = "black" -- "#dddddd"
myFocusedBorderColor = "green"  -- "#ff0000" don't use hex, not <24 bit safe
---

--Main
main = do
    xmproc <- spawnPipe "xmobar ~/.xmonad/xmobarrc" --for security, it is a good idea to hard-code ~ to /home/username here; ~ is being used for portability only and is NOT recommended for use in a production environment; same goes for everywhere you see ~
    xmonad $ ewmh $ withUrgencyHook NoUrgencyHook $ gnomeConfig -- necessary to keep LibreOffice menus working
	{ workspaces = myWorkspaces
	, terminal = myTerminal
	, borderWidth        = myBorderWidth
	, normalBorderColor  = myNormalBorderColor
    	, focusedBorderColor = myFocusedBorderColor
	, manageHook = myManageHook <+> manageHook gnomeConfig
	, layoutHook = avoidStruts $ myLayout
	, startupHook = setWMName "LG3D" -- required to get some Java GUI applications running properly
        , logHook = dynamicLogWithPP xmobarPP
        	{ ppOutput = hPutStrLn xmproc
                , ppTitle = xmobarColor "green" "" . shorten 150
                , ppCurrent = xmobarColor "green" "" . wrap "[*" "*]"
		, ppVisible = xmobarColor "green" "" . wrap "[" "]"
     		, ppHidden = xmobarColor "yellow" "#838383" . wrap "" ""
		, ppUrgent = xmobarColor "red" "" . wrap "-!!" "!!-"
		-- tried the following, but it doesn't work; problem is that Skype does not respect the X11 Urgent flag; however, running the GNOME panel with unified notification applet will allow Skype to show popup notifications
		--, ppUrgent = xmobarColor "black" "red" . xmobarStrip
		-- uncomment the following line to show ids for workspaces with no windows
		--, ppHiddenNoWindows = xmobarColor "grey" "" . wrap "| " " |"
		, ppLayout = const "" -- disables layout info on xmobar; comment to show layout names
                }
	, modMask = XMonad.mod4Mask --Rebind Mod to Windows key
	} `additionalKeysP` myKeys 

-- <Variables>


-- <Workspaces>

myWorkspaces = ["`", "1-t", "2-e", "3-§", "4-f", "5-o", "6", "7-$", "8-web", "9-vb", "0", "-", "gimp"] 
--Why 13 workspaces? ` = monitoring apps, both console and GUI; 1 = Terminal; 2 = Email; 3 = Skype and google chat; 4 - file manager; 5 = office applications 6 = spare, often used for reading extra PDFs while writing about them on ws 5 with a PDF and a LibreOffice Writer document open next to it; 7 = spreadsheets; 8 = web browsing; 9 = VirtualBox; 0 = spare; - = spare; gimp = GIMP, with a slightly tweaked custom layout that works well for me (just remember to raise the main image window to master)
--
--myWorkspaces = ["1-t", "2-e", "3-§", "4-f", "5-o", "6", "7-$", "8-web", "9-vb"] 

-- <Default applications>

myBar = "xmobar"
myTerminal = "gnome-terminal"

-- <Appearance>

xftFont = "xft:Ubuntu:weight=bold:size=10"

myTheme = defaultTheme {
	  fontName = xftFont
		}

myXPConfig = defaultXPConfig {
	font = xftFont
}

-- <GridSelect>
myGSConfig colorizer = (buildDefaultGSConfig colorizer)
   { gs_cellheight   = 50
   , gs_cellwidth    = 350
   , gs_cellpadding  = 10
   , gs_font = xftFont
   }

-- warpToCenter brings the pointer to the center of the grid for gridSelect
warpToCenter = gets (W.screen . W.current . windowset) >>= \x -> warpToScreen x  0.5 0.5

-- <Layouts>

---Tabbed - shows at a glance which apps/windows are open on a given workspace

myLayout = 	onWorkspace "9-vb" simpleTabbed $ 
		onWorkspace "gimp" gimpTabbedMultiColumn $
		tabbedMultiColumn ||| Mirror tiled ||| simpleTabbed ||| Full
	where
		fontName = xftFont
		tabbedMultiColumn = simpleTabBar baseColumns
		gimpTabbedMultiColumn = simpleTabBar gimpColumns
		tabbedZoomRow = simpleTabBar zoomRow		
		baseColumns = multiCol [1] 0 0.03 0.56 -- use Mod-, or Mod-. to change the number of windows per column; Mod-S-Space resets to default
		gimpColumns = multiCol [1] 1 0.03 0.56
		tiled = Tall nmaster delta ratio
		nmaster = 1
		ratio = 0.56 --roughly 1 / sqrt(5)
		delta = 3/100

-- <Automatic application and window actions>

myManageHook = composeAll . concat $
 	[ [isDialog --> doFloat] -- This allows you to move things like modal dialogs, file open/save windows so you can peek underneath if you need to.
	, [className =? "Firefox" --> doShift "8-web"
 	--, appName =? "google-chrome" --> doShift "8-web"
 	, className =? "google-chrome" --> doShift "8-web"
	, className =? "Xmessage" --> doCenterFloat
	, className =? "Do"	--> doCenterFloat
	, className =? "Kupfer"	--> doCenterFloat
	, className =? "Gimp-2.6" <&&> stringProperty "WM_WINDOW_ROLE" =? "gimp-image-window" --> doF W.shiftMaster -- doesn't work
	, className =? "Gimp-2.6" <&&> stringProperty "WM_WINDOW_ROLE(STRING)" =? "gimp-image-window" --> doF W.shiftMaster --doesn't work
	, className =? "Gimp-2.6"	--> doShift "gimp" --works
	, className =? "Skype"	--> doShift "3-§"
	, manageDocks 
		]
    ]

-- <Keys>

--myKeys :: [([Char], X ())] -- use this if you want to use the default workspaces 1-9 
myKeys :: [(String, X ())] -- this is needed to get functioning workspace switching keys for extended workspaces using the keys set below
myKeys =
	[ ("<Print>", spawn "sleep 0.2; sh ~/bin/scs &")  ----This is a small shell script to use scrot to take screenshots into /run/shm named with the date and time of the picture. For security, it is a good idea to hard-code ~ to /home/username here; ~ is being used for portability only and is NOT recommended for use in a production environment	
	, ("M-S-q", spawn "xmessage 'Use Ctrl-Mod-Shift-q to exit.'") --This is the default keybinding to kill XMonad, and it is easy to hit by accident, with sometimes disastrous results. I have unmapped it here to help prevent unintentional exits. XMonad is a bit abrupt on exiting and will dump you to the display manager without asking you to save anything.
	, ("M-C-S-q", io (exitWith ExitSuccess)) --In more than a year of using XMonad as my only desktop, I have never exited by accident with the key combination set to this; just try hitting 4 keys by accident.
	, ("M-q", spawn "xmonad --recompile; xmessage 'XMonad recompiled'") --This unmaps M-q from recompile and restart to prevent XMo from restarting after a failed recompile
	, ("M-C-r", spawn "xmonad --restart")
	, ("M-a", warpToCenter >> goToSelected (myGSConfig defaultColorizer) )
	, ("M-x", windowMenu)
	--change view to previous workspace
	, ("M-<L>", prevWS)
	--Move client to previous workspace
	, ("M-S-<L>", shiftToPrev)
	--change view to next workspace
	, ("M-<R>", nextWS)
	--Move client to next workspace
	, ("M-S-<R>", shiftToNext)
	, ("M-p", runOrRaisePrompt myXPConfig 
			{position = Top
			})
	, ("M-z", warpToWindow (0.1) (0.1)) -- Move pointer to currently focused window, 10% in from the upper left corner
	, ("M-u", focusUrgent)
	, ("M-b", sendMessage ToggleStruts)
	, ("M-<Return>", spawn myTerminal) -- change from default
	, ("M-S-<Return>", windows W.shiftMaster) --per xmonad-contrib-0.10 README to move current window to master in current workspace to be more consistent with workspace shifting commands
	]
	++
--No idea where the following came from, but it is the most reliable way for me to get non-greedy views with multiple monitors. Use this code block for the default workspaces (1-9) and workspace keybindings (again, 1-9) only
-- 	[ (otherModMasks ++ "M-" ++ key, action tag)
--        	| (tag, key)  <- zip myWorkspaces (map (\x -> show x ) [1..9])
--	        , (otherModMasks, action) <- [ ("", windows . W.view) -- or W.greedyView
--        				     ,  ("S-", windows . W.shift)]
--	]
--	++
-- 	[ (otherModMasks ++ "M-C-" ++ key, action tag)
--        	| (tag, key)  <- zip myWorkspaces (map (\x -> show x ) [1..9])
--	        , (otherModMasks, action) <- [ ("", windows . W.greedyView) -- or W.view for non-greedy
--        				     ,  ("S-", windows . W.shift)]
--	]
-- end default workspace codeblock

--To use extra workspaces as laid out in this configuration, use this codeblock; [key] needs to be in brackets, workspaceKeys needs to be out of them; didn't work the other way around
 	[ (otherModMasks ++ "M-" ++ [key], action tag)
        	| (tag, key)  <- zip myWorkspaces workspaceKeys
	        , (otherModMasks, action) <- [ ("", windows . W.view) -- lets you move focus to the workspace on another monitor without swapping them, which is the default, and quite frustrating if you have different-sized monitors and applications that depend on staying a fixed size, e.g., VirtualBox with Windows inside.
        				     ,  ("S-", windows . W.shift)]
	]
	++
 	[ (otherModMasks ++ "M-C-" ++ [key], action tag)
        	| (tag, key)  <- zip myWorkspaces workspaceKeys
	        , (otherModMasks, action) <- [ ("", windows . W.greedyView) -- or W.view for non-greedy
        				     ,  ("S-", windows . W.shift)] --the intention is something like a "greedy shift", but it doesn't seem to work for me; just M-S-#, then M-C-#
	]
	where workspaceKeys = "`1234567890-=" --these are the literal keys; = goes to the gimp workspace; change to "123456789" to get default keybindings back, but make sure you only have 9 workspaces declared or you won't have a very easy way to get to them all 
--end extra workspace codeblock

