# Friday Night Funkin' - Difficult Engine
Engine powered by Psych Engine, which was originally used on [Mind Games Mod](https://gamebanana.com/mods/301107) and intended to be a fix for the vanilla version's many issues while keeping the casual play aspect of it. Also aiming to be an easier alternative to newbie coders.
Difficult Engine adds a few little things for soft-coded mods using the mods folder.

## Installation:
You must have [the most up-to-date version of Haxe](https://haxe.org/download/), seriously, stop using 4.1.5, it misses some stuff.

Follow a Friday Night Funkin' source code compilation tutorial, after this you will need to install LuaJIT.

To install LuaJIT do this: `haxelib git linc_luajit https://github.com/nebulazorua/linc_luajit` on a Command prompt/PowerShell

...Or if you don't want your mod to be able to run .lua scripts, delete the "LUA_ALLOWED" line on Project.xml


If you get an error about StatePointer when using Lua, run `haxelib remove linc_luajit` into Command Prompt/PowerShell, then re-install linc_luajit.

If you want video support on your mod, simply do `haxelib install hxCodec` on a Command prompt/PowerShell (Suggested Version: 1.60.0)

otherwise, you can delete the "VIDEOS_ALLOWED" Line on Project.xml

Suggested version for flixel-addons: 2.12.0

## Credits:

### Difficult Engine Team
* DifficultBit2901 - Programmer

### Psych Engine Team
* Shadow Mario - Programmer
* RiverOaken - Artist
* Yoshubs - Assistant Programmer


### Special Thanks
* bbpanzu - Ex-Programmer
* shubs - New Input System
* SqirraRNG - Crash Handler and Base code for Chart Editor's Waveform
* KadeDev - Fixed some cool stuff on Chart Editor and other PRs
* iFlicky - Composer of Psync and Tea Time, also made the Dialogue Sounds
* PolybiusProxy - .MP4 Video Loader Library (hxCodec)
* Keoiki - Note Splash Animations
* Smokey - Sprite Atlas Support
* Nebula the Zorua - LUA JIT Fork and some Lua reworks
_____________________________________

# Features (In Addition to Psych Engine)
## Lua/Json Achievements
* You can create json files for achievements
* You can grant achievements using lua

## Lua/Json Options
* You can create json files for adding options
* Custom options appear in the "Engine and Custom" section of the options menu
* You can give the options logic using lua

## Judgement Counter
* There's a counter for sicks, goods, bads, and more on the left hand side
* Can be turned off in the options

## Trails
* Added trails to bf and dad (similar to shaggy)
* Can be toggled using an event

## Lua Backdrops
* Added FlxBackdrops (infinitely scrolling backgrounds) to lua
* They work similar to Sprites or texts

## Engine Customization
* Change the style for the time bar
* Enable/Disable judgment counter colors