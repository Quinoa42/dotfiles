------------------------------------------------------------------------
--              yahyper -- yet another Hyper Key Module               --
------------------------------------------------------------------------

local MHyper = {} -- module

local BindKey = {}
local HyperKey = {}

-------------------------------------
--    HyperKey class definition    --
-------------------------------------

-- HyperKey is a class that implements the features of a hyper key.
-- HyperKey:new(key)                      -> a constructor of HyperKey, taken one argument (the name of the key)
-- HyperKey:setPressedAlone(targetKey)    -> set what key is returned when the hyper key is pressed alone
-- HyperKey:bind(mod, key)                -> return a BindKey object by taken two arguments, modifier (mod) and key


function HyperKey:new(key, modalkey)
    local this = {
        _triggered = false,
        _hyperMod = nil,
        _alone = function () return nil end,
        _aloneEvent = nil
    }
    self.__index = self
    setmetatable(this, self)

    this._pressed = function()
        this._triggered = false
        this._hyperMod:enter()
    end

    this._released = function()
        this._hyperMod:exit()
        if not this._triggered then
            if this._aloneEvent then this._aloneEvent() end
            this._alone()
        end
    end
    -- constructor begin
    this._hyperMod = modalkey and hs.hotkey.modal.new({}, modalkey) or hs.hotkey.modal.new({"Shift"}, key)
    hs.hotkey.bind({}, key, this._pressed, this._released)
    -- constructor end
    return this
end

function HyperKey:setPressedAlone(targetKey)
    self._alone = function()
        hs.eventtap.keyStroke({}, targetKey)
    end
end

function HyperKey:setPressedAloneEvent(event)
    self._aloneEvent = event
end


function HyperKey:bind(mod, key)
    return BindKey:new(self, mod, key)
end

--------------------------------
--  BindKey class definition  --
--------------------------------

-- BindKey is a class that implements a key combination that can invoke something.
-- BindKey:new(hyper, mod, key)                  -> the constructor that takes three arguments: hyper (its parent), *mod*ifier, key
-- BindKey:stroke(event)                         -> set what happens if a key is stroked
-- BindKey:press(event)                          -> set what happens if a key is pressed

function BindKey:new(hyper, mod, key)
    local this = {
        _hyper = hyper, -- parent HyperKey
        _mod = mod,
        _key = key,
        _wrapper = function (this, event)
            return function ()
                event()
                this._hyper._triggered = true
            end
        end
    }
    self.__index = self
    return setmetatable(this, self)
end

function BindKey:stroke(event)
    self._hyper._hyperMod:bind(self._mod, self._key, nil, self:_wrapper(event))
end

function BindKey:press(event)
    wrappedEvent = self:_wrapper(event)
    self._hyper._hyperMod:bind(self._mod, self._key, wrappedEvent, nil, wrappedEvent)
end

-----------------------------
--  end class definitions  --
-----------------------------

function MHyper.new(key)
    return HyperKey:new(key)
end

function MHyper.new(key, modalkey)
    return HyperKey:new(key, modalkey)
end

return MHyper -- end module
