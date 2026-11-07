# CatMon 0.1 — original monster-catching RPG prototype
Native Apple Silicon macOS Cocoa app, written in Objective-C++ (C++17 plus Cocoa bindings). No external libraries or image files.

## Build on Apple Silicon Mac
Install Apple Command Line Tools (`xcode-select --install`) if needed. Run `sh build_mac.sh`, then `./CatMon-MChip`.

## Controls
Enter starts / confirms. WASD or arrows move in the world; in battle they select actions. Space confirms. Escape returns to the title. Walk through grass to encounter original creatures. Attack, capture with limited orbs, heal, or run. On fainting, press Enter to rest.

## Notes
640x480 centered window, 60Hz timer target. Original creatures and map, not a Pokémon Red ROM conversion. Mac build must be compiled and tested on macOS; this Linux environment does not include Apple's Cocoa SDK.
