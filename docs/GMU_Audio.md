# GMU_Audio

A comprehensive audio management system for GameMaker. This module provides group-based volume control, 3D spatial audio, music playlists with crossfading, audio ducking, reverb presets, and sound pooling.

## Table of Contents

- [Overview](#overview)
- [Global Instance](#global-instance)
- [Enums](#enums)
  - [AUDIO_GROUP](#audio_group)
  - [AUDIO_FADE](#audio_fade)
  - [AUDIO_REVERB](#audio_reverb)
  - [AUDIO_PRIORITY](#audio_priority)
  - [AUDIO_STATE](#audio_state)
- [AudioManager](#audiomanager)
  - [Registering Sounds](#registering-sounds)
  - [Playing SFX](#playing-sfx)
  - [3D Spatial Audio](#3d-spatial-audio)
  - [Music System](#music-system)
  - [Volume Control](#volume-control)
  - [Fading and Crossfading](#fading-and-crossfading)
  - [Audio Ducking](#audio-ducking)
  - [Reverb Effects](#reverb-effects)
  - [Utility Methods](#utility-methods)
- [Complete Examples](#complete-examples)

---

## Overview

The AudioManager provides a professional-grade audio system with features commonly found in game engines:

- **Audio Groups** - Organize sounds into categories (Master, SFX, Music, Ambient, Voice, UI)
- **Independent Volume Control** - Control volume per group with smooth fading
- **3D Spatial Audio** - Position sounds in 3D space with distance attenuation
- **Music Playlists** - Create and manage playlists with shuffle support
- **Crossfading** - Smooth transitions between music tracks
- **Audio Ducking** - Automatically lower music volume during dialogue/SFX
- **Sound Pooling** - Reuse sound instances for performance
- **Priority System** - Automatic culling of low-priority sounds when at limit

---

## Global Instance

A global `AudioManager` instance is automatically created via the `GMU_NAMESPACES_INIT` macro:

```gml
globalvar AudioManager;
AudioManager = new AudioManager();
```

---

## Enums

### AUDIO_GROUP

Audio categories for grouping and independent volume control.

```gml
enum AUDIO_GROUP {
    MASTER,
    SFX,
    MUSIC,
    AMBIENT,
    VOICE,
    UI,
    CUSTOM_1,
    CUSTOM_2,
    CUSTOM_3
}
```

### AUDIO_FADE

Fade curve types for volume transitions.

```gml
enum AUDIO_FADE {
    LINEAR,
    SMOOTH,
    EXPONENTIAL,
    LOGARITHMIC
}
```

### AUDIO_REVERB

Preset reverb environments.

```gml
enum AUDIO_REVERB {
    OFF,
    SMALL_ROOM,
    MEDIUM_ROOM,
    LARGE_ROOM,
    HALL,
    CAVE,
    ARENA,
    CATHEDRAL,
    UNDERWATER,
    CUSTOM
}
```

### AUDIO_PRIORITY

Sound priority levels for culling.

```gml
enum AUDIO_PRIORITY {
    LOWEST = 0,
    LOW = 25,
    NORMAL = 50,
    HIGH = 75,
    CRITICAL = 100
}
```

### AUDIO_STATE

Current state of an audio instance.

```gml
enum AUDIO_STATE {
    STOPPED,
    PLAYING,
    PAUSED,
    FADING_IN,
    FADING_OUT
}
```

---

## AudioManager

### Registering Sounds

Before playing sounds, register them to assign groups and properties.

#### RegisterSFX(sound_asset, group = AUDIO_GROUP.SFX, priority = AUDIO_PRIORITY.NORMAL)

Registers a sound effect.

```gml
AudioManager.RegisterSFX(snd_jump, AUDIO_GROUP.SFX, AUDIO_PRIORITY.NORMAL);
AudioManager.RegisterSFX(snd_gunshot, AUDIO_GROUP.SFX, AUDIO_PRIORITY.HIGH);
AudioManager.RegisterSFX(snd_footstep, AUDIO_GROUP.SFX, AUDIO_PRIORITY.LOW);
```

**Parameters:**
- `sound_asset` - The sound asset from GameMaker
- `group` - Audio group (default: SFX)
- `priority` - Priority level (default: NORMAL)

**Returns:** Sound info struct.

---

#### RegisterMusic(music_asset, loop = true, intro_asset = undefined)

Registers a music track.

```gml
// Simple music track
AudioManager.RegisterMusic(mus_main_theme, true);

// Music with intro
AudioManager.RegisterMusic(mus_boss_loop, true, mus_boss_intro);
```

**Parameters:**
- `music_asset` - The music asset
- `loop` - Whether the track should loop
- `intro_asset` - Optional intro section that plays once before looping

**Returns:** Music info struct.

---

#### RegisterAmbient(ambient_asset, volume = 0.5, fade_in = 2.0)

Registers an ambient sound.

```gml
AudioManager.RegisterAmbient(snd_wind, 0.3, 3.0);
AudioManager.RegisterAmbient(snd_cave_drips, 0.4, 2.0);
AudioManager.RegisterAmbient(snd_crowd_murmur, 0.5, 1.0);
```

**Parameters:**
- `ambient_asset` - The ambient sound asset
- `volume` - Base volume (default: 0.5)
- `fade_in` - Fade in duration in seconds (default: 2.0)

**Returns:** Ambient info struct.

---

### Playing SFX

#### PlaySFX(sound_asset, volume = 1.0, pitch = 1.0, priority = AUDIO_PRIORITY.NORMAL)

Plays a sound effect.

```gml
// Simple playback
AudioManager.PlaySFX(snd_jump);

// With volume and pitch variation
AudioManager.PlaySFX(snd_footstep, 0.8, 1.0 + random_range(-0.1, 0.1));

// High priority sound
AudioManager.PlaySFX(snd_alarm, 1.0, 1.0, AUDIO_PRIORITY.CRITICAL);
```

**Parameters:**
- `sound_asset` - The sound asset to play
- `volume` - Volume multiplier (default: 1.0)
- `pitch` - Pitch multiplier (default: 1.0)
- `priority` - Priority level (default: NORMAL)

**Returns:** Sound instance ID, or -1 if failed.

---

#### PlaySFX3D(sound_asset, x, y, z = 0, volume = 1.0, pitch = 1.0, priority = AUDIO_PRIORITY.NORMAL)

Plays a sound effect at a 3D position.

```gml
// Play sound at enemy position
AudioManager.PlaySFX3D(snd_enemy_spawn, enemy.x, enemy.y, 0, 0.8);

// Play sound at player position
AudioManager.PlaySFX3D(snd_footstep, player.x, player.y, 0, 0.6, 1.0 + random_range(-0.1, 0.1));

// Sound at height (z-axis)
AudioManager.PlaySFX3D(snd_bird, 500, 300, 100, 0.5);
```

**Parameters:**
- `sound_asset` - The sound asset to play
- `x, y, z` - World position
- `volume` - Volume multiplier (default: 1.0)
- `pitch` - Pitch multiplier (default: 1.0)
- `priority` - Priority level (default: NORMAL)

**Returns:** Sound instance ID, or -1 if failed or out of range.

---

#### StopSound(sound_id, fade = false, fade_time = 0.1)

Stops a specific sound instance.

```gml
var sound_id = AudioManager.PlaySFX(snd_long_effect);

// Stop immediately
AudioManager.StopSound(sound_id);

// Stop with fade out
AudioManager.StopSound(sound_id, true, 0.5);
```

**Parameters:**
- `sound_id` - The sound instance ID
- `fade` - Whether to fade out
- `fade_time` - Fade duration in seconds

**Returns:** `self` for chaining.

---

#### StopAll(fade = false, fade_time = 0.3)

Stops all currently playing SFX.

```gml
// Stop all SFX immediately
AudioManager.StopAll();

// Stop all SFX with fade out
AudioManager.StopAll(true, 0.5);
```

**Parameters:**
- `fade` - Whether to fade out
- `fade_time` - Fade duration in seconds

**Returns:** `self` for chaining.

---

#### IsPlaying(sound_id)

Checks if a sound instance is still playing.

```gml
var sound_id = AudioManager.PlaySFX(snd_explosion);
// Later...
if (AudioManager.IsPlaying(sound_id)) {
    // Still playing
}
```

**Returns:** `true` if playing, `false` otherwise.

---

### 3D Spatial Audio

Configure the 3D audio listener and spatial settings.

#### SetListenerPosition(x, y, z = 0)

Sets the position of the audio listener (usually the camera or player).

```gml
// In camera update
AudioManager.SetListenerPosition(camera.x, camera.y, 0);

// For 3D games
AudioManager.SetListenerPosition(player.x, player.y, player.z);
```

**Returns:** `self` for chaining.

---

#### SetListenerOrientation(look_x, look_y, look_z, up_x, up_y, up_z)

Sets the orientation of the audio listener.

```gml
// 2D top-down (looking down at the plane)
AudioManager.SetListenerOrientation(0, 0, -1, 0, 1, 0);

// 3D first-person (looking forward)
var look_x = lengthdir_x(1, direction);
var look_y = lengthdir_y(1, direction);
AudioManager.SetListenerOrientation(look_x, look_y, 0, 0, 0, 1);
```

**Returns:** `self` for chaining.

---

#### SetSpatialSettings(max_dist = 1000, rolloff = 1.0, doppler = 1.0)

Configures 3D audio parameters.

```gml
AudioManager.SetSpatialSettings(800, 1.5, 1.0);
```

**Parameters:**
- `max_dist` - Maximum distance sounds can be heard
- `rolloff` - Rolloff factor for distance attenuation
- `doppler` - Doppler effect factor

**Returns:** `self` for chaining.

---

#### UpdateSoundPosition(sound_id, x, y, z = 0)

Updates the position of a playing 3D sound.

```gml
// For moving sound sources
AudioManager.UpdateSoundPosition(engine_sound_id, car.x, car.y, 0);
```

**Returns:** `self` for chaining.

---

### Music System

#### PlayMusic(music_asset, fade = true, fade_time = 1.0, loop = true)

Starts playing a music track.

```gml
// Play with default fade
AudioManager.PlayMusic(mus_main_theme);

// Play immediately
AudioManager.PlayMusic(mus_boss_theme, false);

// Play with custom fade time
AudioManager.PlayMusic(mus_ambient, true, 2.0);
```

**Parameters:**
- `music_asset` - The music asset to play
- `fade` - Whether to fade in (default: true)
- `fade_time` - Fade duration in seconds (default: 1.0)
- `loop` - Whether to loop (default: true)

**Returns:** Sound instance ID, or -1 if failed.

---

#### StopMusic(fade = true, fade_time = 1.0)

Stops the currently playing music.

```gml
// Stop with fade out
AudioManager.StopMusic();

// Stop immediately
AudioManager.StopMusic(false);

// Custom fade time
AudioManager.StopMusic(true, 2.0);
```

**Returns:** `self` for chaining.

---

#### PauseMusic(fade = true, fade_time = 0.5)

Pauses the current music track.

```gml
// When opening pause menu
AudioManager.PauseMusic(true, 0.3);
```

**Returns:** `self` for chaining.

---

#### ResumeMusic(fade = true, fade_time = 0.5)

Resumes paused music.

```gml
// When closing pause menu
AudioManager.ResumeMusic(true, 0.3);
```

**Returns:** `self` for chaining.

---

#### CrossfadeMusic(new_music, duration = 2.0)

Smoothly transitions from current music to a new track.

```gml
// Switch to battle music
AudioManager.CrossfadeMusic(mus_battle, 1.5);

// Quick transition
AudioManager.CrossfadeMusic(mus_game_over, 0.5);
```

**Parameters:**
- `new_music` - The music asset to transition to
- `duration` - Crossfade duration in seconds (default: 2.0)

**Returns:** `self` for chaining.

---

### Music Playlists

#### CreatePlaylist(music_list, shuffle = false)

Creates a playlist from an array of music assets.

```gml
var overworld_music = [
    mus_overworld_1,
    mus_overworld_2,
    mus_overworld_3,
    mus_overworld_4
];

AudioManager.CreatePlaylist(overworld_music, true); // Shuffled
```

**Parameters:**
- `music_list` - Array of music assets
- `shuffle` - Whether to shuffle the playlist

**Returns:** `self` for chaining.

---

#### PlayPlaylist(start_index = 0, shuffle = false)

Starts playing the current playlist.

```gml
AudioManager.PlayPlaylist(0, false);
```

**Returns:** `self` for chaining.

---

#### NextTrack(fade = true, fade_time = 1.0)

Skips to the next track in the playlist.

```gml
// Skip current track
AudioManager.NextTrack(true, 1.0);
```

**Returns:** `self` for chaining.

---

#### PreviousTrack(fade = true, fade_time = 1.0)

Goes back to the previous track in the playlist.

```gml
AudioManager.PreviousTrack(true, 1.0);
```

**Returns:** `self` for chaining.

---

### Volume Control

#### SetMasterVolume(volume, fade_time = 0)

Sets the master volume.

```gml
AudioManager.SetMasterVolume(0.8, 0.5); // Fade to 80% over 0.5 seconds
AudioManager.SetMasterVolume(0); // Mute immediately
```

**Returns:** `self` for chaining.

---

#### SetSFXVolume(volume, fade_time = 0)

Sets the SFX group volume.

```gml
AudioManager.SetSFXVolume(0.7);
```

**Returns:** `self` for chaining.

---

#### SetMusicVolume(volume, fade_time = 0)

Sets the music group volume.

```gml
AudioManager.SetMusicVolume(0.6);
```

**Returns:** `self` for chaining.

---

#### SetAmbientVolume(volume, fade_time = 0)

Sets the ambient group volume.

```gml
AudioManager.SetAmbientVolume(0.4);
```

**Returns:** `self` for chaining.

---

#### SetGroupVolume(group, volume, fade_time = 0)

Sets volume for any audio group.

```gml
AudioManager.SetGroupVolume(AUDIO_GROUP.VOICE, 0.9, 0.3);
AudioManager.SetGroupVolume(AUDIO_GROUP.UI, 0.5);
```

**Parameters:**
- `group` - The audio group
- `volume` - Volume level (0.0 to 1.0)
- `fade_time` - Fade duration in seconds

**Returns:** `self` for chaining.

---

#### MuteGroup(group, mute = true, fade_time = 0.3)

Mutes or unmutes an audio group.

```gml
// Mute SFX during cutscene
AudioManager.MuteGroup(AUDIO_GROUP.SFX, true, 0.5);

// Unmute after cutscene
AudioManager.MuteGroup(AUDIO_GROUP.SFX, false, 0.5);
```

**Returns:** `self` for chaining.

---

#### MuteAll(mute = true, fade_time = 0.3)

Mutes or unmutes all audio groups.

```gml
// Mute everything
AudioManager.MuteAll(true, 0.3);

// Unmute
AudioManager.MuteAll(false, 0.3);
```

**Returns:** `self` for chaining.

---

### Fading and Crossfading

#### FadeInMusic(duration = 1.0, target_volume = 1.0)

Fades in the current music from silence.

```gml
AudioManager.PlayMusic(mus_theme, false); // Start silent
AudioManager.FadeInMusic(2.0, 0.8); // Fade in over 2 seconds
```

**Returns:** `self` for chaining.

---

#### FadeOutMusic(duration = 1.0)

Fades out the current music.

```gml
AudioManager.FadeOutMusic(1.5);
```

**Returns:** `self` for chaining.

---

### Audio Ducking

Audio ducking automatically lowers music volume when priority sounds (like dialogue or important SFX) are playing.

#### EnableDucking(enabled = true)

Enables or disables audio ducking.

```gml
AudioManager.EnableDucking(true);
```

**Returns:** `self` for chaining.

---

#### SetDuckingReduction(reduction, release_time = 0.5)

Configures ducking behavior.

```gml
// Reduce music by 60% when voice is playing
AudioManager.SetDuckingReduction(0.6, 0.3);
```

**Parameters:**
- `reduction` - Amount to reduce music volume (0.0 to 1.0)
- `release_time` - Time to restore volume after priority sound stops

**Returns:** `self` for chaining.

---

### Reverb Effects

#### SetReverbPreset(preset, wet_mix = 0.5)

Applies a reverb preset to the audio.

```gml
// Cave environment
AudioManager.SetReverbPreset(AUDIO_REVERB.CAVE, 0.4);

// Large hall
AudioManager.SetReverbPreset(AUDIO_REVERB.HALL, 0.5);

// Underwater effect
AudioManager.SetReverbPreset(AUDIO_REVERB.UNDERWATER, 0.6);

// Disable reverb
AudioManager.SetReverbPreset(AUDIO_REVERB.OFF);
```

**Parameters:**
- `preset` - Reverb preset from AUDIO_REVERB enum
- `wet_mix` - Wet/dry mix (0.0 to 1.0)

**Returns:** `self` for chaining.

---

### Utility Methods

#### GetStats()

Returns audio system statistics.

```gml
var stats = AudioManager.GetStats();
show_debug_message($"Active sounds: {stats.active_sounds}");
show_debug_message($"Total played: {stats.total_played}");
show_debug_message($"Music playing: {stats.music_playing}");
```

**Returns:** Struct with statistics.

---

#### Update(delta_time = 1/60)

Updates the audio system (call in Step event).

```gml
// In a controller object's Step event
AudioManager.Update();
```

**Returns:** `self` for chaining.

---

#### Free()

Cleans up all audio resources.

```gml
// In Game End event
AudioManager.Free();
```

---

## Complete Examples

### Example 1: Basic Game Audio Setup

```gml
// Create Event - Register all sounds
AudioManager.RegisterSFX(snd_jump, AUDIO_GROUP.SFX, AUDIO_PRIORITY.NORMAL);
AudioManager.RegisterSFX(snd_land, AUDIO_GROUP.SFX, AUDIO_PRIORITY.LOW);
AudioManager.RegisterSFX(snd_coin, AUDIO_GROUP.SFX, AUDIO_PRIORITY.HIGH);
AudioManager.RegisterSFX(snd_hurt, AUDIO_GROUP.SFX, AUDIO_PRIORITY.HIGH);
AudioManager.RegisterSFX(snd_ui_click, AUDIO_GROUP.UI, AUDIO_PRIORITY.NORMAL);
AudioManager.RegisterSFX(snd_ui_hover, AUDIO_GROUP.UI, AUDIO_PRIORITY.LOW);

AudioManager.RegisterMusic(mus_main, true);
AudioManager.RegisterMusic(mus_boss, true, mus_boss_intro);
AudioManager.RegisterAmbient(snd_wind, 0.3, 2.0);

// Set initial volumes
AudioManager.SetMasterVolume(0.8);
AudioManager.SetSFXVolume(0.7);
AudioManager.SetMusicVolume(0.6);
AudioManager.SetAmbientVolume(0.4);

// Enable ducking for voice lines
AudioManager.EnableDucking(true);
AudioManager.SetDuckingReduction(0.5, 0.3);

// Start music
AudioManager.PlayMusic(mus_main, true, 1.0);

// Step Event
AudioManager.Update();

// Player jump
if (InputManager.IsJustPressed("Jump") && on_ground) {
    AudioManager.PlaySFX(snd_jump, 0.8, 1.0 + random_range(-0.05, 0.05));
}

// Player land
if (just_landed) {
    AudioManager.PlaySFX(snd_land, 0.6);
}

// Collect coin
if (place_meeting(x, y, obj_coin)) {
    AudioManager.PlaySFX(snd_coin, 0.9, 1.0 + random_range(-0.1, 0.1));
}

// Enter boss area
if (entered_boss_room) {
    AudioManager.CrossfadeMusic(mus_boss, 1.5);
    AudioManager.SetReverbPreset(AUDIO_REVERB.LARGE_ROOM, 0.4);
}

// Exit boss area
if (exited_boss_room) {
    AudioManager.CrossfadeMusic(mus_main, 1.5);
    AudioManager.SetReverbPreset(AUDIO_REVERB.OFF);
}
```

### Example 2: 3D Audio for Top-Down Game

```gml
// Create Event
AudioManager.RegisterSFX(snd_enemy_spawn, AUDIO_GROUP.SFX);
AudioManager.RegisterSFX(snd_explosion, AUDIO_GROUP.SFX);
AudioManager.RegisterSFX(snd_engine, AUDIO_GROUP.SFX);

AudioManager.SetSpatialSettings(600, 1.2, 1.0);

// Step Event - Update listener position to camera
AudioManager.SetListenerPosition(camera.x, camera.y, 0);
AudioManager.Update();

// Enemy spawn (3D sound)
function SpawnEnemy(x, y, type) {
    var enemy = instance_create_layer(x, y, "Enemies", type);
    AudioManager.PlaySFX3D(snd_enemy_spawn, x, y, 0, 0.7);
    return enemy;
}

// Explosion at position
function CreateExplosion(x, y) {
    AudioManager.PlaySFX3D(snd_explosion, x, y, 0, 1.0);
    // Create visual effect...
}

// Vehicle with continuous engine sound
function CreateVehicle(x, y) {
    var vehicle = instance_create_layer(x, y, "Vehicles", obj_car);
    vehicle.engine_sound = AudioManager.PlaySFX3D(snd_engine, x, y, 0, 0.5);
    return vehicle;
}

// In vehicle Step event
AudioManager.UpdateSoundPosition(engine_sound, x, y, 0);
```

### Example 3: Music Playlist with Dynamic Changes

```gml
// Create Event
// Different playlists for different areas
var forest_playlist = [mus_forest_1, mus_forest_2, mus_forest_3];
var cave_playlist = [mus_cave_1, mus_cave_2];
var town_playlist = [mus_town_1, mus_town_2, mus_town_3, mus_town_4];
var battle_playlist = [mus_battle_1, mus_battle_2, mus_battle_3];

// Register all music
array_foreach(forest_playlist, function(track) {
    AudioManager.RegisterMusic(track, true);
});
// ... register others similarly

// Function to change area music
function ChangeAreaMusic(area) {
    switch(area) {
        case "forest":
            AudioManager.CreatePlaylist(forest_playlist, true);
            break;
        case "cave":
            AudioManager.CreatePlaylist(cave_playlist, true);
            AudioManager.SetReverbPreset(AUDIO_REVERB.CAVE, 0.5);
            break;
        case "town":
            AudioManager.CreatePlaylist(town_playlist, false); // Sequential
            AudioManager.SetReverbPreset(AUDIO_REVERB.OFF);
            break;
    }
    
    AudioManager.PlayPlaylist(0, area != "town");
}

// Enter battle
function EnterBattle() {
    // Save current playlist position
    saved_playlist = AudioManager.music_playlist;
    saved_index = AudioManager.playlist_index;
    
    // Switch to battle music
    AudioManager.CreatePlaylist(battle_playlist, true);
    AudioManager.PlayPlaylist();
}

// Exit battle
function ExitBattle() {
    // Restore previous playlist
    AudioManager.music_playlist = saved_playlist;
    AudioManager.playlist_index = saved_index;
    AudioManager.NextTrack(true, 1.0);
}

// UI button to skip track
if (InputManager.IsJustPressed("SkipTrack")) {
    AudioManager.NextTrack(true, 0.5);
}
```

### Example 4: Cutscene Audio Management

```gml
// Cutscene controller
function StartCutscene() {
    // Pause gameplay audio
    AudioManager.MuteGroup(AUDIO_GROUP.SFX, true, 0.5);
    AudioManager.MuteGroup(AUDIO_GROUP.AMBIENT, true, 0.5);
    
    // Lower music for dialogue
    AudioManager.SetMusicVolume(0.3, 0.5);
    
    // Enable voice group
    AudioManager.SetGroupVolume(AUDIO_GROUP.VOICE, 1.0);
}

function PlayDialogue(voice_line, text) {
    // Ducking will automatically lower music further
    var sound_id = AudioManager.PlaySFX(voice_line, 1.0, 1.0, AUDIO_PRIORITY.CRITICAL);
    
    // Show text
    DialogueBox.Show(text);
    
    return sound_id;
}

function EndCutscene() {
    // Restore normal audio
    AudioManager.MuteGroup(AUDIO_GROUP.SFX, false, 0.5);
    AudioManager.MuteGroup(AUDIO_GROUP.AMBIENT, false, 0.5);
    AudioManager.SetMusicVolume(0.6, 0.5);
    AudioManager.SetGroupVolume(AUDIO_GROUP.VOICE, 0.8);
}
```

### Example 5: Options Menu with Volume Sliders

```gml
// Options menu controller
function CreateAudioOptions() {
    var options = {
        master_vol: AudioManager.group_volumes[? "MASTER"],
        sfx_vol: AudioManager.group_volumes[? "SFX"],
        music_vol: AudioManager.group_volumes[? "MUSIC"],
        ambient_vol: AudioManager.group_volumes[? "AMBIENT"],
        voice_vol: AudioManager.group_volumes[? "VOICE"]
    };
    
    return options;
}

function ApplyAudioOptions(options) {
    AudioManager.SetMasterVolume(options.master_vol);
    AudioManager.SetSFXVolume(options.sfx_vol);
    AudioManager.SetMusicVolume(options.music_vol);
    AudioManager.SetAmbientVolume(options.ambient_vol);
    AudioManager.SetGroupVolume(AUDIO_GROUP.VOICE, options.voice_vol);
}

// Slider interaction
function OnMasterVolumeChanged(value) {
    AudioManager.SetMasterVolume(value);
    
    // Preview sound
    if (!audio_is_playing(preview_sound)) {
        preview_sound = AudioManager.PlaySFX(snd_ui_click, 0.5);
    }
}

// Save settings
function SaveAudioSettings() {
    var settings = CreateAudioOptions();
    File.SaveJSON("audio_settings.json", settings);
}

// Load settings
function LoadAudioSettings() {
    var settings = File.LoadJSON("audio_settings.json");
    if (settings != undefined) {
        ApplyAudioOptions(settings);
    }
}
```

### Example 6: Environmental Audio Zones

```gml
// Audio zone object
function AudioZone(_area_type) constructor {
    area_type = _area_type;
    
    function OnEnter() {
        switch(area_type) {
            case "cave":
                AudioManager.SetReverbPreset(AUDIO_REVERB.CAVE, 0.5);
                AudioManager.CrossfadeMusic(mus_cave, 2.0);
                AudioManager.RegisterAmbient(snd_cave_drips, 0.4, 2.0);
                break;
                
            case "forest":
                AudioManager.SetReverbPreset(AUDIO_REVERB.OFF);
                AudioManager.CrossfadeMusic(mus_forest, 2.0);
                AudioManager.RegisterAmbient(snd_wind_trees, 0.3, 2.0);
                break;
                
            case "underwater":
                AudioManager.SetReverbPreset(AUDIO_REVERB.UNDERWATER, 0.7);
                AudioManager.SetSFXVolume(0.4, 0.5); // Muffle SFX
                AudioManager.RegisterAmbient(snd_underwater, 0.5, 1.0);
                break;
                
            case "cathedral":
                AudioManager.SetReverbPreset(AUDIO_REVERB.CATHEDRAL, 0.6);
                AudioManager.CrossfadeMusic(mus_cathedral, 3.0);
                break;
        }
    }
    
    function OnExit() {
        // Reset to defaults
        AudioManager.SetReverbPreset(AUDIO_REVERB.OFF);
        AudioManager.SetSFXVolume(0.7, 0.5);
        AudioManager.CrossfadeMusic(mus_overworld, 2.0);
    }
}

// Place audio zones in room
var cave_zone = new AudioZone("cave");
var forest_zone = new AudioZone("forest");

// Collision with player
if (place_meeting(x, y, obj_player)) {
    if (!is_active) {
        zone.OnEnter();
        is_active = true;
    }
} else {
    if (is_active) {
        zone.OnExit();
        is_active = false;
    }
}
```
