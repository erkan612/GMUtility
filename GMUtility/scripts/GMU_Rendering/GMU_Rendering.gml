//  Camera System
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

enum CAMERA_SHAKE_TYPE {
    RANDOM,
    PERLIN,
    DIRECTIONAL,
    CIRCULAR
}

enum CAMERA_FOLLOW_MODE {
    LOCKED,
    SMOOTH,
    PREDICTIVE,
    ZONE,
    PLATFORMER
}

function Camera(_index, _resolution, _object = -1, _position = {x:0, y:0}, _border = {x:0, y:0}, _angle = 0, _spd = {x:-1, y:-1}) constructor {
    index = _index;
    resolution = _resolution;
    object = _object;
    position = {x: _position.x, y: _position.y};
    target_position = {x: _position.x, y: _position.y};
    angle = _angle;
    target_angle = _angle;
    spd = _spd;
    border = _border;
    
    // follow
    follow_mode = CAMERA_FOLLOW_MODE.SMOOTH;
    follow_speed = 0.1;
    follow_deadzone = {x: 0, y: 0, w: 0, h: 0};
    follow_predict = 0;
    follow_offset = {x: 0, y: 0};
    
    // zoom
    zoom = 1;
    target_zoom = 1;
    zoom_speed = 0.1;
    min_zoom = 0.1;
    max_zoom = 10;
    zoom_ease = CAMERA_EASE.LINEAR;
    
    // shake
    shake_trauma = 0;
    shake_decay = 0.8;
    shake_offset_x = 0;
    shake_offset_y = 0;
    shake_type = CAMERA_SHAKE_TYPE.PERLIN;
    shake_direction = 0;
    
    // effects
    rotation_shake = 0;
    rotation_shake_power = 0;
    chromatic_aberration = 0;
    vignette_intensity = 0;
    motion_blur = 0;
    
    // transitions
    is_transitioning = false;
    transition_timer = 0;
    transition_duration = 0;
    transition_start_pos = {x: 0, y: 0};
    transition_start_zoom = 1;
    transition_start_angle = 0;
    transition_ease = CAMERA_EASE.QUAD_IN_OUT;
    
    parallax_layers = [];
    
    post_process = ds_map_create_gmu();
    pp_enabled = false;
    
    bounds_enabled = false;
    bounds = {x: -10000, y: -10000, w: 20000, h: 20000};
    
    view_matrix = matrix_build_identity();
    projection_matrix = matrix_build_identity();
    
    update_frequency = 1;
    frame_counter = 0;
    
    on_update = undefined;
    on_shake = undefined;
    on_transition_complete = undefined;
    
    camera = camera_create_view(position.x, position.y, resolution.width, resolution.height, angle, object, spd.x, spd.y, border.x, border.y);
    view_enabled = true;
    view_visible[index] = true;
    
    function Set() {
        view_set_camera(index, camera);
        return self;
    };
    
	// follow behaviour
    function FollowObject(obj, speed = 0.1, mode = CAMERA_FOLLOW_MODE.SMOOTH) {
        object = obj;
        follow_speed = speed;
        follow_mode = mode;
        return self;
    };
    
    function SetFollowOffset(x, y) {
        follow_offset = {x: x, y: y};
        return self;
    };
    
    function SetDeadzone(x, y, w, h) {
        follow_deadzone = {x: x, y: y, w: w, h: h};
        return self;
    };
    
    function SetPredictiveFollow(frames_ahead) {
        follow_predict = frames_ahead;
        return self;
    };
    
    // position
    function SetPosition(x, y, instant = false) {
        target_position = {x: x, y: y};
        if (instant) {
            position.x = x;
            position.y = y;
        }
        return self;
    };
    
    function MoveTo(x, y, duration = 1, ease = CAMERA_EASE.QUAD_IN_OUT) {
        is_transitioning = true;
        transition_timer = 0;
        transition_duration = duration;
        transition_start_pos = {x: position.x, y: position.y};
        transition_start_zoom = zoom;
        transition_start_angle = angle;
        transition_ease = ease;
        target_position = {x: x, y: y};
        return self;
    };
    
    function LookAt(x, y, duration = 1) {
        return MoveTo(x, y, duration);
    };
    
    // zoom
    function SetZoom(target, speed = 0.1, ease = CAMERA_EASE.LINEAR) {
        target_zoom = clamp(target, min_zoom, max_zoom);
        zoom_speed = speed;
        zoom_ease = ease;
        return self;
    };
    
    function ZoomTo(target, duration = 1, ease = CAMERA_EASE.QUAD_IN_OUT) {
        is_transitioning = true;
        transition_timer = 0;
        transition_duration = duration;
        transition_start_pos = {x: position.x, y: position.y};
        transition_start_zoom = zoom;
        transition_start_angle = angle;
        transition_ease = ease;
        target_zoom = clamp(target, min_zoom, max_zoom);
        return self;
    };
    
    function SetZoomLimits(min_zoom_val, max_zoom_val) {
        min_zoom = min_zoom_val;
        max_zoom = max_zoom_val;
        return self;
    };
    
    // shake
    function Shake(trauma = 1, decay = 0.8, type = CAMERA_SHAKE_TYPE.PERLIN) {
        shake_trauma = min(shake_trauma + trauma, 1);
        shake_decay = decay;
        shake_type = type;
        
        if (on_shake != undefined) {
            on_shake(trauma);
        }
        
        return self;
    };
    
    function DirectionalShake(trauma, direction, decay = 0.8) {
        shake_trauma = min(shake_trauma + trauma, 1);
        shake_decay = decay;
        shake_type = CAMERA_SHAKE_TYPE.DIRECTIONAL;
        shake_direction = direction;
        return self;
    };
    
    function StopShake() {
        shake_trauma = 0;
        shake_offset_x = 0;
        shake_offset_y = 0;
        rotation_shake_power = 0;
        return self;
    };
    
    // boundries
    function EnableBounds(x, y, w, h) {
        bounds_enabled = true;
        bounds = {x: x, y: y, w: w, h: h};
        return self;
    };
    
    function DisableBounds() {
        bounds_enabled = false;
        return self;
    };
    
    // parallax
    function AddParallaxLayer(layer_object, factor_x, factor_y) {
        array_push(parallax_layers, {
            obj: layer_object,
            factor_x: factor_x,
            factor_y: factor_y,
            offset_x: 0,
            offset_y: 0
        });
        return self;
    };
    
    function RemoveParallaxLayer(layer_object) {
        for (var i = 0; i < array_length(parallax_layers); i++) {
            if (parallax_layers[i].obj == layer_object) {
                array_delete(parallax_layers, i, 1);
                break;
            }
        }
        return self;
    };
    
    // post processing
    function EnablePostProcess(enabled = true) {
        pp_enabled = enabled;
        return self;
    };
    
    function SetChromaticAberration(intensity) {
        chromatic_aberration = clamp(intensity, 0, 1);
        return self;
    };
    
    function SetVignette(intensity) {
        vignette_intensity = clamp(intensity, 0, 1);
        return self;
    };
    
    function SetMotionBlur(amount) {
        motion_blur = clamp(amount, 0, 1);
        return self;
    };
    
    // utlity
    function WorldToScreen(world_x, world_y) {
        var view_x = camera_get_view_x(camera);
        var view_y = camera_get_view_y(camera);
        var view_w = camera_get_view_width(camera);
        var view_h = camera_get_view_height(camera);
        
        var screen_x = (world_x - view_x) * (resolution.width / view_w);
        var screen_y = (world_y - view_y) * (resolution.height / view_h);
        
        return {x: screen_x, y: screen_y};
    };
    
    function ScreenToWorld(screen_x, screen_y) {
        var view_x = camera_get_view_x(camera);
        var view_y = camera_get_view_y(camera);
        var view_w = camera_get_view_width(camera);
        var view_h = camera_get_view_height(camera);
        
        var world_x = view_x + (screen_x / resolution.width) * view_w;
        var world_y = view_y + (screen_y / resolution.height) * view_h;
        
        return {x: world_x, y: world_y};
    };
    
    function IsVisible(x, y, w, h) {
        var view_x = position.x - (resolution.width / zoom) / 2;
        var view_y = position.y - (resolution.height / zoom) / 2;
        var view_w = resolution.width / zoom;
        var view_h = resolution.height / zoom;
        
        return !(x + w < view_x || x > view_x + view_w || 
                 y + h < view_y || y > view_y + view_h);
    };
    
    function GetViewRect() {
        return {
            x: position.x - (resolution.width / zoom) / 2,
            y: position.y - (resolution.height / zoom) / 2,
            w: resolution.width / zoom,
            h: resolution.height / zoom
        };
    };
    
    // callbacks
    function SetOnUpdate(callback) {
        on_update = callback;
        return self;
    };
    
    function SetOnShake(callback) {
        on_shake = callback;
        return self;
    };
    
    function SetOnTransitionComplete(callback) {
        on_transition_complete = callback;
        return self;
    };
    
    // easing
    function Ease(t, type) {
        switch(type) {
            case CAMERA_EASE.QUAD_IN: return t * t;
            case CAMERA_EASE.QUAD_OUT: return 1 - (1 - t) * (1 - t);
            case CAMERA_EASE.QUAD_IN_OUT: 
                return t < 0.5 ? 2 * t * t : 1 - power(-2 * t + 2, 2) / 2;
            case CAMERA_EASE.CUBIC_IN: return t * t * t;
            case CAMERA_EASE.CUBIC_OUT: return 1 - power(1 - t, 3);
            case CAMERA_EASE.CUBIC_IN_OUT:
                return t < 0.5 ? 4 * t * t * t : 1 - power(-2 * t + 2, 3) / 2;
            case CAMERA_EASE.ELASTIC_OUT:
                var c4 = (2 * pi) / 3;
                return t == 0 ? 0 : (t == 1 ? 1 : power(2, -10 * t) * sin((t * 10 - 0.75) * c4) + 1);
            case CAMERA_EASE.BACK_OUT:
                var c1 = 1.70158, c3 = c1 + 1;
                return 1 + c3 * power(t - 1, 3) + c1 * power(t - 1, 2);
            case CAMERA_EASE.BOUNCE_OUT:
                var n1 = 7.5625, d1 = 2.75;
                if (t < 1 / d1) return n1 * t * t;
                else if (t < 2 / d1) { t -= 1.5 / d1; return n1 * t * t + 0.75; }
                else if (t < 2.5 / d1) { t -= 2.25 / d1; return n1 * t * t + 0.9375; }
                else { t -= 2.625 / d1; return n1 * t * t + 0.984375; }
            case CAMERA_EASE.SINE_IN_OUT:
                return -(cos(pi * t) - 1) / 2;
            default:
                return t;
        }
    };
    
    // update
    function Update() {
        frame_counter++;
        if (frame_counter % update_frequency != 0) return self;
        
        if (object != -1 && instance_exists(object)) {
            var target_x = object.x + follow_offset.x;
            var target_y = object.y + follow_offset.y;
            
            if (follow_predict > 0) {
                target_x += object.hspeed * follow_predict;
                target_y += object.vspeed * follow_predict;
            }
            
            switch(follow_mode) {
                case CAMERA_FOLLOW_MODE.LOCKED:
                    target_position.x = target_x;
                    target_position.y = target_y;
                    break;
                    
                case CAMERA_FOLLOW_MODE.SMOOTH:
                    target_position.x = target_x;
                    target_position.y = target_y;
                    break;
                    
                case CAMERA_FOLLOW_MODE.ZONE:
                    var dz = follow_deadzone;
                    if (abs(target_x - position.x) > dz.w/2) {
                        target_position.x = target_x;
                    }
                    if (abs(target_y - position.y) > dz.h/2) {
                        target_position.y = target_y;
                    }
                    break;
                    
                case CAMERA_FOLLOW_MODE.PLATFORMER:
                    target_position.x = target_x + object.hspeed * 30;
                    target_position.y = target_y + object.vspeed * 10;
                    break;
            }
        }
        
        if (is_transitioning) {
            transition_timer += 1 / game_get_speed(gamespeed_fps);
            var t = min(transition_timer / transition_duration, 1);
            var eased = Ease(t, transition_ease);
            
            position.x = lerp(transition_start_pos.x, target_position.x, eased);
            position.y = lerp(transition_start_pos.y, target_position.y, eased);
            zoom = lerp(transition_start_zoom, target_zoom, eased);
            angle = lerp(transition_start_angle, target_angle, eased);
            
            if (t >= 1) {
                is_transitioning = false;
                if (on_transition_complete != undefined) {
                    on_transition_complete();
                }
            }
        } else {
            if (follow_mode == CAMERA_FOLLOW_MODE.SMOOTH) {
                position.x = lerp(position.x, target_position.x, follow_speed);
                position.y = lerp(position.y, target_position.y, follow_speed);
            } else {
                position.x = target_position.x;
                position.y = target_position.y;
            }
            
            if (abs(zoom - target_zoom) > 0.001) {
                var t = Ease(zoom_speed, zoom_ease);
                zoom = lerp(zoom, target_zoom, t);
            } else {
                zoom = target_zoom;
            }
        }
        
        if (bounds_enabled) {
            var view_w = resolution.width / zoom;
            var view_h = resolution.height / zoom;
            position.x = clamp(position.x, bounds.x + view_w/2, bounds.x + bounds.w - view_w/2);
            position.y = clamp(position.y, bounds.y + view_h/2, bounds.y + bounds.h - view_h/2);
        }
        
        UpdateShake();
        
        UpdateParallax();
        
        var view_w = resolution.width / zoom;
        var view_h = resolution.height / zoom;
        var view_x = position.x + shake_offset_x - view_w/2;
        var view_y = position.y + shake_offset_y - view_h/2;
        
        camera_set_view_pos(camera, view_x, view_y);
        camera_set_view_size(camera, view_w, view_h);
        camera_set_view_angle(camera, angle + rotation_shake_power);
        
        if (pp_enabled) {
            ApplyPostProcess();
        }
        
        if (on_update != undefined) {
            on_update(self);
        }
        
        return self;
    };
    
    function UpdateShake() {
        if (shake_trauma > 0) {
            var _power = shake_trauma * shake_trauma;
            
            switch(shake_type) {
                case CAMERA_SHAKE_TYPE.RANDOM:
                    shake_offset_x = random_range(-_power, _power) * 10;
                    shake_offset_y = random_range(-_power, _power) * 10;
                    break;
                    
                case CAMERA_SHAKE_TYPE.PERLIN:
                    var time = current_time / 100;
                    shake_offset_x = (Noise.ValueNoise2D([time, 0]) * 2 - 1) * _power * 15;
                    shake_offset_y = (Noise.ValueNoise2D([0, time]) * 2 - 1) * _power * 15;
                    break;
                    
                case CAMERA_SHAKE_TYPE.DIRECTIONAL:
                    var dir_x = cos(shake_direction);
                    var dir_y = sin(shake_direction);
                    var perp_x = -dir_y;
                    var perp_y = dir_x;
                    shake_offset_x = (dir_x * random_range(-1, 1) + perp_x * random_range(-0.5, 0.5)) * _power * 10;
                    shake_offset_y = (dir_y * random_range(-1, 1) + perp_y * random_range(-0.5, 0.5)) * _power * 10;
                    break;
                    
                case CAMERA_SHAKE_TYPE.CIRCULAR:
                    var ang = random(360);
                    shake_offset_x = cos(ang) * _power * 10;
                    shake_offset_y = sin(ang) * _power * 10;
                    break;
            }
            
            rotation_shake_power = random_range(-_power, _power) * 5;
            
            shake_trauma = max(shake_trauma - shake_decay * 0.016, 0);
            
            if (shake_trauma <= 0.01) {
                shake_trauma = 0;
                shake_offset_x = 0;
                shake_offset_y = 0;
                rotation_shake_power = 0;
            }
        } else {
            shake_offset_x = 0;
            shake_offset_y = 0;
            rotation_shake_power = 0;
        }
    };
    
    function UpdateParallax() {
        var base_x = position.x;
        var base_y = position.y;
        
        for (var i = 0; i < array_length(parallax_layers); i++) {
            var _layer = parallax_layers[i];
            if (instance_exists(_layer.obj)) {
                _layer.obj.x = base_x * _layer.factor_x + _layer.offset_x;
                _layer.obj.y = base_y * _layer.factor_y + _layer.offset_y;
            }
        }
    };
    
    function ApplyPostProcess() {
        if (chromatic_aberration > 0) {
            // TODO
        }
        
        if (vignette_intensity > 0) {
            // TODO
        }
        
        if (motion_blur > 0) {
            // TODO
        }
		
		// TODO: add more
    };
    
    // cleanup
    function Free() {
        camera_destroy(camera);
        ds_map_destroy_gmu(post_process);
        parallax_layers = [];
    };
    
    // debug
    function DebugDraw() {
        var rect = GetViewRect();
        draw_rectangle(rect.x, rect.y, rect.x + rect.w, rect.y + rect.h, true);
        
        if (bounds_enabled) {
            draw_rectangle(bounds.x, bounds.y, bounds.x + bounds.w, bounds.y + bounds.h, true);
        }
        
        if (follow_mode == CAMERA_FOLLOW_MODE.ZONE && follow_deadzone.w > 0) {
            var dz = follow_deadzone;
            draw_rectangle(position.x - dz.w/2, position.y - dz.h/2, 
                          position.x + dz.w/2, position.y + dz.h/2, true);
        }
        
        return self;
    };
    
    function GetInfo() {
        return {
            position: position,
            zoom: zoom,
            angle: angle,
            shake_trauma: shake_trauma,
            is_transitioning: is_transitioning,
            follow_mode: follow_mode,
            view_rect: GetViewRect()
        };
    };
}

function CameraManager() constructor { // for multiple cameras
    cameras = ds_list_create_gmu();
    active_camera = 0;
    
    function Add(camera) {
        ds_list_add(cameras, camera);
        return self;
    };
    
    function SetActive(index) {
        if (index >= 0 && index < ds_list_size(cameras)) {
            active_camera = index;
            cameras[| index].Set();
        }
        return self;
    };
    
    function GetActive() {
        return cameras[| active_camera];
    };
    
    function UpdateAll() {
        for (var i = 0; i < ds_list_size(cameras); i++) {
            cameras[| i].Update();
        }
        return self;
    };
    
    function Free() {
        for (var i = 0; i < ds_list_size(cameras); i++) {
            cameras[| i].Free();
        }
        ds_list_destroy_gmu(cameras);
    };
}

//  Animation System
//function Animation(_animation, _speed = 1, _onUpdate = undefined) constructor {
//    animation = _animation;
//    speed = _speed;
//    onUpdate = _onUpdate;
//
//    function Update(_object) {
//        _object.sprite_index = animation;
//        _object.image_speed = speed;
//        if (onUpdate != undefined) onUpdate(self, _object);
//    };
//};
//
//function AnimPack(_object) constructor {
//    object = _object;
//    animations = ds_map_create_gmu();
//    current = undefined;
//
//    function Add(name, anim) {
//        animations[? name] = anim;
//        return self;
//    };
//    function Get(name) {
//        return animations[? name];
//    };
//    function Exists(name) {
//        return ds_map_exists(animations, name);
//    };
//    function Set(name) {
//        if (!Exists(name)) return self;
//        current = animations[? name];
//        return self;
//    };
//    function Update() {
//        if (current != undefined) current.Update(object);
//        return self;
//    };
//    function Free() {
//        var keys = ds_map_keys_to_array(animations);
//        for (var i = 0; i < array_length(keys); i++) delete animations[? keys[i]];
//        ds_map_destroy_gmu(animations);
//    };
//};

//  Enhanced Animation System
//  Supports: Blending, events, sequences, and advanced playback control

enum ANIM_PLAYBACK {
    NORMAL,
    REVERSE,
    PING_PONG,
    LOOP,
    ONCE
}

enum ANIM_BLEND_MODE {
    NONE,
    CROSSFADE,
    ADDITIVE,
    OVERRIDE
}

enum ANIM_EVENT {
    ON_START,
    ON_FRAME,
    ON_END,
    ON_LOOP,
    ON_PAUSE,
    ON_RESUME
}

function Animation(_animation, _speed = 1, _onUpdate = undefined) constructor {
    animation = _animation;
    speed = _speed;
    onUpdate = _onUpdate;
    
    name = "unnamed";
    frame_start = 0;
    frame_end = -1;  // -1 means use sprite's frame count
    playback_mode = ANIM_PLAYBACK.NORMAL;
    loop_count = -1;  // -1 = infinite
    current_loop = 0;
    is_paused = false;
    time_scale = 1.0;
    
    frame_duration = 1;  // frames per game frame (for frame-based timing)
    frame_timer = 0;
    current_frame = 0;
    direction = 1;
    
    blend_weight = 1.0;
    blend_mode = ANIM_BLEND_MODE.NONE;
    blend_duration = 0.0;
    blend_timer = 0.0;
    
    events = ds_map_create_gmu();
    
    on_start = undefined;
    on_frame = undefined;
    on_end = undefined;
    on_loop = undefined;
    
    function Init() {
        if (frame_end == -1) {
            frame_end = sprite_get_number(animation) - 1;
        }
        current_frame = frame_start;
        return self;
    } Init();
    
    // config
    function SetName(_name) {
        name = _name;
        return self;
    };
    
    function SetFrameRange(start, _end) {
        frame_start = start;
        frame_end = _end >= 0 ? _end : sprite_get_number(animation) - 1;
        current_frame = clamp(current_frame, frame_start, frame_end);
        return self;
    };
    
    function SetPlaybackMode(mode, loop_count_val = -1) {
        playback_mode = mode;
        loop_count = loop_count_val;
        return self;
    };
    
    function SetTimeScale(scale) {
        time_scale = max(scale, 0);
        return self;
    };
    
    function SetFrameDuration(frames_per_image) {
        frame_duration = max(frames_per_image, 0.1);
        return self;
    };
    
    // blending
    function SetBlendWeight(weight) {
        blend_weight = clamp(weight, 0, 1);
        return self;
    };
    
    function SetBlendMode(mode, duration = 0.3) {
        blend_mode = mode;
        blend_duration = duration;
        blend_timer = 0;
        return self;
    };
    
    // event sys
    function AddEvent(event_type, frame_or_callback, callback = undefined) {
        if (!ds_map_exists(events, event_type)) {
            events[? event_type] = [];
        }
        
        var event_list = events[? event_type];
        
        if (event_type == ANIM_EVENT.ON_FRAME) {
            array_push(event_list, {
                frame: frame_or_callback,
                callback: callback,
                triggered: false
            });
        } else {
            array_push(event_list, {
                callback: frame_or_callback,
                triggered: false
            });
        }
        
        return self;
    };
    
    function ClearEvents(event_type = undefined) {
        if (event_type != undefined) {
            ds_map_delete(events, event_type);
        } else {
            ds_map_clear(events);
        }
        return self;
    };
    
    function OnStart(callback) {
        on_start = callback;
        return self;
    };
    
    function OnFrame(callback) {
        on_frame = callback;
        return self;
    };
    
    function OnEnd(callback) {
        on_end = callback;
        return self;
    };
    
    function OnLoop(callback) {
        on_loop = callback;
        return self;
    };
    
    // control
    function Play() {
        is_paused = false;
        return self;
    };
    
    function Pause() {
        is_paused = true;
        TriggerEvents(ANIM_EVENT.ON_PAUSE);
        return self;
    };
    
    function Resume() {
        is_paused = false;
        TriggerEvents(ANIM_EVENT.ON_RESUME);
        return self;
    };
    
    function Stop() {
        is_paused = true;
        current_frame = frame_start;
        frame_timer = 0;
        return self;
    };
    
    function Reset() {
        current_frame = frame_start;
        frame_timer = 0;
        current_loop = 0;
        direction = 1;
        ResetFrameEvents();
        return self;
    };
    
    function JumpToFrame(frame) {
        current_frame = clamp(frame, frame_start, frame_end);
        frame_timer = 0;
        return self;
    };
    
    function JumpToProgress(progress) {
        var total_frames = frame_end - frame_start + 1;
        current_frame = frame_start + floor(progress * (total_frames - 1));
        return self;
    };
    
    // query
    function GetCurrentFrame() {
        return current_frame;
    };
    
    function GetProgress() {
        var total_frames = frame_end - frame_start;
        return total_frames > 0 ? (current_frame - frame_start) / total_frames : 0;
    };
    
    function IsPlaying() {
        return !is_paused;
    };
    
    function IsFinished() {
        return playback_mode == ANIM_PLAYBACK.ONCE && 
               current_loop >= 1 && 
               current_frame == frame_end;
    };
    
    function GetDuration() {
        var total_frames = frame_end - frame_start + 1;
        return (total_frames * frame_duration) / (speed * time_scale);
    };
    
    // internal
    function UpdateFrame() {
        if (is_paused) return;
        
        frame_timer += (speed * time_scale);
        
        while (frame_timer >= frame_duration) {
            frame_timer -= frame_duration;
            AdvanceFrame();
        }
    };
    
    function AdvanceFrame() {
        var prev_frame = current_frame;
        
        switch(playback_mode) {
            case ANIM_PLAYBACK.NORMAL:
                current_frame += direction;
                break;
                
            case ANIM_PLAYBACK.REVERSE:
                current_frame -= direction;
                break;
                
            case ANIM_PLAYBACK.PING_PONG:
                current_frame += direction;
                if (current_frame >= frame_end || current_frame <= frame_start) {
                    direction = -direction;
                }
                break;
                
            case ANIM_PLAYBACK.LOOP:
                current_frame += direction;
                if (current_frame > frame_end) {
                    current_frame = frame_start;
                    HandleLoop();
                }
                break;
                
            case ANIM_PLAYBACK.ONCE:
                current_frame += direction;
                if (current_frame > frame_end) {
                    current_frame = frame_end;
                    HandleEnd();
                }
                break;
        }
        
        current_frame = clamp(current_frame, frame_start, frame_end);
        
        if (prev_frame != current_frame) {
            TriggerFrameEvents(current_frame);
            if (on_frame != undefined) {
                on_frame(current_frame);
            }
        }
    };
    
    function HandleLoop() {
        current_loop++;
        TriggerEvents(ANIM_EVENT.ON_LOOP);
        
        if (on_loop != undefined) {
            on_loop(current_loop);
        }
        
        if (loop_count > 0 && current_loop >= loop_count) {
            playback_mode = ANIM_PLAYBACK.ONCE;
        }
        
        ResetFrameEvents();
    };
    
    function HandleEnd() {
        is_paused = true;
        TriggerEvents(ANIM_EVENT.ON_END);
        
        if (on_end != undefined) {
            on_end();
        }
    };
    
    function TriggerEvents(event_type) {
        if (!ds_map_exists(events, event_type)) return;
        
        var event_list = events[? event_type];
        for (var i = 0; i < array_length(event_list); i++) {
            var evt = event_list[i];
            if (evt.callback != undefined) {
                evt.callback(self);
            }
        }
    };
    
    function TriggerFrameEvents(frame) {
        if (!ds_map_exists(events, ANIM_EVENT.ON_FRAME)) return;
        
        var event_list = events[? ANIM_EVENT.ON_FRAME];
        for (var i = 0; i < array_length(event_list); i++) {
            var evt = event_list[i];
            if (evt.frame == frame && !evt.triggered) {
                evt.triggered = true;
                if (evt.callback != undefined) {
                    evt.callback(self, frame);
                }
            }
        }
    };
    
    function ResetFrameEvents() {
        if (!ds_map_exists(events, ANIM_EVENT.ON_FRAME)) return;
        
        var event_list = events[? ANIM_EVENT.ON_FRAME];
        for (var i = 0; i < array_length(event_list); i++) {
            event_list[i].triggered = false;
        }
    };
    
    function _UpdateBlend(delta_time) {
        if (blend_mode != ANIM_BLEND_MODE.NONE && blend_timer < blend_duration) {
            blend_timer = min(blend_timer + delta_time, blend_duration);
            
            if (blend_mode == ANIM_BLEND_MODE.CROSSFADE) {
                blend_weight = blend_timer / blend_duration;
            }
        }
    };
    
    // update
    function Update(_object, delta_time = 1) {
        UpdateFrame();
        _UpdateBlend(delta_time);
        
        if (_object != undefined) {
            _object.sprite_index = animation;
            _object.image_index = current_frame;
            _object.image_speed = 0;  // controls frames manually
            
            if (blend_mode == ANIM_BLEND_MODE.ADDITIVE && blend_weight < 1) {
                _object.image_alpha = blend_weight;
            } else {
                _object.image_alpha = 1;
            }
        }
        
        if (onUpdate != undefined) {
            onUpdate(self, _object);
        }
        
        return self;
    };
    
    function Free() {
        ds_map_destroy_gmu(events);
    };
}

// Animation Pack
function AnimPack(_object) constructor {
    object = _object;
    animations = ds_map_create_gmu();
    current = undefined;
    previous = undefined;
    blend_animation = undefined;
    blend_timer = 0;
    blend_duration = 0;
    default_anim = undefined;
    
    queue = ds_queue_create_gmu();
    queue_enabled = false;
    
    on_anim_changed = undefined;
    
    function Add(name, anim_or_sprite, speed = 1) {
        var anim;
        if (is_struct(anim_or_sprite)) {
            anim = anim_or_sprite;
            anim.SetName(name);
        } else {
            anim = new Animation(anim_or_sprite, speed);
            anim.SetName(name);
        }
        
        animations[? name] = anim;
        
        if (ds_map_size(animations) == 1) { // first is default
            default_anim = name;
        }
        
        return self;
    };
    
    function AddRange(anim_map) {
        var keys = variable_struct_get_names(anim_map);
        for (var i = 0; i < array_length(keys); i++) {
            var name = keys[i];
            var data = anim_map[$ name];
            
            if (is_array(data)) {
                Add(name, data[0], data[1]);
            } else {
                Add(name, data);
            }
        }
        return self;
    };
    
    // control
    function Get(name) {
        return animations[? name];
    };
    
    function Exists(name) {
        return ds_map_exists(animations, name);
    };
    
    function Set(name, blend_duration_val = 0, blend_mode = ANIM_BLEND_MODE.CROSSFADE) {
        if (!Exists(name)) {
            show_debug_message($"AnimPack: Animation '{name}' not found");
            return self;
        }
        
        var new_anim = animations[? name];
        
        if (current == new_anim) return self;
        
        previous = current;
        current = new_anim;
        
        current.Reset();
        current.Play();
        
        if (blend_duration_val > 0 && previous != undefined) {
            blend_animation = previous;
            blend_timer = 0;
            blend_duration = blend_duration_val;
            current.SetBlendMode(blend_mode, blend_duration_val);
        }
        
        if (on_anim_changed != undefined) {
            on_anim_changed(name, previous != undefined ? previous.name : undefined);
        }
        
        current.TriggerEvents(ANIM_EVENT.ON_START);
        if (current.on_start != undefined) {
            current.on_start(current);
        }
        
        return self;
    };
    
    function Play(name, blend = 0) {
        Set(name, blend);
        return self;
    };
    
    function SetDefault(name) {
        if (Exists(name)) {
            default_anim = name;
        }
        return self;
    };
    
    function PlayDefault(blend = 0) {
        if (default_anim != undefined) {
            Set(default_anim, blend);
        }
        return self;
    };
    
    // queue
    function EnableQueue(enabled = true) {
        queue_enabled = enabled;
        if (!enabled) {
            ds_queue_clear(queue);
        }
        return self;
    };
    
    function Queue(name, blend = 0) {
        if (!Exists(name)) return self;
        
        ds_queue_enqueue(queue, {
            name: name,
            blend: blend
        });
        
        return self;
    };
    
    function ClearQueue() {
        ds_queue_clear(queue);
        return self;
    };
    
    function PlayNextInQueue(blend = 0.2) {
        if (ds_queue_empty(queue)) return self;
        
        var next = ds_queue_dequeue(queue);
        Set(next.name, next.blend > 0 ? next.blend : blend);
        
        return self;
    };
    
    // playback
    function Pause() {
        if (current != undefined) {
            current.Pause();
        }
        return self;
    };
    
    function Resume() {
        if (current != undefined) {
            current.Resume();
        }
        return self;
    };
    
    function Stop() {
        if (current != undefined) {
            current.Stop();
        }
        return self;
    };
    
    function SetSpeed(speed) {
        if (current != undefined) {
            current.speed = speed;
        }
        return self;
    };
    
    function SetTimeScale(scale) {
        if (current != undefined) {
            current.SetTimeScale(scale);
        }
        return self;
    };
    
    // query
    function GetCurrent() {
        return current;
    };
    
    function GetCurrentName() {
        return current != undefined ? current.name : undefined;
    };
    
    function GetPrevious() {
        return previous;
    };
    
    function IsPlaying() {
        return current != undefined && current.IsPlaying();
    };
    
    function IsCurrent(name) {
        return current != undefined && current.name == name;
    };
    
    function GetProgress() {
        return current != undefined ? current.GetProgress() : 0;
    };
    
    function GetAllNames() {
        return ds_map_keys_to_array(animations);
    };
    
    // events
    function OnAnimChanged(callback) {
        on_anim_changed = callback;
        return self;
    };
    
    // update
    function Update(delta_time = 1) {
        if (current != undefined) {
            current.Update(object, delta_time);
            
            if (current.IsFinished()) {
                if (queue_enabled && !ds_queue_empty(queue)) {
                    PlayNextInQueue(0.2);
                } else if (default_anim != undefined && current.name != default_anim) {
                    PlayDefault(0.3);
                }
            }
        }
        
        if (blend_animation != undefined) {
            blend_timer += delta_time;
            if (blend_timer >= blend_duration) {
                blend_animation = undefined;
            }
        }
        
        return self;
    };
    
    // utility & debug
    function CreateStateMachine() {
        var sm = new StateMachine(GetCurrentName());
        
        var names = GetAllNames();
        for (var i = 0; i < array_length(names); i++) {
            var anim_name = names[i];
            sm.AddState(anim_name,
                function(data) {
                    Set(anim_name, 0.2);
                },
                undefined,
                undefined
            );
        }
        
        return sm;
    };
    
    function ExportToJSON() {
        var data = {
            current: GetCurrentName(),
            animations: {}
        };
        
        var names = GetAllNames();
        for (var i = 0; i < array_length(names); i++) {
            var anim = Get(names[i]);
            data.animations[$ names[i]] = {
                sprite: anim.animation,
                speed: anim.speed,
                playback: anim.playback_mode,
                frame_start: anim.frame_start,
                frame_end: anim.frame_end
            };
        }
        
        return json_stringify(data);
    };
    
    function DebugDraw(x, y) {
        if (current == undefined) return;
        
        var info = $"Current: {current.name}\n";
        info += $"Frame: {current.current_frame}/{current.frame_end}\n";
        info += $"Progress: {round(current.GetProgress() * 100)}%\n";
        info += $"Playing: {current.IsPlaying()}\n";
        info += $"Queue: {ds_queue_size(queue)}";
        
        draw_text(x, y, info);
    };
    
	// cleanup
    function Free() {
        var keys = ds_map_keys_to_array(animations);
        for (var i = 0; i < array_length(keys); i++) {
            var anim = animations[? keys[i]];
            if (anim != undefined) {
                anim.Free();
            }
            delete animations[? keys[i]];
        }
        
        ds_map_destroy_gmu(animations);
        ds_queue_destroy_gmu(queue);
    };
}

