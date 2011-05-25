{- xmonad.hs
 - Author: Jelle van der Waa ( jelly1 )
 -}

-- Import stuff
import XMonad
import qualified XMonad.StackSet as W 
import qualified XMonad.StackSet as Z 
import qualified Data.Map as M
import XMonad.Util.EZConfig(additionalKeys)
import System.Exit
import Graphics.X11.Xlib
import System.IO


-- actions
import XMonad.Actions.CycleWS
import XMonad.Actions.WindowGo
import qualified XMonad.Actions.Submap as SM
import XMonad.Actions.GridSelect
import XMonad.Actions.FloatKeys
import XMonad.Actions.Submap

-- utils
import XMonad.Util.NamedScratchpad
import XMonad.Util.Scratchpad

import XMonad.Util.Run(spawnPipe)
import qualified XMonad.Prompt 		as P
import XMonad.Prompt.Shell
import XMonad.Prompt
import XMonad.Prompt.AppendFile (appendFilePrompt)
import XMonad.Prompt.RunOrRaise


-- hooks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.ManageHelpers

-- layouts
import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile
import XMonad.Layout.Reflect
import XMonad.Layout.IM
import XMonad.Layout.Tabbed
import XMonad.Layout.PerWorkspace (onWorkspace)
import XMonad.Layout.Grid
import Control.OldException(catchDyn,try)

-- Data.Ratio for IM layout
import Data.Ratio ((%))
import Data.List (isInfixOf)


-- Main --
main = do
    xmproc <- spawnPipe "xmobar"
    spawn "sh /home/jelle/.xmonad/autostart.sh"
    xmonad defaultConfig  {  manageHook = myManageHook  <+> manageDocks
        	, layoutHook = myLayoutHook   
		, borderWidth = myBorderWidth
		, normalBorderColor = myNormalBorderColor
		, focusedBorderColor = myFocusedBorderColor
		, keys = myKeys
        	, modMask = myModMask  
        	, terminal = myTerminal
		, workspaces = myWorkspaces
                , focusFollowsMouse = False
                , logHook = dynamicLogWithPP $ xmobarPP { ppOutput = hPutStrLn xmproc , ppTitle = xmobarColor "green" "" . shorten 50}
		}


scratchpadSize = W.RationalRect (1/4) (1/4) (1/2) (1/2)
mySPFloat = customFloating scratchpadSize

cname = stringProperty "WM_NAME"
-- hooks
-- automaticly switching app to workspace 
myManageHook :: ManageHook
myManageHook = scratchpadManageHook scratchpadSize <+> ( composeAll . concat $
                [[isFullscreen                  --> doFullFloat
		, className =?  "Xmessage" 	--> doCenterFloat 
                , className =? "Gimp"           --> doShift "9:gimp"
                , className =? "Evolution"           --> doShift "2:web"
                , className =? "Pidgin"           --> doShift "1:chat"
                , className =? "Skype"           --> doShift "1:chat"
                , className =? "Mail"           --> doShift "2:mail"
                , className =? "Thunderbird"           --> doShift "2:mail"
		, className =? "MPlayer"	--> doShift "8:vid"
		, className =? "rdesktop"	--> doShift "6:vm"
		, className =? "Wine"	--> doShift "7:games"
		, appName =? "localhost:5556 - freerdp" --> doShift "6:vm"
                , fmap ("libreoffice"  `isInfixOf`) className --> doShift "5:doc"
		, className =? "MPlayer"	--> (ask >>= doF . W.sink) 
                ]]
                          )  
            

--logHook
myLogHook :: Handle -> X ()
myLogHook h = dynamicLogWithPP $ customPP { ppOutput = hPutStrLn h }
         


---- Looks --
---- bar
customPP :: PP
customPP = defaultPP { 
     			    ppHidden = xmobarColor "#00FF00" ""
			  , ppCurrent = xmobarColor "#FF0000" "" . wrap "[" "]"
			  , ppUrgent = xmobarColor "#FF0000" "" . wrap "*" "*"
                          , ppLayout = xmobarColor "#FF0000" ""
                          , ppTitle = xmobarColor "#00FF00" "" . shorten 80
                          , ppSep = "<fc=#0033FF> | </fc>"
                     }

-- some nice colors for the prompt windows to match the dzen status bar.
myXPConfig = defaultXPConfig                                    
    { 
	font  = "-*-terminus-*-*-*-*-12-*-*-*-*-*-*-u" 
	,fgColor = "#0096d1"
	, bgColor = "#000000"
	, bgHLight    = "#000000"
	, fgHLight    = "#FF0000"
	, position = Top
        , historySize = 512
        , showCompletionOnTab = True
        , historyFilter = deleteConsecutive
    }



--LayoutHook
myLayoutHook  =  onWorkspace "1:chat" imLayout $  onWorkspace "2:mail" webL $ onWorkspace "6:VM" fullL $ onWorkspace "8:vid" fullL $ standardLayouts 
   where
	standardLayouts =   avoidStruts  $ (tiled |||  reflectTiled ||| Mirror tiled ||| Grid ||| Full) 

        --Layouts
	tiled     = smartBorders (ResizableTall 1 (2/100) (1/2) [])
        reflectTiled = (reflectHoriz tiled)
	full 	  = noBorders Full

        --Im Layout
        imLayout = avoidStruts $ smartBorders $ withIM ratio pidginRoster $ reflectHoriz $ withIM skypeRatio skypeRoster (tiled ||| reflectTiled ||| Grid) where
                chatLayout      = Grid
	        ratio = (1%9)
                skypeRatio = (1%8)
                pidginRoster    = And (ClassName "Pidgin") (Role "buddy_list")
                skypeRoster  = (ClassName "Skype")     `And`
                               (Not (Title "Options")) `And`
                                              (Not (Role "Chats"))    `And`
                                                             (Not (Role "CallWindowForm"))
         --       skypeRoster     = (ClassName "Skype") `And` (Not (Title "Options")) `And` (Not (Role "Chats")) `And` (Not (Role "CallWindowForm"))

	webL      = avoidStruts $  full ||| tiled ||| reflectHoriz tiled  

        --VirtualLayout
        fullL = avoidStruts $ full





-------------------------------------------------------------------------------
---- Terminal --
myTerminal :: String
myTerminal = "urxvt -depth 32 -fg white -bg rgba:0000/0000/0000/bbbb"

scratchTerminal :: String
scratchTerminal = "urxvt -depth 32 -fg white -bg rgba:0000/0000/0000/bbbb"

-------------------------------------------------------------------------------
-- Keys/Button bindings --
-- modmask
myModMask :: KeyMask
myModMask = mod4Mask



-- borders
myBorderWidth :: Dimension
myBorderWidth = 1
--  
myNormalBorderColor, myFocusedBorderColor :: String
myNormalBorderColor = "#333333"
myFocusedBorderColor = "#306EFF"
--


--Workspaces
myWorkspaces :: [WorkspaceId]
myWorkspaces = ["1:chat", "2:mail", "3:code", "4:pdf", "5:doc", "6:vm" ,"7:games", "8:vid", "9:gimp"] 
--


-- keys
myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
    -- killing programs
    [ ((modMask, xK_Return), spawn $ XMonad.terminal conf)
    , ((modMask .|. shiftMask, xK_c ), kill)

    -- opening program launcher / search engine
    ,((modMask , xK_p), shellPrompt myXPConfig)



    
    -- GridSelect
    , ((modMask, xK_g), goToSelected defaultGSConfig)

    -- layouts
    , ((modMask, xK_space ), sendMessage NextLayout)
    , ((modMask .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
    , ((modMask, xK_b ), sendMessage ToggleStruts)
 
    -- floating layer stuff
    , ((modMask, xK_t ), withFocused $ windows . W.sink)
 
    -- refresh'
    , ((modMask, xK_n ), refresh)
 
    -- focus
    , ((modMask, xK_Tab ), windows W.focusDown)
    , ((modMask, xK_j ), windows W.focusDown)
    , ((modMask, xK_k ), windows W.focusUp)
    , ((modMask, xK_m ), windows W.focusMaster)

 
    -- swapping
    , ((modMask .|. shiftMask, xK_Return), windows W.swapMaster)
    , ((modMask .|. shiftMask, xK_j ), windows W.swapDown )
    , ((modMask .|. shiftMask, xK_k ), windows W.swapUp )
 
    -- increase or decrease number of windows in the master area
    , ((modMask , xK_comma ), sendMessage (IncMasterN 1))
    , ((modMask , xK_period), sendMessage (IncMasterN (-1)))
 
    -- resizing
    , ((modMask, xK_h ), sendMessage Shrink)
    , ((modMask, xK_l ), sendMessage Expand)
    , ((modMask .|. shiftMask, xK_h ), sendMessage MirrorShrink)
    , ((modMask .|. shiftMask, xK_l ), sendMessage MirrorExpand)
 
    -- scratchpad
    , ((modMask ,  0xfe50), scratchpadSpawnAction defaultConfig  {terminal = myTerminal}) 

    --MPD
    , ((0 			, 0x1008ff16 ), spawn "ncmpcpp prev")
    , ((0 			, 0x1008ff14 ), spawn "ncmpcpp toggle")
    , ((0 			, 0x1008ff17 ), spawn "ncmpcpp next")
    , ((0 			, 0x1008ff19 ), runOrRaise "thunderbird" (className =? "Lanikai"))
    , ((0 			, 0x1008ff18 ), runOrRaise "firefox" (className =? "Firefox"))



    -- volume control
    , ((0 			, 0x1008ff13 ), spawn "amixer -q set Master 2dB+ && amixer -q set PCM 2dB+")
    , ((0 			, 0x1008ff11 ), spawn "amixer -q set Master 2dB-  && amixer -q set PCM 2dB-")
    , ((0 			, 0x1008ff12 ), spawn "amixer -q set Master toggle")

    -- brightness control
    , ((0 			, 0x1008ff03 ), spawn "nvclock -S -5")
    , ((0 			, 0x1008ff02 ), spawn "nvclock -S +5")

    -- toggle trackpad
    , ((modMask .|. shiftMask, xK_t ), spawn "/sbin/trackpad-toggle.sh")

    -- python-notify info
    , ((0 			, 0x1008ff93 ), spawn "/home/jelle/bin/battery-notification.py")

    , ((0,               0x1008FF2A), spawn "sudo pm-suspend")

 -- Floating window square move
    , ((modMask, xK_a), withFocused (keysMoveWindow (-8, 0)))
    , ((modMask, xK_s), withFocused (keysMoveWindow (0, 8)))
    , ((modMask, xK_d), withFocused (keysMoveWindow (0, -8)))
    , ((modMask, xK_f), withFocused (keysMoveWindow (8, 0)))
    , ((modMask .|. shiftMask, xK_a), withFocused (keysResizeWindow (-8, 0) (0, 0)))
    , ((modMask .|. shiftMask, xK_s), withFocused (keysResizeWindow (0, 8) (0, 0)))
    , ((modMask .|. shiftMask, xK_d), withFocused (keysResizeWindow (0, -8) (0, 0)))
    , ((modMask .|. shiftMask, xK_f), withFocused (keysResizeWindow (8, 0) (0, 0)))
    , ((modMask .|. controlMask, xK_s), submap . M.fromList $
        [ ((0, xK_q), withFocused (keysMoveWindowTo (0, 17) (0, 0)))
        , ((0, xK_w), withFocused (keysMoveWindowTo (720, 17) (1/2, 0)))
        , ((0, xK_e), withFocused (keysMoveWindowTo (1400, 17) (1, 0)))
        , ((0, xK_a), withFocused (keysMoveWindowTo (0, 533) (0, 1/2)))
        , ((0, xK_s), withFocused (keysMoveWindowTo (720, 533) (1/2, 1/2)))
        , ((0, xK_d), withFocused (keysMoveWindowTo (1400, 533) (1, 1/2)))
        , ((0, xK_z), withFocused (keysMoveWindowTo (0, 1050) (0, 1)))
        , ((0, xK_x), withFocused (keysMoveWindowTo (720, 1050) (1/2, 1)))
        , ((0, xK_c), withFocused (keysMoveWindowTo (1400, 1050) (1, 1)))])



 
    -- quit, or restart
    , ((modMask .|. shiftMask, xK_q ), io (exitWith ExitSuccess))
    , ((modMask , xK_q ), restart "xmonad" True)
    ]
    ++
    -- mod-[1..9] %! Switch to workspace N
    -- mod-shift-[1..9] %! Move client to workspace N
    [((m .|. modMask, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++
    -- mod-[w,e] %! switch to twinview screen 1/2
    -- mod-shift-[w,e] %! move window to screen 1/2
    [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_e, xK_w] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
