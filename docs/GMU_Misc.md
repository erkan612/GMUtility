# GMU_Misc

Miscellaneous utilities and helper systems for GameMaker. This module provides timers, object pooling, save management, profiling, movement utilities, color and rect structs, plus various helper functions.

## Table of Contents

- [Overview](#overview)
- [Enums](#enums)
  - [MOVEMENT](#movement)
  - [ALIGNMENT](#alignment)
- [InterfaceAccess](#interfaceaccess)
- [SaveManager](#savemanager)
- [Timer System](#timer-system)
- [ObjectPool](#objectpool)
- [Profiler](#profiler)
- [Movement](#movement-utility)
- [Color Struct](#color-struct)
- [Rect Struct](#rect-struct)
- [Utility Functions](#utility-functions)
- [Complete Examples](#complete-examples)

---

## Overview

The GMU_Misc module provides a collection of independent utilities:

- **InterfaceAccess** - Dynamic registry for UI elements and systems
- **SaveManager** - Simple save/load with auto-save support
- **Timer** - Countdown timers with callbacks and looping
- **ObjectPool** - Efficient instance pooling for particles, bullets, etc.
- **Profiler** - Performance monitoring and reporting
- **Movement** - Smooth acceleration-based movement helper
- **Color** - RGBA color struct with hex conversion
- **Rect** - Rectangle struct with intersection testing

---

## Enums

### MOVEMENT

Direction constants for movement.

```gml
enum MOVEMENT {
    NONE  = 0,
    LEFT  = -1,
    RIGHT = 1,
    UP    = -1,
    DOWN  = 1
}
```

### ALIGNMENT

Alignment options for UI and text positioning.

```gml
enum ALIGNMENT {
    LEFT,
    CENTER,
    RIGHT,
    TOP,
    MIDDLE,
    BOTTOM,
    TOP_LEFT,
    TOP_CENTER,
    TOP_RIGHT,
    MIDDLE_LEFT,
    MIDDLE_CENTER,
    MIDDLE_RIGHT,
    BOTTOM_LEFT,
    BOTTOM_CENTER,
    BOTTOM_RIGHT,
    JUSTIFY,
    AUTO
}
```

---

## InterfaceAccess

A dynamic registry for storing and retrieving elements by name. Useful for UI systems, service locators, or any system needing named access to objects.

### Global Instance

```gml
globalvar InterfaceAccess;
InterfaceAccess = new InterfaceAccess();
```

### Methods

#### Add(name, element)

Adds an element to the registry.

```gml
InterfaceAccess.Add("main_menu", main_menu_instance);
InterfaceAccess.Add("hud", hud_controller);
InterfaceAccess.Add("player", obj_player);
InterfaceAccess.Add("config", game_config);
```

**Returns:** `self` for chaining.

---

#### Get(name)

Retrieves an element by name.

```gml
var hud = InterfaceAccess.Get("hud");
if (hud != undefined) {
    hud.ShowMessage("Hello World!");
}
```

**Returns:** The stored element or `undefined`.

---

#### Set(name, element)

Updates an existing element.

```gml
InterfaceAccess.Set("player", new_player_instance);
```

**Returns:** `self` for chaining.

---

#### Exists(name)

Checks if an element exists.

```gml
if (InterfaceAccess.Exists("pause_menu")) {
    var menu = InterfaceAccess.Get("pause_menu");
    menu.Close();
}
```

**Returns:** `true` if exists.

---

#### Remove(name)

Removes an element from the registry.

```gml
InterfaceAccess.Remove("old_ui");
```

**Returns:** `self` for chaining.

---

#### GetKeys()

Gets all registered element names.

```gml
var keys = InterfaceAccess.GetKeys();
for (var i = 0; i < array_length(keys); i++) {
    show_debug_message($"Registered: {keys[i]}");
}
```

**Returns:** Array of name strings.

---

#### Clear()

Clears all registered elements.

```gml
InterfaceAccess.Clear();
```

**Returns:** `self` for chaining.

---

#### Free()

Cleans up the registry.

```gml
InterfaceAccess.Free();
```

---

## SaveManager

A simple save/load system with auto-save support.

### Constructor

```gml
new SaveManager()
```

```gml
var save_manager = new SaveManager();
save_manager.slots = 10; // Number of save slots
```

### Methods

#### Save(slot, data, thumbnail = undefined)

Saves data to a slot.

```gml
var game_data = {
    player: {
        name: player_name,
        level: player_level,
        x: obj_player.x,
        y: obj_player.y
    },
    inventory: SerializeInventory(),
    progress: story_progress
};

var success = save_manager.Save(0, game_data);
if (success) {
    show_message("Game saved!");
}
```

**Parameters:**
- `slot` - Save slot index (0 to slots-1)
- `data` - Struct or array to save
- `thumbnail` - Optional thumbnail data

**Returns:** `true` on success, `false` on failure.

---

#### Load(slot)

Loads data from a slot.

```gml
var data = save_manager.Load(0);
if (data != undefined) {
    player_name = data.player.name;
    player_level = data.player.level;
    obj_player.x = data.player.x;
    obj_player.y = data.player.y;
    DeserializeInventory(data.inventory);
    story_progress = data.progress;
}
```

**Parameters:**
- `slot` - Save slot index

**Returns:** Loaded data or `undefined`.

---

#### Exists(slot)

Checks if a save slot exists.

```gml
if (save_manager.Exists(0)) {
    draw_text(x, y, "Slot 1: Saved Game");
} else {
    draw_text(x, y, "Slot 1: Empty");
}
```

**Returns:** `true` if save file exists.

---

#### Delete(slot)

Deletes a save slot.

```gml
if (save_manager.Delete(0)) {
    show_message("Save deleted");
}
```

**Returns:** `true` on success.

---

#### GetSaveList()

Gets information about all save slots.

```gml
var saves = save_manager.GetSaveList();
for (var i = 0; i < array_length(saves); i++) {
    var save = saves[i];
    show_debug_message($"Slot {save.slot}: {save.timestamp}");
}
```

**Returns:** Array of save info structs with `slot` and `timestamp`.

---

#### EnableAutoSave(interval_seconds = 300)

Enables automatic saving.

```gml
save_manager.EnableAutoSave(180); // Auto-save every 3 minutes
```

**Returns:** `self` for chaining.

---

#### DisableAutoSave()

Disables automatic saving.

```gml
save_manager.DisableAutoSave();
```

**Returns:** `self` for chaining.

---

#### UpdateAutoSave(delta, get_data_function)

Updates auto-save timer (call in Step event).

```gml
// In Step event
save_manager.UpdateAutoSave(1, function() {
    return {
        player: SerializePlayer(),
        timestamp: GetUnixDateTime(date_current_datetime())
    };
});
```

---

## Timer System

Simple countdown timers with callbacks.

### Constructor

```gml
new Timer(duration, onComplete, loop = false, onUpdate = undefined)
```

**Parameters:**
- `duration` - Timer duration in frames/seconds
- `onComplete` - Callback when timer finishes
- `loop` - Whether to restart after completion (default: false)
- `onUpdate` - Optional callback each update

```gml
var timer = new Timer(180, function(t) {
    show_message("3 minutes elapsed!");
}, false, function(t) {
    // Update UI with remaining time
    ui_timer_text = string(ceil(t.remaining / 60));
});
```

### Methods

#### Update(delta = 1)

Updates the timer (call each frame).

```gml
// In Step event
timer.Update();
timer.Update(0.5); // With delta time
```

**Returns:** `self` for chaining.

---

#### Reset()

Resets the timer to initial duration.

```gml
timer.Reset();
```

**Returns:** `self` for chaining.

---

#### Pause()

Pauses the timer.

```gml
timer.Pause();
```

**Returns:** `self` for chaining.

---

#### Resume()

Resumes the timer.

```gml
timer.Resume();
```

**Returns:** `self` for chaining.

---

#### Stop()

Stops the timer completely.

```gml
timer.Stop();
```

**Returns:** `self` for chaining.

---

#### Properties

```gml
timer.duration   // Total duration
timer.remaining  // Time remaining
timer.active     // Is timer active
timer.paused     // Is timer paused
timer.loop       // Does timer loop
```

---

## ObjectPool

Efficient instance pooling for frequently created/destroyed objects.

### Constructor

```gml
new ObjectPool(objectName, size, layer = "Instances")
```

**Parameters:**
- `objectName` - Object asset to pool
- `size` - Initial pool size
- `layer` - Instance layer name (default: "Instances")

```gml
var bullet_pool = new ObjectPool(obj_bullet, 50);
var particle_pool = new ObjectPool(obj_particle, 100, "Effects");
var enemy_pool = new ObjectPool(obj_enemy, 20, "Enemies");
```

### Methods

#### Get(x, y, activate = true)

Gets an instance from the pool.

```gml
// Get and activate at position
var bullet = bullet_pool.Get(x, y);

// Get without activating
var enemy = enemy_pool.Get(spawn_x, spawn_y, false);
enemy.hp = 100;
instance_activate_object(enemy);
```

**Parameters:**
- `x, y` - Spawn position
- `activate` - Whether to activate immediately (default: true)

**Returns:** Instance ID.

---

#### Return(inst)

Returns an instance to the pool.

```gml
bullet_pool.Return(bullet);
```

**Returns:** `self` for chaining.

---

#### Free()

Destroys all pooled instances and cleans up.

```gml
bullet_pool.Free();
```

---

## Profiler

Performance monitoring and reporting tool.

### Constructor

```gml
new Profiler()
```

```gml
var profiler = new Profiler();
profiler.SetEnabled(true);
```

### Methods

#### Begin(name)

Starts timing a section.

```gml
profiler.Begin("Physics");
// ... physics code ...
profiler.End();

profiler.Begin("AI_Update");
// ... AI code ...
profiler.End();

profiler.Begin("Render");
// ... render code ...
profiler.End();
```

**Returns:** `self` for chaining.

---

#### End()

Ends the current timing section.

```gml
profiler.End();
```

**Returns:** `self` for chaining.

---

#### GetData()

Gets raw profiling data.

```gml
var data = profiler.GetData();
var physics_time = data[$ "Physics"].total_ms;
show_debug_message($"Physics: {physics_time}ms");
```

**Returns:** Struct with timing data per marker.

---

#### GetReport()

Gets a formatted performance report.

```gml
var report = profiler.GetReport();
show_debug_message(report);
// Output:
// === Performance Profile ===
// AI_Update: 15.2ms (45%) - Avg: 0.25ms, Calls: 60
// Physics: 10.1ms (30%) - Avg: 0.17ms, Calls: 60
// Render: 8.4ms (25%) - Avg: 0.14ms, Calls: 60
```

**Returns:** Formatted string report.

---

#### Reset()

Resets all profiling data.

```gml
profiler.Reset();
```

**Returns:** `self` for chaining.

---

#### SetEnabled(enabled)

Enables or disables profiling.

```gml
profiler.SetEnabled(false); // Disable for release builds
```

**Returns:** `self` for chaining.

---

#### Free()

Cleans up the profiler.

```gml
profiler.Free();
```

---

## Movement Utility

Smooth acceleration-based movement helper.

### Constructor

```gml
new Movement(speed = 5, accel = 0, damping = 0)
```

**Parameters:**
- `speed` - Maximum speed (default: 5)
- `accel` - Acceleration rate (default: 0 for instant)
- `damping` - Damping when no input (default: 0)

```gml
var mover = new Movement(8, 0.5, 0.2);
```

### Methods

#### Update(object)

Updates movement and applies to object.

```gml
// Set input direction
mover.h = keyboard_check(vk_right) - keyboard_check(vk_left);
mover.v = keyboard_check(vk_down) - keyboard_check(vk_up);

// Apply to object
mover.Update(self);
```

**Returns:** `self` for chaining.

---

#### Properties

```gml
mover.h       // Horizontal input (-1 to 1)
mover.v       // Vertical input (-1 to 1)
mover.speed   // Maximum speed
mover.accel   // Acceleration rate
mover.damping // Damping rate
mover.vel_x   // Current X velocity
mover.vel_y   // Current Y velocity
```

---

## Color Struct

RGBA color utility with hex conversion.

### Constructor

```gml
new Color(r = 0, g = 0, b = 0, a = 1)
```

```gml
var red = new Color(1, 0, 0);
var blue = new Color(0, 0, 1, 0.5);
var custom = new Color(0.5, 0.2, 0.8);
```

### Static Methods

#### Color.FromHex(hex)

Creates a Color from a hex string.

```gml
var color = Color.FromHex("#FF5733");
var color2 = Color.FromHex("3366FF");
var with_alpha = Color.FromHex("#FF5733CC");
```

**Returns:** Color instance.

---

#### Color.FromArray(arr)

Creates a Color from an array [r, g, b, a].

```gml
var color = Color.FromArray([1, 0.5, 0, 1]);
```

**Returns:** Color instance.

---

#### Color.White()

Returns white color.

```gml
var white = Color.White();
```

#### Color.Black()

Returns black color.

```gml
var black = Color.Black();
```

#### Color.Red() / Green() / Blue()

Returns primary colors.

```gml
var red = Color.Red();
var green = Color.Green();
var blue = Color.Blue();
```

#### Color.Yellow() / Magenta() / Cyan()

Returns secondary colors.

```gml
var yellow = Color.Yellow();
var magenta = Color.Magenta();
var cyan = Color.Cyan();
```

### Instance Methods

#### ToHex(includeAlpha = false)

Converts to hex string.

```gml
var hex = color.ToHex();      // "#FF5733"
var hexa = color.ToHex(true); // "#FF5733CC"
```

**Returns:** Hex color string.

---

#### ToArray()

Converts to array [r, g, b, a].

```gml
var arr = color.ToArray();
var r = arr[0];
```

**Returns:** Array of color components.

---

## Rect Struct

Rectangle utility with intersection testing.

### Constructor

```gml
new Rect(x = 0, y = 0, w = 0, h = 0)
```

```gml
var rect = new Rect(100, 100, 200, 100);
var bounds = new Rect(0, 0, room_width, room_height);
```

### Methods

#### Contains(px, py)

Checks if a point is inside the rectangle.

```gml
if (rect.Contains(mouse_x, mouse_y)) {
    // Mouse is over the rectangle
}
```

**Returns:** `true` if point is inside.

---

#### Intersects(other)

Checks if two rectangles intersect.

```gml
var rect1 = new Rect(0, 0, 100, 100);
var rect2 = new Rect(50, 50, 100, 100);
if (rect1.Intersects(rect2)) {
    // Rectangles overlap
}
```

**Returns:** `true` if rectangles intersect.

---

#### Expand(amt)

Expands the rectangle by an amount in all directions.

```gml
rect.Expand(10); // Grows by 10 pixels on all sides
```

**Returns:** `self` for chaining.

---

#### Clone()

Creates a copy of the rectangle.

```gml
var copy = rect.Clone();
```

**Returns:** New Rect instance.

---

## Utility Functions

### ExecuteSafe(fn, data = undefined, fallback = undefined)

Safely executes a function with try-catch.

```gml
ExecuteSafe(function(data) {
    // Potentially risky code
    var result = SomeUnreliableFunction(data);
}, { value: 42 }, function() {
    // Fallback if error occurs
    return default_value;
});
```

**Parameters:**
- `fn` - Function to execute
- `data` - Optional data to pass
- `fallback` - Optional fallback function

**Returns:** Function result or fallback value.

---

### GetUnixDateTime(dateTarget)

Gets Unix timestamp from a GameMaker datetime.

```gml
var now = date_current_datetime();
var timestamp = GetUnixDateTime(now);
show_debug_message($"Unix time: {timestamp}");
```

**Returns:** Unix timestamp integer.

---

### ds_queue_to_array(queue)

Converts a ds_queue to an array without destroying the queue.

```gml
var my_queue = ds_queue_create();
ds_queue_enqueue(my_queue, "first");
ds_queue_enqueue(my_queue, "second");
ds_queue_enqueue(my_queue, "third");

var arr = ds_queue_to_array(my_queue);
// arr = ["first", "second", "third"]
// my_queue is unchanged
```

**Returns:** Array of queue contents.

---

## Complete Examples

### Example 1: Object Pooling for Bullets

```gml
// Create Event - Bullet Manager
bullet_pool = new ObjectPool(obj_bullet, 100, "Projectiles");

function SpawnBullet(x, y, direction, speed, damage) {
    var bullet = bullet_pool.Get(x, y);
    
    with (bullet) {
        dir = direction;
        spd = speed;
        dmg = damage;
        life_timer = 120;
    }
    
    return bullet;
}

// In obj_bullet Step Event
life_timer--;
if (life_timer <= 0 || place_meeting(x, y, obj_wall)) {
    bullet_pool.Return(self);
}

// Cleanup on room end
bullet_pool.Free();
```

### Example 2: Save System with Auto-Save

```gml
// Create Event
save_manager = new SaveManager();
save_manager.EnableAutoSave(300); // 5 minutes

function CollectSaveData() {
    return {
        version: "1.2",
        player: {
            name: global.player_name,
            level: global.player_level,
            hp: obj_player.hp,
            max_hp: obj_player.max_hp,
            x: obj_player.x,
            y: obj_player.y
        },
        inventory: SerializeInventory(),
        flags: global.story_flags.Get(),
        timestamp: GetUnixDateTime(date_current_datetime())
    };
}

// Step Event
save_manager.UpdateAutoSave(1, CollectSaveData);

// Manual save
if (InputManager.IsJustPressed("QuickSave")) {
    if (save_manager.Save(0, CollectSaveData())) {
        ShowNotification("Game Saved");
    }
}

// Manual load
if (InputManager.IsJustPressed("QuickLoad")) {
    var data = save_manager.Load(0);
    if (data != undefined) {
        ApplySaveData(data);
        ShowNotification("Game Loaded");
    }
}
```

### Example 3: Profiling Game Performance

```gml
// Create Event
profiler = new Profiler();
profiler.SetEnabled(true);

// Step Event
profiler.Begin("Total Frame");

profiler.Begin("Input");
InputManager.Update();
profiler.End();

profiler.Begin("Player Update");
with (obj_player) {
    event_user(0); // Custom update
}
profiler.End();

profiler.Begin("Enemy AI");
with (obj_enemy) {
    UpdateAI();
}
profiler.End();

profiler.Begin("Physics");
ProcessCollisions();
profiler.End();

profiler.Begin("Camera");
camera.Update();
profiler.End();

profiler.End(); // Total Frame

// F12 to print report
if (keyboard_check_pressed(vk_f12)) {
    show_debug_message(profiler.GetReport());
}

// Draw profiler overlay
if (keyboard_check(vk_f11)) {
    var data = profiler.GetData();
    var y = 10;
    var keys = variable_struct_get_names(data);
    
    draw_set_color(c_black);
    draw_rectangle(5, 5, 300, 10 + array_length(keys) * 15, false);
    
    draw_set_color(c_white);
    for (var i = 0; i < array_length(keys); i++) {
        var d = data[$ keys[i]];
        draw_text(10, y, $"{keys[i]}: {string_format(d.total_ms, 1, 2)}ms");
        y += 15;
    }
}
```

### Example 4: Color and Rect Utilities

```gml
// Create Event
var primary_color = Color.FromHex("#4A90E2");
var accent_color = Color.FromHex("#F5A623");
var danger_color = Color.Red();

// Using colors
function DrawColoredButton(rect, color, text) {
    // Draw background
    var col_arr = color.ToArray();
    draw_set_color(make_color_rgb(
        col_arr[0] * 255,
        col_arr[1] * 255,
        col_arr[2] * 255
    ));
    draw_rectangle(rect.x, rect.y, rect.x + rect.w, rect.y + rect.h, false);
    
    // Draw border (darker version)
    draw_set_color(make_color_rgb(
        col_arr[0] * 180,
        col_arr[1] * 180,
        col_arr[2] * 180
    ));
    draw_rectangle(rect.x, rect.y, rect.x + rect.w, rect.y + rect.h, true);
    
    // Draw text
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(rect.x + rect.w / 2, rect.y + rect.h / 2, text);
}

// Rect intersection for UI
var button_rect = new Rect(100, 200, 150, 50);
var mouse_rect = new Rect(mouse_x, mouse_y, 1, 1);

if (button_rect.Intersects(mouse_rect)) {
    // Mouse is over button
    DrawColoredButton(button_rect.Clone().Expand(2), accent_color, "Hover");
    
    if (mouse_check_button_pressed(mb_left)) {
        // Button clicked
        show_message("Clicked!");
    }
} else {
    DrawColoredButton(button_rect, primary_color, "Normal");
}
```

### Example 5: Timer-Based Gameplay

```gml
// Create Event
round_timer = new Timer(180, function(t) {
    // Round ended
    EndRound();
}, false, function(t) {
    // Update UI each frame
    ui_time_text = string(ceil(t.remaining / 60));
    
    // Warning when low
    if (t.remaining < 30) {
        ui_time_color = c_red;
    }
});

ability_cooldown = new Timer(60, function(t) {
    can_use_ability = true;
    ui_ability_ready = true;
}, false);

// Step Event
round_timer.Update();
ability_cooldown.Update();

// Start round
function StartRound() {
    round_timer.Reset();
    round_timer.active = true;
}

// Use ability
function UseAbility() {
    if (!can_use_ability) return false;
    
    can_use_ability = false;
    ui_ability_ready = false;
    ability_cooldown.Reset();
    
    // Perform ability
    PerformSpecialAttack();
    
    return true;
}

// Pause menu
function PauseGame() {
    round_timer.Pause();
    ability_cooldown.Pause();
}

function ResumeGame() {
    round_timer.Resume();
    ability_cooldown.Resume();
}
```

### Example 6: Movement with Acceleration

```gml
// Create Event - Player
mover = new Movement(5, 0.4, 0.15);

// Step Event
// Get input
mover.h = InputManager.GetVector("Move").x;
mover.v = InputManager.GetVector("Move").y;

// Apply movement
mover.Update(self);

// Use velocity for animation
if (abs(mover.vel_x) > 0.1 || abs(mover.vel_y) > 0.1) {
    var speed = sqrt(mover.vel_x * mover.vel_x + mover.vel_y * mover.vel_y);
    var speed_ratio = speed / mover.speed;
    
    if (speed_ratio > 0.7) {
        anim_pack.Set("run");
    } else {
        anim_pack.Set("walk");
    }
    
    // Face movement direction
    if (abs(mover.vel_x) > 0.1) {
        image_xscale = sign(mover.vel_x);
    }
} else {
    anim_pack.Set("idle");
}

// Dash ability (temporary speed boost)
function Dash() {
    mover.speed = 12;
    alarm[0] = 15; // Dash duration
}

// Alarm 0 - End dash
mover.speed = 5;
```

### Example 7: InterfaceAccess for UI Management

```gml
// Register UI elements on creation
InterfaceAccess.Add("hud", self);
InterfaceAccess.Add("inventory", obj_inventory);
InterfaceAccess.Add("quest_log", obj_quest_journal);
InterfaceAccess.Add("dialogue_box", obj_dialogue);

// Access from anywhere
function ShowMessage(text) {
    var dialogue = InterfaceAccess.Get("dialogue_box");
    if (dialogue != undefined) {
        dialogue.Show(text);
    }
}

function UpdateHealthBar(value, max_value) {
    var hud = InterfaceAccess.Get("hud");
    if (hud != undefined) {
        hud.SetHealth(value, max_value);
    }
}

function ToggleInventory() {
    var inventory = InterfaceAccess.Get("inventory");
    if (inventory != undefined) {
        inventory.Toggle();
    }
}

// Check if UI elements exist before using
function SafeUICall(element_name, method, args = []) {
    if (InterfaceAccess.Exists(element_name)) {
        var element = InterfaceAccess.Get(element_name);
        var fn = variable_instance_get(element, method);
        if (is_method(fn)) {
            return fn(element, args);
        }
    }
    return undefined;
}

// Usage
SafeUICall("quest_log", "AddQuest", ["The Journey Begins"]);
SafeUICall("hud", "ShowObjective", ["Find the ancient artifact"]);
```
