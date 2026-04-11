// Enums
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

enum AUDIO_FADE {
    LINEAR,
    SMOOTH,
    EXPONENTIAL,
    LOGARITHMIC
}

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

enum AUDIO_PRIORITY {
    LOWEST = 0,
    LOW = 25,
    NORMAL = 50,
    HIGH = 75,
    CRITICAL = 100
}

enum AUDIO_STATE {
    STOPPED,
    PLAYING,
    PAUSED,
    FADING_IN,
    FADING_OUT
}

function AudioManager() constructor {
    // volume groups
    groups = ds_map_create();
    group_volumes = ds_map_create();
    group_muted = ds_map_create();
    
    // active sounds tracking
    active_sounds = ds_list_create();
    active_music = ds_list_create();
    active_ambient = ds_list_create();
    
    // sound count tracking
    active_count = 0;
    max_simultaneous_sounds = 32;
    
    // music system
    current_music = undefined;
    next_music = undefined;
    music_playlist = ds_list_create();
    playlist_index = 0;
    music_fade_active = false;
    music_fade_timer = 0;
    music_fade_duration = 0;
    music_fade_start_vol = 0;
    music_fade_target_vol = 0;
    music_fade_type = AUDIO_FADE.SMOOTH;
    
    // 3D audio
    listener_position = { x: 0, y: 0, z: 0 };
    listener_orientation = { dx: 0, dy: 1, dz: 0, ux: 0, uy: 0, uz: 1 };
    spatial_enabled = true;
    max_distance = 1000;
    rolloff_factor = 1.0;
    doppler_factor = 1.0;
    
    // 3D audio emitters (pool works for emitters)
    emitter_pool = [];
    emitter_pool_size = 32;
    
    // effects
    reverb_active = false;
    reverb_preset = AUDIO_REVERB.OFF;
    reverb_params = ds_map_create();
    
    // ducking
    ducking_enabled = true;
    ducking_groups = [AUDIO_GROUP.SFX, AUDIO_GROUP.VOICE];
    ducking_reduction = 0.5; // Reduce music by 50%
    ducking_release = 0.5; // Seconds
    
    // callbacks
    on_music_changed = undefined;
    on_volume_changed = undefined;
    
    // performance
    stats = {
        sounds_played: 0,
        sounds_active: 0,
        peak_sounds: 0
    };
    
    // init
    function InitializeGroups() {
        var group_names = [
            "MASTER", "SFX", "MUSIC", "AMBIENT", 
            "VOICE", "UI", "CUSTOM_1", "CUSTOM_2", "CUSTOM_3"
        ];
        
        for (var i = 0; i < array_length(group_names); i++) {
            groups[? group_names[i]] = ds_list_create();
            group_volumes[? group_names[i]] = 1.0;
            group_muted[? group_names[i]] = false;
        }
    } InitializeGroups();
    
    function InitializeEmitters() {
        for (var i = 0; i < emitter_pool_size; i++) {
            var emitter = audio_emitter_create();
            audio_emitter_falloff(emitter, 100, max_distance, rolloff_factor);
            emitter_pool[i] = {
                emitter: emitter,
                in_use: false,
                current_sound: -1
            };
        }
    } InitializeEmitters();
    
    // calculate final volume with group settings
    function CalculateFinalVolume(sound_instance) {
        var group = sound_instance.group;
        var base_volume = sound_instance.volume;
        
        var group_vol = group_volumes[? group];
        var group_mute = group_muted[? group];
        var master_vol = group_volumes[? "MASTER"];
        var master_mute = group_muted[? "MASTER"];
        
        if (master_mute || group_mute) {
            return 0;
        }
        
        return base_volume * group_vol * master_vol;
    };
    
    // clean up finished sounds
    function CleanFinishedSounds() {
        for (var i = ds_list_size(active_sounds) - 1; i >= 0; i--) {
            var sound = active_sounds[| i];
            if (!audio_is_playing(sound.id)) {
                // free emitter if this was a 3D sound
                if (sound.spatial && sound.emitter_index != undefined) {
                    var slot = emitter_pool[sound.emitter_index];
                    slot.in_use = false;
                    slot.current_sound = -1;
                }
                ds_list_delete(active_sounds, i);
                active_count--;
            }
        }
    };
    
    // get free emitter for 3D sounds
    function GetFreeEmitter(priority) {
        // look for completely free emitter
        for (var i = 0; i < emitter_pool_size; i++) {
            var slot = emitter_pool[i];
            if (!slot.in_use) {
                slot.in_use = true;
                return { slot: slot, index: i };
            }
        }
        
        // look for emitter whose sound finished
        for (var i = 0; i < emitter_pool_size; i++) {
            var slot = emitter_pool[i];
            if (!audio_emitter_is_playing(slot.emitter)) {
                slot.in_use = true;
                return { slot: slot, index: i };
            }
        }
        
        // steal from lowest priority active 3D sound
        var lowest_priority = AUDIO_PRIORITY.CRITICAL + 1;
        var stolen_index = -1;
        
        for (var i = 0; i < ds_list_size(active_sounds); i++) {
            var sound = active_sounds[| i];
            if (sound.spatial && sound.emitter_index != undefined) {
                if (sound.priority < lowest_priority && sound.priority < priority) {
                    lowest_priority = sound.priority;
                    stolen_index = sound.emitter_index;
                }
            }
        }
        
        if (stolen_index != -1) {
            var slot = emitter_pool[stolen_index];
            audio_stop_sound(slot.current_sound);
            slot.in_use = true;
            return { slot: slot, index: stolen_index };
        }
        
        // fallback: use first emitter
        var first_slot = emitter_pool[0];
        audio_stop_sound(first_slot.current_sound);
        first_slot.in_use = true;
        return { slot: first_slot, index: 0 };
    };
    
    // register sound
    function RegisterSFX(sound_asset, group = AUDIO_GROUP.SFX, priority = AUDIO_PRIORITY.NORMAL) {
        var sound_info = {
            asset: sound_asset,
            group: group,
            priority: priority,
            max_instances: 3,
            cooldown: 0,
            last_played: 0,
            volume_mod: 1.0,
            pitch_mod: 1.0,
            spatial: false,
            loop: false
        };
        
        ds_list_add(groups[? group], sound_info);
        return sound_info;
    };
    
    function RegisterMusic(music_asset, loop = true, intro_asset = undefined) {
        var music_info = {
            asset: music_asset,
            intro: intro_asset,
            loop: loop,
            volume_mod: 1.0,
            bpm: 120,
            beat_offset: 0
        };
        
        ds_list_add(groups[? "MUSIC"], music_info);
        return music_info;
    };
    
    function RegisterAmbient(ambient_asset, volume = 0.5, fade_in = 2.0) {
        var ambient_info = {
            asset: ambient_asset,
            volume_mod: volume,
            fade_in: fade_in,
            active: false
        };
        
        ds_list_add(groups[? "AMBIENT"], ambient_info);
        return ambient_info;
    };
    
    // playback control
    function PlaySFX(sound_asset, volume = 1.0, pitch = 1.0, priority = AUDIO_PRIORITY.NORMAL) {
        // clean up finished sounds first
        CleanFinishedSounds();
        
        // check if we need to cull
        if (active_count >= max_simultaneous_sounds) {
            if (!CullLowestPrioritySound(priority)) {
                return -1;
            }
        }
        
        // play the sound
        var sound_id = audio_play_sound(sound_asset, priority, false);
        
        if (sound_id != -1) {
            var group = GetSoundGroup(sound_asset);
            
            var sound_instance = {
                id: sound_id,
                asset: sound_asset,
                group: group,
                volume: volume,
                pitch: pitch,
                priority: priority,
                start_time: current_time,
                state: AUDIO_STATE.PLAYING,
                spatial: false
            };
            
            var final_volume = CalculateFinalVolume(sound_instance);
            
            audio_sound_gain(sound_id, final_volume, 0);
            audio_sound_pitch(sound_id, pitch);
            
            ds_list_add(active_sounds, sound_instance);
            active_count++;
            
            stats.sounds_played++;
            stats.sounds_active = active_count;
            stats.peak_sounds = max(stats.peak_sounds, stats.sounds_active);
            
            show_debug_message($"[Audio] Playing SFX: {sound_asset} (Vol: {final_volume}, Pitch: {pitch})");
            
            return sound_id;
        }
        
        return -1;
    };
    
    function PlaySFX3D(sound_asset, x, y, z = 0, volume = 1.0, pitch = 1.0, priority = AUDIO_PRIORITY.NORMAL) {
        if (!spatial_enabled) {
            return PlaySFX(sound_asset, volume, pitch, priority);
        }
        
        // calculate distance
        var dx = x - listener_position.x;
        var dy = y - listener_position.y;
        var dz = z - listener_position.z;
        var distance = sqrt(dx*dx + dy*dy + dz*dz);
        
        // too far away
        if (distance > max_distance) {
            return -1;
        }
        
        // get an emitter
        var emitter_result = GetFreeEmitter(priority);
        var emitter_slot = emitter_result.slot;
        var emitter_index = emitter_result.index;
        
        // position the emitter
        audio_emitter_position(emitter_slot.emitter, x, y, z);
        
        // calculate distance attenuation
        var attenuation = max(0, 1 - (distance / max_distance));
        var attenuated_volume = volume * attenuation;
        
        // play on emitter
        var sound_id = audio_play_sound_on(emitter_slot.emitter, sound_asset, false, priority);
        
        if (sound_id != -1) {
            emitter_slot.current_sound = sound_id;
            
            var group = GetSoundGroup(sound_asset);
            
            var sound_instance = {
                id: sound_id,
                asset: sound_asset,
                group: group,
                volume: volume,
                pitch: pitch,
                priority: priority,
                start_time: current_time,
                state: AUDIO_STATE.PLAYING,
                spatial: true,
                position: { x: x, y: y, z: z },
                emitter_index: emitter_index,
                emitter: emitter_slot.emitter
            };
            
            var final_volume = CalculateFinalVolume(sound_instance) * attenuation;
            
            audio_sound_gain(sound_id, final_volume, 0);
            audio_sound_pitch(sound_id, pitch);
            
            ds_list_add(active_sounds, sound_instance);
            active_count++;
            
            stats.sounds_played++;
            stats.sounds_active = active_count;
            stats.peak_sounds = max(stats.peak_sounds, stats.sounds_active);
            
            show_debug_message($"[Audio] Playing 3D SFX: {sound_asset} at ({x}, {y}, {z})");
            
            return sound_id;
        }
        
        // failed to play, release emitter
        emitter_slot.in_use = false;
        return -1;
    };
    
    function PlayMusic(music_asset, fade = true, fade_time = 1.0, loop = true) {
        if (current_music != undefined) {
            StopMusic(fade, fade_time);
        }
        
        var music_info = GetMusicInfo(music_asset);
        var intro_asset = music_info != undefined ? music_info.intro : undefined;
        
        var sound_id;
        
        if (intro_asset != undefined) {
            sound_id = audio_play_sound(intro_asset, AUDIO_PRIORITY.CRITICAL, false);
            
            var intro_length = audio_sound_length(intro_asset);
			// GM doesnt have built in scheduling, so it's being handled in update
        } else {
            sound_id = audio_play_sound(music_asset, AUDIO_PRIORITY.CRITICAL, loop);
        }
        
        if (sound_id != -1) {
            var music_instance = {
                id: sound_id,
                asset: music_asset,
                intro: intro_asset,
                loop: loop,
                state: fade ? AUDIO_STATE.FADING_IN : AUDIO_STATE.PLAYING,
                volume: 1.0
            };
            
            current_music = music_instance;
            ds_list_add(active_music, music_instance);
            
            var group_vol = group_volumes[? "MUSIC"];
            var group_mute = group_muted[? "MUSIC"];
            var final_volume = group_mute ? 0 : group_vol * group_volumes[? "MASTER"];
            
            if (fade) {
                audio_sound_gain(sound_id, 0, 0);
                FadeInMusic(fade_time);
            } else {
                audio_sound_gain(sound_id, final_volume, 0);
            }
            
            if (on_music_changed != undefined) {
                on_music_changed(music_asset, true);
            }
            
            show_debug_message($"[Audio] Playing Music: {music_asset}");
            
            return sound_id;
        }
        
        return -1;
    };
    
    function StopMusic(fade = true, fade_time = 1.0) {
        if (current_music == undefined) return self;
        
        if (fade) {
            FadeOutMusic(fade_time);
        } else {
            if (audio_is_playing(current_music.id)) {
                audio_stop_sound(current_music.id);
            }
            current_music = undefined;
        }
        
        if (on_music_changed != undefined) {
            on_music_changed(undefined, false);
        }
        
        return self;
    };
    
    function PauseMusic(fade = true, fade_time = 0.5) {
        if (current_music == undefined) return self;
        
        if (fade) {
            FadeOutMusic(fade_time);
        } else {
            audio_pause_sound(current_music.id);
            current_music.state = AUDIO_STATE.PAUSED;
        }
        
        return self;
    };
    
    function ResumeMusic(fade = true, fade_time = 0.5) {
        if (current_music == undefined) return self;
        
        if (current_music.state == AUDIO_STATE.PAUSED) {
            audio_resume_sound(current_music.id);
            
            if (fade) {
                FadeInMusic(fade_time);
            } else {
                current_music.state = AUDIO_STATE.PLAYING;
            }
        }
        
        return self;
    };
    
    // volume control
    function SetGroupVolume(group, volume, fade_time = 0) {
        volume = clamp(volume, 0, 1);
        group_volumes[? group] = volume;
        
        UpdateGroupVolume(group, fade_time);
        
        if (on_volume_changed != undefined) {
            on_volume_changed(group, volume);
        }
        
        return self;
    };
    
    function SetMasterVolume(volume, fade_time = 0) {
        return SetGroupVolume("MASTER", volume, fade_time);
    };
    
    function SetSFXVolume(volume, fade_time = 0) {
        return SetGroupVolume("SFX", volume, fade_time);
    };
    
    function SetMusicVolume(volume, fade_time = 0) {
        return SetGroupVolume("MUSIC", volume, fade_time);
    };
    
    function SetAmbientVolume(volume, fade_time = 0) {
        return SetGroupVolume("AMBIENT", volume, fade_time);
    };
    
    function MuteGroup(group, mute = true, fade_time = 0.3) {
        group_muted[? group] = mute;
        UpdateGroupVolume(group, fade_time);
        return self;
    };
    
    function MuteAll(mute = true, fade_time = 0.3) {
        var keys = ds_map_keys_to_array(groups);
        for (var i = 0; i < array_length(keys); i++) {
            MuteGroup(keys[i], mute, fade_time);
        }
        return self;
    };
    
    function UpdateGroupVolume(group, fade_time) {
        var group_vol = group_volumes[? group];
        var group_mute = group_muted[? group];
        var master_vol = group_volumes[? "MASTER"];
        var master_mute = group_muted[? "MASTER"];
        
        var final_volume = (master_mute || group_mute) ? 0 : group_vol * master_vol;
        
        for (var i = 0; i < ds_list_size(active_sounds); i++) {
            var sound = active_sounds[| i];
            if (sound.group == group) {
                audio_sound_gain(sound.id, final_volume * sound.volume, fade_time * 1000);
            }
        }
        
        if (group == "MUSIC" && current_music != undefined) {
            audio_sound_gain(current_music.id, final_volume * current_music.volume, fade_time * 1000);
        }
    };
    
    // face funcs
    function FadeInMusic(duration = 1.0, target_volume = 1.0) {
        if (current_music == undefined) return self;
        
        music_fade_active = true;
        music_fade_timer = 0;
        music_fade_duration = duration;
        music_fade_start_vol = 0;
        music_fade_target_vol = target_volume;
        music_fade_type = AUDIO_FADE.SMOOTH;
        
        current_music.state = AUDIO_STATE.FADING_IN;
        
        return self;
    };
    
    function FadeOutMusic(duration = 1.0) {
        if (current_music == undefined) return self;
        
        music_fade_active = true;
        music_fade_timer = 0;
        music_fade_duration = duration;
        music_fade_start_vol = current_music.volume;
        music_fade_target_vol = 0;
        music_fade_type = AUDIO_FADE.SMOOTH;
        
        current_music.state = AUDIO_STATE.FADING_OUT;
        
        return self;
    };
    
    function CrossfadeMusic(new_music, duration = 2.0) {
        StopMusic(true, duration);
        PlayMusic(new_music, true, duration);
        return self;
    };
    
    // music playlist
    function CreatePlaylist(music_list, shuffle = false) {
        ds_list_clear(music_playlist);
        
        for (var i = 0; i < array_length(music_list); i++) {
            ds_list_add(music_playlist, music_list[i]);
        }
        
        if (shuffle) {
            ds_list_shuffle(music_playlist);
        }
        
        playlist_index = 0;
        return self;
    };
    
    function PlayPlaylist(start_index = 0, shuffle = false) {
        if (ds_list_empty(music_playlist)) return self;
        
        if (shuffle) {
            ds_list_shuffle(music_playlist);
        }
        
        playlist_index = clamp(start_index, 0, ds_list_size(music_playlist) - 1);
        PlayMusic(music_playlist[| playlist_index]);
        
        return self;
    };
    
    function NextTrack(fade = true, fade_time = 1.0) {
        if (ds_list_empty(music_playlist)) return self;
        
        playlist_index++;
        if (playlist_index >= ds_list_size(music_playlist)) {
            playlist_index = 0;
        }
        
        CrossfadeMusic(music_playlist[| playlist_index], fade_time);
        return self;
    };
    
    function PreviousTrack(fade = true, fade_time = 1.0) {
        if (ds_list_empty(music_playlist)) return self;
        
        playlist_index--;
        if (playlist_index < 0) {
            playlist_index = ds_list_size(music_playlist) - 1;
        }
        
        CrossfadeMusic(music_playlist[| playlist_index], fade_time);
        return self;
    };
    
    // ducking system
    function EnableDucking(enabled = true) {
        ducking_enabled = enabled;
        return self;
    };
    
    function SetDuckingReduction(reduction, release_time = 0.5) {
        ducking_reduction = clamp(reduction, 0, 1);
        ducking_release = release_time;
        return self;
    };
    
    function ApplyDucking() {
        if (!ducking_enabled) return;
        
        var has_priority_sound = false;
        
        for (var i = 0; i < ds_list_size(active_sounds); i++) {
            var sound = active_sounds[| i];
            for (var j = 0; j < array_length(ducking_groups); j++) {
                if (sound.group == ducking_groups[j] && sound.state == AUDIO_STATE.PLAYING) {
                    has_priority_sound = true;
                    break;
                }
            }
            if (has_priority_sound) break;
        }
        
        if (current_music != undefined) { // ducking
            var target_vol = has_priority_sound ? (1.0 - ducking_reduction) : 1.0;
            var current_vol = current_music.volume;
            
            if (abs(current_vol - target_vol) > 0.01) {
                var new_vol = lerp(current_vol, target_vol, ducking_release * 0.1);
                current_music.volume = new_vol;
                
                var group_vol = group_volumes[? "MUSIC"];
                var master_vol = group_volumes[? "MASTER"];
                audio_sound_gain(current_music.id, new_vol * group_vol * master_vol, 0);
            }
        }
    };
    
    // 3d
    function SetListenerPosition(x, y, z = 0) {
        listener_position = { x: x, y: y, z: z };
        audio_listener_position(x, y, z);
        return self;
    };
    
    function SetListenerOrientation(look_x, look_y, look_z, up_x, up_y, up_z) {
        listener_orientation = { 
            dx: look_x, dy: look_y, dz: look_z, 
            ux: up_x, uy: up_y, uz: up_z 
        };
        audio_listener_orientation(
            look_x, look_y, look_z,
            up_x, up_y, up_z
        );
        return self;
    };
    
    function SetSpatialSettings(max_dist = 1000, rolloff = 1.0, doppler = 1.0) {
        max_distance = max_dist;
        rolloff_factor = rolloff;
        doppler_factor = doppler;
        
        // update all emitters with new settings
        for (var i = 0; i < emitter_pool_size; i++) {
            audio_emitter_falloff(emitter_pool[i].emitter, 100, max_distance, rolloff_factor);
        }
        
        return self;
    };
    
    function UpdateSoundPosition(sound_id, x, y, z = 0) {
        for (var i = 0; i < ds_list_size(active_sounds); i++) {
            var sound = active_sounds[| i];
            if (sound.id == sound_id && sound.spatial) {
                sound.position = { x: x, y: y, z: z };
                if (sound.emitter_index != undefined) {
                    audio_emitter_position(emitter_pool[sound.emitter_index].emitter, x, y, z);
                }
                break;
            }
        }
        return self;
    };
    
    // reverb
    function SetReverbPreset(preset, wet_mix = 0.5) {
        reverb_preset = preset;
        reverb_active = preset != AUDIO_REVERB.OFF;
        
        switch(preset) {
            case AUDIO_REVERB.SMALL_ROOM:
                reverb_params[? "size"] = 0.3;
                reverb_params[? "damping"] = 0.3;
                reverb_params[? "width"] = 0.5;
                break;
            case AUDIO_REVERB.MEDIUM_ROOM:
                reverb_params[? "size"] = 0.5;
                reverb_params[? "damping"] = 0.4;
                reverb_params[? "width"] = 0.7;
                break;
            case AUDIO_REVERB.LARGE_ROOM:
                reverb_params[? "size"] = 0.7;
                reverb_params[? "damping"] = 0.5;
                reverb_params[? "width"] = 0.8;
                break;
            case AUDIO_REVERB.HALL:
                reverb_params[? "size"] = 0.9;
                reverb_params[? "damping"] = 0.6;
                reverb_params[? "width"] = 1.0;
                break;
            case AUDIO_REVERB.CAVE:
                reverb_params[? "size"] = 0.8;
                reverb_params[? "damping"] = 0.2;
                reverb_params[? "width"] = 0.6;
                break;
            case AUDIO_REVERB.UNDERWATER:
                reverb_params[? "size"] = 0.4;
                reverb_params[? "damping"] = 0.1;
                reverb_params[? "width"] = 0.3;
                break;
        }
        
		// TODO: GM doesnt support this, gotta find a way around it
        
        return self;
    };
    
    // utility
    function GetSoundGroup(sound_asset) {
        var keys = ds_map_keys_to_array(groups);
        for (var i = 0; i < array_length(keys); i++) {
            var group_list = groups[? keys[i]];
            for (var j = 0; j < ds_list_size(group_list); j++) {
                var info = group_list[| j];
                if (info.asset == sound_asset) {
                    return keys[i];
                }
            }
        }
        return "SFX"; // default group
    };
    
    function GetMusicInfo(music_asset) {
        var music_list = groups[? "MUSIC"];
        for (var i = 0; i < ds_list_size(music_list); i++) {
            var info = music_list[| i];
            if (info.asset == music_asset) {
                return info;
            }
        }
        return undefined;
    };
    
    function CullLowestPrioritySound(new_priority) {
        var lowest_priority = AUDIO_PRIORITY.CRITICAL + 1;
        var lowest_index = -1;
        
        for (var i = 0; i < ds_list_size(active_sounds); i++) {
            var sound = active_sounds[| i];
            if (sound.priority < lowest_priority && sound.priority < new_priority) {
                lowest_priority = sound.priority;
                lowest_index = i;
            }
        }
        
        if (lowest_index != -1) {
            var sound = active_sounds[| lowest_index];
            audio_stop_sound(sound.id);
            
            // free emitter if 3D sound
            if (sound.spatial && sound.emitter_index != undefined) {
                var slot = emitter_pool[sound.emitter_index];
                slot.in_use = false;
                slot.current_sound = -1;
            }
            
            ds_list_delete(active_sounds, lowest_index);
            active_count--;
            
            return true;
        }
        
        return false;
    };
    
    function IsPlaying(sound_id) {
        return audio_is_playing(sound_id);
    };
    
    function StopSound(sound_id, fade = false, fade_time = 0.1) {
        if (fade) {
            audio_sound_gain(sound_id, 0, fade_time * 1000);
        } else {
            audio_stop_sound(sound_id);
        }
        
        for (var i = 0; i < ds_list_size(active_sounds); i++) {
            var sound = active_sounds[| i];
            if (sound.id == sound_id) {
                // free emitter if 3D sound
                if (sound.spatial && sound.emitter_index != undefined) {
                    var slot = emitter_pool[sound.emitter_index];
                    slot.in_use = false;
                    slot.current_sound = -1;
                }
                ds_list_delete(active_sounds, i);
                active_count--;
                break;
            }
        }
        
        return self;
    };
    
    function StopAll(fade = false, fade_time = 0.3) {
        for (var i = ds_list_size(active_sounds) - 1; i >= 0; i--) {
            var sound = active_sounds[| i];
            StopSound(sound.id, fade, fade_time);
        }
        
        ds_list_clear(active_sounds);
        active_count = 0;
        
        return self;
    };
    
    // update
    function Update(delta_time = 1/60) {
        if (music_fade_active) {
            music_fade_timer += delta_time;
            var t = min(music_fade_timer / music_fade_duration, 1.0);
            
            var fade_value;
            switch(music_fade_type) {
                case AUDIO_FADE.SMOOTH:
                    fade_value = t * t * (3 - 2 * t);
                    break;
                case AUDIO_FADE.EXPONENTIAL:
                    fade_value = 1 - power(2, -10 * t);
                    break;
                case AUDIO_FADE.LOGARITHMIC:
                    fade_value = log10(9 * t + 1);
                    break;
                default:
                    fade_value = t;
            }
            
            var current_volume = lerp(music_fade_start_vol, music_fade_target_vol, fade_value);
            
            if (current_music != undefined) {
                current_music.volume = current_volume;
                var group_vol = group_volumes[? "MUSIC"];
                var master_vol = group_volumes[? "MASTER"];
                audio_sound_gain(current_music.id, current_volume * group_vol * master_vol, 0);
            }
            
            if (t >= 1.0) {
                music_fade_active = false;
                
                if (current_music != undefined) {
                    if (music_fade_target_vol == 0) {
                        audio_stop_sound(current_music.id);
                        current_music = undefined;
                    } else {
                        current_music.state = AUDIO_STATE.PLAYING;
                    }
                }
            }
        }
        
        // clean up finished sounds
        CleanFinishedSounds();
        
        // update 3D sounds
        if (spatial_enabled) {
            for (var i = 0; i < ds_list_size(active_sounds); i++) {
                var sound = active_sounds[| i];
                if (sound.spatial && sound.position != undefined) {
                    var dx = sound.position.x - listener_position.x;
                    var dy = sound.position.y - listener_position.y;
                    var dz = sound.position.z - listener_position.z;
                    var distance = sqrt(dx*dx + dy*dy + dz*dz);
                    
                    if (distance > max_distance) {
                        StopSound(sound.id);
                    } else {
                        var attenuation = max(0, 1 - (distance / max_distance));
                        var base_vol = CalculateFinalVolume(sound);
                        audio_sound_gain(sound.id, base_vol * attenuation, 0);
                    }
                }
            }
        }
        
        ApplyDucking();
        
        stats.sounds_active = active_count;
        
        return self;
    };
    
    // debug
    function GetStats() {
        return {
            active_sounds: stats.sounds_active,
            total_played: stats.sounds_played,
            peak_sounds: stats.peak_sounds,
            music_playing: current_music != undefined,
            master_volume: group_volumes[? "MASTER"],
            sfx_volume: group_volumes[? "SFX"],
            music_volume: group_volumes[? "MUSIC"]
        };
    };
    
    // cleanup
    function Free() {
        StopAll();
        StopMusic(false);
        
        // free emitters
        for (var i = 0; i < emitter_pool_size; i++) {
            if (emitter_pool[i].emitter != undefined) {
                audio_emitter_free(emitter_pool[i].emitter);
            }
        }
        emitter_pool = [];
        
        ds_map_destroy(groups);
        ds_map_destroy(group_volumes);
        ds_map_destroy(group_muted);
        ds_map_destroy(reverb_params);
        
        ds_list_destroy(active_sounds);
        ds_list_destroy(active_music);
        ds_list_destroy(active_ambient);
        ds_list_destroy(music_playlist);
    };
}
