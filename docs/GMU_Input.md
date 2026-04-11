# GMU_Input

A comprehensive input management system for GameMaker. This module provides action-based input handling with support for keyboard, mouse, gamepad, touch, chords, modifiers, and input buffering.

## Table of Contents

- [Overview](#overview)
- [Global Instance](#global-instance)
- [Enums](#enums)
  - [INPUT_DEVICE](#input_device)
  - [INPUT_TYPE](#input_type)
  - [INPUT_STATE](#input_state)
  - [MOUSE_BUTTON](#mouse_button)
  - [MOUSE_WHEEL](#mouse_wheel)
  - [GAMEPAD_BUTTON](#gamepad_button)
  - [GAMEPAD_AXIS](#gamepad_axis)
  - [GAMEPAD_TYPE](#gamepad_type)
  - [INPUT_MODIFIER](#input_modifier)
  - [BUFFERED_CALL](#buffered_call)
- [InputManager](#inputmanager)
  - [Creating Actions](#creating-actions)
  - [Binding Inputs](#binding-inputs)
  - [Querying Input](#querying-input)
  - [Gamepad Utilities](#gamepad-utilities)
  - [Input Buffering](#input-buffering)
- [Input (Simple Wrapper)](#input-simple-wrapper)
- [Complete Examples](#complete-examples)

---

## Overview

The InputManager uses an action-based system where you define named actions (like "Jump", "Move", "Attack") and bind them to various input sources. This decouples your game logic from specific input devices, making it easy to support multiple control schemes and remapping.

### Key Features

- **Action-based input** - Define what the player does, not how they do it
- **Multiple device support** - Keyboard, mouse, gamepad, and touch
- **Input chords** - Combine multiple inputs (e.g., Ctrl+C)
- **Modifier keys** - Shift, Ctrl, Alt support
- **Analog input** - Gamepad sticks and triggers with deadzone and curves
- **Input buffering** - Queue inputs for frame-perfect timing
- **Double-tap and long-press detection** - Built-in timing for advanced gestures
- **Mouse region checking** - Bind actions to specific screen areas

---

## Global Instance

A global `InputManager` instance is automatically created via the `GMU_NAMESPACES_INIT` macro:

```gml
globalvar InputManager;
InputManager = new InputManager();
```

---

## Enums

### INPUT_DEVICE

Specifies the source device for input.

```gml
enum INPUT_DEVICE {
    KEYBOARD,
    MOUSE,
    GAMEPAD_1,
    GAMEPAD_2,
    GAMEPAD_3,
    GAMEPAD_4,
    TOUCH,
    ANY
}
```

### INPUT_TYPE

Internal types used for binding identification.

```gml
enum INPUT_TYPE {
    KEY,
    MOUSE_BUTTON,
    GAMEPAD_BUTTON,
    GAMEPAD_AXIS,
    MOUSE_AXIS,
    TOUCH_POINT,
    MOUSE_WHEEL
}
```

### INPUT_STATE

States that can be queried for an action.

```gml
enum INPUT_STATE {
    JUST_PRESSED,
    PRESSED,
    JUST_RELEASED,
    RELEASED,
    DOUBLE_TAPPED,
    LONG_PRESSED
}
```

### MOUSE_BUTTON

Mouse button identifiers.

```gml
enum MOUSE_BUTTON {
    LEFT    = 0,
    RIGHT   = 1,
    MIDDLE  = 2,
    BACK    = 3,
    FORWARD = 4
}
```

### MOUSE_WHEEL

Mouse wheel directions.

```gml
enum MOUSE_WHEEL {
    UP,
    DOWN,
    LEFT,
    RIGHT
}
```

### GAMEPAD_BUTTON

Universal gamepad button constants. Platform-specific enums are also available.

```gml
enum GAMEPAD_BUTTON {
    // Face buttons
    FACE1 = 32769,   // Xbox A, PlayStation Cross
    FACE2 = 32770,   // Xbox B, PlayStation Circle
    FACE3 = 32771,   // Xbox X, PlayStation Square
    FACE4 = 32772,   // Xbox Y, PlayStation Triangle
    
    // Shoulder buttons
    SHOULDER_L  = 32773,   // LB / L1
    SHOULDER_R  = 32774,   // RB / R1
    SHOULDER_LB = 32775,   // LT / L2
    SHOULDER_RB = 32776,   // RT / R2
    
    // System buttons
    SELECT = 32777,   // Select / Back / Touchpad
    START  = 32778,   // Start / Options
    HOME   = 32799,   // Home / Guide / PS
    
    // Stick clicks
    STICK_L = 32779,   // Left stick click (L3)
    STICK_R = 32780,   // Right stick click (R3)
    
    // D-pad
    DPAD_UP    = 32781,
    DPAD_DOWN  = 32782,
    DPAD_LEFT  = 32783,
    DPAD_RIGHT = 32784,
    
    // Extra buttons
    TOUCHPAD = 32808,   // PS4/PS5 touchpad button
    PADDLE_L = 32805,   // Left paddle (Elite)
    PADDLE_R = 32804,   // Right paddle (Elite)
    PADDLE_LB = 32807,  // Left lower paddle
    PADDLE_RB = 32806   // Right lower paddle
}
```

#### Platform-Specific Button Enums

```gml
// Xbox naming
enum GAMEPAD_BUTTON_XBOX {
    A = GAMEPAD_BUTTON.FACE1,
    B = GAMEPAD_BUTTON.FACE2,
    X = GAMEPAD_BUTTON.FACE3,
    Y = GAMEPAD_BUTTON.FACE4,
    LB = GAMEPAD_BUTTON.SHOULDER_L,
    RB = GAMEPAD_BUTTON.SHOULDER_R,
    LT = GAMEPAD_BUTTON.SHOULDER_LB,
    RT = GAMEPAD_BUTTON.SHOULDER_RB
    // ... and more
}

// PlayStation naming
enum GAMEPAD_BUTTON_PS {
    CROSS    = GAMEPAD_BUTTON.FACE1,
    CIRCLE   = GAMEPAD_BUTTON.FACE2,
    SQUARE   = GAMEPAD_BUTTON.FACE3,
    TRIANGLE = GAMEPAD_BUTTON.FACE4,
    L1 = GAMEPAD_BUTTON.SHOULDER_L,
    R1 = GAMEPAD_BUTTON.SHOULDER_R,
    L2 = GAMEPAD_BUTTON.SHOULDER_LB,
    R2 = GAMEPAD_BUTTON.SHOULDER_RB
    // ... and more
}

// Nintendo Switch naming
enum GAMEPAD_BUTTON_SWITCH {
    B = GAMEPAD_BUTTON.FACE1,
    A = GAMEPAD_BUTTON.FACE2,
    Y = GAMEPAD_BUTTON.FACE3,
    X = GAMEPAD_BUTTON.FACE4,
    L  = GAMEPAD_BUTTON.SHOULDER_L,
    R  = GAMEPAD_BUTTON.SHOULDER_R,
    ZL = GAMEPAD_BUTTON.SHOULDER_LB,
    ZR = GAMEPAD_BUTTON.SHOULDER_RB
    // ... and more
}
```

### GAMEPAD_AXIS

Gamepad axis identifiers.

```gml
enum GAMEPAD_AXIS {
    LEFT_X  = 32785,   // Left stick horizontal
    LEFT_Y  = 32786,   // Left stick vertical
    RIGHT_X = 32787,   // Right stick horizontal
    RIGHT_Y = 32788,   // Right stick vertical
    
    // PlayStation motion sensors
    ACCELERATION_X = 32789,
    ACCELERATION_Y = 32790,
    ACCELERATION_Z = 32791,
    GYRO_X = 32792,
    GYRO_Y = 32793,
    GYRO_Z = 32794
}
```

### GAMEPAD_TYPE

Controller type detection.

```gml
enum GAMEPAD_TYPE {
    NONE,
    PLAYSTATION,
    XBOX,
    SWITCH
}
```

### INPUT_MODIFIER

Modifier key flags for keyboard combinations.

```gml
enum INPUT_MODIFIER {
    NONE  = 0,
    SHIFT = 1 << 0,
    CTRL  = 1 << 1,
    ALT   = 1 << 2,
    ANY   = 1 << 3
}
```

### BUFFERED_CALL

Flags for input buffering.

```gml
enum BUFFERED_CALL {
    NONE                  = 0,
    ACTION                = 1 << 0,
    ACTION_JUST_PRESSED   = 1 << 1,
    ACTION_JUST_RELEASED  = 1 << 2,
    ACTION_DOUBLE_TAPPED  = 1 << 3
}
```

---

## InputManager

### Creating Actions

#### CreateAction(name, methodAction, methodActionJustPressed, methodActionJustReleased)

Creates a new input action.

```gml
// Simple action (query manually)
InputManager.CreateAction("Jump");

// Action with callbacks
InputManager.CreateAction("Attack",
    function() {
        // Called while attack is pressed
        ChargeAttack();
    },
    function() {
        // Called when attack is first pressed
        StartAttack();
    },
    function() {
        // Called when attack is released
        ReleaseAttack();
    }
);
```

**Parameters:**
- `name` - Action identifier string
- `methodAction` - (Optional) Called each frame while action is pressed
- `methodActionJustPressed` - (Optional) Called when action is first pressed
- `methodActionJustReleased` - (Optional) Called when action is released

**Returns:** `ActionConfig` instance.

#### GetAction(name)

Gets an existing action configuration.

```gml
var action = InputManager.GetAction("Jump");
action.deadzone = 0.15;
action.curve_power = 1.5;
```

**Returns:** `ActionConfig` or `undefined`.

---

### ActionConfig Properties

Each action has configurable properties:

```gml
var action = InputManager.CreateAction("Move");

// Deadzone for analog sticks (0-1)
action.deadzone = 0.2;

// Input curve (1 = linear, 2 = quadratic, etc.)
action.curve_power = 1.5;

// Smoothing factor (0-1, higher = more smoothing)
action.smooth_factor = 0.85;

// Double-tap detection window (seconds)
action.double_tap_window = 0.3;

// Long-press detection time (seconds)
action.long_press_time = 0.5;
```

---

### Binding Inputs

#### BindKey(actionName, keyCode, device = INPUT_DEVICE.KEYBOARD)

Binds a keyboard key to an action.

```gml
InputManager.BindKey("Jump", vk_space);
InputManager.BindKey("MoveLeft", ord("A"));
InputManager.BindKey("MoveRight", ord("D"));
InputManager.BindKey("Attack", vk_control, INPUT_DEVICE.KEYBOARD, INPUT_MODIFIER.NONE);
```

**Returns:** `self` for chaining.

#### BindMouseButton(actionName, button, useRegion = false, rx = 0, ry = 0, rw = 0, rh = 0)

Binds a mouse button to an action.

```gml
// Simple binding
InputManager.BindMouseButton("Attack", MOUSE_BUTTON.LEFT);

// Region-specific binding
InputManager.BindMouseButton("ClickButton", MOUSE_BUTTON.LEFT, true, 100, 200, 150, 50);
```

**Returns:** `self` for chaining.

#### BindMouseWheel(actionName, direction, threshold = 1)

Binds mouse wheel scrolling to an action.

```gml
InputManager.BindMouseWheel("ZoomIn", MOUSE_WHEEL.UP, 1);
InputManager.BindMouseWheel("ZoomOut", MOUSE_WHEEL.DOWN, 1);
InputManager.BindMouseWheel("SwitchWeapon", MOUSE_WHEEL.UP, 2); // Requires 2 ticks
```

**Returns:** `self` for chaining.

#### BindGamepadButton(actionName, button, gamepad_id = 0)

Binds a gamepad button to an action.

```gml
InputManager.BindGamepadButton("Jump", GAMEPAD_BUTTON.FACE1);
InputManager.BindGamepadButton("Attack", GAMEPAD_BUTTON_PS.SQUARE);
InputManager.BindGamepadButton("Pause", GAMEPAD_BUTTON.START);
```

**Returns:** `self` for chaining.

#### BindGamepadAxis(actionName, axis, threshold = 0.5, positive_only = false, gamepad_id = 0)

Binds a gamepad axis to an action.

```gml
// Full axis (both directions)
InputManager.BindGamepadAxis("MoveHorizontal", GAMEPAD_AXIS.LEFT_X, 0.2);

// Positive only (e.g., trigger)
InputManager.BindGamepadAxis("Accelerate", GAMEPAD_AXIS_PS.R2, 0.1, true);
```

**Returns:** `self` for chaining.

---

### Advanced Bindings

#### Input Chords (Multiple Keys)

Create bindings that require multiple inputs simultaneously.

```gml
// Create individual bindings
var ctrl_binding = InputManager.InputBindingFromKey(vk_control);
var c_binding = InputManager.InputBindingFromKey(ord("C"));

// Create chord binding (all keys must be pressed)
var chord = InputManager.InputBindingFromChord([ctrl_binding, c_binding], "all");

// Add to action
var action = InputManager.GetAction("Copy");
action.AddBinding(chord);

// "any" mode - any key in the chord triggers the action
var any_chord = InputManager.InputBindingFromChord([ctrl_binding, c_binding], "any");
```

#### Modifier Keys

Add modifier requirements to any binding.

```gml
// Ctrl+S
var binding = InputManager.InputBindingFromKey(ord("S"), INPUT_DEVICE.KEYBOARD, INPUT_MODIFIER.CTRL);
InputManager.GetAction("Save").AddBinding(binding);

// Ctrl+Shift+S
var binding2 = InputManager.InputBindingFromKey(ord("S"), INPUT_DEVICE.KEYBOARD, INPUT_MODIFIER.CTRL | INPUT_MODIFIER.SHIFT);
InputManager.GetAction("SaveAs").AddBinding(binding2);
```

#### Mouse Region Binding

Bind actions to specific screen areas.

```gml
// Button at position (100, 200) with size 150x50
InputManager.BindMouseButton("Button1", MOUSE_BUTTON.LEFT, true, 100, 200, 150, 50);
```

---

### Querying Input

#### IsPressed(actionName)

Checks if an action is currently pressed (held down).

```gml
if (InputManager.IsPressed("MoveRight")) {
    x += move_speed;
}
```

**Returns:** `true` if pressed.

#### IsJustPressed(actionName)

Checks if an action was pressed this exact frame.

```gml
if (InputManager.IsJustPressed("Jump")) {
    vspeed = -jump_power;
}
```

**Returns:** `true` if just pressed.

#### IsJustReleased(actionName)

Checks if an action was released this exact frame.

```gml
if (InputManager.IsJustReleased("Attack")) {
    // Release charged attack
    FireChargedAttack();
}
```

**Returns:** `true` if just released.

#### GetValue(actionName)

Gets the analog value of an action (0-1).

```gml
var move_amount = InputManager.GetValue("MoveHorizontal");
x += move_amount * move_speed * facing_direction;
```

**Returns:** Float from 0.0 to 1.0.

#### GetVector(actionName)

Gets the 2D vector value from an analog stick.

```gml
var move = InputManager.GetVector("Move");
x += move.x * move_speed;
y += move.y * move_speed;
```

**Returns:** Struct with `x` and `y` properties.

#### GetMagnitude(actionName)

Gets the magnitude (length) of the analog vector.

```gml
var speed_multiplier = InputManager.GetMagnitude("Move");
anim_speed = base_speed * speed_multiplier;
```

**Returns:** Float from 0.0 to 1.0.

#### GetAngle(actionName)

Gets the angle (in radians) of the analog vector.

```gml
var angle = InputManager.GetAngle("Aim");
bullet_direction = angle;
```

**Returns:** Angle in radians.

#### IsDoubleTapped(actionName)

Checks if an action was double-tapped.

```gml
if (InputManager.IsDoubleTapped("MoveRight")) {
    // Perform dodge roll
    StartDodgeRoll();
}
```

**Returns:** `true` if double-tapped.

#### IsLongPressed(actionName)

Checks if an action has been held for the long-press duration.

```gml
if (InputManager.IsLongPressed("Interact")) {
    // Show detailed tooltip
    ShowExtendedInfo();
}
```

**Returns:** `true` if long-pressed.

---

### Gamepad Utilities

#### GetConnectedControllerType(gamepad_id = 0)

Detects the type of connected controller.

```gml
var type = InputManager.GetConnectedControllerType(0);
switch(type) {
    case GAMEPAD_TYPE.XBOX:
        // Show Xbox button prompts
        break;
    case GAMEPAD_TYPE.PLAYSTATION:
        // Show PlayStation button prompts
        break;
    case GAMEPAD_TYPE.SWITCH:
        // Show Switch button prompts
        break;
}
```

**Returns:** `GAMEPAD_TYPE` enum value.

#### GetPlatformButtonName(button, platform)

Gets a human-readable button name for a specific platform.

```gml
var button_name = InputManager.GetPlatformButtonName(GAMEPAD_BUTTON.FACE1, GAMEPAD_TYPE.XBOX);
// Returns "A"

var ps_name = InputManager.GetPlatformButtonName(GAMEPAD_BUTTON.FACE1, GAMEPAD_TYPE.PLAYSTATION);
// Returns "Cross"
```

**Returns:** String button name.

#### GamepadButtonToString(button)

Gets a generic description of a gamepad button.

```gml
var desc = InputManager.GamepadButtonToString(GAMEPAD_BUTTON.FACE1);
// Returns "FACE1 (A/Cross)"
```

**Returns:** String description.

#### GamepadAxisToString(axis)

Gets a description of a gamepad axis.

```gml
var desc = InputManager.GamepadAxisToString(GAMEPAD_AXIS.LEFT_X);
// Returns "LEFT_X (Left Stick Horizontal)"
```

**Returns:** String description.

---

### Input Buffering

Input buffering allows you to queue an input check for a future frame, useful for frame-perfect mechanics like fighting games.

#### BufferAction(name, flags)

Buffers an action for the next update.

```gml
// Buffer a regular press check
InputManager.BufferAction("Attack", BUFFERED_CALL.ACTION);

// Buffer a just-pressed check
InputManager.BufferAction("Jump", BUFFERED_CALL.ACTION_JUST_PRESSED);

// Buffer multiple checks
InputManager.BufferAction("Special", BUFFERED_CALL.ACTION_JUST_PRESSED | BUFFERED_CALL.ACTION_DOUBLE_TAPPED);
```

**Parameters:**
- `name` - Action name
- `flags` - `BUFFERED_CALL` flags indicating what to buffer

**Returns:** `self` for chaining.

---

### Update

The `Update()` method must be called each frame (typically in a controller object's Step event).

```gml
// In Step Event of obj_input_controller
InputManager.Update();
```

---

### Cleanup

```gml
// In Game End event
InputManager.Free();
```

---

## Input (Simple Wrapper)

A simplified input wrapper for basic key binding needs.

### Global Instance

```gml
globalvar Input;
Input = new Input();
```

### Methods

#### BindKey(key, action)

Binds a key to an action name.

```gml
Input.BindKey(vk_space, "Jump");
Input.BindKey(ord("W"), "MoveUp");
Input.BindKey(ord("S"), "MoveDown");
```

**Returns:** `self` for chaining.

#### IsPressed(action)

Checks if any key bound to the action is pressed.

```gml
if (Input.IsPressed("MoveUp")) {
    y -= 5;
}
```

**Returns:** `true` if pressed.

#### IsPressedOnce(action)

Checks if any key bound to the action was just pressed.

```gml
if (Input.IsPressedOnce("Jump")) {
    vspeed = -10;
}
```

**Returns:** `true` if just pressed.

#### Free()

Cleans up the input wrapper.

```gml
Input.Free();
```

---

## Complete Examples

### Example 1: Platformer Character Controller

```gml
// Create Event
// Define actions
InputManager.CreateAction("MoveLeft");
InputManager.CreateAction("MoveRight");
InputManager.CreateAction("Jump");
InputManager.CreateAction("Dash");
InputManager.CreateAction("Attack");

// Keyboard bindings
InputManager.BindKey("MoveLeft", ord("A"));
InputManager.BindKey("MoveLeft", vk_left);
InputManager.BindKey("MoveRight", ord("D"));
InputManager.BindKey("MoveRight", vk_right);
InputManager.BindKey("Jump", vk_space);
InputManager.BindKey("Dash", vk_shift);
InputManager.BindKey("Attack", ord("J"));

// Gamepad bindings
InputManager.BindGamepadButton("Jump", GAMEPAD_BUTTON.FACE1);
InputManager.BindGamepadButton("Dash", GAMEPAD_BUTTON.SHOULDER_L);
InputManager.BindGamepadButton("Attack", GAMEPAD_BUTTON.FACE3);
InputManager.BindGamepadAxis("MoveHorizontal", GAMEPAD_AXIS.LEFT_X, 0.2);

// Configure analog movement
var move_action = InputManager.GetAction("MoveHorizontal");
move_action.deadzone = 0.15;
move_action.curve_power = 1.2;

// Step Event
InputManager.Update();

// Movement
var move_left = InputManager.IsPressed("MoveLeft");
var move_right = InputManager.IsPressed("MoveRight");
var move_axis = InputManager.GetValue("MoveHorizontal");

// Combine keyboard and analog input
var move_input = 0;
if (move_right || move_axis > 0) move_input = max(1, move_axis);
if (move_left || move_axis < 0) move_input = min(-1, move_axis);

x += move_input * move_speed;

// Jump
if (InputManager.IsJustPressed("Jump") && on_ground) {
    vspeed = -jump_power;
}

// Dash (double-tap)
if (InputManager.IsDoubleTapped("MoveLeft") || InputManager.IsDoubleTapped("MoveRight")) {
    StartDash(move_input);
}

// Attack
if (InputManager.IsJustPressed("Attack")) {
    if (on_ground) {
        state = STATE_ATTACK_GROUND;
    } else {
        state = STATE_ATTACK_AIR;
    }
}
```

### Example 2: Menu Navigation

```gml
// Create Event
InputManager.CreateAction("MenuUp");
InputManager.CreateAction("MenuDown");
InputManager.CreateAction("MenuLeft");
InputManager.CreateAction("MenuRight");
InputManager.CreateAction("MenuConfirm");
InputManager.CreateAction("MenuBack");
InputManager.CreateAction("MenuTabLeft");
InputManager.CreateAction("MenuTabRight");

// Keyboard
InputManager.BindKey("MenuUp", vk_up);
InputManager.BindKey("MenuDown", vk_down);
InputManager.BindKey("MenuLeft", vk_left);
InputManager.BindKey("MenuRight", vk_right);
InputManager.BindKey("MenuConfirm", vk_enter);
InputManager.BindKey("MenuConfirm", vk_space);
InputManager.BindKey("MenuBack", vk_escape);
InputManager.BindKey("MenuTabLeft", ord("Q"));
InputManager.BindKey("MenuTabRight", ord("E"));

// Gamepad
InputManager.BindGamepadButton("MenuUp", GAMEPAD_BUTTON.DPAD_UP);
InputManager.BindGamepadButton("MenuDown", GAMEPAD_BUTTON.DPAD_DOWN);
InputManager.BindGamepadButton("MenuLeft", GAMEPAD_BUTTON.DPAD_LEFT);
InputManager.BindGamepadButton("MenuRight", GAMEPAD_BUTTON.DPAD_RIGHT);
InputManager.BindGamepadButton("MenuConfirm", GAMEPAD_BUTTON.FACE1);
InputManager.BindGamepadButton("MenuBack", GAMEPAD_BUTTON.FACE2);
InputManager.BindGamepadButton("MenuTabLeft", GAMEPAD_BUTTON.SHOULDER_L);
InputManager.BindGamepadButton("MenuTabRight", GAMEPAD_BUTTON.SHOULDER_R);

// Gamepad analog stick for menu navigation
InputManager.BindGamepadAxis("MenuVertical", GAMEPAD_AXIS.LEFT_Y, 0.5);
InputManager.BindGamepadAxis("MenuHorizontal", GAMEPAD_AXIS.LEFT_X, 0.5);

// Step Event
InputManager.Update();

// Navigation with cooldown
menu_cooldown--;
if (menu_cooldown <= 0) {
    var moved = false;
    
    if (InputManager.IsPressed("MenuUp") || InputManager.GetValue("MenuVertical") < -0.5) {
        selected_index--;
        moved = true;
    }
    if (InputManager.IsPressed("MenuDown") || InputManager.GetValue("MenuVertical") > 0.5) {
        selected_index++;
        moved = true;
    }
    
    if (moved) {
        menu_cooldown = 10;
        selected_index = clamp(selected_index, 0, menu_items - 1);
    }
}

// Tab switching (no cooldown needed)
if (InputManager.IsJustPressed("MenuTabLeft")) {
    current_tab--;
}
if (InputManager.IsJustPressed("MenuTabRight")) {
    current_tab++;
}

// Confirm
if (InputManager.IsJustPressed("MenuConfirm")) {
    ActivateMenuItem(selected_index);
}

// Back
if (InputManager.IsJustPressed("MenuBack")) {
    CloseMenu();
}
```

### Example 3: Input Buffering for Fighting Game

```gml
// Create Event
InputManager.CreateAction("Punch");
InputManager.CreateAction("Kick");
InputManager.CreateAction("Special");

InputManager.BindKey("Punch", ord("J"));
InputManager.BindKey("Kick", ord("K"));
InputManager.BindKey("Special", ord("L"));

InputManager.BindGamepadButton("Punch", GAMEPAD_BUTTON.FACE3);
InputManager.BindGamepadButton("Kick", GAMEPAD_BUTTON.FACE4);
InputManager.BindGamepadButton("Special", GAMEPAD_BUTTON.SHOULDER_R);

// Configure double-tap window for special moves
var special_action = InputManager.GetAction("Special");
special_action.double_tap_window = 0.2;

// Step Event - During attack animation
if (state == STATE_ATTACKING) {
    // Buffer next attack input
    if (InputManager.IsJustPressed("Punch")) {
        InputManager.BufferAction("Punch", BUFFERED_CALL.ACTION_JUST_PRESSED);
    }
    if (InputManager.IsJustPressed("Kick")) {
        InputManager.BufferAction("Kick", BUFFERED_CALL.ACTION_JUST_PRESSED);
    }
    if (InputManager.IsDoubleTapped("Special")) {
        InputManager.BufferAction("Special", BUFFERED_CALL.ACTION_DOUBLE_TAPPED);
    }
}

// After animation ends, check buffered inputs
if (animation_just_ended) {
    // The buffer will be processed automatically in the next Update()
    // Your action callbacks will fire if the input was buffered
}
```

### Example 4: Mouse Region UI Buttons

```gml
// Create Event
InputManager.CreateAction("PlayButton");
InputManager.CreateAction("OptionsButton");
InputManager.CreateAction("QuitButton");

// Bind to specific screen regions
InputManager.BindMouseButton("PlayButton", MOUSE_BUTTON.LEFT, true, 540, 300, 200, 50);
InputManager.BindMouseButton("OptionsButton", MOUSE_BUTTON.LEFT, true, 540, 370, 200, 50);
InputManager.BindMouseButton("QuitButton", MOUSE_BUTTON.LEFT, true, 540, 440, 200, 50);

// Step Event
InputManager.Update();

if (InputManager.IsJustPressed("PlayButton")) {
    StartGame();
}

if (InputManager.IsJustPressed("OptionsButton")) {
    OpenOptionsMenu();
}

if (InputManager.IsJustPressed("QuitButton")) {
    game_end();
}

// Draw Event - Visual feedback
draw_set_color(c_white);
if (InputManager.IsPressed("PlayButton")) {
    draw_set_color(c_yellow);
}
draw_rectangle(540, 300, 740, 350, false);
draw_text(640, 325, "Play");
```

### Example 5: Detecting Controller Type for UI Prompts

```gml
// Create Event
controller_type = GAMEPAD_TYPE.NONE;
prompt_sprites = ds_map_create();

// Load button prompt sprites
prompt_sprites[? "jump_xbox"] = spr_xbox_a;
prompt_sprites[? "jump_ps"] = spr_ps_cross;
prompt_sprites[? "jump_switch"] = spr_switch_b;

prompt_sprites[? "attack_xbox"] = spr_xbox_x;
prompt_sprites[? "attack_ps"] = spr_ps_square;
prompt_sprites[? "attack_switch"] = spr_switch_y;

// Step Event
InputManager.Update();

// Detect controller
var new_type = InputManager.GetConnectedControllerType(0);
if (new_type != controller_type) {
    controller_type = new_type;
    // Update UI prompts
    UpdateButtonPrompts();
}

// Draw Event - Show correct button prompt
function DrawJumpPrompt(x, y) {
    var sprite;
    switch(controller_type) {
        case GAMEPAD_TYPE.XBOX:
            sprite = prompt_sprites[? "jump_xbox"];
            break;
        case GAMEPAD_TYPE.PLAYSTATION:
            sprite = prompt_sprites[? "jump_ps"];
            break;
        case GAMEPAD_TYPE.SWITCH:
            sprite = prompt_sprites[? "jump_switch"];
            break;
        default:
            // Keyboard prompt
            draw_text(x, y, "[SPACE]");
            return;
    }
    draw_sprite(sprite, 0, x, y);
}
```
