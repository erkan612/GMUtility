# GMU_State

State management utilities for GameMaker. This module provides a flexible state machine and various patrol/flag systems for tracking object states, modes, and flags.

## Table of Contents

- [StateMachine](#statemachine)
- [Patrol](#patrol)
- [FlagPatrol](#flagpatrol)
- [ModePatrol](#modepatrol)
- [StatePatrol](#statepatrol)

---

## StateMachine

A full-featured state machine with enter, update, and exit callbacks for each state.

### Constructor

```gml
new StateMachine(initial_state)
```

**Parameters:**
- `initial_state` - The starting state name

```gml
var sm = new StateMachine("idle");
```

### Methods

#### AddState(name, on_enter, on_update, on_exit)

Adds a new state to the machine.

```gml
sm.AddState("idle",
    function(data) {
        // On enter
        sprite_index = spr_player_idle;
        image_speed = 0.2;
    },
    function(delta) {
        // On update (called each frame)
        if (InputManager.IsPressed("Move")) {
            sm.ChangeTo("walk");
        }
        if (InputManager.IsJustPressed("Jump")) {
            sm.ChangeTo("jump");
        }
    },
    function(data) {
        // On exit
        image_index = 0;
    }
);

sm.AddState("walk",
    function(data) {
        sprite_index = spr_player_walk;
    },
    function(delta) {
        // Movement logic
        if (!InputManager.IsPressed("Move")) {
            sm.ChangeTo("idle");
        }
    },
    undefined // No exit callback
);

sm.AddState("jump",
    function(data) {
        sprite_index = spr_player_jump;
        vspeed = -10;
    },
    function(delta) {
        // Jump physics
        if (place_meeting(x, y+1, obj_ground)) {
            sm.ChangeTo("idle");
        }
    },
    undefined
);
```

**Parameters:**
- `name` - State identifier string
- `on_enter` - Function called when entering state `function(data)`
- `on_update` - Function called each frame `function(delta)`
- `on_exit` - Function called when exiting state `function(data)`

**Returns:** `self` for chaining.

---

#### ChangeTo(new_state, data = undefined)

Transitions to a new state.

```gml
// Simple transition
sm.ChangeTo("walk");

// Transition with data
sm.ChangeTo("damaged", { damage: 25, source: enemy });
```

**Parameters:**
- `new_state` - Target state name
- `data` - Optional data passed to exit and enter callbacks

**Returns:** `self` for chaining.

---

#### Update(delta = 1/60)

Updates the current state (calls its on_update callback).

```gml
// In Step Event
sm.Update();

// With custom delta time
sm.Update(delta_time);
```

**Returns:** `self` for chaining.

---

#### Serialize()

Exports the state machine's current state as a struct.

```gml
var save_data = sm.Serialize();
// save_data = { current: "walk", previous: "idle", state_names: ["idle", "walk", "jump"] }
```

**Returns:** Struct with `current`, `previous`, and `state_names`.

---

#### Deserialize(data)

Restores the state machine from serialized data.

```gml
sm.Deserialize(save_data);
```

**Returns:** `self` for chaining.

---

#### Visualize()

Prints the current state information to the debug console.

```gml
sm.Visualize();
// Output:
// === State Machine ===
// Current: walk
// Previous: idle
// Registered states: ["idle","walk","jump"]
```

**Returns:** `self` for chaining.

---

#### Free()

Cleans up the state machine's internal data structures.

```gml
sm.Free();
```

---

#### Properties

- `current` - Current state name
- `previous` - Previous state name
- `changed` - Boolean indicating if state changed this frame
- `states` - Internal ds_map of state definitions

```gml
// Check current state
if (sm.current == "idle") {
    // Do something
}

// Check if state just changed
if (sm.changed) {
    show_debug_message($"State changed from {sm.previous} to {sm.current}");
}
```

---

### Complete StateMachine Example

```gml
// Create Event
state_machine = new StateMachine("idle");

state_machine.AddState("idle",
    function() {
        image_speed = 0.1;
    },
    function(dt) {
        if (keyboard_check(vk_left) || keyboard_check(vk_right)) {
            state_machine.ChangeTo("walk");
        }
        if (keyboard_check_pressed(vk_space)) {
            state_machine.ChangeTo("jump");
        }
    },
    undefined
);

state_machine.AddState("walk",
    function() {
        image_speed = 0.2;
    },
    function(dt) {
        var move = keyboard_check(vk_right) - keyboard_check(vk_left);
        x += move * 4;
        
        if (move == 0) {
            state_machine.ChangeTo("idle");
        }
        if (keyboard_check_pressed(vk_space)) {
            state_machine.ChangeTo("jump");
        }
    },
    undefined
);

state_machine.AddState("jump",
    function() {
        vspeed = -8;
        image_index = 2;
    },
    function(dt) {
        // Gravity
        vspeed += 0.5;
        
        // Horizontal movement in air
        var move = keyboard_check(vk_right) - keyboard_check(vk_left);
        x += move * 3;
        
        // Landed
        if (vspeed >= 0 && place_meeting(x, y+1, obj_ground)) {
            state_machine.ChangeTo("idle");
        }
    },
    undefined
);

// Step Event
state_machine.Update();
```

---

## Patrol

A simple state and flag tracker combined into one lightweight struct. Useful for basic enemy AI states.

### Constructor

```gml
new Patrol(initialState = -1)
```

**Parameters:**
- `initialState` - Starting state value (default: -1)

```gml
var patrol = new Patrol();
var enemy_patrol = new Patrol(STATE_IDLE);
```

### Methods

#### SetState(newState)

Sets the current state.

```gml
patrol.SetState(STATE_CHASING);
```

**Returns:** `self` for chaining.

#### GetState()

Gets the current state.

```gml
var current = patrol.GetState();
```

**Returns:** Current state value.

#### PrevState()

Gets the previous state.

```gml
var previous = patrol.PrevState();
```

**Returns:** Previous state value.

#### IsState(target)

Checks if current state matches target.

```gml
if (patrol.IsState(STATE_IDLE)) {
    // Do idle behavior
}
```

**Returns:** `true` if current state equals target.

#### ChangedState()

Checks if state changed this frame.

```gml
if (patrol.ChangedState()) {
    show_debug_message("State just changed!");
}
```

**Returns:** `true` if state changed from previous frame.

#### ClearState()

Resets state to -1.

```gml
patrol.ClearState();
```

**Returns:** `self` for chaining.

#### AddFlag(flag1, flag2, ...)

Adds one or more flags using bitwise OR.

```gml
patrol.AddFlag(FLAG_GROUNDED, FLAG_CAN_ATTACK);
```

**Returns:** `self` for chaining.

#### RemoveFlag(flag1, flag2, ...)

Removes one or more flags using bitwise AND with complement.

```gml
patrol.RemoveFlag(FLAG_CAN_ATTACK);
```

**Returns:** `self` for chaining.

#### ToggleFlag(flag1, flag2, ...)

Toggles one or more flags using bitwise XOR.

```gml
patrol.ToggleFlag(FLAG_INVINCIBLE);
```

**Returns:** `self` for chaining.

#### HasFlag(flag)

Checks if a specific flag is set.

```gml
if (patrol.HasFlag(FLAG_GROUNDED)) {
    // Can jump
}
```

**Returns:** `true` if flag is set.

#### ClearFlags()

Clears all flags.

```gml
patrol.ClearFlags();
```

**Returns:** `self` for chaining.

#### GetFlags()

Gets the raw flags value.

```gml
var flags = patrol.GetFlags();
```

**Returns:** Raw flags integer.

#### SetFlags(value)

Sets the raw flags value.

```gml
patrol.SetFlags(FLAG_GROUNDED | FLAG_MOVING);
```

**Returns:** `self` for chaining.

---

### Patrol Example

```gml
// Define state constants
enum ENEMY_STATE {
    IDLE,
    PATROL,
    ALERT,
    CHASING,
    ATTACKING,
    RETREATING,
    DEAD
}

// Define flag constants (must be powers of 2)
enum ENEMY_FLAG {
    CAN_SEE_PLAYER = 1 << 0,
    PLAYER_IN_RANGE = 1 << 1,
    GROUNDED       = 1 << 2,
    CAN_ATTACK     = 1 << 3,
    INVINCIBLE     = 1 << 4
}

// Create Event
enemy_ai = new Patrol(ENEMY_STATE.IDLE);

// Step Event
var can_see = distance_to_object(obj_player) < 200;
var in_range = distance_to_object(obj_player) < 50;
var on_ground = place_meeting(x, y+1, obj_ground);

// Update flags
if (can_see) enemy_ai.AddFlag(ENEMY_FLAG.CAN_SEE_PLAYER);
else enemy_ai.RemoveFlag(ENEMY_FLAG.CAN_SEE_PLAYER);

if (in_range) enemy_ai.AddFlag(ENEMY_FLAG.PLAYER_IN_RANGE);
else enemy_ai.RemoveFlag(ENEMY_FLAG.PLAYER_IN_RANGE);

if (on_ground) enemy_ai.AddFlag(ENEMY_FLAG.GROUNDED);
else enemy_ai.RemoveFlag(ENEMY_FLAG.GROUNDED);

// State logic
switch(enemy_ai.GetState()) {
    case ENEMY_STATE.IDLE:
        if (enemy_ai.HasFlag(ENEMY_FLAG.CAN_SEE_PLAYER)) {
            enemy_ai.SetState(ENEMY_STATE.ALERT);
        }
        break;
        
    case ENEMY_STATE.ALERT:
        // Look at player
        if (enemy_ai.HasFlag(ENEMY_FLAG.PLAYER_IN_RANGE)) {
            enemy_ai.SetState(ENEMY_STATE.ATTACKING);
        } else if (distance_to_object(obj_player) > 300) {
            enemy_ai.SetState(ENEMY_STATE.IDLE);
        }
        break;
        
    case ENEMY_STATE.ATTACKING:
        if (enemy_ai.HasFlag(ENEMY_FLAG.CAN_ATTACK)) {
            // Perform attack
            enemy_ai.AddFlag(ENEMY_FLAG.CAN_ATTACK, false);
        }
        if (!enemy_ai.HasFlag(ENEMY_FLAG.PLAYER_IN_RANGE)) {
            enemy_ai.SetState(ENEMY_STATE.CHASING);
        }
        break;
}

// Check for state changes
if (enemy_ai.ChangedState()) {
    show_debug_message($"Enemy state: {enemy_ai.PrevState()} -> {enemy_ai.GetState()}");
}
```

---

## FlagPatrol

A dedicated flag tracker without state management. Useful when you only need to track multiple boolean conditions.

### Constructor

```gml
new FlagPatrol()
```

```gml
var flags = new FlagPatrol();
```

### Methods

#### Add(flag1, flag2, ...)

Adds one or more flags.

```gml
flags.Add(FLAG_POISONED, FLAG_SLOWED);
```

**Returns:** `self` for chaining.

#### Remove(flag1, flag2, ...)

Removes one or more flags.

```gml
flags.Remove(FLAG_POISONED);
```

**Returns:** `self` for chaining.

#### Toggle(flag1, flag2, ...)

Toggles one or more flags.

```gml
flags.Toggle(FLAG_INVISIBLE);
```

**Returns:** `self` for chaining.

#### Has(flag)

Checks if a flag is set.

```gml
if (flags.Has(FLAG_STUNNED)) {
    // Can't move
}
```

**Returns:** `true` if flag is set.

#### Clear()

Clears all flags.

```gml
flags.Clear();
```

**Returns:** `self` for chaining.

#### Get()

Gets the raw flags value.

```gml
var raw = flags.Get();
```

**Returns:** Raw flags integer.

#### Set(value)

Sets the raw flags value.

```gml
flags.Set(FLAG_GROUNDED | FLAG_WALL_SLIDING);
```

**Returns:** `self` for chaining.

---

### FlagPatrol Example

```gml
// Define status effect flags
enum STATUS_EFFECT {
    NONE      = 0,
    POISONED  = 1 << 0,
    SLOWED    = 1 << 1,
    STUNNED   = 1 << 2,
    BURNING   = 1 << 3,
    FROZEN    = 1 << 4,
    INVISIBLE = 1 << 5,
    INVINCIBLE = 1 << 6
}

// Create Event
status_effects = new FlagPatrol();

// Apply effects
function ApplyPoison() {
    status_effects.Add(STATUS_EFFECT.POISONED);
    poison_timer = 180;
}

function ApplyStun(duration) {
    status_effects.Add(STATUS_EFFECT.STUNNED);
    stun_timer = duration;
}

// Step Event - Process effects
if (status_effects.Has(STATUS_EFFECT.STUNNED)) {
    // Can't act
    return;
}

if (status_effects.Has(STATUS_EFFECT.POISONED)) {
    hp -= 1;
    poison_timer--;
    if (poison_timer <= 0) {
        status_effects.Remove(STATUS_EFFECT.POISONED);
    }
}

if (status_effects.Has(STATUS_EFFECT.SLOWED)) {
    move_speed = base_speed * 0.5;
} else {
    move_speed = base_speed;
}

// Check multiple flags
if (status_effects.Has(STATUS_EFFECT.POISONED) && 
    status_effects.Has(STATUS_EFFECT.BURNING)) {
    // Take extra damage from combo
    hp -= 2;
}
```

---

## ModePatrol

A hierarchical state and flag system. Each mode (state) has its own independent set of flags.

### Constructor

```gml
new ModePatrol()
```

```gml
var mode_patrol = new ModePatrol();
```

### Methods

#### AddState(name)

Adds a new mode/state with its own flag tracker.

```gml
mode_patrol.AddState("combat");
mode_patrol.AddState("exploration");
mode_patrol.AddState("dialogue");
```

**Returns:** `self` for chaining.

#### SetState(name)

Sets the current mode.

```gml
mode_patrol.SetState("combat");
```

**Returns:** `self` for chaining.

#### GetState()

Gets the current mode name.

```gml
var current_mode = mode_patrol.GetState();
```

**Returns:** Current mode name string.

#### PrevState()

Gets the previous mode name.

```gml
var previous_mode = mode_patrol.PrevState();
```

**Returns:** Previous mode name string.

#### HasState()

Checks if a state is currently set.

```gml
if (mode_patrol.HasState()) {
    // State is set
}
```

**Returns:** `true` if state is set (not undefined).

#### Flag(name)

Gets the `FlagPatrol` instance for a specific mode.

```gml
var combat_flags = mode_patrol.Flag("combat");
combat_flags.Add(FLAG_IN_COMBAT, FLAG_WEAPON_DRAWN);
```

**Returns:** `FlagPatrol` instance for the mode, or `undefined` if mode doesn't exist.

#### CurrentFlag()

Gets the `FlagPatrol` for the current mode.

```gml
var current_flags = mode_patrol.CurrentFlag();
if (current_flags != undefined) {
    current_flags.Add(FLAG_PAUSED);
}
```

**Returns:** `FlagPatrol` for current mode, or `undefined` if no mode set.

#### ClearStates()

Clears all states and their flags (but keeps the state definitions).

```gml
mode_patrol.ClearStates();
```

**Returns:** `self` for chaining.

#### Clear()

Clears all state definitions.

```gml
mode_patrol.Clear();
```

**Returns:** `self` for chaining.

#### Free()

Cleans up all internal data structures.

```gml
mode_patrol.Free();
```

---

### ModePatrol Example

```gml
// Create Event
game_mode = new ModePatrol();

// Define modes
game_mode.AddState("title");
game_mode.AddState("gameplay");
game_mode.AddState("pause");
game_mode.AddState("game_over");

// Set initial mode
game_mode.SetState("title");

// Define mode-specific flags
game_mode.Flag("gameplay").Add(FLAG_PLAYER_CONTROL);
game_mode.Flag("pause").Add(FLAG_GAME_PAUSED);

// Step Event
switch(game_mode.GetState()) {
    case "title":
        // Title screen logic
        if (keyboard_check_pressed(vk_enter)) {
            game_mode.SetState("gameplay");
        }
        break;
        
    case "gameplay":
        var flags = game_mode.CurrentFlag();
        
        // Toggle pause
        if (keyboard_check_pressed(vk_escape)) {
            game_mode.SetState("pause");
        }
        
        // Player died
        if (player_hp <= 0) {
            game_mode.SetState("game_over");
        }
        
        // Check gameplay-specific flags
        if (flags.Has(FLAG_PLAYER_CONTROL)) {
            // Handle input
        }
        break;
        
    case "pause":
        if (keyboard_check_pressed(vk_escape)) {
            game_mode.SetState("gameplay");
        }
        break;
        
    case "game_over":
        if (keyboard_check_pressed(vk_enter)) {
            // Restart
            game_mode.SetState("gameplay");
        }
        break;
}

// Track mode changes
if (game_mode.GetState() != game_mode.PrevState()) {
    show_debug_message($"Mode changed: {game_mode.PrevState()} -> {game_mode.GetState()}");
}
```

---

## StatePatrol

A minimal state-only tracker. Similar to `Patrol` but without flag support.

### Constructor

```gml
new StatePatrol(initialState = -1)
```

**Parameters:**
- `initialState` - Starting state value (default: -1)

```gml
var state = new StatePatrol();
var ai_state = new StatePatrol(AI_STATE.IDLE);
```

### Methods

#### Set(newState)

Sets the current state.

```gml
state.Set(STATE_RUNNING);
```

**Returns:** `self` for chaining.

#### Get()

Gets the current state.

```gml
var current = state.Get();
```

**Returns:** Current state value.

#### Previous()

Gets the previous state.

```gml
var previous = state.Previous();
```

**Returns:** Previous state value.

#### Is(currentState)

Checks if current state matches target.

```gml
if (state.Is(STATE_JUMPING)) {
    // Handle jump
}
```

**Returns:** `true` if current state equals target.

#### Changed()

Checks if state changed this frame.

```gml
if (state.Changed()) {
    // State just changed - trigger animation
    UpdateAnimationForState(state.Get());
}
```

**Returns:** `true` if state changed from previous frame.

#### Clear()

Resets state to -1.

```gml
state.Clear();
```

**Returns:** `self` for chaining.

---

### StatePatrol Example

```gml
// Simple animation state tracker
enum ANIM_STATE {
    IDLE,
    WALKING,
    RUNNING,
    JUMPING,
    FALLING,
    LANDING,
    ATTACKING
}

// Create Event
anim_state = new StatePatrol(ANIM_STATE.IDLE);

// Step Event
// Determine desired state based on conditions
var new_state = ANIM_STATE.IDLE;

if (!place_meeting(x, y+1, obj_ground)) {
    if (vspeed < 0) {
        new_state = ANIM_STATE.JUMPING;
    } else {
        new_state = ANIM_STATE.FALLING;
    }
} else {
    var moving = keyboard_check(vk_right) - keyboard_check(vk_left);
    if (moving != 0) {
        if (keyboard_check(vk_shift)) {
            new_state = ANIM_STATE.RUNNING;
        } else {
            new_state = ANIM_STATE.WALKING;
        }
    }
}

// Update state
anim_state.Set(new_state);

// React to state changes
if (anim_state.Changed()) {
    switch(anim_state.Get()) {
        case ANIM_STATE.IDLE:
            sprite_index = spr_player_idle;
            image_speed = 0.1;
            break;
        case ANIM_STATE.WALKING:
            sprite_index = spr_player_walk;
            image_speed = 0.2;
            break;
        case ANIM_STATE.RUNNING:
            sprite_index = spr_player_run;
            image_speed = 0.3;
            break;
        case ANIM_STATE.JUMPING:
            sprite_index = spr_player_jump;
            image_index = 0;
            image_speed = 0;
            break;
        case ANIM_STATE.FALLING:
            sprite_index = spr_player_fall;
            image_index = 0;
            image_speed = 0;
            break;
    }
}
```

---

## Comparison Table

| Feature | StateMachine | Patrol | FlagPatrol | ModePatrol | StatePatrol |
|---------|-------------|--------|------------|------------|-------------|
| Multiple named states | ✓ | - | - | ✓ | - |
| State enter/exit callbacks | ✓ | - | - | - | - |
| State update callback | ✓ | - | - | - | - |
| Numeric states | - | ✓ | - | - | ✓ |
| String states | ✓ | - | - | ✓ | - |
| Flags/bitwise operations | - | ✓ | ✓ | ✓ | - |
| Per-state flags | - | - | - | ✓ | - |
| State change detection | ✓ | ✓ | - | ✓ | ✓ |
| Serialization | ✓ | - | - | - | - |
| Best for | Complex behaviors | Simple AI | Status effects | Game modes | Simple state tracking |
