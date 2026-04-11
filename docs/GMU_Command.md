# GMU_Command

A flexible command pattern implementation for GameMaker. This module provides a command manager with undo/redo support, command queuing, delayed execution, command chaining, and category-based organization.

## Table of Contents

- [Overview](#overview)
- [Global Instance](#global-instance)
- [CommandManager](#commandmanager)
  - [Registering Commands](#registering-commands)
  - [Executing Commands](#executing-commands)
  - [Undo and Redo](#undo-and-redo)
  - [Command Categories](#command-categories)
  - [Delayed Commands](#delayed-commands)
  - [Command Chaining](#command-chaining)
  - [Debug and Utilities](#debug-and-utilities)
- [CommandChain](#commandchain)
- [Complete Examples](#complete-examples)

---

## Overview

The CommandManager implements the Command design pattern, encapsulating actions as objects. This enables:

- **Undo/Redo functionality** - Reverse any action with inverse commands
- **Command queuing** - Schedule commands for later execution
- **Delayed execution** - Run commands after a specified number of frames
- **Command categories** - Organize commands into logical groups
- **History tracking** - Track command execution for debugging
- **Safe execution** - Commands are wrapped in try-catch blocks

---

## Global Instance

A global `CommandManager` instance is automatically created via the `GMU_NAMESPACES_INIT` macro:

```gml
globalvar CommandManager;
CommandManager = new CommandManager();
```

---

## CommandManager

### Registering Commands

#### RegisterAction(cmd, handler, category = "default")

Registers a command handler function.

```gml
// Simple command
CommandManager.RegisterAction("SAVE_GAME", function(data) {
    SaveManager.Save(current_slot, game_data);
});

// Command with data
CommandManager.RegisterAction("SPAWN_ENEMY", function(data) {
    var enemy = instance_create_layer(data.x, data.y, "Enemies", data.type);
    enemy.hp = data.health;
});

// Inverse command for undo support
CommandManager.RegisterAction("MOVE_UNIT", function(data) {
    // Forward: move unit
    data.unit.x = data.new_x;
    data.unit.y = data.new_y;
});

CommandManager.RegisterAction("MOVE_UNIT_INVERSE", function(data) {
    // Inverse: move unit back
    data.unit.x = data.old_x;
    data.unit.y = data.old_y;
});

// Category-based registration
CommandManager.RegisterAction("PLAYER_JUMP", HandleJump, "player");
CommandManager.RegisterAction("ENEMY_ATTACK", HandleEnemyAttack, "enemy");
```

**Parameters:**
- `cmd` - Command identifier string
- `handler` - Function to execute `function(data)`
- `category` - Category name for grouping (default: "default")

**Returns:** `self` for chaining.

---

#### GetAction(cmd)

Gets a registered command handler.

```gml
var handler = CommandManager.GetAction("SAVE_GAME");
if (handler != undefined) {
    // Handler exists
}
```

**Returns:** Handler function or `undefined`.

---

### Executing Commands

#### Push(cmd, data = undefined)

Adds a command to the execution queue.

```gml
// Simple command
CommandManager.Push("SAVE_GAME");

// Command with data
CommandManager.Push("SPAWN_ENEMY", {
    x: 400,
    y: 300,
    type: obj_goblin,
    health: 50
});

// Queue multiple commands
CommandManager.Push("PLAY_SOUND", { sound: snd_click });
CommandManager.Push("UPDATE_UI");
CommandManager.Push("SAVE_GAME");
```

**Parameters:**
- `cmd` - Command identifier
- `data` - Optional data to pass to handler

**Returns:** `self` for chaining.

---

#### PushFront(cmd, data = undefined)

Adds a command to the front of the queue (executes next).

```gml
// High priority command
CommandManager.PushFront("EMERGENCY_STOP");
```

**Parameters:**
- `cmd` - Command identifier
- `data` - Optional data

**Returns:** `self` for chaining.

---

#### Execute()

Processes all queued commands immediately.

```gml
// In Step Event
CommandManager.Execute();
```

**Returns:** `self` for chaining.

---

#### ExecuteCategory(category)

Executes all registered commands in a category (doesn't use the queue).

```gml
// Execute all UI-related commands
CommandManager.ExecuteCategory("ui");

// Execute all debug commands
CommandManager.ExecuteCategory("debug");
```

**Parameters:**
- `category` - Category name

**Returns:** `self` for chaining.

---

### Undo and Redo

To enable undo/redo functionality, you must:

1. Enable history tracking
2. Register inverse commands (suffixed with `_INVERSE`)
3. Use `Push()` for all undoable actions

#### EnableHistory(enabled = true)

Enables history tracking for undo/redo.

```gml
CommandManager.EnableHistory(true);
```

**Returns:** `self` for chaining.

---

#### Undo()

Reverts the last executed command by calling its inverse.

```gml
// Undo last action
CommandManager.Undo();

// Check if undo is available
if (CommandManager.undoStack != undefined && !ds_stack_empty(CommandManager.undoStack)) {
    CommandManager.Undo();
}
```

**Returns:** `self` for chaining.

---

#### Redo()

Re-applies the last undone command.

```gml
// Redo last undone action
CommandManager.Redo();
```

**Returns:** `self` for chaining.

---

#### Example: Undoable Commands

```gml
// Register forward and inverse commands
CommandManager.RegisterAction("CREATE_UNIT", function(data) {
    data.instance = instance_create_layer(data.x, data.y, "Units", data.type);
    data.instance.hp = data.health;
    show_debug_message($"Created unit at {data.x}, {data.y}");
});

CommandManager.RegisterAction("CREATE_UNIT_INVERSE", function(data) {
    if (instance_exists(data.instance)) {
        instance_destroy(data.instance);
        show_debug_message("Undo: Destroyed unit");
    }
});

CommandManager.RegisterAction("SET_HEALTH", function(data) {
    data.old_health = data.target.hp;
    data.target.hp = data.new_health;
});

CommandManager.RegisterAction("SET_HEALTH_INVERSE", function(data) {
    data.target.hp = data.old_health;
});

// Enable history
CommandManager.EnableHistory(true);

// Use commands
CommandManager.Push("CREATE_UNIT", {
    x: mouse_x,
    y: mouse_y,
    type: obj_soldier,
    health: 100
});

CommandManager.Push("SET_HEALTH", {
    target: selected_unit,
    new_health: 50
});

// Execute all
CommandManager.Execute();

// Later, undo
CommandManager.Undo(); // Reverts SET_HEALTH
CommandManager.Undo(); // Reverts CREATE_UNIT

// Redo
CommandManager.Redo(); // Re-applies CREATE_UNIT
```

---

### Command Categories

Categories help organize commands and allow batch execution or clearing.

#### GetCategories()

Gets all registered category names.

```gml
var categories = CommandManager.GetCategories();
for (var i = 0; i < array_length(categories); i++) {
    show_debug_message($"Category: {categories[i]}");
}
```

**Returns:** Array of category names.

---

#### GetCommandsInCategory(category)

Gets all command names in a category.

```gml
var commands = CommandManager.GetCommandsInCategory("player");
// Returns ["PLAYER_JUMP", "PLAYER_ATTACK", "PLAYER_DASH"]
```

**Returns:** Array of command names.

---

#### ClearCategory(category)

Removes all queued commands belonging to a category.

```gml
// Cancel all pending player actions
CommandManager.ClearCategory("player");
```

**Returns:** `self` for chaining.

---

### Delayed Commands

#### PushDelayed(cmd, delayFrames = 0, data = undefined)

Adds a command that executes after a delay.

```gml
// Execute after 30 frames (0.5 seconds at 60 FPS)
CommandManager.PushDelayed("SPAWN_ENEMY", 30, {
    x: 500,
    y: 300,
    type: obj_boss
});

// Chain delayed commands
CommandManager.PushDelayed("SHAKE_CAMERA", 10);
CommandManager.PushDelayed("PLAY_SOUND", 15, { sound: snd_explosion });
CommandManager.PushDelayed("SPAWN_PARTICLES", 15, { x: 400, y: 300 });
```

**Parameters:**
- `cmd` - Command identifier
- `delayFrames` - Number of frames to wait
- `data` - Optional data

**Returns:** `self` for chaining.

---

### Command Chaining

#### Chain(commands)

Executes a sequence of commands from an array.

```gml
var sequence = [
    { cmd: "FADE_OUT", data: { duration: 1.0 } },
    { cmd: "LOAD_LEVEL", delay: 60, data: { level: "level2" } },
    { cmd: "FADE_IN", delay: 60, data: { duration: 1.0 } }
];

CommandManager.Chain(sequence);
```

**Parameters:**
- `commands` - Array of command objects with `cmd`, optional `data`, and optional `delay`

**Returns:** `self` for chaining.

---

### Debug and Utilities

#### EnableDebug(enabled = true)

Enables debug logging for command execution.

```gml
CommandManager.EnableDebug(true);
// Now all commands will log: [CMD] Executing: SAVE_GAME | Data: { ... }
```

**Returns:** `self` for chaining.

---

#### GetQueueSize()

Gets the number of commands currently queued.

```gml
var pending = CommandManager.GetQueueSize();
show_debug_message($"{pending} commands pending");
```

**Returns:** Number of queued commands.

---

#### GetCommandCount()

Gets the total number of registered commands.

```gml
var total = CommandManager.GetCommandCount();
show_debug_message($"{total} commands registered");
```

**Returns:** Number of registered commands.

---

#### Clear()

Clears all queued commands without executing them.

```gml
CommandManager.Clear();
```

**Returns:** `self` for chaining.

---

#### Reset()

Completely resets the CommandManager (clears queue, registered commands, categories, and history).

```gml
CommandManager.Reset();
```

**Returns:** `self` for chaining.

---

#### Free()

Cleans up all internal data structures.

```gml
CommandManager.Free();
```

---

## CommandChain

The `CommandChain` struct provides a fluent interface for building command sequences.

### Constructor

```gml
new CommandChain()
```

```gml
var chain = new CommandChain();
```

### Methods

#### Then(cmd, data = undefined, delay = 0)

Adds a command to the chain.

```gml
chain.Then("FADE_OUT", { duration: 1.0 })
     .Then("LOAD_LEVEL", { level: "boss_room" }, 30)
     .Then("SPAWN_BOSS", { x: 400, y: 200 }, 30)
     .Then("FADE_IN", { duration: 1.0 }, 30)
     .Then("PLAY_MUSIC", { track: "boss_theme" });
```

**Parameters:**
- `cmd` - Command identifier
- `data` - Optional data
- `delay` - Optional frame delay

**Returns:** `self` for chaining.

---

#### ThenWait(frames)

Adds a wait delay to the chain.

```gml
chain.Then("ATTACK")
     .ThenWait(20)  // Wait 20 frames
     .Then("ATTACK")
     .ThenWait(20)
     .Then("ATTACK");  // Three-hit combo
```

**Parameters:**
- `frames` - Number of frames to wait

**Returns:** `self` for chaining.

---

#### Execute(manager)

Executes the entire chain on a CommandManager.

```gml
chain.Execute(CommandManager);
```

**Parameters:**
- `manager` - The CommandManager instance to use

**Returns:** `self` for chaining.

---

#### Clear()

Clears all commands from the chain.

```gml
chain.Clear();
```

**Returns:** `self` for chaining.

---

## Complete Examples

### Example 1: Undoable Level Editor

```gml
// Setup
CommandManager.EnableHistory(true);
CommandManager.EnableDebug(true);

// Register commands
CommandManager.RegisterAction("PLACE_TILE", function(data) {
    data.previous_tile = tilemap_get_at_pixel(data.tilemap, data.x, data.y);
    tilemap_set_at_pixel(data.tilemap, data.tile_id, data.x, data.y);
});

CommandManager.RegisterAction("PLACE_TILE_INVERSE", function(data) {
    tilemap_set_at_pixel(data.tilemap, data.previous_tile, data.x, data.y);
});

CommandManager.RegisterAction("PLACE_OBJECT", function(data) {
    data.instance = instance_create_layer(data.x, data.y, data.layer, data.object);
});

CommandManager.RegisterAction("PLACE_OBJECT_INVERSE", function(data) {
    if (instance_exists(data.instance)) {
        instance_destroy(data.instance);
    }
});

CommandManager.RegisterAction("DELETE_OBJECT", function(data) {
    data.saved_x = data.target.x;
    data.saved_y = data.target.y;
    data.saved_object = data.target.object_index;
    instance_destroy(data.target);
});

CommandManager.RegisterAction("DELETE_OBJECT_INVERSE", function(data) {
    data.instance = instance_create_layer(data.saved_x, data.saved_y, "Instances", data.saved_object);
});

// Step Event - Handle input
if (keyboard_check_pressed(ord("Z")) && keyboard_check(vk_control)) {
    CommandManager.Undo();
}

if (keyboard_check_pressed(ord("Y")) && keyboard_check(vk_control)) {
    CommandManager.Redo();
}

if (mouse_check_button_pressed(mb_left)) {
    if (current_tool == TOOL_TILE) {
        CommandManager.Push("PLACE_TILE", {
            tilemap: current_layer,
            x: mouse_x,
            y: mouse_y,
            tile_id: selected_tile
        });
    } else if (current_tool == TOOL_OBJECT) {
        CommandManager.Push("PLACE_OBJECT", {
            x: mouse_x,
            y: mouse_y,
            layer: "Instances",
            object: selected_object
        });
    }
}

if (mouse_check_button_pressed(mb_right)) {
    var obj = instance_position(mouse_x, mouse_y, all);
    if (obj != noone) {
        CommandManager.Push("DELETE_OBJECT", { target: obj });
    }
}

// Execute queued commands
CommandManager.Execute();
```

### Example 2: Turn-Based Strategy Game

```gml
// Register commands
CommandManager.RegisterAction("MOVE_UNIT", function(data) {
    data.unit.x = data.new_x;
    data.unit.y = data.new_y;
    data.unit.moves_remaining--;
});

CommandManager.RegisterAction("MOVE_UNIT_INVERSE", function(data) {
    data.unit.x = data.old_x;
    data.unit.y = data.old_y;
    data.unit.moves_remaining++;
});

CommandManager.RegisterAction("ATTACK", function(data) {
    data.target.hp -= data.damage;
    data.attacker.has_attacked = true;
});

CommandManager.RegisterAction("ATTACK_INVERSE", function(data) {
    data.target.hp += data.damage;
    data.attacker.has_attacked = false;
});

CommandManager.RegisterAction("END_TURN", function(data) {
    // Process AI moves
    with(obj_enemy) {
        AITakeTurn();
    }
    // Reset player units
    with(obj_player_unit) {
        moves_remaining = max_moves;
        has_attacked = false;
    }
    current_turn++;
});

// Enable history for undo
CommandManager.EnableHistory(true);

// Player moves unit
function MoveUnit(unit, target_x, target_y) {
    var old_x = unit.x;
    var old_y = unit.y;
    
    CommandManager.Push("MOVE_UNIT", {
        unit: unit,
        old_x: old_x,
        old_y: old_y,
        new_x: target_x,
        new_y: target_y
    });
    
    CommandManager.Execute();
}

// Attack
function AttackUnit(attacker, defender, damage) {
    CommandManager.Push("ATTACK", {
        attacker: attacker,
        target: defender,
        damage: damage
    });
    
    CommandManager.Execute();
}

// End turn button
if (InputManager.IsJustPressed("EndTurn")) {
    CommandManager.Push("END_TURN");
    CommandManager.Execute();
}

// Undo button
if (InputManager.IsJustPressed("Undo")) {
    CommandManager.Undo();
}
```

### Example 3: Cutscene System with CommandChain

```gml
// Register cutscene commands
CommandManager.RegisterAction("CAMERA_PAN", function(data) {
    Camera.MoveTo(data.x, data.y, data.duration);
}, "cutscene");

CommandManager.RegisterAction("DIALOGUE_SHOW", function(data) {
    DialogueBox.Show(data.speaker, data.text);
}, "cutscene");

CommandManager.RegisterAction("DIALOGUE_HIDE", function(data) {
    DialogueBox.Hide();
}, "cutscene");

CommandManager.RegisterAction("WAIT", function(data) {
    // Do nothing, just wait
}, "cutscene");

CommandManager.RegisterAction("FADE_OUT", function(data) {
    FadeEffect.Start(FADE_OUT, data.duration);
}, "cutscene");

CommandManager.RegisterAction("FADE_IN", function(data) {
    FadeEffect.Start(FADE_IN, data.duration);
}, "cutscene");

CommandManager.RegisterAction("SPAWN_NPC", function(data) {
    data.instance = instance_create_layer(data.x, data.y, "NPCs", data.type);
}, "cutscene");

CommandManager.RegisterAction("PLAY_SOUND", function(data) {
    AudioManager.PlaySFX(data.sound);
}, "cutscene");

// Create a cutscene using CommandChain
function PlayIntroCutscene() {
    var chain = new CommandChain();
    
    chain.Then("FADE_OUT", { duration: 0 })
         .Then("CAMERA_PAN", { x: 0, y: 0, duration: 0 })
         .Then("SPAWN_NPC", { x: 400, y: 300, type: obj_king })
         .Then("FADE_IN", { duration: 2.0 })
         .ThenWait(60)
         .Then("CAMERA_PAN", { x: 400, y: 300, duration: 3.0 })
         .Then("DIALOGUE_SHOW", { speaker: "King", text: "Welcome, hero..." })
         .ThenWait(180)
         .Then("DIALOGUE_SHOW", { speaker: "King", text: "Our kingdom needs your help." })
         .ThenWait(180)
         .Then("DIALOGUE_HIDE")
         .Then("CAMERA_PAN", { x: 800, y: 300, duration: 2.0 })
         .Then("PLAY_SOUND", { sound: snd_ominous })
         .Then("FADE_OUT", { duration: 1.0 })
         .Then("LOAD_LEVEL", { level: "world_map" }, 30)
         .Then("FADE_IN", { duration: 1.0 }, 30);
    
    chain.Execute(CommandManager);
}

// Play the cutscene
PlayIntroCutscene();

// In Step Event - Execute commands each frame
CommandManager.Execute();
```

### Example 4: Delayed Commands for Game Feel

```gml
// Register commands
CommandManager.RegisterAction("HIT_STOP", function(data) {
    // Brief pause for impact feel
    instance_deactivate_all(true);
    alarm[0] = data.duration;
}, "effects");

CommandManager.RegisterAction("SCREEN_SHAKE", function(data) {
    Camera.Shake(data.intensity, data.decay);
}, "effects");

CommandManager.RegisterAction("SPAWN_HIT_EFFECT", function(data) {
    var effect = instance_create_layer(data.x, data.y, "Effects", obj_hit_spark);
    effect.direction = data.direction;
}, "effects");

CommandManager.RegisterAction("PLAY_HIT_SOUND", function(data) {
    AudioManager.PlaySFX(snd_hit, 0.8, 1.0 + random_range(-0.1, 0.1));
}, "effects");

// Combo attack with delays for better game feel
function PerformHeavyAttack(attacker, target) {
    var chain = new CommandChain();
    
    // Wind-up
    chain.Then("PLAY_SOUND", { sound: snd_heavy_woosh });
    
    // Impact after 15 frames
    chain.Then("HIT_STOP", { duration: 4 }, 15);
    chain.Then("SCREEN_SHAKE", { intensity: 0.8, decay: 0.7 }, 15);
    chain.Then("SPAWN_HIT_EFFECT", { x: target.x, y: target.y, direction: attacker.direction }, 15);
    chain.Then("PLAY_HIT_SOUND", {}, 15);
    chain.Then("APPLY_DAMAGE", { target: target, damage: 50 }, 15);
    
    // Knockback
    chain.Then("KNOCKBACK", { 
        target: target, 
        direction: attacker.direction, 
        force: 15 
    }, 15);
    
    chain.Execute(CommandManager);
}
```

### Example 5: Macro Recording and Playback

```gml
// Record player actions for replay/demo system
CommandManager.EnableHistory(true);

var recorded_commands = ds_list_create();

// Override Push to record commands
var original_push = CommandManager.Push;
CommandManager.Push = function(cmd, data) {
    // Record the command with timestamp
    ds_list_add(recorded_commands, {
        cmd: cmd,
        data: data,
        frame: current_frame
    });
    
    // Call original push
    return original_push(cmd, data);
};

// Later, play back the recording
function PlaybackRecording() {
    CommandManager.Clear();
    
    var frame = 0;
    for (var i = 0; i < ds_list_size(recorded_commands); i++) {
        var record = recorded_commands[| i];
        var delay = record.frame - frame;
        frame = record.frame;
        
        CommandManager.PushDelayed(record.cmd, delay, record.data);
    }
}

// Save recording to file
function SaveRecording(filename) {
    var data = [];
    for (var i = 0; i < ds_list_size(recorded_commands); i++) {
        array_push(data, recorded_commands[| i]);
    }
    File.SaveJSON(filename, data);
}

// Load recording from file
function LoadRecording(filename) {
    var data = File.LoadJSON(filename);
    ds_list_clear(recorded_commands);
    for (var i = 0; i < array_length(data); i++) {
        ds_list_add(recorded_commands, data[i]);
    }
}
```

### Example 6: Command Queue Visualization

```gml
// Draw Event - Show pending commands
function DrawCommandQueue(x, y) {
    var queue_size = CommandManager.GetQueueSize();
    
    draw_set_color(c_white);
    draw_text(x, y, $"Pending Commands: {queue_size}");
    
    if (queue_size > 0) {
        y += 20;
        draw_set_color(c_gray);
        
        // Note: cmdList is internal, this is just for visualization
        var commands = CommandManager.GetQueuedCommands(); // Custom method you could add
        for (var i = 0; i < min(array_length(commands), 10); i++) {
            draw_text(x, y, $"- {commands[i].command}");
            y += 16;
        }
        
        if (queue_size > 10) {
            draw_text(x, y, $"... and {queue_size - 10} more");
        }
    }
}

// Draw undo/redo status
function DrawHistoryStatus(x, y) {
    draw_set_color(c_white);
    
    var undo_size = 0;
    var redo_size = 0;
    
    if (CommandManager.undoStack != undefined) {
        undo_size = ds_stack_size(CommandManager.undoStack);
    }
    if (CommandManager.redoStack != undefined) {
        redo_size = ds_stack_size(CommandManager.redoStack);
    }
    
    draw_text(x, y, $"Undo: {undo_size}  Redo: {redo_size}");
    
    // Draw visual stack
    y += 20;
    for (var i = 0; i < min(undo_size, 5); i++) {
        draw_set_color(make_color_rgb(100, 150, 200));
        draw_rectangle(x, y + i * 4, x + 100, y + i * 4 + 3, false);
    }
}
```
