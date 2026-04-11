# GMU_Rendering

Rendering and visual systems for GameMaker. This module provides a professional camera system with smooth following, shake effects, and transitions, plus a robust animation pack with blending, events, and state machine integration.

## Table of Contents

- [Overview](#overview)
- [Camera System](#camera-system)
  - [Enums](#camera-enums)
  - [Camera Constructor](#camera-constructor)
  - [Following Objects](#following-objects)
  - [Position and Movement](#position-and-movement)
  - [Zoom Control](#zoom-control)
  - [Camera Shake](#camera-shake)
  - [Bounds and Parallax](#bounds-and-parallax)
  - [Post-Processing Effects](#post-processing-effects)
  - [Utility Methods](#camera-utility-methods)
  - [CameraManager](#cameramanager)
- [Animation System](#animation-system)
  - [Enums](#animation-enums)
  - [Animation Constructor](#animation-constructor)
  - [Playback Control](#playback-control)
  - [Events and Callbacks](#events-and-callbacks)
  - [Blending](#blending)
  - [AnimPack](#animpack)
- [Complete Examples](#complete-examples)

---

## Overview

The GMU_Rendering module provides two major systems:

### Camera System
- Smooth following with multiple modes (locked, smooth, predictive, zone, platformer)
- Camera shake with various patterns (random, perlin, directional, circular)
- Zoom with easing functions
- Bounds and deadzones
- Parallax layers
- Transitions with customizable easing
- Post-processing effects (chromatic aberration, vignette, motion blur)

### Animation System
- Sprite-based animation controller
- Multiple playback modes (normal, reverse, ping-pong, loop, once)
- Animation blending and crossfading
- Event system for frame-specific callbacks
- Animation queuing
- AnimPack for managing multiple animations per object

---

## Camera System

### Camera Enums

#### CAMERA_EASE

Easing functions for camera movement.

```gml
enum CAMERA_EASE {
    LINEAR,
    QUAD_IN,
    QUAD_OUT,
    QUAD_IN_OUT,
    CUBIC_IN,
    CUBIC_OUT,
    CUBIC_IN_OUT,
    ELASTIC_OUT,
    BACK_OUT,
    BOUNCE_OUT,
    SINE_IN_OUT
}
```

#### CAMERA_SHAKE_TYPE

Types of camera shake.

```gml
enum CAMERA_SHAKE_TYPE {
    RANDOM,      // Random offset each frame
    PERLIN,      // Smooth perlin noise shake
    DIRECTIONAL, // Shake along a specific direction
    CIRCULAR     // Circular shake pattern
}
```

#### CAMERA_FOLLOW_MODE

Camera following behaviors.

```gml
enum CAMERA_FOLLOW_MODE {
    LOCKED,      // Camera locked exactly to target
    SMOOTH,      // Smooth lerp following
    PREDICTIVE,  // Looks ahead based on target velocity
    ZONE,        // Only moves when target leaves deadzone
    PLATFORMER   // Platformer-style follow (look ahead horizontally)
}
```

---

### Camera Constructor

Creates a new camera instance.

```gml
new Camera(index, resolution, object = -1, position = {x: 0, y: 0}, border = {x: 0, y: 0}, angle = 0, spd = {x: -1, y: -1})
```

**Parameters:**
- `index` - View index (0-7)
- `resolution` - Struct with `width` and `height`
- `object` - Optional object to follow (default: -1)
- `position` - Initial position (default: {0, 0})
- `border` - View border (default: {0, 0})
- `angle` - Initial angle (default: 0)
- `spd` - View speed (default: {-1, -1} for instant)

```gml
// Create a camera for view 0
var cam = new Camera(0, { width: 640, height: 360 });

// Create camera following player
var cam = new Camera(0, { width: 1920, height: 1080 }, obj_player);

// Set the camera as active
cam.Set();
```

---

### Following Objects

#### FollowObject(obj, speed = 0.1, mode = CAMERA_FOLLOW_MODE.SMOOTH)

Sets the camera to follow an object.

```gml
cam.FollowObject(obj_player, 0.15, CAMERA_FOLLOW_MODE.SMOOTH);
cam.FollowObject(obj_boss, 0.05, CAMERA_FOLLOW_MODE.ZONE);
cam.FollowObject(obj_player, 0.2, CAMERA_FOLLOW_MODE.PLATFORMER);
```

**Returns:** `self` for chaining.

---

#### SetFollowOffset(x, y)

Sets an offset from the follow target.

```gml
// Look ahead in facing direction
cam.SetFollowOffset(50 * facing_direction, -20);
```

**Returns:** `self` for chaining.

---

#### SetDeadzone(x, y, w, h)

Sets a deadzone rectangle for ZONE follow mode.

```gml
// Camera only moves when player leaves this zone
cam.SetDeadzone(0, 0, 200, 100);
```

**Returns:** `self` for chaining.

---

#### SetPredictiveFollow(frames_ahead)

Sets predictive look-ahead based on target velocity.

```gml
// Look 10 frames ahead based on current velocity
cam.SetPredictiveFollow(10);
```

**Returns:** `self` for chaining.

---

### Position and Movement

#### SetPosition(x, y, instant = false)

Sets the camera target position.

```gml
cam.SetPosition(400, 300);
cam.SetPosition(new_x, new_y, true); // Instant move
```

**Returns:** `self` for chaining.

---

#### MoveTo(x, y, duration = 1, ease = CAMERA_EASE.QUAD_IN_OUT)

Moves the camera to a position over time.

```gml
cam.MoveTo(boss.x, boss.y, 2.0, CAMERA_EASE.CUBIC_IN_OUT);
cam.MoveTo(0, 0, 1.5, CAMERA_EASE.ELASTIC_OUT);
```

**Returns:** `self` for chaining.

---

#### LookAt(x, y, duration = 1)

Alias for MoveTo.

```gml
cam.LookAt(target.x, target.y, 1.0);
```

**Returns:** `self` for chaining.

---

### Zoom Control

#### SetZoom(target, speed = 0.1, ease = CAMERA_EASE.LINEAR)

Sets the target zoom level with smoothing.

```gml
cam.SetZoom(1.5, 0.05, CAMERA_EASE.QUAD_IN_OUT);
cam.SetZoom(0.8); // Zoom out slightly
```

**Returns:** `self` for chaining.

---

#### ZoomTo(target, duration = 1, ease = CAMERA_EASE.QUAD_IN_OUT)

Zooms to a target level over time.

```gml
cam.ZoomTo(2.0, 1.0, CAMERA_EASE.BACK_OUT);
cam.ZoomTo(1.0, 0.5); // Reset zoom
```

**Returns:** `self` for chaining.

---

#### SetZoomLimits(min_zoom_val, max_zoom_val)

Sets minimum and maximum zoom levels.

```gml
cam.SetZoomLimits(0.5, 3.0);
```

**Returns:** `self` for chaining.

---

### Camera Shake

#### Shake(trauma = 1, decay = 0.8, type = CAMERA_SHAKE_TYPE.PERLIN)

Adds camera shake.

```gml
// Small shake
cam.Shake(0.3, 0.7);

// Heavy shake on explosion
cam.Shake(1.0, 0.9, CAMERA_SHAKE_TYPE.RANDOM);

// Perlin noise shake (smoother)
cam.Shake(0.8, 0.85, CAMERA_SHAKE_TYPE.PERLIN);
```

**Parameters:**
- `trauma` - Shake intensity (0-1)
- `decay` - How quickly shake fades (0-1)
- `type` - Shake pattern type

**Returns:** `self` for chaining.

---

#### DirectionalShake(trauma, direction, decay = 0.8)

Shakes along a specific direction.

```gml
// Shake in direction of impact
var impact_dir = point_direction(hit_x, hit_y, player.x, player.y);
cam.DirectionalShake(0.9, impact_dir, 0.85);
```

**Returns:** `self` for chaining.

---

#### StopShake()

Immediately stops all camera shake.

```gml
cam.StopShake();
```

**Returns:** `self` for chaining.

---

### Bounds and Parallax

#### EnableBounds(x, y, w, h)

Enables camera boundaries.

```gml
cam.EnableBounds(0, 0, room_width, room_height);
```

**Returns:** `self` for chaining.

---

#### DisableBounds()

Disables camera boundaries.

```gml
cam.DisableBounds();
```

**Returns:** `self` for chaining.

---

#### AddParallaxLayer(layer_object, factor_x, factor_y)

Adds a parallax scrolling layer.

```gml
// Background moves at 50% camera speed
cam.AddParallaxLayer(obj_bg_far, 0.5, 0.5);

// Foreground moves faster than camera
cam.AddParallaxLayer(obj_fg_near, 1.2, 1.2);

// Clouds only move horizontally
cam.AddParallaxLayer(obj_clouds, 0.3, 0);
```

**Returns:** `self` for chaining.

---

#### RemoveParallaxLayer(layer_object)

Removes a parallax layer.

```gml
cam.RemoveParallaxLayer(obj_bg_far);
```

**Returns:** `self` for chaining.

---

### Post-Processing Effects

#### EnablePostProcess(enabled = true)

Enables post-processing effects.

```gml
cam.EnablePostProcess(true);
```

**Returns:** `self` for chaining.

---

#### SetChromaticAberration(intensity)

Sets chromatic aberration intensity.

```gml
cam.SetChromaticAberration(0.3);
```

**Returns:** `self` for chaining.

---

#### SetVignette(intensity)

Sets vignette intensity.

```gml
cam.SetVignette(0.5);
```

**Returns:** `self` for chaining.

---

#### SetMotionBlur(amount)

Sets motion blur amount.

```gml
cam.SetMotionBlur(0.4);
```

**Returns:** `self` for chaining.

---

### Camera Utility Methods

#### WorldToScreen(world_x, world_y)

Converts world coordinates to screen coordinates.

```gml
var screen_pos = cam.WorldToScreen(player.x, player.y);
draw_text(screen_pos.x, screen_pos.y - 20, "Player");
```

**Returns:** Struct with `x` and `y` screen coordinates.

---

#### ScreenToWorld(screen_x, screen_y)

Converts screen coordinates to world coordinates.

```gml
var world_pos = cam.ScreenToWorld(mouse_x, mouse_y);
instance_create_layer(world_pos.x, world_pos.y, "Instances", obj_bullet);
```

**Returns:** Struct with `x` and `y` world coordinates.

---

#### IsVisible(x, y, w, h)

Checks if a rectangle is visible in the camera view.

```gml
if (cam.IsVisible(enemy.x - 32, enemy.y - 32, 64, 64)) {
    // Enemy is on screen - update AI
    enemy.UpdateAI();
}
```

**Returns:** `true` if visible.

---

#### GetViewRect()

Gets the current view rectangle in world coordinates.

```gml
var view = cam.GetViewRect();
// view = { x, y, w, h }
```

**Returns:** Struct with `x`, `y`, `w`, `h`.

---

#### SetOnUpdate(callback)

Sets a callback for each camera update.

```gml
cam.SetOnUpdate(function(camera) {
    // Custom update logic
    show_debug_message($"Camera at {camera.position.x}, {camera.position.y}");
});
```

**Returns:** `self` for chaining.

---

#### SetOnShake(callback)

Sets a callback when shake is applied.

```gml
cam.SetOnShake(function(trauma) {
    // Trigger screen shake effect on UI
    UI.Shake(trauma);
});
```

**Returns:** `self` for chaining.

---

#### SetOnTransitionComplete(callback)

Sets a callback when a transition finishes.

```gml
cam.SetOnTransitionComplete(function() {
    show_debug_message("Camera transition complete");
    can_accept_input = true;
});
```

**Returns:** `self` for chaining.

---

#### Update()

Updates the camera (call in Step event).

```gml
// In controller object Step event
cam.Update();
```

**Returns:** `self` for chaining.

---

#### DebugDraw()

Draws debug information for the camera.

```gml
// In Draw event
cam.DebugDraw();
```

**Returns:** `self` for chaining.

---

#### GetInfo()

Gets current camera information.

```gml
var info = cam.GetInfo();
show_debug_message($"Position: {info.position.x}, {info.position.y}");
show_debug_message($"Zoom: {info.zoom}");
show_debug_message($"Shake: {info.shake_trauma}");
```

**Returns:** Struct with camera state.

---

#### Free()

Cleans up the camera.

```gml
cam.Free();
```

---

### CameraManager

Manages multiple cameras with easy switching.

#### Constructor

```gml
new CameraManager()
```

```gml
var cam_manager = new CameraManager();
```

#### Add(camera)

Adds a camera to the manager.

```gml
cam_manager.Add(main_camera);
cam_manager.Add(ui_camera);
cam_manager.Add(cutscene_camera);
```

**Returns:** `self` for chaining.

---

#### SetActive(index)

Sets the active camera by index.

```gml
cam_manager.SetActive(0); // Main camera
cam_manager.SetActive(2); // Cutscene camera
```

**Returns:** `self` for chaining.

---

#### GetActive()

Gets the currently active camera.

```gml
var active_cam = cam_manager.GetActive();
active_cam.Shake(0.5);
```

**Returns:** Active Camera instance.

---

#### UpdateAll()

Updates all managed cameras.

```gml
// In Step event
cam_manager.UpdateAll();
```

**Returns:** `self` for chaining.

---

#### Free()

Cleans up all cameras.

```gml
cam_manager.Free();
```

---

## Animation System

### Animation Enums

#### ANIM_PLAYBACK

Animation playback modes.

```gml
enum ANIM_PLAYBACK {
    NORMAL,    // Play forward once
    REVERSE,   // Play backward once
    PING_PONG, // Play forward then backward
    LOOP,      // Loop continuously
    ONCE       // Play once and stop
}
```

#### ANIM_BLEND_MODE

Animation blending modes.

```gml
enum ANIM_BLEND_MODE {
    NONE,      // No blending
    CROSSFADE, // Crossfade between animations
    ADDITIVE,  // Additive blending
    OVERRIDE   // Override current animation
}
```

#### ANIM_EVENT

Animation event types.

```gml
enum ANIM_EVENT {
    ON_START,   // When animation starts
    ON_FRAME,   // On specific frame
    ON_END,     // When animation ends
    ON_LOOP,    // When animation loops
    ON_PAUSE,   // When paused
    ON_RESUME   // When resumed
}
```

---

### Animation Constructor

Creates a new animation controller.

```gml
new Animation(sprite, speed = 1, onUpdate = undefined)
```

**Parameters:**
- `sprite` - Sprite asset to animate
- `speed` - Playback speed multiplier (default: 1)
- `onUpdate` - Optional update callback

```gml
var anim = new Animation(spr_player_idle, 0.2);
var run_anim = new Animation(spr_player_run, 0.3);
```

---

### Animation Configuration

#### SetName(name)

Sets the animation name.

```gml
anim.SetName("idle");
```

**Returns:** `self` for chaining.

---

#### SetFrameRange(start, end)

Sets the frame range to play.

```gml
// Play only frames 0-5
anim.SetFrameRange(0, 5);

// Play from frame 6 to end
anim.SetFrameRange(6, -1);
```

**Returns:** `self` for chaining.

---

#### SetPlaybackMode(mode, loop_count = -1)

Sets the playback mode and optional loop count.

```gml
anim.SetPlaybackMode(ANIM_PLAYBACK.LOOP, -1); // Infinite loop
anim.SetPlaybackMode(ANIM_PLAYBACK.LOOP, 3);  // Loop 3 times
anim.SetPlaybackMode(ANIM_PLAYBACK.PING_PONG);
anim.SetPlaybackMode(ANIM_PLAYBACK.ONCE);
```

**Returns:** `self` for chaining.

---

#### SetTimeScale(scale)

Sets the time scale for playback.

```gml
anim.SetTimeScale(0.5); // Half speed
anim.SetTimeScale(2.0); // Double speed
```

**Returns:** `self` for chaining.

---

#### SetFrameDuration(frames_per_image)

Sets how many frames each animation frame lasts.

```gml
anim.SetFrameDuration(4); // Each frame lasts 4 game frames
```

**Returns:** `self` for chaining.

---

### Playback Control

#### Play()

Starts or resumes playback.

```gml
anim.Play();
```

**Returns:** `self` for chaining.

---

#### Pause()

Pauses playback.

```gml
anim.Pause();
```

**Returns:** `self` for chaining.

---

#### Resume()

Resumes paused playback.

```gml
anim.Resume();
```

**Returns:** `self` for chaining.

---

#### Stop()

Stops playback and resets to start frame.

```gml
anim.Stop();
```

**Returns:** `self` for chaining.

---

#### Reset()

Resets animation to start frame.

```gml
anim.Reset();
```

**Returns:** `self` for chaining.

---

#### JumpToFrame(frame)

Jumps to a specific frame.

```gml
anim.JumpToFrame(5);
```

**Returns:** `self` for chaining.

---

#### JumpToProgress(progress)

Jumps to a position based on progress (0-1).

```gml
anim.JumpToProgress(0.5); // Jump to middle of animation
```

**Returns:** `self` for chaining.

---

### Query Methods

#### GetCurrentFrame()

Gets the current frame index.

```gml
var frame = anim.GetCurrentFrame();
```

**Returns:** Current frame index.

---

#### GetProgress()

Gets the current progress (0-1).

```gml
var progress = anim.GetProgress();
```

**Returns:** Progress value.

---

#### IsPlaying()

Checks if animation is playing.

```gml
if (anim.IsPlaying()) {
    // Animation is active
}
```

**Returns:** `true` if playing.

---

#### IsFinished()

Checks if animation has finished.

```gml
if (anim.IsFinished()) {
    // Animation completed
}
```

**Returns:** `true` if finished.

---

#### GetDuration()

Gets the total duration in frames.

```gml
var frames = anim.GetDuration();
```

**Returns:** Duration in frames.

---

### Events and Callbacks

#### OnStart(callback)

Sets callback for animation start.

```gml
anim.OnStart(function(anim) {
    show_debug_message("Animation started");
});
```

**Returns:** `self` for chaining.

---

#### OnFrame(callback)

Sets callback for each frame change.

```gml
anim.OnFrame(function(frame) {
    if (frame == 3) {
        // Frame 3 reached - spawn effect
    }
});
```

**Returns:** `self` for chaining.

---

#### OnEnd(callback)

Sets callback for animation end.

```gml
anim.OnEnd(function() {
    // Animation finished - transition to next state
});
```

**Returns:** `self` for chaining.

---

#### OnLoop(callback)

Sets callback for animation loop.

```gml
anim.OnLoop(function(loop_count) {
    show_debug_message($"Loop {loop_count}");
});
```

**Returns:** `self` for chaining.

---

#### AddEvent(event_type, frame_or_callback, callback = undefined)

Adds a custom event.

```gml
// Frame-specific event
anim.AddEvent(ANIM_EVENT.ON_FRAME, 4, function(anim, frame) {
    // Create hitbox on frame 4
    CreateHitbox();
});

// General event
anim.AddEvent(ANIM_EVENT.ON_START, function(anim) {
    // Reset state
});
```

**Returns:** `self` for chaining.

---

#### ClearEvents(event_type = undefined)

Clears events.

```gml
anim.ClearEvents(); // Clear all events
anim.ClearEvents(ANIM_EVENT.ON_FRAME); // Clear only frame events
```

**Returns:** `self` for chaining.

---

### Blending

#### SetBlendWeight(weight)

Sets the blend weight for this animation.

```gml
anim.SetBlendWeight(0.5);
```

**Returns:** `self` for chaining.

---

#### SetBlendMode(mode, duration = 0.3)

Sets the blend mode and duration.

```gml
anim.SetBlendMode(ANIM_BLEND_MODE.CROSSFADE, 0.2);
```

**Returns:** `self` for chaining.

---

### Update

#### Update(object, delta_time = 1)

Updates the animation and applies to object.

```gml
// In object's Step event
anim.Update(self);
```

**Parameters:**
- `object` - The instance to apply animation to
- `delta_time` - Delta time multiplier

**Returns:** `self` for chaining.

---

#### Free()

Cleans up the animation.

```gml
anim.Free();
```

---

### AnimPack

Manages multiple animations for a single object with state machine integration.

#### Constructor

```gml
new AnimPack(object)
```

**Parameters:**
- `object` - The instance this pack belongs to

```gml
var anim_pack = new AnimPack(self);
```

---

#### Add(name, anim_or_sprite, speed = 1)

Adds an animation to the pack.

```gml
// Add with existing animation
anim_pack.Add("idle", idle_anim);

// Add with sprite (creates animation automatically)
anim_pack.Add("run", spr_player_run, 0.3);

// Add with configuration
var attack_anim = new Animation(spr_player_attack, 0.4);
attack_anim.SetPlaybackMode(ANIM_PLAYBACK.ONCE);
attack_anim.SetFrameRange(0, 5);
anim_pack.Add("attack", attack_anim);
```

**Returns:** `self` for chaining.

---

#### AddRange(anim_map)

Adds multiple animations from a struct.

```gml
anim_pack.AddRange({
    idle: [spr_player_idle, 0.2],
    walk: [spr_player_walk, 0.25],
    run: [spr_player_run, 0.35],
    jump: spr_player_jump,
    fall: spr_player_fall
});
```

**Returns:** `self` for chaining.

---

#### Get(name)

Gets an animation by name.

```gml
var run_anim = anim_pack.Get("run");
run_anim.SetTimeScale(1.5);
```

**Returns:** Animation instance or `undefined`.

---

#### Exists(name)

Checks if an animation exists.

```gml
if (anim_pack.Exists("attack")) {
    anim_pack.Play("attack");
}
```

**Returns:** `true` if exists.

---

#### Set(name, blend_duration = 0, blend_mode = ANIM_BLEND_MODE.CROSSFADE)

Sets the current animation.

```gml
// Immediate switch
anim_pack.Set("idle");

// Smooth transition
anim_pack.Set("run", 0.2, ANIM_BLEND_MODE.CROSSFADE);
```

**Returns:** `self` for chaining.

---

#### Play(name, blend = 0)

Alias for Set.

```gml
anim_pack.Play("jump", 0.1);
```

**Returns:** `self` for chaining.

---

#### SetDefault(name)

Sets the default animation (played when current finishes).

```gml
anim_pack.SetDefault("idle");
```

**Returns:** `self` for chaining.

---

#### PlayDefault(blend = 0)

Plays the default animation.

```gml
anim_pack.PlayDefault(0.3);
```

**Returns:** `self` for chaining.

---

### Animation Queue

#### EnableQueue(enabled = true)

Enables animation queuing.

```gml
anim_pack.EnableQueue(true);
```

**Returns:** `self` for chaining.

---

#### Queue(name, blend = 0)

Queues an animation to play after current finishes.

```gml
anim_pack.Queue("attack2", 0.1);
anim_pack.Queue("attack3", 0.1);
anim_pack.Queue("idle", 0.3);
```

**Returns:** `self` for chaining.

---

#### ClearQueue()

Clears the animation queue.

```gml
anim_pack.ClearQueue();
```

**Returns:** `self` for chaining.

---

#### PlayNextInQueue(blend = 0.2)

Plays the next queued animation.

```gml
anim_pack.PlayNextInQueue();
```

**Returns:** `self` for chaining.

---

### Playback Control

#### Pause()

Pauses current animation.

```gml
anim_pack.Pause();
```

**Returns:** `self` for chaining.

---

#### Resume()

Resumes current animation.

```gml
anim_pack.Resume();
```

**Returns:** `self` for chaining.

---

#### Stop()

Stops current animation.

```gml
anim_pack.Stop();
```

**Returns:** `self` for chaining.

---

#### SetSpeed(speed)

Sets speed of current animation.

```gml
anim_pack.SetSpeed(2.0); // Double speed
```

**Returns:** `self` for chaining.

---

#### SetTimeScale(scale)

Sets time scale of current animation.

```gml
anim_pack.SetTimeScale(0.5); // Half speed
```

**Returns:** `self` for chaining.

---

### Query Methods

#### GetCurrent()

Gets current animation instance.

```gml
var current = anim_pack.GetCurrent();
```

**Returns:** Current Animation instance.

---

#### GetCurrentName()

Gets current animation name.

```gml
var name = anim_pack.GetCurrentName();
```

**Returns:** Current animation name string.

---

#### GetPrevious()

Gets previous animation instance.

```gml
var previous = anim_pack.GetPrevious();
```

**Returns:** Previous Animation instance.

---

#### IsPlaying()

Checks if current animation is playing.

```gml
if (anim_pack.IsPlaying()) {
    // Animation is active
}
```

**Returns:** `true` if playing.

---

#### IsCurrent(name)

Checks if current animation matches name.

```gml
if (anim_pack.IsCurrent("attack")) {
    // Currently attacking
}
```

**Returns:** `true` if current animation matches.

---

#### GetProgress()

Gets progress of current animation.

```gml
var progress = anim_pack.GetProgress();
```

**Returns:** Progress value (0-1).

---

#### GetAllNames()

Gets all animation names in the pack.

```gml
var names = anim_pack.GetAllNames();
for (var i = 0; i < array_length(names); i++) {
    show_debug_message(names[i]);
}
```

**Returns:** Array of animation names.

---

### Events and Utilities

#### OnAnimChanged(callback)

Sets callback for animation changes.

```gml
anim_pack.OnAnimChanged(function(new_anim, old_anim) {
    show_debug_message($"Changed from {old_anim} to {new_anim}");
});
```

**Returns:** `self` for chaining.

---

#### CreateStateMachine()

Creates a StateMachine from the animations.

```gml
var sm = anim_pack.CreateStateMachine();
sm.ChangeTo("run");
```

**Returns:** StateMachine instance.

---

#### ExportToJSON()

Exports animation data to JSON.

```gml
var json = anim_pack.ExportToJSON();
File.SaveString("anim_data.json", json);
```

**Returns:** JSON string.

---

#### DebugDraw(x, y)

Draws debug information.

```gml
anim_pack.DebugDraw(10, 10);
```

---

#### Update(delta_time = 1)

Updates the animation pack.

```gml
// In Step event
anim_pack.Update();
```

**Returns:** `self` for chaining.

---

#### Free()

Cleans up the animation pack.

```gml
anim_pack.Free();
```

---

## Complete Examples

### Example 1: Platformer Camera Setup

```gml
// Create Event
cam = new Camera(0, { width: 640, height: 360 });
cam.FollowObject(self, 0.1, CAMERA_FOLLOW_MODE.PLATFORMER);
cam.SetFollowOffset(60 * facing_direction, -20);
cam.SetZoomLimits(1.0, 1.5);
cam.EnableBounds(0, 0, room_width, room_height);
cam.Set();

// Step Event
cam.Update();

// On player damage
cam.Shake(0.6, 0.8, CAMERA_SHAKE_TYPE.DIRECTIONAL);
cam.DirectionalShake(0.6, damage_direction, 0.8);

// On player death
cam.ZoomTo(1.8, 2.0, CAMERA_EASE.QUAD_IN);
cam.SetChromaticAberration(0.4);
cam.SetVignette(0.6);

// On power-up
cam.ZoomTo(1.3, 0.5, CAMERA_EASE.BACK_OUT);
```

### Example 2: Cutscene Camera with Transitions

```gml
// Cutscene controller
function PlayCutscene() {
    var cam = CameraManager.GetActive();
    
    // Disable player control
    cam.FollowObject(-1);
    
    // Sequence of camera movements
    cam.MoveTo(npc1.x, npc1.y, 2.0, CAMERA_EASE.QUAD_IN_OUT);
    
    cam.SetOnTransitionComplete(function() {
        // First move complete
        DialogueBox.Show("Welcome, hero...");
        
        // Schedule next move
        call_later(3.0, function() {
            cam.MoveTo(npc2.x, npc2.y, 2.0, CAMERA_EASE.QUAD_IN_OUT);
            
            cam.SetOnTransitionComplete(function() {
                DialogueBox.Show("We need your help.");
                
                call_later(2.0, function() {
                    cam.ZoomTo(1.5, 1.0);
                    cam.MoveTo(altar.x, altar.y, 3.0, CAMERA_EASE.SINE_IN_OUT);
                    
                    cam.SetOnTransitionComplete(function() {
                        // Cutscene complete
                        cam.FollowObject(obj_player, 0.1);
                        cam.ZoomTo(1.0, 0.5);
                        EndCutscene();
                    });
                });
            });
        });
    });
}
```

### Example 3: Player Animation Controller

```gml
// Create Event
anim_pack = new AnimPack(self);

// Add all animations
anim_pack.AddRange({
    idle: [spr_player_idle, 0.15],
    walk: [spr_player_walk, 0.2],
    run: [spr_player_run, 0.3],
    jump: spr_player_jump,
    fall: spr_player_fall,
    land: spr_player_land,
    attack1: spr_player_attack1,
    attack2: spr_player_attack2,
    attack3: spr_player_attack3,
    hurt: spr_player_hurt,
    die: spr_player_die
});

// Configure attack animations
anim_pack.Get("attack1").SetPlaybackMode(ANIM_PLAYBACK.ONCE);
anim_pack.Get("attack2").SetPlaybackMode(ANIM_PLAYBACK.ONCE);
anim_pack.Get("attack3").SetPlaybackMode(ANIM_PLAYBACK.ONCE);

// Add hitbox events
anim_pack.Get("attack1").AddEvent(ANIM_EVENT.ON_FRAME, 3, function() {
    CreateHitbox(10, "light");
});
anim_pack.Get("attack2").AddEvent(ANIM_EVENT.ON_FRAME, 4, function() {
    CreateHitbox(15, "medium");
});
anim_pack.Get("attack3").AddEvent(ANIM_EVENT.ON_FRAME, 5, function() {
    CreateHitbox(25, "heavy");
});

// Set default
anim_pack.SetDefault("idle");

// Enable queue for combo system
anim_pack.EnableQueue(true);

// Step Event
function UpdateAnimation() {
    anim_pack.Update();
    
    // Don't interrupt certain animations
    var current = anim_pack.GetCurrentName();
    var uninterruptible = ["attack1", "attack2", "attack3", "hurt", "die", "land"];
    
    if (array_contains(uninterruptible, current)) {
        if (!anim_pack.GetCurrent().IsFinished()) {
            return;
        }
    }
    
    // Determine new animation based on state
    if (hp <= 0) {
        anim_pack.Set("die", 0.1);
    } else if (hurt_timer > 0) {
        anim_pack.Set("hurt", 0.1);
    } else if (!on_ground) {
        if (vspeed < 0) {
            anim_pack.Set("jump");
        } else {
            anim_pack.Set("fall");
        }
    } else if (just_landed) {
        anim_pack.Set("land", 0.1);
    } else if (abs(hspeed) > 0) {
        if (is_running) {
            anim_pack.Set("run");
        } else {
            anim_pack.Set("walk");
        }
    } else {
        anim_pack.Set("idle", 0.15);
    }
}

// Attack input
if (InputManager.IsJustPressed("Attack")) {
    if (anim_pack.IsCurrent("attack1")) {
        anim_pack.Queue("attack2", 0.05);
    } else if (anim_pack.IsCurrent("attack2")) {
        anim_pack.Queue("attack3", 0.05);
    } else {
        anim_pack.Set("attack1", 0.05);
    }
}
```

### Example 4: Multi-Camera Setup with Manager

```gml
// Create Event
camera_manager = new CameraManager();

// Main gameplay camera
var main_cam = new Camera(0, { width: 1920, height: 1080 });
main_cam.FollowObject(obj_player, 0.12, CAMERA_FOLLOW_MODE.SMOOTH);
main_cam.SetZoomLimits(0.8, 2.0);
main_cam.EnableBounds(0, 0, room_width, room_height);
camera_manager.Add(main_cam);

// UI camera (fixed)
var ui_cam = new Camera(1, { width: 1920, height: 1080 });
ui_cam.SetPosition(0, 0, true);
camera_manager.Add(ui_cam);

// Cinematic camera
var cine_cam = new Camera(2, { width: 1920, height: 1080 });
cine_cam.SetZoom(1.2);
camera_manager.Add(cine_cam);

// Set active camera
camera_manager.SetActive(0);

// Step Event
camera_manager.UpdateAll();

// Switch to cinematic
function StartCinematic() {
    camera_manager.SetActive(2);
    var cam = camera_manager.GetActive();
    cam.SetOnTransitionComplete(OnCinematicComplete);
}

// Return to gameplay
function EndCinematic() {
    camera_manager.SetActive(0);
}
```

### Example 5: Boss Battle Camera

```gml
// Boss room camera setup
function SetupBossCamera(boss) {
    var cam = CameraManager.GetActive();
    
    // Lock camera to show both player and boss
    cam.FollowObject(-1); // Stop following player
    
    // Create dynamic bounds for boss arena
    cam.EnableBounds(arena_x, arena_y, arena_width, arena_height);
    
    // Update camera to frame both entities
    cam.SetOnUpdate(function(c) {
        var target_x = (obj_player.x + boss.x) / 2;
        var target_y = (obj_player.y + boss.y) / 2;
        
        // Add vertical offset for better visibility
        target_y -= 50;
        
        // Calculate zoom to keep both on screen
        var dist = point_distance(obj_player.x, obj_player.y, boss.x, boss.y);
        var target_zoom = 1.0 + (dist / 500);
        target_zoom = clamp(target_zoom, 1.0, 1.5);
        
        c.SetPosition(target_x, target_y);
        c.SetZoom(target_zoom, 0.05);
    });
    
    // Boss phase transitions
    boss.on_phase_change = function(phase) {
        cam.Shake(0.8, 0.9);
        cam.ZoomTo(1.3, 1.0, CAMERA_EASE.ELASTIC_OUT);
    };
    
    // Boss death
    boss.on_death = function() {
        cam.SetOnUpdate(undefined);
        cam.MoveTo(boss.x, boss.y, 2.0, CAMERA_EASE.QUAD_IN);
        cam.ZoomTo(1.8, 2.0, CAMERA_EASE.QUAD_IN);
        cam.SetOnTransitionComplete(function() {
            // Return to player follow
            cam.FollowObject(obj_player, 0.1);
            cam.SetZoom(1.0);
        });
    };
}
```
