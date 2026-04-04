# KISMET - GameMaker Utility Framework

KISMET is a comprehensive utility framework for GameMaker Studio that provides production-ready systems for memory management, input handling, command queuing, quests, achievements, saving, and much more. It's designed to accelerate game development by solving common problems that every GameMaker developer faces.

## Features

### Core Systems
- **Memory Tracker** - Automatic tracking and cleanup of all `ds_*` structures (maps, lists, queues, stacks, grids, priorities)
- **Input Manager** - Full-featured action-based input system with keyboard, mouse, gamepad (4 players), and touch support
- **Command Manager** - Queue-based command execution with delay support, undo/redo, categories, and chaining
- **State Machine** - Flexible state management with enter/update/exit callbacks

### Game Systems
- **Quest System** - Template-based quests with task tracking, states (pending, active, completed, failed, etc.)
- **Achievement System** - Progress tracking, unlock callbacks, hidden achievements, save/load support
- **Save Manager** - JSON-based saving with multiple slots, auto-save, checksum validation, and thumbnail support
- **Object Pooling** - Reuse objects instead of creating/destroying them for better performance
- **Timer System** - Countdown timers with loop support and callbacks

### Utility Systems
- **XML Parser/Writer** - Full XML support with CDATA, attributes, and query paths
- **Animation System** - Animation packs for easy sprite state management
- **Camera System** - Multi-camera support with shake, zoom, pan, and follow behaviors
- **Movement Helpers** - Acceleration, damping, and vector-based movement
- **Profiler** - Performance monitoring with timing data and reports
- **Noise Functions** - Value noise, FBM, and ridge noise for procedural generation

### Data Structures
- **Color** - RGBA color manipulation with hex conversion
- **Rect** - Rectangle with collision and transformation methods
- **ID Generation** - GUID, UUID, incremental, timestamped, and hash-based IDs

## Quick Start

### 1. Initialization

Add this code in your **Game Start** event or a dedicated init script:

```gml
// Initialize KISMET (creates global KISMET object and MemoryTracker)
KISMET_NAMESPACE_INIT();

// Optional: Enable debug mode for verbose logging
globalvar KISMET_DEBUG;
global.KISMET_DEBUG = true;

// Optional: Enable command history for undo/redo
KISMET.DefaultCommandManager.EnableHistory(true);

// Optional: Enable auto-save
KISMET.SaveManager.EnableAutoSave(300); // Save every 5 minutes
```

### 2. Basic Input Setup

```gml
// In Create event of a controller object
// Create movement action
KISMET.InputManager.CreateAction("move_left")
    .AddBinding(KISMET.InputBindingFromKey("A"))
    .AddBinding(KISMET.InputBindingFromGamepadButton(KISMET_GAMEPAD_BUTTON.DPAD_LEFT))
    .AddBinding(KISMET.InputBindingFromGamepadAxis(KISMET_GAMEPAD_AXIS.LEFT_X, 0.5, true));

KISMET.InputManager.CreateAction("move_right")
    .AddBinding(KISMET.InputBindingFromKey("D"))
    .AddBinding(KISMET.InputBindingFromGamepadButton(KISMET_GAMEPAD_BUTTON.DPAD_RIGHT))
    .AddBinding(KISMET.InputBindingFromGamepadAxis(KISMET_GAMEPAD_AXIS.LEFT_X, 0.5, false));

KISMET.InputManager.CreateAction("jump")
    .AddBinding(KISMET.InputBindingFromKey(vk_space))
    .AddBinding(KISMET.InputBindingFromGamepadButton(KISMET_GAMEPAD_BUTTON.A));

// In Step event
KISMET.InputManager.Update(); // Call this every frame

// Check input
if (KISMET.InputManager.IsJustPressed("jump")) {
    CMD_PLAYER_JUMP; // Execute jump command
}

// Get analog movement (for gamepad)
var move = KISMET.InputManager.GetVector("move");
hspeed = move.x * 5;
vspeed = move.y * 5;
```

### 3. Using the Command System

KISMET's command system allows you to queue actions for later execution, perfect for cutscenes, tutorials, and game logic.

```gml
// Simple commands
CMD_QUIT;                          // Quit the game
CMD_ROOM_GOTO(rm_level_2);         // Change room
CMD_TOGGLE_FULLSCREEN;             // Toggle fullscreen mode

// Command with data
CMD_ADD_GOLD(100);                 // Add 100 gold
CMD_PLAYER_SKILL(1);               // Use skill 1
CMD_CAMERA_SHAKE(5, 0.95);         // Shake camera with magnitude 5 and decay 0.95

// Delayed commands
KISMET.DefaultCommandManager.PushDelayed(KISMET_COMMAND.UI_NOTIFICATION_PUSH, 30, "Level Complete!");

// Command chains for cutscenes
var cutscene = new KISMET.CommandChain();
cutscene.Then(KISMET_COMMAND.CUTSCENE_START)
    .ThenWait(30)  // Wait 30 frames
    .Then(KISMET_COMMAND.CAMERA_PAN_TO, {x: 500, y: 300})
    .Then(KISMET_COMMAND.UI_FADE_IN)
    .Then(KISMET_COMMAND.CUTSCENE_END)
    .Execute();

// Register custom commands
KISMET.DefaultCommandManager.RegisterAction(1000, function(data) {
    show_debug_message("Custom command executed with data: " + string(data));
}, "custom");
```

### 4. Memory Management

Never leak memory again with automatic ds_* tracking:

```gml
// Use these instead of standard ds_* functions
var my_map = ds_map_create_kismet();      // Automatically tracked
var my_list = ds_list_create_kismet();    // Automatically tracked
var my_grid = ds_grid_create_kismet(10, 10);

// Or track existing structures
MemoryTracker.RegisterMap(existing_map);

// Clean up by owner (useful for objects)
MemoryTracker.CleanupOwner(my_object_id);

// Get memory statistics
var stats = MemoryTracker.GetStats();
show_debug_message($"Maps: {stats.maps}, Lists: {stats.lists}, Total: {stats.total}");

// Detect memory leaks
var baseline = KISMET.LeakDetector.TakeSnapshot("game_start");
// ... gameplay ...
var diff = KISMET.LeakDetector.DetectLeaks("game_start");
if (diff.total_diff > 0) {
    show_debug_message($"Potential leak: {diff.total_diff} new structures");
}
```

### 5. Quest System

Create complex quests with task tracking:

```gml
// Define a quest template
var kill_goblins_quest = new KISMET.Quest("Goblin Slayer", "Defeat 10 goblins", 
    function(quest) { 
        show_debug_message("Quest complete! Reward: 100 XP");
        CMD_ADD_GOLD(50);
    },
    function(quest) { 
        show_debug_message("Quest failed!"); 
    }
);

// Add tasks
kill_goblins_quest.AddTask(new KISMET.Task("kill_goblins", 10, function(data) {
    show_debug_message("Killed a goblin!");
}));

// Register and spawn
KISMET.QuestManager.AddTemplate(kill_goblins_quest);
var active_quest = KISMET.QuestManager.SpawnQuest("Goblin Slayer");
KISMET.QuestTracker.AddQuest(active_quest);
active_quest.Start();

// Update progress when player kills goblin
function OnGoblinKilled() {
    var task = active_quest.tasks.GetTask("kill_goblins");
    task.AddProgress(1);
    active_quest.Update();
}
```

### 6. Achievement System

```gml
// Define achievements
KISMET.AchievementManager.Add("welcome", "Welcome!", 1, false);
KISMET.AchievementManager.Add("collector", "Collector", 50, false, function(id) {
    show_debug_message("Unlocked collector achievement!");
});
KISMET.AchievementManager.Add("secret", "Secret Achievement", 1, true); // Hidden

// Progress achievements
KISMET.AchievementManager.Progress("collector", 1); // Increment by 1

// Check unlock status
if (KISMET.AchievementManager.IsUnlocked("welcome")) {
    // Give reward
}

// Save/load achievement data
var save_data = KISMET.AchievementManager.GetAll();
KISMET.SaveManager.Save(0, save_data);
KISMET.AchievementManager.LoadFromSave(loaded_data);
```

### 7. Save System

```gml
// Save game data
var game_data = {
    level: 5,
    player_hp: 100,
    inventory: ["sword", "shield"],
    position: {x: 500, y: 300}
};

// Save to slot 0
KISMET.SaveManager.Save(0, game_data, sprite_get_texture(spr_thumbnail, 0));

// Load from slot 0
var loaded = KISMET.SaveManager.Load(0);
if (loaded != undefined) {
    level = loaded.level;
    player_hp = loaded.player_hp;
}

// Check if save exists
if (KISMET.SaveManager.Exists(0)) {
    show_debug_message("Save file found!");
}

// Get all save files
var saves = KISMET.SaveManager.GetSaveList();
for (var i = 0; i < array_length(saves); i++) {
    show_debug_message($"Slot {saves[i].slot}: {date_datetime_string(saves[i].timestamp)}");
}
```

### 8. Object Pooling

Improve performance by reusing objects instead of creating/destroying:

```gml
// Create a pool of 20 bullet objects
bullet_pool = new KISMET.ObjectPool(obj_bullet, 20, "Instances");

// Spawn a bullet
var bullet = bullet_pool.Get(x, y, true);
bullet.direction = direction;
bullet.speed = 10;

// Return bullet when it's done
function OnBulletDeactivate(bullet) {
    bullet_pool.Return(bullet);
}
```

### 9. State Machine

```gml
// Create state machine
var player_states = new KISMET.StateMachine("idle");

// Add states
player_states.AddState("idle", 
    function() { sprite_index = spr_player_idle; },
    function(delta) { /* Update idle */ },
    function() { show_debug_message("Exiting idle"); }
);

player_states.AddState("running",
    function() { sprite_index = spr_player_run; },
    function(delta) { 
        x += move_speed * delta;
        if (move_speed == 0) player_states.ChangeTo("idle");
    }
);

player_states.AddState("jumping",
    function() { vsp = -10; },
    function(delta) { 
        vsp += gravity;
        if (place_meeting(x, y+vsp, obj_ground)) {
            player_states.ChangeTo("idle");
        }
    }
);

// In step event
player_states.Update();
```

### 10. XML Generation and Parsing

```gml
// Create XML document
var doc = new KISMET.DataPack();
doc.NewDocument("game_data");

doc.PushTag("player");
doc.AddAttribute("name", "Hero");
doc.AddAttribute("level", "5");

doc.PushTag("inventory");
doc.PushTag("item");
doc.AddAttribute("id", "sword");
doc.AddContent("Steel Sword");
doc.PopTag();

doc.PopTag(); // Close inventory
doc.PopTag(); // Close player

// Save to file
doc.SaveToFile("save.xml", true);

// Parse existing XML
var loaded_doc = KISMET.DataPack.LoadFromFile("save.xml");
if (loaded_doc != undefined) {
    var player_name = loaded_doc.Query("player@name");
    var items = loaded_doc.Query("player/inventory").GetChildren("item");
    
    for (var i = 0; i < array_length(items); i++) {
        show_debug_message($"Item: {items[i].GetAttribute("id")} = {items[i].GetContent()}");
    }
}

doc.Free();
```

### 11. Camera System

```gml
// Create camera with 640x360 resolution
var game_cam = new KISMET.Camera(0, {width: 640, height: 360}, obj_player, 
    {x: 320, y: 180}, {x: 100, y: 100}, 0, {x: 5, y: 5});
game_cam.Set();

// Shake camera when player gets hit
function OnPlayerHit() {
    game_cam.Shake(10, 0.9);
}

// Zoom effect for focus
function FocusOnObject(obj) {
    game_cam.SetZoom(2.0, 0.1);
    game_cam.object = obj;
}

// In step event
game_cam.Update();
```

### 12. Profiling Performance

```gml
// Start profiling a section
KISMET.Profiler.Begin("level_loading");
    LoadLevel();
    SpawnEnemies();
    InitializeUI();
KISMET.Profiler.End();

// Get performance report
var report = KISMET.Profiler.GetReport();
show_debug_message(report);

// Output example:
// === Performance Profile ===
// level_loading: 125.3ms (45.2%) - Avg: 125.3ms, Calls: 1
// enemy_spawn: 87.1ms (31.5%) - Avg: 43.5ms, Calls: 2
// ui_init: 64.2ms (23.2%) - Avg: 32.1ms, Calls: 2
```

## Pre-defined Commands

KISMET includes over 300 pre-defined commands organized by category:

**Game Commands**: `GAME_PAUSE`, `GAME_RESUME`, `GAME_QUIT`, `GAME_RESTART`, `GAME_SAVE`, `GAME_LOAD`

**Room Commands**: `ROOM_GOTO`, `ROOM_RESTART`, `ROOM_PREVIOUS`, `ROOM_NEXT`

**Player Commands**: `PLAYER_JUMP`, `PLAYER_ATTACK`, `PLAYER_DASH`, `PLAYER_SKILL_1-5`, `PLAYER_HEAL`, `PLAYER_DAMAGE`

**UI Commands**: `UI_OPEN_MENU`, `UI_CLOSE_MENU`, `UI_TOGGLE_INVENTORY`, `UI_NOTIFICATION_PUSH`

**Audio Commands**: `AUDIO_PLAY_MUSIC`, `AUDIO_PLAY_SFX`, `AUDIO_MUTE`, `AUDIO_VOLUME_SET_MASTER`

**Camera Commands**: `CAMERA_SHAKE`, `CAMERA_ZOOM_IN`, `CAMERA_PAN_TO`, `CAMERA_SET_BOUNDS`

**Time Commands**: `TIME_SLOW_MOTION`, `TIME_FREEZE`, `TIME_SET_SCALE`

**Economy Commands**: `ECONOMY_ADD_GOLD`, `INVENTORY_ADD_ITEM`, `INVENTORY_REMOVE_ITEM`

**System Commands**: `SYSTEM_SCREENSHOT`, `SYSTEM_FULLSCREEN`, `SYSTEM_DEBUG_INFO`, `SYSTEM_MEMORY_CLEAN`

## Player Movement Flags

The framework includes comprehensive bitflag enums for player states:

```gml
// Check movement capabilities
if (KISMET.InputManager.IsPressed("dash") && (player_flags & KISMET_PLAYER_MOVEMENT_FLAGS.CAN_DASH)) {
    StartDash();
}

// Apply status effects
player_status |= KISMET_PLAYER_STATUS_EFFECT_FLAGS.IS_POISONED;
player_status |= KISMET_PLAYER_STATUS_EFFECT_FLAGS.IS_SLOWED;

// Check conditions
if (player_status & KISMET_PLAYER_STATUS_EFFECT_FLAGS.IS_STUNNED) {
    return; // Can't act while stunned
}
```

## Utility Functions

```gml
// Color manipulation
var health_color = new KISMET.Color(1, 0.2, 0.2, 1);
var gold_color = KISMET.Color.FromHex("#FFD700");
show_debug_message(gold_color.ToHex()); // "#FFD700"

// Rectangle operations
var bounds = new KISMET.Rect(0, 0, 100, 100);
if (bounds.Contains(mouse_x, mouse_y)) {
    // Mouse inside bounds
}

// ID generation
var guid = KISMET.IDGenerate.GUID(); // "123e4567-e89b-12d3-a456-426614174000"
var uuid = KISMET.IDGenerate.UUID(); // RFC-compliant UUID
var timestamp_id = KISMET.IDGenerate.Timestamped("save_"); // "save_1645234567"

// Drawing helpers
KISMET.Draw.HealthBar(x, y-20, 100, 10, current_hp / max_hp, c_red, c_green, c_black);
KISMET.Draw.OutlinedText("Game Over", x, y, c_black, c_white, 2);
KISMET.Draw.CenteredText("Score: " + string(score), display_get_gui_width()/2, 50);

// World to UI conversion (for health bars above enemies)
var ui_pos = KISMET.WorldToUI(camera, enemy.x, enemy.y - 50);
draw_text(ui_pos[0], ui_pos[1], string(enemy.hp));
```

## Integration Guide

### Step-by-step setup:

1. Import the `KISMET` local package into your project.

2. **Initialize in Game Start event**:
```gml
KISMET_NAMESPACE_INIT();
global.KISMET_DEBUG = true; // Optional
```

3. **Set up input manager** in your persistent controller object:
```gml
// Create event
KISMET.InputManager.CreateAction("move_left").AddBinding(KISMET.InputBindingFromKey("A"));
KISMET.InputManager.CreateAction("move_right").AddBinding(KISMET.InputBindingFromKey("D"));

// Step event
KISMET.InputManager.Update();
```

4. **Add command processing** in your game loop:
```gml
// Process queued commands (call this after your input handling)
KISMET.DefaultCommandManager.Execute();
```

5. **Clean up on game end** (optional, but recommended):
```gml
// In Game End event
KISMET.Cleanup();
```

## Best Practices

### Memory Management
- Always use `ds_*_create_kismet()` instead of standard `ds_*_create()`
- Register cleanup for objects using `MemoryTracker.CleanupOwner(__kismet_id)`
- Take snapshots with `LeakDetector` during development to catch leaks

### Input Handling
- Create actions once, preferably in a persistent object's Create event
- Use `IsJustPressed()` for one-time actions (jump, attack)
- Use `IsPressed()` for continuous actions (movement)
- Call `InputManager.Update()` before checking input states

### Command System
- Use commands for game logic that needs to be queued or delayed
- Register inverse commands if you need undo functionality
- Group related commands into categories
- Use `CommandChain` for complex sequences

### Performance
- Pool frequently created/destroyed objects (bullets, particles)
- Use the profiler to identify bottlenecks
- Clean up unused ds_structures immediately
- Avoid creating many short-lived timers

## Known Limitations

1. **Audio Manager** - Commands exist but audio implementation is not provided (yet!)
2. **Networking** - Multiplayer commands are defined but not implemented
3. **Physics System** - Only flags exist
4. **Particle System** - Only flags exist
5. **UI Widgets** - No pre-built UI components (buttons, lists, etc.)

