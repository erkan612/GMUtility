# GMU - GameMaker Utility Framework

A comprehensive utility framework for GameMaker, designed to accelerate development and provide robust, reusable systems for common game development tasks.

## Overview

GMU (GameMaker Utility) is a modular framework that provides production-ready solutions for input handling, state management, audio systems, camera control, procedural generation, and much more. Each module is designed to work independently or together, allowing you to pick and choose what your project needs.

## Features

- **Memory-Safe Data Structures** - Wrapped ds_* functions with automatic tracking and leak detection
- **Input Manager** - Multi-device input with action binding, chords, modifiers, and buffering
- **State Machine** - Flexible state management with enter/update/exit callbacks
- **Command Manager** - Command pattern implementation with undo/redo support
- **Audio Manager** - Group-based audio with 3D sound, ducking, crossfading, and playlists
- **Camera System** - Smooth camera following, shake effects, zoom, bounds, and parallax
- **Animation Pack** - Sprite animation controller with blending, events, and queuing
- **Procedural Generation** - Perlin, Simplex, Worley noise with fractal variants
- **ID Generator** - UUID v4, GUID, NanoID, and custom ID generation
- **Quest System** - Task-based quests with tracking and completion callbacks
- **Achievement Manager** - Progress tracking with unlock callbacks
- **Save Manager** - Simple save/load with checksum validation and auto-save
- **Object Pooling** - Efficient instance reuse for particles, bullets, etc.
- **Profiler** - Performance monitoring and reporting
- **XML DataPack** - Build and parse XML documents with ease

## Installation

1. Download the latest release
2. Import the `*.yymps` file from `Local Package Manager`
3. Call `GMU_NAMESPACES_INIT();` at game start and `GMU_NAMESPACES_CLEANUP();` at game end

## Quick Start

```gml
// Game Start Event
GMU_NAMESPACES_INIT();

// Create an input action
InputManager.CreateAction("Jump");
InputManager.BindKey("Jump", vk_space);
InputManager.BindGamepadButton("Jump", GAMEPAD_BUTTON.FACE1);

// Check input in Step Event
if (InputManager.IsJustPressed("Jump")) {
    // Player jumps
}

// Create a state machine
player_state = new StateMachine("idle");
player_state.AddState("idle", 
    function() { sprite_index = spr_player_idle; },
    function(dt) { /* update idle */ },
    function() { /* exit idle */ }
);

// Update state machine
player_state.Update();
```

## Module Documentation

- [GMU_Core](docs/GMU_Core.md) - Memory tracking, weak callbacks, file utilities
- [GMU_DS](docs/GMU_DS.md) - Memory-safe data structures and XML handling
- [GMU_State](docs/GMU_State.md) - State machines and patrol systems
- [GMU_Input](docs/GMU_Input.md) - Comprehensive input management
- [GMU_Command](docs/GMU_Command.md) - Command pattern with undo/redo
- [GMU_Audio](docs/GMU_Audio.md) - Advanced audio system
- [GMU_Rendering](docs/GMU_Rendering.md) - Camera and animation systems
- [GMU_Procedural](docs/GMU_Procedural.md) - Noise generation and IDs
- [GMU_Game](docs/GMU_Game.md) - Quests and achievements
- [GMU_Misc](docs/GMU_Misc.md) - Timers, pooling, profiling, and utilities

## Memory Safety

GMU includes a built-in `MemoryTracker` that automatically tracks all data structures created through the wrapped `*_gmu` functions:

```gml
// Use the wrapped functions instead of built-in ones
var my_map = ds_map_create_gmu();      // Tracked
var my_list = ds_list_create_gmu();    // Tracked

// Clean up everything at once
MemoryTracker.CleanupAll();

// Or track by owner
MemoryTracker.RegisterMap(my_map, "player_system");
MemoryTracker.CleanupOwner("player_system");

// Or clean one by one
ds_map_destroy_gmu(my_map);
ds_list_destroy_gmu(my_list);
```

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
