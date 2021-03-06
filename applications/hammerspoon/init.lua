------------------------------------------------------------------------
--                     key bindings and settings                      --
------------------------------------------------------------------------


local reload = require "reload"
local yahyper = require "yahyper"
local window = require "window"
local movement = require "movement"
local input = require "input"

hs.window.animationDuration = 0

-----------------
--  hyper key  --
-----------------

hyper = yahyper.new("F18", "F19")
hyper:setPressedAloneEvent(input.setEng)
hyper:setPressedAlone("ESCAPE")

--------------
--  window  --
--------------

hyper:bind({"Option"}, "L"):stroke(window.setToRight)
hyper:bind({"Option"}, "H"):stroke(window.setToLeft)
hyper:bind({"Option"}, "J"):stroke(window.setToBottom)
hyper:bind({"Option"}, "K"):stroke(window.setToTop)
hyper:bind({"Option"}, "M"):stroke(window.maximize)
hyper:bind({"Option"}, "Q"):stroke(window.setToUpperLeft)
hyper:bind({"Option"}, "E"):stroke(window.setToUpperRight)
hyper:bind({"Option"}, "Z"):stroke(window.setToLowerLeft)
hyper:bind({"Option"}, "C"):stroke(window.setToLowerRight)
hyper:bind({"Option"}, "S"):stroke(window.setToCenter)
hyper:bind({"Option"}, "F"):stroke(window.toggleFullScreen)


hyper:bind({"Option", "Ctrl"}, "H"):stroke(window.setToWestScreen)
hyper:bind({"Option", "Ctrl"}, "L"):stroke(window.setToEastScreen)
hyper:bind({"Option", "Ctrl"}, "J"):stroke(window.setToSouthScreen)
hyper:bind({"Option", "Ctrl"}, "K"):stroke(window.setToNorthScreen)

hyper:bind({"Ctrl"}, "L"):stroke(window.focusEast)
hyper:bind({"Ctrl"}, "H"):stroke(window.focusWest)
hyper:bind({"Ctrl"}, "J"):stroke(window.focusSouth)
hyper:bind({"Ctrl"}, "K"):stroke(window.focusNorth)
hyper:bind({"Ctrl"}, "F"):stroke(window.hint)

----------------
--  movement  --
----------------
hyper:bind({}, 'h'):press(movement.hfun)
hyper:bind({}, 'j'):press(movement.jfun)
hyper:bind({}, 'k'):press(movement.kfun)
hyper:bind({}, 'l'):press(movement.lfun)
hyper:bind({}, 'b'):press(movement.bfun)
hyper:bind({}, 'f'):press(movement.ffun)

--------------------
--  input method  --
--------------------

hyper:bind({}, '1'):stroke(input.setEng)
hyper:bind({}, '2'):stroke(input.setChn)
hyper:bind({}, '3'):stroke(input.setJpn)

-- make a windowfilterDisable for redshift: VLC, Photos and screensaver/login window will disable color adjustment and inversion
local wfRedshift=hs.window.filter.new({mpv={focused=true},Photos={focused=true},loginwindow={visible=true,allowRoles='*'}},'wf-redshift')
-- start redshift: 2800K + inverted from 21 to 7, very long transition duration (19->23 and 5->9)
hs.redshift.start(3600,'18:00','7:00','4h',false,wfRedshift)
