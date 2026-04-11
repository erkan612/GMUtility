// Enums
enum MOVEMENT {
	NONE									= 0, 
	LEFT									= -1, 
	RIGHT									= 1, 
	UP										= -1, 
	DOWN									= 1
}

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

enum TASK_STATE {
    PENDING,        // Not started yet
    ACTIVE,         // Currently in progress
    COMPLETED,      // Successfully finished
    FAILED,         // Failed to complete
    ABANDONED,      // Player gave up
    LOCKED,         // Cannot start yet (requirements not met)
    UNLOCKED,       // Available but not started
    REWARDED,       // Completed and rewards claimed
    HIDDEN,         // Secret task not yet revealed
    TIMED_OUT,      // Failed due to time limit
    SKIPPED,        // Bypassed (for debug or story reasons)
    REPEATABLE,     // Can be done multiple times
    ON_HOLD,        // Temporarily paused
    RESET,          // Reset to pending state
    UPGRADED        // Task was improved/replaced
}

//  InterfaceAccess – dynamic registry
function InterfaceAccess() constructor {
    m_elements = ds_map_create_gmu();

    function Add(name, element) {
        ds_map_add(m_elements, name, element);
        return self;
    };
    function Get(name) {
        return m_elements[? name];
    };
    function Set(name, element) {
        m_elements[? name] = element;
        return self;
    };
    function Exists(name) {
        return ds_map_exists(m_elements, name);
    };
    function Remove(name) {
        if (ds_map_exists(m_elements, name)) {
            ds_map_delete(m_elements, name);
        }
        return self;
    };
    function GetKeys() {
        return ds_map_keys_to_array(m_elements);
    };
    function Clear() {
        ds_map_clear(m_elements);
        return self;
    };
    function Free() {
        ds_map_destroy(m_elements);
    };
};

// SaveManager (simplified)
function SaveManager() constructor {
    slots = 10;
    current_slot = 0;
    auto_save_enabled = false;
    auto_save_timer = 0;
    auto_save_interval = 300; // seconds

    function Save(_slot, _data, _thumbnail = undefined) { // Simple save
        var save_data = {
            version: variable_global_exists("__VERSION") ? variable_global_get("__VERSION") : "undefined",
            timestamp: GetUnixDateTime(date_current_datetime()),
            data: _data,
            thumbnail: _thumbnail,
            checksum: "" // simple checksum
        };
    
        save_data.checksum = string_hash(json_stringify(_data)); // simple checksum (just for validation)
    
        var file_name = "save_slot_" + string(_slot) + ".kismet";
        var success = File.SaveJSON(file_name, save_data);
        
		return success;
    };

    // Simple load
    function Load(_slot) {
        var file_name = "save_slot_" + string(_slot) + ".kismet";
        var save_data = File.LoadJSON(file_name);
    
        if (save_data == undefined) return undefined;
    
        // Verify checksum
        var expected = string_hash(json_stringify(save_data.data));
        if (save_data.checksum != expected) {
            show_debug_message("[Save] Corrupted save slot " + string(_slot));
            return undefined;
        }
    
        current_slot = _slot;
        return save_data.data;
    };

    function Exists(_slot) {
        var file_name = "save_slot_" + string(_slot) + ".kismet";
        return file_exists(file_name);
    };

    function Delete(_slot) {
        var file_name = "save_slot_" + string(_slot) + ".kismet";
        if (file_exists(file_name)) {
            file_delete(file_name);
            return true;
        }
        return false;
    };

    function GetSaveList() {
        var saves = [];
        for (var i = 0; i < slots; i++) {
            if (Exists(i)) {
                var file_name = "save_slot_" + string(i) + ".kismet";
                var data = File.LoadJSON(file_name);
                if (data != undefined) {
                    array_push(saves, {
                        slot: i,
                        timestamp: data.timestamp,
                        has_thumbnail: data.thumbnail != undefined
                    });
                }
            }
        }
        return saves;
    };

    // Auto-save (call in Step event)
    function UpdateAutoSave(_delta, _get_data_function) {
        if (!auto_save_enabled) return;
    
        auto_save_timer += _delta;
        if (auto_save_timer >= auto_save_interval) {
            auto_save_timer = 0;
            if (_get_data_function != undefined) {
                var data = _get_data_function();
                Save(current_slot, data);
            }
        }
    };

    function EnableAutoSave(_interval_seconds = 300) {
        auto_save_enabled = true;
        auto_save_interval = _interval_seconds;
        auto_save_timer = 0;
        return self;
    };

    function DisableAutoSave() {
        auto_save_enabled = false;
        return self;
    };
}

//  Timer System
function Timer(_duration, _onComplete, _loop = false, _onUpdate = undefined) constructor {
    duration = _duration; remaining = _duration; onComplete = _onComplete; loop = _loop; onUpdate = _onUpdate; active = true; paused = false;
    function Update(delta = 1) {
        if (!active || paused) return self;
        remaining -= delta;
        if (onUpdate != undefined) onUpdate(self);
        if (remaining <= 0) {
            if (loop) { remaining += duration; if (onComplete != undefined) onComplete(self); }
            else { active = false; if (onComplete != undefined) onComplete(self); }
        }
        return self;
    };
    function Reset() { remaining = duration; active = true; paused = false; return self; };
    function Pause() { paused = true; return self; };
    function Resume() { paused = false; return self; };
    function Stop() { active = false; return self; };
};

//  Object Pooling
function ObjectPool(_objectName, _size, _layer = "Instances") constructor {
    objectName = _objectName; layer = _layer; pool = ds_queue_create_gmu();
    for (var i=0;i<_size;i++) {
        var inst = instance_create_layer(0,0,layer,objectName);
        instance_deactivate_object(inst);
        ds_queue_enqueue(pool, inst);
    }
    function Get(x, y, activate = true) {
        var inst = ds_queue_empty(pool) ? instance_create_layer(x,y,layer,objectName) : ds_queue_dequeue(pool);
        if (activate) instance_activate_object(inst);
        inst.x = x; inst.y = y;
        return inst;
    };
    function Return(inst) { instance_deactivate_object(inst); ds_queue_enqueue(pool, inst); return self; };
    function Free() { while (!ds_queue_empty(pool)) instance_destroy(ds_queue_dequeue(pool)); ds_queue_destroy_gmu(pool); };
};

// Profiler
function Profiler() constructor {
    markers = ds_map_create_gmu();     // name -> {total_time, call_count, min, max, samples}
    current_marker = undefined;
    start_time = 0;
    enabled = true;

    function Begin(_name) {
        if (!enabled) return self;
    
        if (ds_map_exists(markers, _name)) {
            current_marker = markers[? _name];
        } else {
            current_marker = {
                total_time: 0,
                call_count: 0,
                min_time: Infinity,
                max_time: 0,
                samples: ds_list_create_gmu(),
                name: _name
            };
            markers[? _name] = current_marker;
        }
    
        current_marker.call_count++;
        start_time = current_time;
        return self;
    };

    function End() {
        if (!enabled || current_marker == undefined) return self;
    
        var elapsed = (current_time - start_time) / 1000.0; // milliseconds
        current_marker.total_time += elapsed;
    
        if (elapsed < current_marker.min_time) current_marker.min_time = elapsed;
        if (elapsed > current_marker.max_time) current_marker.max_time = elapsed;
    
        // Keep last 60 samples for average
        if (ds_list_size(current_marker.samples) >= 60) {
            ds_list_delete(current_marker.samples, 0);
        }
        ds_list_add(current_marker.samples, elapsed);
    
        current_marker = undefined;
        return self;
    };

    function GetData() {
        var result = {};
        var keys = ds_map_keys_to_array(markers);
    
        for (var i = 0; i < array_length(keys); i++) {
            var m = markers[? keys[i]];
        
            // Calculate average from samples
            var avg = 0;
            for (var j = 0; j < ds_list_size(m.samples); j++) {
                avg += m.samples[| j];
            }
            avg = avg / max(1, ds_list_size(m.samples));
        
            result[$ m.name] = {
                total_ms: m.total_time,
                calls: m.call_count,
                avg_ms: avg,
                min_ms: m.min_time,
                max_ms: m.max_time,
                percent: 0 // Calculate after
            };
        }
    
        // Calculate percentages
        var total_time = 0;
        keys = ds_map_keys_to_array(markers);
        for (var i = 0; i < array_length(keys); i++) {
            total_time += result[$ keys[i]].total_ms;
        }
    
        for (var i = 0; i < array_length(keys); i++) {
            result[$ keys[i]].percent = (result[$ keys[i]].total_ms / total_time) * 100;
        }
    
        return result;
    };

    function GetReport() {
        var data = GetData();
        var keys = variable_struct_get_names(data);
    
        // Sort by total time (descending)
        for (var i = 0; i < array_length(keys) - 1; i++) {
            for (var j = i + 1; j < array_length(keys); j++) {
                if (data[$ keys[i]].total_ms < data[$ keys[j]].total_ms) {
                    var temp = keys[i];
                    keys[i] = keys[j];
                    keys[j] = temp;
                }
            }
        }
    
        var report = "=== Performance Profile ===\n";
        for (var i = 0; i < array_length(keys); i++) {
            var d = data[$ keys[i]];
            report += string(keys[i]) + ": " + string(d.total_ms) + "ms (" + string(d.percent) + "%) - Avg: " + string(d.avg_ms) + "ms, Calls: " + string(d.calls) + "\n";
        }
    
        return report;
    };

    function Reset() {
        var keys = ds_map_keys_to_array(markers);
        for (var i = 0; i < array_length(keys); i++) {
            var m = markers[? keys[i]];
            ds_list_destroy_gmu(m.samples);
        }
        ds_map_clear(markers);
        current_marker = undefined;
        return self;
    };

    function SetEnabled(_enabled) {
        enabled = _enabled;
        return self;
    };

    function Free() {
        Reset();
        ds_map_destroy_gmu(markers);
    };
}

//  Movement
function Movement(_speed = 5, _accel = 0, _damping = 0) constructor {
    h = 0; v = 0;
    speed = _speed;
    accel = _accel;
    damping = _damping;
    vel_x = 0; vel_y = 0;

    function Update(object) {
        var target_x = h * speed;
        var target_y = v * speed;
        if (accel > 0) {
            vel_x = approach(vel_x, target_x, accel);
            vel_y = approach(vel_y, target_y, accel);
        } else {
            vel_x = target_x;
            vel_y = target_y;
        }
        if (h == 0 && damping > 0) vel_x = approach(vel_x, 0, damping);
        if (v == 0 && damping > 0) vel_y = approach(vel_y, 0, damping);
        if (vel_x != 0 && vel_y != 0) {
            var len = sqrt(vel_x*vel_x + vel_y*vel_y);
            if (len > speed) {
                vel_x = vel_x / len * speed;
                vel_y = vel_y / len * speed;
            }
        }
        object.hspeed = vel_x;
        object.vspeed = vel_y;
        return self;
    };
    function approach(val, target, step) {
        if (val < target) return min(val + step, target);
        if (val > target) return max(val - step, target);
        return target;
    }
};

//  Color Struct (RGBA + hex)
function Color(_r=0, _g=0, _b=0, _a=1) constructor {
    r=_r; g=_g; b=_b; a=_a;
    function FromHex(hex) {
        if (string_char_at(hex,1)=="#") hex = string_delete(hex,1,1);
        var r = hex_to_dec(string_copy(hex,1,2))/255;
        var g = hex_to_dec(string_copy(hex,3,2))/255;
        var b = hex_to_dec(string_copy(hex,5,2))/255;
        var a = string_length(hex)>=8 ? hex_to_dec(string_copy(hex,7,2))/255 : 1;
        return new Color(r,g,b,a);
    };
    function ToHex(includeAlpha=false) {
        var rh = string_format(floor(r*255),1,0);
        var gh = string_format(floor(g*255),1,0);
        var bh = string_format(floor(b*255),1,0);
        if (includeAlpha) { var ah = string_format(floor(a*255),1,0); return "#"+rh+gh+bh+ah; }
        return "#"+rh+gh+bh;
    };
    function ToArray() { return [r,g,b,a]; };
    function FromArray(arr) { return new Color(arr[0],arr[1],arr[2],arr[3]??1); };
    function White() { return new Color(1,1,1,1); };
    function Black() { return new Color(0,0,0,1); };
    function Red() { return new Color(1,0,0,1); };
    function Green() { return new Color(0,1,0,1); };
    function Blue() { return new Color(0,0,1,1); };
    function Yellow() { return new Color(1,1,0,1); };
    function Magenta() { return new Color(1,0,1,1); };
    function Cyan() { return new Color(0,1,1,1); };
};

//  Rect Struct
function Rect(_x=0, _y=0, _w=0, _h=0) constructor {
    x=_x; y=_y; w=_w; h=_h;
    Contains = function(px, py) { return px>=x && px<=x+w && py>=y && py<=y+h; };
    Intersects = function(other) { return !(other.x > x+w || other.x+other.w < x || other.y > y+h || other.y+other.h < y); };
    Expand = function(amt) { x-=amt; y-=amt; w+=amt*2; h+=amt*2; return self; };
    Clone = function() { return new Rect(x,y,w,h); };
};

//  Task & TaskTracer
function Task(id, _goal = 1, _onComplete = undefined) constructor {
    id = id; state = TASK_STATE.PENDING; progress = 0; goal = _goal; onComplete = _onComplete;
    function SetState(_state) { state = _state; return self; };
    function AddProgress(amount = 1, data = undefined) {
        if (state == TASK_STATE.COMPLETED || state == TASK_STATE.FAILED) return self;
        progress += amount;
        if (progress >= goal) {
            progress = goal;
            state = TASK_STATE.COMPLETED;
            if (onComplete != undefined) onComplete(data);
        }
        return self;
    };
    function Reset() { state = TASK_STATE.PENDING; progress = 0; return self; };
    function IsComplete() { return state == TASK_STATE.COMPLETED; };
    function GetProgressRatio() { return goal > 0 ? progress / goal : 0; };
};

function TaskTracer() constructor {
    tasks = ds_map_create_gmu();
    function AddTask(task) { tasks[? task.id] = task; return self; };
    function RemoveTask(id) { if (ds_map_exists(tasks, id)) ds_map_delete(tasks, id); return self; };
    function GetTask(id) { return ds_map_exists(tasks, id) ? tasks[? id] : undefined; };
    function AreAllComplete() {
        var keys = ds_map_keys_to_array(tasks);
        for (var i=0;i<array_length(keys);i++) if (!tasks[? keys[i]].IsComplete()) { array_delete(keys,0,array_length(keys)); return false; }
        array_delete(keys,0,array_length(keys));
        return true;
    };
    function Clear() { ds_map_clear(tasks); return self; };
    function Free() { ds_map_destroy_gmu(tasks); };
};

//  Utility Functions
function ExecuteSafe(fn, data = undefined, fallback = undefined) {
    try { fn(data); } catch(e) { show_debug_message("ExecuteSafe error: "+string(e)); if (fallback!=undefined) return fallback(); return undefined; }
};

function GetUnixDateTime(dateTarget) {
    var dateStart = date_create_datetime(1970,1,1,0,0,0);
    return date_compare_date(dateStart, dateTarget);
};

function ds_queue_to_array(queue) {
    var result = [];
	var copy = ds_queue_create();
	
	ds_queue_copy(copy, queue);
    
    var size = ds_queue_size(copy);
    
    for (var i = 0; i < size; i++) {
        result[i] = ds_queue_dequeue(copy);
    }
	
	ds_queue_destroy(copy);
    
    return result;
}

