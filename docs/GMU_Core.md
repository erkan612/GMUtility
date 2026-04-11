# GMU_Core

Core utilities and foundation systems for the GMU framework. This module provides memory management, leak detection, weak callbacks, and file handling utilities.

## Table of Contents

- [MemoryTracker](#memorytracker)
- [MemoryLeakDetector](#memoryleakdetector)
- [WeakCallback](#weakcallback)
- [File Utilities](#file-utilities)
- [Macros](#macros)

---

## MemoryTracker

The `MemoryTracker` automatically tracks data structures created through the wrapped `*_gmu` functions, preventing memory leaks and providing cleanup utilities.

### Global Instance

A global `MemoryTracker` instance is automatically created via the `GMU_NAMESPACES_INIT` macro:

```gml
globalvar MemoryTracker;
MemoryTracker = new MemoryTracker();
```

### Methods

#### RegisterMap(map, owner = undefined)

Registers a ds_map for tracking.

```gml
var my_map = ds_map_create();
MemoryTracker.RegisterMap(my_map, "ui_system");
```

#### RegisterList(list, owner = undefined)

Registers a ds_list for tracking.

```gml
var my_list = ds_list_create();
MemoryTracker.RegisterList(my_list, "enemy_manager");
```

#### RegisterQueue(queue, owner = undefined)

Registers a ds_queue for tracking.

```gml
var my_queue = ds_queue_create();
MemoryTracker.RegisterQueue(my_queue);
```

#### RegisterStack(stack, owner = undefined)

Registers a ds_stack for tracking.

```gml
var my_stack = ds_stack_create();
MemoryTracker.RegisterStack(my_stack, "undo_system");
```

#### RegisterGrid(grid, owner = undefined)

Registers a ds_grid for tracking.

```gml
var my_grid = ds_grid_create(10, 10);
MemoryTracker.RegisterGrid(my_grid);
```

#### RegisterPriority(priority, owner = undefined)

Registers a ds_priority queue for tracking.

```gml
var my_priority = ds_priority_create();
MemoryTracker.RegisterPriority(my_priority);
```

#### Unregister(struct)

Removes a structure from tracking without destroying it.

```gml
MemoryTracker.Unregister(my_map);
```

**Returns:** `true` if found and removed, `false` otherwise.

#### CleanupOwner(owner)

Destroys all tracked data structures belonging to a specific owner.

```gml
// Clean up all structures owned by "battle_system"
var freed = MemoryTracker.CleanupOwner("battle_system");
show_debug_message($"Freed {freed} structures");
```

**Returns:** `number` - Total structures freed.

#### CleanupAll()

Destroys all tracked data structures and clears all tracking lists.

```gml
// Call this at game end or when resetting
MemoryTracker.CleanupAll();
```

#### GetStats()

Returns statistics about currently tracked structures.

```gml
var stats = MemoryTracker.GetStats();
show_debug_message($"Maps: {stats.maps}, Lists: {stats.lists}");
show_debug_message($"Total tracked: {stats.total}");
```

**Returns:** Struct with properties:
- `maps` - Number of tracked ds_maps
- `lists` - Number of tracked ds_lists
- `queues` - Number of tracked ds_queues
- `stacks` - Number of tracked ds_stacks
- `grids` - Number of tracked ds_grids
- `priorities` - Number of tracked ds_priorities
- `total` - Total tracked structures

---

## MemoryLeakDetector

The `MemoryLeakDetector` helps identify memory leaks by taking snapshots of tracked structures and comparing them over time.

### Global Instance

```gml
globalvar MemoryLeakDetector;
MemoryLeakDetector = new MemoryLeakDetector();
```

### Methods

#### TakeSnapshot(name)

Captures the current state of all tracked data structures.

```gml
// Take a snapshot before loading a level
MemoryLeakDetector.TakeSnapshot("before_level_load");

// ... load level ...

// Check for leaks
var diff = MemoryLeakDetector.CompareSnapshots("before_level_load", "current");
```

**Parameters:**
- `name` - Identifier for the snapshot (defaults to "snapshot_" + timestamp)

**Returns:** Snapshot struct with `name`, `timestamp`, and `stats`.

#### CompareSnapshots(snapshot1, snapshot2)

Compares two snapshots and returns the differences.

```gml
var diff = MemoryLeakDetector.CompareSnapshots("start", "end");
if (diff.total_diff > 0) {
    show_debug_message($"Potential leak: {diff.total_diff} structures");
}
```

**Returns:** Struct with difference values:
- `maps_diff`, `lists_diff`, `queues_diff`, `stacks_diff`, `grids_diff`, `priorities_diff`
- `total_diff` - Total difference in tracked structures

#### DetectLeaks(baseline_snapshot)

Takes a current snapshot and compares it against a baseline.

```gml
// Set baseline at game start
MemoryLeakDetector.TakeSnapshot("game_start");

// Check periodically
MemoryLeakDetector.DetectLeaks("game_start");
```

**Returns:** Difference struct (same as `CompareSnapshots`).

#### Free()

Cleans up the leak detector's internal data structures.

```gml
MemoryLeakDetector.Free();
```

---

## WeakCallback

A `WeakCallback` safely stores a reference to an instance or struct method, preventing errors when the target no longer exists.

### Constructor

```gml
new WeakCallback(target, method)
```

**Parameters:**
- `target` - Instance ID or struct reference
- `method` - Method to call on the target

### Example

```gml
// Store a callback that may outlive its target
var callback = new WeakCallback(enemy_instance, enemy_take_damage);

// Later, safely execute
callback.Execute(10); // Calls enemy_take_damage(enemy_instance, 10) if enemy still exists

// Check if callback is still valid
if (callback.IsValid()) {
    // Target still exists
}
```

### Methods

#### Execute(data = undefined)

Executes the stored method if the target still exists.

```gml
var result = callback.Execute({ damage: 25, type: "fire" });
```

**Returns:** The method's return value, or `undefined` if target no longer exists.

#### IsValid()

Checks if the target still exists.

```gml
if (callback.IsValid()) {
    // Safe to use
}
```

**Returns:** `true` if target exists, `false` otherwise.

---

## File Utilities

The global `File` struct provides simple file I/O operations.

### Methods

#### File.SaveString(filename, str)

Saves a string to a file.

```gml
var success = File.SaveString("config.ini", "[Settings]\nvolume=0.8");
if (success) {
    show_debug_message("File saved successfully");
}
```

**Returns:** `true` on success, `false` on failure.

#### File.LoadString(filename)

Loads a string from a file.

```gml
var content = File.LoadString("config.ini");
if (content != "") {
    // Parse content
}
```

**Returns:** File contents as string, or empty string if file doesn't exist or can't be read.

#### File.SaveJSON(filename, struct)

Saves a struct or array as JSON.

```gml
var save_data = {
    player_name: "Hero",
    level: 5,
    inventory: ["sword", "shield", "potion"]
};

File.SaveJSON("save_game.json", save_data);
```

**Returns:** `true` on success, `false` on failure.

#### File.LoadJSON(filename)

Loads and parses a JSON file.

```gml
var save_data = File.LoadJSON("save_game.json");
if (save_data != undefined) {
    player_name = save_data.player_name;
    level = save_data.level;
    inventory = save_data.inventory;
}
```

**Returns:** Parsed struct/array, or `undefined` if file doesn't exist or parsing fails.

#### File.Delete(filename)

Deletes a file.

```gml
if (File.Delete("temp_data.json")) {
    show_debug_message("File deleted");
}
```

**Returns:** `true` on success, `false` on failure.

---

## Macros

GMU_Core provides two essential macros that should be used for initialization and cleanup.

### GMU_NAMESPACES_INIT

Call this at game start to initialize all global GMU instances:

```gml
// In a script that runs at game start (e.g., gm_init)
GMU_NAMESPACES_INIT;
```

This macro expands to:

```gml
globalvar MemoryTracker; MemoryTracker = new MemoryTracker();
globalvar InputManager; InputManager = new InputManager();
globalvar Input; Input = new Input();
globalvar MemoryLeakDetector; MemoryLeakDetector = new MemoryLeakDetector();
globalvar CommandManager; CommandManager = new CommandManager();
globalvar InterfaceAccess; InterfaceAccess = new InterfaceAccess();
globalvar IDGenerate; IDGenerate = new IDGenerate();
globalvar GenerateNoise; GenerateNoise = new GenerateNoise();
globalvar AudioManager; AudioManager = new AudioManager
```

### GMU_NAMESPACES_CLEANUP

Call this at game end to properly free all GMU resources:

```gml
// In Game End event
GMU_NAMESPACES_CLEANUP;
```

This macro expands to:

```gml
InputManager.Free();
MemoryLeakDetector.Free();
CommandManager.Free();
InterfaceAccess.Free();
MemoryTracker.CleanupAll();
AudioManager.Free
```

---

## Complete Example

```gml
// Game Start Event
GMU_NAMESPACES_INIT;

// Set up baseline for leak detection
MemoryLeakDetector.TakeSnapshot("game_start");

// Create tracked data structures
var player_data = ds_map_create_gmu();
player_data[? "health"] = 100;
player_data[? "max_health"] = 100;

var inventory = ds_list_create_gmu();
ds_list_add(inventory, "sword", "shield");

// Register with owner for easy cleanup
MemoryTracker.RegisterMap(player_data, "player");
MemoryTracker.RegisterList(inventory, "player");

// Create a weak callback for delayed damage
var damage_callback = new WeakCallback(obj_enemy, function(inst, amount) {
    inst.hp -= amount;
});

// Schedule damage after 2 seconds
call_later(2, function() {
    damage_callback.Execute(25);
});

// Save game
var save = {
    health: player_data[? "health"],
    inventory: ds_list_to_array(inventory)
};
File.SaveJSON("save.json", save);

// Game End Event
GMU_NAMESPACES_CLEANUP;
```
