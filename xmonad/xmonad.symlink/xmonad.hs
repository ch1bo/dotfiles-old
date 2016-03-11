{-# LANGUAGE DeriveDataTypeable, MultiParamTypeClasses, TypeSynonymInstances #-}

import Data.Ratio ((%))
import System.Exit (ExitCode(..), exitWith)
import XMonad hiding (config)
import XMonad.Actions.Navigation2D (withNavigation2DConfig, windowGo, windowSwap, switchLayer)
import XMonad.Hooks.DynamicLog (statusBar, PP(..), defaultPP, xmobarColor, wrap, shorten)
import XMonad.Layout.Spacing (spacing)
import XMonad.Layout.Gaps (gaps)
import XMonad.Layout.IM (gridIM, Property(..))
import XMonad.Layout.Maximize (maximize, maximizeRestore)
import XMonad.Layout.MultiToggle (mkToggle, single, Toggle(..), Transformer(..))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(SMARTBORDERS))
import XMonad.Layout.LayoutModifier (ModifiedLayout(..))
import XMonad.Layout.ResizableTile (ResizableTall(..), MirrorResize(..))
import XMonad.Util.Scratchpad (scratchpadSpawnAction, scratchpadManageHook)
import XMonad.Util.Types (Direction2D(..))

import qualified Data.Map as Map
import qualified XMonad.StackSet as StackSet

main = xmobar config >>= xmonad

config = withNavigation2DConfig def $
  def { modMask = mod4Mask -- Super as modifier
      , terminal = "urxvt"
      , focusFollowsMouse = True -- Focus on mouse enter
      , clickJustFocuses = False -- Click 'into' window
      , normalBorderColor = "#3E4451"
      , focusedBorderColor = "#528BFF"
      , borderWidth = 2
      , keys = keyBindings
      , layoutHook = layouts
      , manageHook = manageHooks
      }

xmobar = statusBar "xmobar" pp toggleStrutsKey
 where
  -- Pretty print xmonad status
  pp = defaultPP { ppCurrent = xmobarColor "#528BFF" "" . wrap "[" "]"
                 , ppTitle   = xmobarColor "#528BFF"  "" . shorten 40
                 , ppVisible = wrap "(" ")"
                 , ppUrgent  = xmobarColor "#E06C75" "#E5C07B"
                 }
  -- Toggle display of top bar
  toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

keyBindings conf@(XConfig {XMonad.modMask = modMask}) = Map.fromList $
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
    -- Reset the layouts on the current workspace to default
    , ((modMask .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf)
    -- Resize viewed windows to the correct size
    , ((modMask, xK_n), refresh)
    -- Focus next/previous window in the stack
    , ((modMask, xK_Tab), windows StackSet.focusDown)
    , ((modMask .|. shiftMask, xK_Tab), windows StackSet.focusUp)
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
    -- Resize windows TODO(SN): switch keys when (not) mirrored layout
    , ((modMask .|. controlMask, xK_l), sendMessage MirrorShrink)
    , ((modMask .|. controlMask, xK_h), sendMessage MirrorExpand)
    , ((modMask .|. controlMask, xK_j), sendMessage Expand)
    , ((modMask .|. controlMask, xK_k), sendMessage Shrink)
    -- Toggle maximize
    , ((modMask, xK_m), withFocused (sendMessage . maximizeRestore))
    -- Toggle smart borders on layout
    , ((modMask, xK_z), sendMessage $ Toggle SMARTBORDERS)
    -- Toggle gaps and spacing on layout
    , ((modMask, xK_x), sendMessage $ Toggle EXPLODE)
    -- Show/hide scratchpad
    , ((modMask, xK_s), scratchpadSpawnAction config)
    -- Launch browser
    , ((modMask, xK_w), spawn "chromium")
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

-- Layout transformer to apply gap and spacing to layouts via MultiToggle
data EXPLODE = EXPLODE deriving (Read, Show, Eq, Typeable)
instance Transformer EXPLODE Window where
  transform EXPLODE x k =
    k (gaps [(U,10),(R,10),(D,10),(L,10)] $ spacing 10 x)
      (\(ModifiedLayout _ (ModifiedLayout _ x')) -> x')

layouts = id
  . mkToggle (single SMARTBORDERS)
  . mkToggle (single EXPLODE)
  $ tiled ||| Mirror tiled ||| Full ||| im
 where
  -- Resizable tiling with maximize modifier
  tiled = maximize $ ResizableTall nmaster delta ratio []
  -- The default number of windows in the master pane
  nmaster = 2
  -- Default proportion of screen occupied by master pane
  ratio = 1/2
  -- Percent of screen to increment by when resizing panes
  delta = 3/100
  -- Instant messaging, 1/6 of width
  im = gridIM (1%6) skype
  skype = (ClassName "Skype") `And` (Not $ Role "ConversationsWindow")
                              `And` (Not $ Role "CallWindow")

manageHooks = scratchpadManageHook (StackSet.RationalRect 0.25 0.25 0.5 0.5)
