# dogukancim-policestatus

A simple FiveM police status script.

## Events

### OpenMenu

```lua
exports['dogukancim-policestatus']:OpenMenu()
```

### StatusCount

```lua
local count = exports['dogukancim-policestatus']:StatusCount('available')
print(('Available: %d'):format(count))
```

### StatusNames

```lua
local names = exports['dogukancim-policestatus']:StatusNames('busy')

for _, name in ipairs(names) do
    print(name)
end
```

---

> [!NOTE]  
> It was created using vibe-coding (Claude Opus 5.5). Script testing and minor adjustments were done by me.
