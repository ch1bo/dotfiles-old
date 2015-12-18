import System.Exit
import XMonad
import XMonad.Actions.Navigation2D
import XMonad.Hooks.DynamicLog

import qualified Data.Map as M
import qualified XMonad.StackSet as StackSet

main = xmonad =<< xmobar' config'

-- Basic configuration
config' = navigation2D' $ defaultConfig
  { modMask            = mod4Mask  -- Super as modifier
  , terminal           = "urxvt"
  , focusFollowsMouse  = True      -- Focus on mouse enter
  , clickJustFocuses   = False     -- Click 'into' window
  , normalBorderColor  = "#454545"
  , focusedBorderColor = "#268bd2"
  , borderWidth        = 2
  -- Key bindings
  , keys               = keyBindings'
  --, mouseBindings      = mouseBindings'
  }

-- XMobar configuration
xmobar' = statusBar "xmobar" pp toggleStrutsKey
 where
  -- Pretty print xmonad status
  pp = xmobarPP { ppCurrent = xmobarColor "#429942" "" . wrap "<" ">" }
  -- Toggle display of top bar
  toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

navigation2D' = withNavigation2DConfig defaultNavigation2DConfig

-- Keybindings
keyBindings' conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $

    -- TODO: switch struts control
    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modMask              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    [ ((modMask .|. shiftMask, xK_q), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modMask .|. shiftMask, xK_r), spawn "xmonad --recompile; xmonad --restart")

    -- Launch terminal
    , ((modMask, xK_Return), spawn $ XMonad.terminal conf)

    -- Launch dmenu
    , ((modMask, xK_p), spawn "dmenu_run")
    , ((modMask .|. shiftMask, xK_p), spawn "dmenu_desktop")

    -- Close focused window
    , ((modMask, xK_q), kill)

     -- Rotate through the available layout algorithms
    , ((modMask, xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modMask .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modMask, xK_n), refresh)

    -- Focus next/previous window in the stack
    , ((modMask, xK_Tab), windows StackSet.focusDown)
    , ((modMask .|. shiftMask, xK_Tab), windows StackSet.focusUp)

    -- Swap the focused window with the next window
    , ((modMask .|. shiftMask, xK_j), windows StackSet.swapDown  )

    -- Swap the focused window with the previous window
    , ((modMask .|. shiftMask, xK_k), windows StackSet.swapUp    )

    -- Focus the master window
    , ((modMask, xK_m), windows StackSet.focusMaster  )
    -- Swap the focused window and the master window
    , ((modMask .|. shiftMask, xK_m), windows StackSet.swapMaster)

    -- Shrink/Expand the master area
    , ((modMask, xK_minus), sendMessage Shrink)
    , ((modMask, xK_equal), sendMessage Expand)

    -- Increment/decremnet the number of windows in the master area
    , ((modMask, xK_comma), sendMessage (IncMasterN 1))
    , ((modMask, xK_period), sendMessage (IncMasterN (-1)))

    -- Push window back into tiling
    , ((modMask, xK_t), withFocused $ windows . StackSet.sink)

    -- Switch between layers (tiled, floating)
    , ((modMask .|. controlMask, xK_Tab), switchLayer)

    -- Directional navigation of windows
    , ((modMask, xK_l), windowGo R False)
    , ((modMask, xK_h), windowGo L False)
    , ((modMask, xK_k), windowGo U False)
    , ((modMask, xK_j), windowGo D False)

    -- Swap adjacent windows
    , ((modMask .|. shiftMask, xK_l), windowSwap R False)
    , ((modMask .|. shiftMask, xK_h), windowSwap L False)
    , ((modMask .|. shiftMask, xK_k), windowSwap U False)
    , ((modMask .|. shiftMask, xK_j), windowSwap D False)
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modMask, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(StackSet.greedyView, 0), (StackSet.shift, shiftMask)]]
    ++

    --
    -- mod-{grave,BackSpace}, Switch to physical/Xinerama screens 1 or 2
    -- mod-shift-{grave,BackSpace}, Move client to screen 1, 2
    --
    [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_grave, xK_BackSpace] [0..]
        , (f, m) <- [(StackSet.view, 0), (StackSet.shift, shiftMask)]]

