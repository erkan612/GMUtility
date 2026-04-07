// Enums
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

enum INPUT_TYPE {
    KEY,
    MOUSE_BUTTON,
    GAMEPAD_BUTTON,
    GAMEPAD_AXIS,
    MOUSE_AXIS,
    TOUCH_POINT,
	MOUSE_WHEEL
}

enum INPUT_STATE {
    JUST_PRESSED,
    PRESSED,
    JUST_RELEASED,
    RELEASED,
    DOUBLE_TAPPED,
    LONG_PRESSED
}

enum MOUSE_BUTTON {
    LEFT									= 0,
    RIGHT									= 1,
    MIDDLE									= 2,
    MBACK									= 3,
    MFORWARD								= 4
}

enum GAMEPAD_BUTTON {
    A										= 0,
    B										= 1,
    X										= 2,
    Y										= 3,
    LB										= 4,
    RB										= 5,
    LT										= 6,
    RT										= 7,
    BACK									= 8,
    START									= 9,
    L_STICK									= 10,
    R_STICK									= 11,
    DPAD_UP									= 12,
    DPAD_DOWN								= 13,
    DPAD_LEFT								= 14,
    DPAD_RIGHT								= 15,
    GUIDE									= 16
}

enum GAMEPAD_AXIS {
    LEFT_X									= 0,
    LEFT_Y									= 1,
    RIGHT_X									= 2,
    RIGHT_Y									= 3,
    LEFT_TRIGGER							= 4,
    RIGHT_TRIGGER							= 5
}

enum INPUT_MODIFIER {
    NONE        = 0,
    SHIFT       = 1 << 0,
    CTRL        = 1 << 1,
    ALT         = 1 << 2,
    ANY         = 1 << 3
}

enum MOUSE_WHEEL {
    UP,
    DOWN,
    LEFT,
    RIGHT
}

// INPUT MANAGEMENT
function InputManager() constructor {
    // PROPERTIES & DATA STRUCTURES
    actions = ds_map_create_gmu();        // Action name -> ActionConfig
    input_states = ds_map_create_gmu();   // Action name -> current state
    input_events = ds_list_create_gmu();  // Queue for input events
    device_callbacks = ds_map_create_gmu(); // Device-specific callbacks
	sequence_states = ds_map_create_gmu();  // Active sequences per binding
    
    // Global settings
    gamepad_deadzone = 0.2;
    double_tap_time = 0.3;      // Seconds
    long_press_time = 0.5;      // Seconds
    repeat_delay = 0.5;         // Seconds before repeat starts
    repeat_interval = 0.05;     // Seconds between repeats
    
    // Touch tracking
    touches = ds_map_create_gmu();
    next_touch_id = 0;
    
    // Axis smoothing
    axis_smoothing = false;
    axis_smoothing_factor = 0.85;
	
	// Mouse Wheel Settings
	mouse_wheel_delta_x = 0;
	mouse_wheel_delta_y = 0;
	mouse_wheel_accumulator_x = 0;
	mouse_wheel_accumulator_y = 0;
	mouse_wheel_last_up_state = false;
	mouse_wheel_last_down_state = false;
	mouse_wheel_last_left_state = false;
	mouse_wheel_last_right_state = false;
	
	// Buffering
	buffer_enabled = true;
	buffer_duration = 0.5;
	buffer_max_size = 1;
	input_buffer = ds_queue_create_gmu();
    
    // CONSTRUCTOR CLASSES
    function ActionConfig(_name) constructor {
        name = _name;
        bindings = ds_list_create_gmu();     // List of InputBinding
        device_priorities = ds_map_create_gmu(); // Device -> priority (lower = higher priority)
        enabled = true;
        consume_input = false;      // If true, other actions won't receive this input
        tags = ds_list_create_gmu();
        
        // Analog settings
        analog_smoothing = 0.0;     // 0-1 smoothing factor
        analog_curve = 1.0;         // Power curve for analog response
        invert_x = false;
        invert_y = false;
        swap_axes = false;
        
        // Digital settings
        digital_delay = 0.0;        // Delay before action triggers
        digital_hold = false;        // Action stays active while held
		
		// For JSON
	    serializable_properties = ["name", "enabled", "consume_input", "analog_smoothing",
	                               "analog_curve", "invert_x", "invert_y", "swap_axes",
	                               "digital_delay", "digital_hold"];
    
	    ToJSON = function() {
	        var json = {};
	        for (var i = 0; i < array_length(serializable_properties); i++) {
	            var prop = serializable_properties[i];
	            if (variable_struct_exists(self, prop)) {
	                json[$ prop] = variable_struct_get(self, prop);
	            }
	        }
        
	        json.bindings = [];
	        for (var i = 0; i < ds_list_size(bindings); i++) {
	            array_push(json.bindings, bindings[| i].ToJSON());
	        }
        
	        json.device_priorities = {};
	        var priority_keys = ds_map_keys_to_array(device_priorities);
	        for (var i = 0; i < array_length(priority_keys); i++) {
	            var key = priority_keys[i];
	            json.device_priorities[$ string(key)] = device_priorities[? key];
	        }
        
	        json.tags = [];
	        for (var i = 0; i < ds_list_size(tags); i++) {
	            array_push(json.tags, tags[| i]);
	        }
        
	        return json;
	    };
    
	    FromJSON = function(json) {
		    var json_keys = variable_struct_get_names(json);
    
		    for (var i = 0; i < array_length(json_keys); i++) {
		        var key = json_keys[i];
        
		        if (key == "bindings") continue;
		        if (key == "device_priorities") continue;
		        if (key == "tags") continue;
        
		        if (variable_struct_exists(self, key)) {
		            var value = variable_struct_get(json, key);
		            variable_struct_set(self, key, value);
		        }
		    }
    
		    if (variable_struct_exists(json, "bindings")) {
		        var bindings_array = variable_struct_get(json, "bindings");
		        for (var i = 0; i < array_length(bindings_array); i++) {
		            var binding = new InputBinding();
		            binding.FromJSON(bindings_array[i]);
		            ds_list_add(bindings, binding);
		        }
		    }
    
		    if (variable_struct_exists(json, "device_priorities")) {
		        var priorities = variable_struct_get(json, "device_priorities");
		        var priority_keys = variable_struct_get_names(priorities);
		        for (var i = 0; i < array_length(priority_keys); i++) {
		            var key = priority_keys[i];
		            var value = variable_struct_get(priorities, key);
		            device_priorities[? real(key)] = value;
		        }
		    }
    
		    if (variable_struct_exists(json, "tags")) {
		        var tags_array = variable_struct_get(json, "tags");
		        for (var i = 0; i < array_length(tags_array); i++) {
		            ds_list_add(tags, tags_array[i]);
		        }
		    }
    
		    return self;
		};
        
        AddBinding = function(binding) {
            ds_list_add(bindings, binding);
            return self;
        };
        
        SetPriority = function(device, priority) {
            device_priorities[? device] = priority;
            return self;
        };
        
        AddTag = function(tag) {
            ds_list_add(tags, tag);
            return self;
        };
        
        Free = function() {
            for (var i = 0; i < ds_list_size(bindings); i++) {
                var binding = bindings[| i];
                binding.Free();
            }
            ds_list_destroy_gmu(bindings);
            ds_map_destroy_gmu(device_priorities);
            ds_list_destroy_gmu(tags);
        };
    }
    
    function InputBinding() constructor {
        type = INPUT_TYPE.KEY;
        device = INPUT_DEVICE.KEYBOARD;
        
        // For keys/buttons
        key_code = 0;
        key_string = "";
        modifiers = 0;  // shift, ctrl, alt flags
        
        // For mouse
        mouse_button = MOUSE_BUTTON.LEFT;
        mouse_region = undefined;  // Rect for region-specific mouse input
	    mouse_wheel_direction = MOUSE_WHEEL.UP;
	    mouse_wheel_threshold = 1;       // Number of scroll ticks
        
        // For gamepad
        gamepad_button = GAMEPAD_BUTTON.A;
        gamepad_axis = GAMEPAD_AXIS.LEFT_X;
        axis_threshold = 0.5;      // For digital triggers from analog
        axis_positive_only = false;
        
        // For touch
        touch_region = undefined;
        touch_gesture = "";  // "tap", "swipe", "pinch", etc.
		
		// For chords
	    chord_bindings = undefined;  // Array of InputBinding for chords
	    chord_mode = "all";          // "all", "any", "sequence"
    
	    // For axis-to-button
	    axis_to_button_threshold = 0.5;
	    axis_to_button_rising = true;   // Trigger on rising edge only
	    axis_to_button_falling = false;  // Trigger on falling edge
	    axis_previous_state = false;
		
		// Sequence settings
		sequence_timeout = 0.5;
		sequence_current_index = 0;
		sequence_timer = 0;
		sequence_completed = false;
		
	    // For JSON serialization
	    serializable_properties = ["type", "device", "key_code", "key_string", "modifiers", 
	                               "mouse_button", "gamepad_button", "gamepad_axis", 
	                               "axis_threshold", "axis_positive_only", "touch_gesture",
	                               "chord_bindings", "chord_mode", "axis_to_button_threshold",
	                               "mouse_wheel_direction", "mouse_wheel_threshold", "sequence_timeout"];
		
	    ToJSON = function() {
	        var json = {};
	        for (var i = 0; i < array_length(serializable_properties); i++) {
	            var prop = serializable_properties[i];
	            if (variable_struct_exists(self, prop)) {
	                json[$ prop] = variable_struct_get(self, prop);
	            }
	        }
        
	        // Handle chord bindings recursively
	        if (chord_bindings != undefined) {
	            json.chord_bindings = [];
	            for (var i = 0; i < array_length(chord_bindings); i++) {
	                array_push(json.chord_bindings, chord_bindings[i].ToJSON());
	            }
	        }
        
	        return json;
	    };
    
	    FromJSON = function(json) {
		    var json_keys = variable_struct_get_names(json);
    
		    for (var i = 0; i < array_length(json_keys); i++) {
		        var key = json_keys[i];
        
		        if (key == "chord_bindings") {
		            chord_bindings = [];
		            var chord_array = variable_struct_get(json, key);
		            for (var j = 0; j < array_length(chord_array); j++) {
		                var binding = new InputBinding();
		                binding.FromJSON(chord_array[j]);
		                array_push(chord_bindings, binding);
		            }
		        } else if (variable_struct_exists(self, key)) {
		            var value = variable_struct_get(json, key);
		            variable_struct_set(self, key, value);
		        }
		    }
		    return self;
		};
        
        invert = false;
        scale = 1.0;
        deadzone = 0.0;
        
        Free = function() {
        };
    }
	
	function BufferedInput(_action_name, _value = 1, _priority = 0) constructor {
	    action = _action_name;
	    value = _value;           // For analog actions
	    priority = _priority;     // Higher priority overrides lower
	    timestamp = current_time;
	    processed = false;
    
	    // For specific input types
	    is_analog = false;
	    vector_x = 0;
	    vector_y = 0;
    
	    // Combo/tag for grouping
	    combo_tag = "";
	    combo_step = 0;
	}
    
    function InputState(_config) constructor {
        config = _config;
        
        // Digital state
        pressed = false;
        just_pressed = false;
        just_released = false;
        press_time = 0;
        release_time = 0;
        press_count = 0;
        last_press_time = 0;
        
        // Analog state
        value = 0;
        raw_value = 0;
        smoothed_value = 0;
        vector_x = 0;
        vector_y = 0;
        raw_vector_x = 0;
        raw_vector_y = 0;
        angle = 0;
        magnitude = 0;
        
        // Timing
        double_tapped = false;
        long_pressed = false;
        hold_timer = 0;
        repeat_timer = 0;
        
        Reset = function() {
            pressed = false;
            just_pressed = false;
            just_released = false;
            value = 0;
            vector_x = 0;
            vector_y = 0;
            magnitude = 0;
            double_tapped = false;
            long_pressed = false;
        };
        
        UpdateAnalog = function(x, y) {
            raw_vector_x = x;
            raw_vector_y = y;
            
            if (config.swap_axes) {
                var temp = x;
                x = y;
                y = temp;
            }
            
            if (config.invert_x) x = -x;
            if (config.invert_y) y = -y;
            
            // Apply deadzone
            var magnitude = sqrt(x*x + y*y);
            if (magnitude < gamepad_deadzone) {
                x = 0;
                y = 0;
                magnitude = 0;
            } else {
                // Scale from deadzone to 1
                var t = (magnitude - gamepad_deadzone) / (1 - gamepad_deadzone);
                magnitude = t;
                if (magnitude > 0) {
                    x = (x / magnitude) * t;
                    y = (y / magnitude) * t;
                }
            }
            
            // Apply curve
            if (config.analog_curve != 1.0) {
                var curved = pow(magnitude, config.analog_curve);
                if (magnitude > 0) {
                    x = (x / magnitude) * curved;
                    y = (y / magnitude) * curved;
                }
                magnitude = curved;
            }
            
            vector_x = x;
            vector_y = y;
            this.magnitude = magnitude;
            angle = arctan2(y, x);
            
            // Update value (for single-axis actions)
            if (abs(x) > abs(y)) {
                value = x;
            } else {
                value = y;
            }
        };
        
        UpdateDigital = function(_pressed, delta_time) {
            if (_pressed && !pressed) {
                // Just pressed
                just_pressed = true;
                pressed = true;
                press_time = current_time;
                press_count++;
                
                // Double tap detection
                if (press_time - last_press_time < InputManager.double_tap_time * 1000000) {
                    double_tapped = true;
                } else {
                    double_tapped = false;
                }
                last_press_time = press_time;
                
                // Long press timer
                long_pressed = false;
                hold_timer = 0;
                repeat_timer = 0;
                
            } else if (!_pressed && pressed) {
                // Just released
                just_released = true;
                pressed = false;
                release_time = current_time;
                
                if (hold_timer >= InputManager.long_press_time && !long_pressed) { // Check if long press was achieved
                    long_pressed = true;
                }
                
            } else if (_pressed && pressed) {
                // Held
                just_pressed = false;
                just_released = false;
                
                // Long press detection
                hold_timer += delta_time;
                if (hold_timer >= long_press_time && !long_pressed) {
                    long_pressed = true;
                }
                
                // Repeat detection (for keyboard repeat behavior)
                if (repeat_timer <= 0 && hold_timer > repeat_delay) {
                    repeat_timer = repeat_interval;
                    just_pressed = true;  // Simulate another press
                } else if (repeat_timer > 0) {
                    repeat_timer -= delta_time;
                }
            } else {
                just_pressed = false;
                just_released = false;
                double_tapped = false;
            }
        };
    }
    
    // BINDING CREATION HELPERS (Factory Methods)
    function InputBindingFromChord(_bindings, _mode = "all") {
        var binding = new InputBinding();
        binding.type = INPUT_TYPE.KEY;  // Or appropriate type
        binding.chord_bindings = _bindings;
        binding.chord_mode = _mode;
        return binding;
    }

    function InputBindingFromAxisToButton(_axis, _threshold = 0.5, _rising = true, _falling = false, _gamepad_id = 0) {
        var binding = new InputBinding();
        binding.type = INPUT_TYPE.GAMEPAD_AXIS;
        binding.device = _gamepad_id;
        binding.gamepad_axis = _axis;
        binding.axis_to_button_threshold = _threshold;
        binding.axis_to_button_rising = _rising;
        binding.axis_to_button_falling = _falling;
        binding.axis_threshold = _threshold;
        return binding;
    }

    function InputBindingFromMouseWheel(_direction, _threshold = 1) {
        var binding = new InputBinding();
        binding.type = INPUT_TYPE.MOUSE_WHEEL;
        binding.device = INPUT_DEVICE.MOUSE;
        binding.mouse_wheel_direction = _direction;
        binding.mouse_wheel_threshold = _threshold;
        return binding;
    }
        
    function InputBindingFromKey(_key, _modifiers = 0, _device = INPUT_DEVICE.KEYBOARD) {
        var binding = new InputBinding();
        binding.type = INPUT_TYPE.KEY;
        binding.device = _device;
        binding.key_code = ord(_key);
        binding.key_string = _key;
        binding.modifiers = _modifiers;
        return binding;
    };
    
    function InputBindingFromMouse(_button, _region = undefined) {
        var binding = new InputBinding();
        binding.type = INPUT_TYPE.MOUSE_BUTTON;
        binding.device = INPUT_DEVICE.MOUSE;
        binding.mouse_button = _button;
        binding.mouse_region = _region;
        return binding;
    };
    
    function InputBindingFromGamepadButton(_button, _gamepad_id = 0) {
        var binding = new InputBinding();
        binding.type = INPUT_TYPE.GAMEPAD_BUTTON;
        binding.device = _gamepad_id;
        binding.gamepad_button = _button;
        return binding;
    };
    
    function InputBindingFromGamepadAxis(_axis, _threshold = 0.5, _positive_only = false, _gamepad_id = 0) {
        var binding = new InputBinding();
        binding.type = INPUT_TYPE.GAMEPAD_AXIS;
        binding.device = _gamepad_id;
        binding.gamepad_axis = _axis;
        binding.axis_threshold = _threshold;
        binding.axis_positive_only = _positive_only;
        return binding;
    };
    
    function InputBindingFromTouch(_region = undefined, _gesture = "tap") {
        var binding = new InputBinding();
        binding.type = INPUT_TYPE.TOUCH_POINT;
        binding.device = INPUT_DEVICE.TOUCH;
        binding.touch_region = _region;
        binding.touch_gesture = _gesture;
        return binding;
    };
    
    function InputBindingFromKeySequence(_keys, _timeout = 0.5, _modifiers = 0) {
        var bindings = [];
        for (var i = 0; i < array_length(_keys); i++) {
            var binding = InputBindingFromKey(_keys[i], _modifiers);
            array_push(bindings, binding);
        }
    
        var binding = new InputBinding();
        binding.type = INPUT_TYPE.KEY;
        binding.chord_bindings = bindings;
        binding.chord_mode = "sequence";
        binding.sequence_timeout = _timeout;
        return binding;
    }

    function InputBindingFromMixedSequence(_bindings_array, _timeout = 0.5) {
        var binding = new InputBinding();
        binding.type = INPUT_TYPE.KEY;  // Dummy type
        binding.chord_bindings = _bindings_array;
        binding.chord_mode = "sequence";
        binding.sequence_timeout = _timeout;
        return binding;
    }
    
    // ACTION MANAGEMENT
    function CreateAction(_name) {
        if (ds_map_exists(actions, _name)) {
            return actions[? _name];
        }
        
        var config = new ActionConfig(_name);
        var state = new InputState(config);
        actions[? _name] = config;
        input_states[? _name] = state;
        
        return config;
    };
    
    function GetAction(_name) {
        return ds_map_exists(actions, _name) ? actions[? _name] : undefined;
    };
    
    function EnableAction(_action_name) {
        var action = GetAction(_action_name);
        if (action != undefined) action.enabled = true;
        return self;
    };
    
    function DisableAction(_action_name) {
        var action = GetAction(_action_name);
        if (action != undefined) action.enabled = false;
        return self;
    };
    
    function EnableAllActions() {
        var keys = ds_map_keys_to_array(actions);
        for (var i = 0; i < array_length(keys); i++) {
            actions[? keys[i]].enabled = true;
        }
        return self;
    };
    
    function DisableAllActions() {
        var keys = ds_map_keys_to_array(actions);
        for (var i = 0; i < array_length(keys); i++) {
            actions[? keys[i]].enabled = false;
        }
        return self;
    };
    
    // BINDING METHODS
    function BindKey(_action_name, _key, _modifiers = 0, _device = INPUT_DEVICE.KEYBOARD) {
        var action = GetAction(_action_name);
        if (action == undefined) action = CreateAction(_action_name);
        action.AddBinding(InputBindingFromKey(_key, _modifiers, _device));
        return self;
    };
    
    function BindMouse(_action_name, _button, _region = undefined) {
        var action = GetAction(_action_name);
        if (action == undefined) action = CreateAction(_action_name);
        action.AddBinding(InputBindingFromMouse(_button, _region));
        return self;
    };
    
    function BindGamepadButton(_action_name, _button, _gamepad_id = 0) {
        var action = GetAction(_action_name);
        if (action == undefined) action = CreateAction(_action_name);
        action.AddBinding(InputBindingFromGamepadButton(_button, _gamepad_id));
        return self;
    };
    
    function BindGamepadAxis(_action_name, _axis, _threshold = 0.5, _positive_only = false, _gamepad_id = 0) {
        var action = GetAction(_action_name);
        if (action == undefined) action = CreateAction(_action_name);
        action.AddBinding(InputBindingFromGamepadAxis(_axis, _threshold, _positive_only, _gamepad_id));
        return self;
    };
    
    function BindTouch(_action_name, _region = undefined, _gesture = "tap") {
        var action = GetAction(_action_name);
        if (action == undefined) action = CreateAction(_action_name);
        action.AddBinding(InputBindingFromTouch(_region, _gesture));
        return self;
    };
    
    // INPUT QUERY METHODS
    function IsPressed(_action_name) {
        if (!ds_map_exists(input_states, _action_name)) return false;
        var action = GetAction(_action_name);
        if (!action.enabled) return false;
        return input_states[? _action_name].pressed;
    };
    
    function IsJustPressed(_action_name) {
        if (!ds_map_exists(input_states, _action_name)) return false;
        var action = GetAction(_action_name);
        if (!action.enabled) return false;
        return input_states[? _action_name].just_pressed;
    };
    
    function IsJustReleased(_action_name) {
        if (!ds_map_exists(input_states, _action_name)) return false;
        var action = GetAction(_action_name);
        if (!action.enabled) return false;
        return input_states[? _action_name].just_released;
    };
    
    function IsDoubleTapped(_action_name) {
        if (!ds_map_exists(input_states, _action_name)) return false;
        var action = GetAction(_action_name);
        if (!action.enabled) return false;
        return input_states[? _action_name].double_tapped;
    };
    
    function IsLongPressed(_action_name) {
        if (!ds_map_exists(input_states, _action_name)) return false;
        var action = GetAction(_action_name);
        if (!action.enabled) return false;
        return input_states[? _action_name].long_pressed;
    };
    
    function GetValue(_action_name) {
        if (!ds_map_exists(input_states, _action_name)) return 0;
        return input_states[? _action_name].value;
    };
    
    function GetVector(_action_name) {
        if (!ds_map_exists(input_states, _action_name)) return { x: 0, y: 0 };
        var state = input_states[? _action_name];
        return { x: state.vector_x, y: state.vector_y };
    };
    
    function GetMagnitude(_action_name) {
        if (!ds_map_exists(input_states, _action_name)) return 0;
        return input_states[? _action_name].magnitude;
    };
    
    function GetAngle(_action_name) {
        if (!ds_map_exists(input_states, _action_name)) return 0;
        return input_states[? _action_name].angle;
    };
    
    function GetPressDuration(_action_name) {
        if (!ds_map_exists(input_states, _action_name)) return 0;
        var state = input_states[? _action_name];
        if (!state.pressed) return 0;
        return (current_time - state.press_time) / 1000000.0;
    };
    
    // BUFFERING SYSTEM
	function BufferInput(_action_name, _value = 1, _priority = 0, _is_analog = false, _vector_x = 0, _vector_y = 0) {
	    if (!buffer_enabled) {
	        TriggerAction(_action_name, _value > 0, { value: _value, analog: _is_analog, x: _vector_x, y: _vector_y });
	        return self;
	    }
    
	    var current_state = input_states[? _action_name];
	    if (current_state != undefined && current_state.pressed && !_is_analog) {
	        return self;
	    }
    
	    var override = false;
	    var buffer_array = ds_queue_to_array(input_buffer);
    
	    for (var i = 0; i < array_length(buffer_array); i++) {
	        var buffered = buffer_array[i];
	        if (buffered.action == _action_name && _priority >= buffered.priority) {
	            override = true;
	            RemoveBufferedInputByIndex(i);
	            break;
	        }
	    }
    
	    if (ds_queue_size(input_buffer) >= buffer_max_size && !override) {
	        return self;
	    }
    
	    var buffered = new BufferedInput(_action_name, _value, _priority);
	    buffered.is_analog = _is_analog;
	    buffered.vector_x = _vector_x;
	    buffered.vector_y = _vector_y;
    
	    ds_queue_enqueue(input_buffer, buffered);
    
	    return self;
	}

	function RemoveBufferedInputByIndex(_index) {
	    var temp_queue = ds_queue_create_gmu();
	    var current_index = 0;
    
	    while (!ds_queue_empty(input_buffer)) {
	        var item = ds_queue_dequeue(input_buffer);
	        if (current_index != _index) {
	            ds_queue_enqueue(temp_queue, item);
	        }
	        current_index++;
	    }
    
	    ds_queue_destroy_gmu(input_buffer);
	    input_buffer = temp_queue;
	}

	function ProcessBuffer(_delta_time) {
	    if (!buffer_enabled) return self;
    
	    var expired = [];
	    var processed_actions = ds_map_create_gmu();
    
	    var buffer_size = ds_queue_size(input_buffer);
	    for (var i = 0; i < buffer_size; i++) {
	        var buffered = input_buffer[| i];
	        if (buffered == undefined) continue;
        
	        var age = (current_time - buffered.timestamp) / 1000000.0;
	        if (age >= buffer_duration) {
	            array_push(expired, i);
	            continue;
	        }
        
	        var action_config = GetAction(buffered.action);
	        if (action_config == undefined || !action_config.enabled) {
	            array_push(expired, i);
	            continue;
	        }
        
	        if (ds_map_exists(processed_actions, buffered.action)) {
	            continue;
	        }
        
	        var current_state = input_states[? buffered.action];
	        var can_execute = true;
        
	        if (!buffered.is_analog && current_state != undefined && current_state.pressed) {
	            can_execute = false;
	        }
        
	        if (can_execute) {
	            if (buffered.is_analog) {
	                var state = input_states[? buffered.action];
	                if (state != undefined) {
	                    state.UpdateAnalog(buffered.vector_x, buffered.vector_y);
	                    state.value = buffered.value;
	                }
	                TriggerAction(buffered.action, true, {
	                    value: buffered.value,
	                    analog: true,
	                    x: buffered.vector_x,
	                    y: buffered.vector_y
	                });
	            } else {
	                TriggerAction(buffered.action, true, { value: buffered.value, buffered: true });
	            }
            
	            ds_map_add(processed_actions, buffered.action, true);
	            array_push(expired, i);
	        }
	    }
    
	    ds_map_destroy_gmu(processed_actions);
    
	    for (var i = array_length(expired) - 1; i >= 0; i--) {
	        RemoveBufferedInputByIndex(expired[i]);
	    }
    
	    return self;
	}
	
	function FlushBuffer() {
	    ds_queue_clear(input_buffer);
	    return self;
	}

	function ClearBufferedAction(_action_name) {
	    var temp_queue = ds_queue_create_gmu();
    
	    while (!ds_queue_empty(input_buffer)) {
	        var item = ds_queue_dequeue(input_buffer);
	        if (item.action != _action_name) {
	            ds_queue_enqueue(temp_queue, item);
	        }
	    }
    
	    ds_queue_destroy_gmu(input_buffer);
	    input_buffer = temp_queue;
    
	    return self;
	}

	function HasBufferedInput(_action_name) {
	    for (var i = 0; i < ds_queue_size(input_buffer); i++) {
	        var buffered = input_buffer[| i];
	        if (buffered.action == _action_name) {
	            return true;
	        }
	    }
	    return false;
	}

	function GetBufferSize() {
	    return ds_queue_size(input_buffer);
	}

	function GetOldestBufferedInput() {
	    if (ds_queue_empty(input_buffer)) return undefined;
	    return input_buffer[| 0];
	}

	function GetNewestBufferedInput() {
	    if (ds_queue_empty(input_buffer)) return undefined;
	    return input_buffer[| ds_queue_size(input_buffer) - 1];
	}
	
	function BufferCombo(_combo_tag, _step, _action_name, _priority = 0) {
	    if (!buffer_enabled) return self;
    
	    var buffered = new BufferedInput(_action_name, 1, _priority);
	    buffered.combo_tag = _combo_tag;
	    buffered.combo_step = _step;
    
	    var temp_queue = ds_queue_create_gmu();
	    while (!ds_queue_empty(input_buffer)) {
	        var item = ds_queue_dequeue(input_buffer);
	        if (!(item.combo_tag == _combo_tag && item.combo_step >= _step)) {
	            ds_queue_enqueue(temp_queue, item);
	        }
	    }
	    ds_queue_destroy_gmu(input_buffer);
	    input_buffer = temp_queue;
    
	    ds_queue_enqueue(input_buffer, buffered);
	    return self;
	}
    
    // MOUSE WHEEL HANDLING
	function MouseGetWheelDeltaX() {
	    var current_left = 0; // gamemaker doesnt have mouse wheel left and right
	    var current_right = 0;
	    var delta = 0;
    
	    if (current_left && !mouse_wheel_last_left_state) {
	        delta = -1;  // Left is negative
	    }
	    if (current_right && !mouse_wheel_last_right_state) {
	        delta = 1;   // Right is positive
	    }
    
	    mouse_wheel_last_left_state = current_left;
	    mouse_wheel_last_right_state = current_right;
    
	    mouse_wheel_delta_x = delta;
    
	    return delta;
	}

	function MouseGetWheelDeltaY() {
	    var current_up = mouse_wheel_up();
	    var current_down = mouse_wheel_down();
	    var delta = 0;
    
	    if (current_up && !mouse_wheel_last_up_state) {
	        delta = 1;   // Up is positive
	    }
	    if (current_down && !mouse_wheel_last_down_state) {
	        delta = -1;  // Down is negative
	    }
    
	    mouse_wheel_last_up_state = current_up;
	    mouse_wheel_last_down_state = current_down;
    
	    mouse_wheel_delta_y = delta;
    
	    return delta;
	}

	function MouseGetWheelDelta() {
	    return {
	        x: MouseGetWheelDeltaX(),
	        y: MouseGetWheelDeltaY()
	    };
	}
	
	function ProcessMouseWheel() {
		mouse_wheel_delta_x = MouseGetWheelDeltaX();
		mouse_wheel_delta_y = MouseGetWheelDeltaY();
		
	    mouse_wheel_accumulator_x += mouse_wheel_delta_x;
	    mouse_wheel_accumulator_y += mouse_wheel_delta_y;
    
	    var action_keys = ds_map_keys_to_array(actions);
	    for (var i = 0; i < array_length(action_keys); i++) {
	        var action_name = action_keys[i];
	        var action = actions[? action_name];
	        if (!action.enabled) continue;
        
	        for (var j = 0; j < ds_list_size(action.bindings); j++) {
	            var binding = action.bindings[| j];
	            if (binding.type == INPUT_TYPE.MOUSE_WHEEL) {
	                var triggered = CheckMouseWheelBinding(binding);
	                if (triggered) {
	                    TriggerAction(action_name, true, { 
	                        direction: binding.mouse_wheel_direction,
	                        delta: binding.mouse_wheel_direction == MOUSE_WHEEL.UP ? mouse_wheel_delta_y : mouse_wheel_delta_x
	                    });
	                }
	            }
	        }
	    }
	}

	function CheckMouseWheelBinding(_binding) {
	    var delta = 0;
	    var accumulator = 0;
    
	    switch(_binding.mouse_wheel_direction) {
	        case MOUSE_WHEEL.UP:
	            delta = mouse_wheel_delta_y;
	            accumulator = mouse_wheel_accumulator_y;
	            break;
	        case MOUSE_WHEEL.DOWN:
	            delta = -mouse_wheel_delta_y;
	            accumulator = -mouse_wheel_accumulator_y;
	            break;
	        case MOUSE_WHEEL.LEFT:
	            delta = -mouse_wheel_delta_x;
	            accumulator = -mouse_wheel_accumulator_x;
	            break;
	        case MOUSE_WHEEL.RIGHT:
	            delta = mouse_wheel_delta_x;
	            accumulator = mouse_wheel_accumulator_x;
	            break;
	    }
    
	    if (delta > 0) {
	        if (accumulator >= _binding.mouse_wheel_threshold) {
	            switch(_binding.mouse_wheel_direction) {
	                case MOUSE_WHEEL.UP: mouse_wheel_accumulator_y = 0; break;
	                case MOUSE_WHEEL.DOWN: mouse_wheel_accumulator_y = 0; break;
	                case MOUSE_WHEEL.LEFT: mouse_wheel_accumulator_x = 0; break;
	                case MOUSE_WHEEL.RIGHT: mouse_wheel_accumulator_x = 0; break;
	            }
	            return true;
	        }
	    }
    
	    return false;
	}
    
    // CHORD & SEQUENCE HANDLING
	function CheckChordBinding(_binding) {
	    if (_binding.chord_bindings == undefined) return false;
    
	    switch(_binding.chord_mode) {
	        case "all":
	            for (var i = 0; i < array_length(_binding.chord_bindings); i++) {
	                if (!CheckSingleBinding(_binding.chord_bindings[i])) return false;
	            }
	            return true;
            
	        case "any":
	            for (var i = 0; i < array_length(_binding.chord_bindings); i++) {
	                if (CheckSingleBinding(_binding.chord_bindings[i])) return true;
	            }
	            return false;
            
	        case "sequence":
	            for (var i = 0; i < array_length(_binding.chord_bindings); i++) {
	                if (!CheckSingleBinding(_binding.chord_bindings[i])) return false;
	            }
	            return true;
	    }
    
	    return false;
	}

	function CheckSingleBinding(_binding, _gamepad_id = -1) {
	    switch(_binding.type) {
	        case INPUT_TYPE.KEY:
	            var key_pressed = keyboard_check(_binding.key_code);
	            if (_binding.modifiers != 0) {
	                if (_binding.modifiers & INPUT_MODIFIER.SHIFT)
	                    key_pressed = key_pressed && keyboard_check(vk_shift);
	                if (_binding.modifiers & INPUT_MODIFIER.CTRL)
	                    key_pressed = key_pressed && keyboard_check(vk_control);
	                if (_binding.modifiers & INPUT_MODIFIER.ALT)
	                    key_pressed = key_pressed && keyboard_check(vk_alt);
	            }
	            return key_pressed;
            
	        case INPUT_TYPE.MOUSE_BUTTON:
	            var pressed = mouse_check_button(_binding.mouse_button);
	            if (pressed && _binding.mouse_region != undefined) {
	                var mx = window_mouse_get_x();
	                var my = window_mouse_get_y();
	                pressed = _binding.mouse_region.Contains(mx, my);
	            }
	            return pressed;
            
	        case INPUT_TYPE.GAMEPAD_BUTTON:
	            var gid = (_binding.device == INPUT_DEVICE.ANY) ? _gamepad_id : _binding.device;
	            return gamepad_button_check(gid, _binding.gamepad_button);
            
	        case INPUT_TYPE.GAMEPAD_AXIS:
	            var gid = (_binding.device == INPUT_DEVICE.ANY) ? _gamepad_id : _binding.device;
	            var value = gamepad_axis_value(gid, _binding.gamepad_axis);
	            if (_binding.axis_positive_only) value = max(0, value);
	            return abs(value) >= _binding.axis_threshold;
            
	        case INPUT_TYPE.MOUSE_WHEEL:
	            return CheckMouseWheelBinding(_binding);
	    }
	    return false;
	}
	
	function CheckSequenceBinding(_binding, _gamepad_id = -1) {
	    if (_binding.chord_bindings == undefined || array_length(_binding.chord_bindings) == 0) {
	        return false;
	    }
    
	    switch(_binding.chord_mode) {
	        case "all":
	            return CheckAllChord(_binding, _gamepad_id);
            
	        case "any":
	            return CheckAnyChord(_binding, _gamepad_id);
            
	        case "sequence":
	            return CheckSequentialChord(_binding, _gamepad_id);
	    }
    
	    return false;
	}

	function CheckAllChord(_binding, _gamepad_id) {
	    for (var i = 0; i < array_length(_binding.chord_bindings); i++) {
	        if (!CheckSingleBinding(_binding.chord_bindings[i], _gamepad_id)) {
	            return false;
	        }
	    }
	    return true;
	}

	function CheckAnyChord(_binding, _gamepad_id) {
	    for (var i = 0; i < array_length(_binding.chord_bindings); i++) {
	        if (CheckSingleBinding(_binding.chord_bindings[i], _gamepad_id)) {
	            return true;
	        }
	    }
	    return false;
	}

	function CheckSequentialChord(_binding, _gamepad_id) {
	    var state_key = string(_binding) + "_" + string(_gamepad_id);
	    var seq_state = ds_map_find_value(sequence_states, state_key);
    
	    if (seq_state == undefined) {
	        seq_state = {
	            current_index: 0,
	            timer: 0,
	            completed: false,
	            last_input_time: 0
	        };
	        ds_map_add(sequence_states, state_key, seq_state);
	    }
    
	    if (seq_state.timer > 0 && current_time - seq_state.last_input_time > _binding.sequence_timeout * 1000000) {
	        seq_state.current_index = 0;
	        seq_state.completed = false;
	        seq_state.timer = 0;
	    }
    
	    if (seq_state.completed) {
	        seq_state.completed = false;
	        seq_state.current_index = 0;
	        return true;
	    }
    
	    if (seq_state.current_index >= array_length(_binding.chord_bindings)) {
	        seq_state.completed = true;
	        seq_state.current_index = 0;
	        return true;
	    }
    
	    var current_step = _binding.chord_bindings[seq_state.current_index];
	    var step_pressed = CheckSingleBinding(current_step, _gamepad_id);
    
	    var is_just_pressed = IsBindingJustPressed(current_step, _gamepad_id);
    
	    if (step_pressed && is_just_pressed) {
	        seq_state.current_index++;
	        seq_state.last_input_time = current_time;
	        seq_state.timer = _binding.sequence_timeout;
        
	        if (seq_state.current_index >= array_length(_binding.chord_bindings)) {
	            seq_state.completed = true;
	            seq_state.current_index = 0;
	            return true;
	        }
	    }
    
	    return false;
	}

	function IsBindingJustPressed(_binding, _gamepad_id = -1) {
	    switch(_binding.type) {
	        case INPUT_TYPE.KEY:
	            return keyboard_check_pressed(_binding.key_code);
            
	        case INPUT_TYPE.MOUSE_BUTTON:
	            return mouse_check_button_pressed(_binding.mouse_button);
            
	        case INPUT_TYPE.GAMEPAD_BUTTON:
	            var gid = (_binding.device == INPUT_DEVICE.ANY) ? _gamepad_id : _binding.device;
	            return gamepad_button_check_pressed(gid, _binding.gamepad_button);
            
	        case INPUT_TYPE.GAMEPAD_AXIS:
	            var gid = (_binding.device == INPUT_DEVICE.ANY) ? _gamepad_id : _binding.device;
	            var value = gamepad_axis_value(gid, _binding.gamepad_axis);
	            if (_binding.axis_positive_only) value = max(0, value);
	            var is_pressed = abs(value) >= _binding.axis_threshold;
	            var was_pressed = _binding.axis_previous_state;
	            _binding.axis_previous_state = is_pressed;
	            return is_pressed && !was_pressed;
            
	        case INPUT_TYPE.MOUSE_WHEEL:
	            return CheckMouseWheelBinding(_binding);
	    }
	    return false;
	}

	function UpdateSequences(delta_time) {
	    var keys = ds_map_keys_to_array(sequence_states);
	    for (var i = 0; i < array_length(keys); i++) {
	        var state = sequence_states[? keys[i]];
	        if (state.timer > 0) {
	            state.timer -= delta_time;
	            if (state.timer <= 0 && !state.completed) {
	                // Timeout - reset sequence
	                state.current_index = 0;
	                state.completed = false;
	            }
	        }
	    }
	}
    
    // TOUCH HANDLING
    function UpdateTouches() {
        var touch_count = touch_get_number();
        var active_touches = ds_map_create_gmu();
        
        for (var i = 0; i < touch_count; i++) {
            var touch_id = touch_get_id(i);
            var touch_x = touch_get_x(i);
            var touch_y = touch_get_y(i);
            var touch_pressure = touch_get_pressure(i);
            
            if (!ds_map_exists(touches, touch_id)) {
                var touch = {
                    id: touch_id,
                    x: touch_x,
                    y: touch_y,
                    start_x: touch_x,
                    start_y: touch_y,
                    pressure: touch_pressure,
                    start_time: current_time,
                    active: true,
                    tap: false,
                    swipe: false,
                    swipe_vector: { x: 0, y: 0 }
                };
                touches[? touch_id] = touch;
                
                // Check for tap
                touch.tap = true;
                
                // Trigger touch events
                ProcessTouchBinding("tap", touch);
                
            } else {
                var touch = touches[? touch_id];
                touch.x = touch_x;
                touch.y = touch_y;
                touch.pressure = touch_pressure;
                touch.active = true;
                active_touches[? touch_id] = touch;
                
                // Check for swipe
                var dx = touch.x - touch.start_x;
                var dy = touch.y - touch.start_y;
                var distance = sqrt(dx*dx + dy*dy);
                var duration = (current_time - touch.start_time) / 1000000.0;
                
                if (distance > 20 && duration < 0.5 && !touch.swipe) {
                    touch.swipe = true;
                    touch.swipe_vector = { x: dx, y: dy };
                    ProcessTouchBinding("swipe", touch);
                }
            }
        }
        
        // Remove ended touches
        var touch_ids = ds_map_keys_to_array(touches);
        for (var i = 0; i < array_length(touch_ids); i++) {
            var _id = touch_ids[i];
            if (!ds_map_exists(active_touches, _id)) {
                ds_map_delete(touches, _id);
            }
        }
        
        ds_map_destroy_gmu(active_touches);
    };
    
    function ProcessTouchBinding(_gesture, _touch) {
        var action_keys = ds_map_keys_to_array(actions);
        for (var i = 0; i < array_length(action_keys); i++) {
            var action_name = action_keys[i];
            var action = actions[? action_name];
            if (!action.enabled) continue;
            
            for (var j = 0; j < ds_list_size(action.bindings); j++) {
                var binding = action.bindings[| j];
                if (binding.type == INPUT_TYPE.TOUCH_POINT &&
                    binding.touch_gesture == _gesture) {
                    
                    if (binding.touch_region != undefined) {
                        if (binding.touch_region.Contains(_touch.x, _touch.y)) {
                            TriggerAction(action_name, true, _touch);
                        }
                    } else {
                        TriggerAction(action_name, true, _touch);
                    }
                }
            }
        }
    };
    
    // MAIN UPDATE LOOP & INPUT PROCESSING
    function TriggerAction(_action_name, _pressed, _data = undefined) {
	    if (buffer_enabled && _pressed && _data == undefined) {
	        BufferInput(_action_name, 1, 0, false);
	        return;
	    }
    
	    var state = input_states[? _action_name];
	    if (state == undefined) return;
    
	    var event = {
	        action: _action_name,
	        pressed: _pressed,
	        data: _data,
	        time: current_time
	    };
	    ds_list_add(input_events, event);
	}
    
    function Update(delta_time = 1/60) {
	    var action_keys = ds_map_keys_to_array(input_states);
	    for (var i = 0; i < array_length(action_keys); i++) {
	        var state = input_states[? action_keys[i]];
	        if (state != undefined) {
	            state.just_pressed = false;
	            state.just_released = false;
	            state.double_tapped = false;
	        }
	    }
    
	    ProcessBuffer(delta_time);
    
	    UpdateSequences(delta_time);
    
	    ProcessKeyboard();
	    ProcessMouse();
	    ProcessMouseWheel();
    
	    for (var i = 0; i < 4; i++) {
	        if (gamepad_is_connected(i)) {
	            ProcessGamepad(i);
	        }
	    }
    
	    if (os_type == os_android || os_type == os_ios) {
	        UpdateTouches();
	    }
    
	    while (ds_list_size(input_events) > 0) {
	        var event = input_events[| 0];
	        var state = input_states[? event.action];
	        if (state != undefined) {
	            state.UpdateDigital(event.pressed, delta_time);
	        }
	        ds_list_delete(input_events, 0);
	    }
	}
    
    function ProcessKeyboard() {
        var action_keys = ds_map_keys_to_array(actions);
        for (var i = 0; i < array_length(action_keys); i++) {
            var action_name = action_keys[i];
            var action = actions[? action_name];
            if (!action.enabled) continue;
            
            var pressed = false;
            for (var j = 0; j < ds_list_size(action.bindings); j++) {
                var binding = action.bindings[| j];
				
	            // Handle chord bindings
	            if (binding.chord_bindings != undefined) {
	                if (CheckSequenceBinding(binding)) {
	                    pressed = true;
	                    if (action.consume_input) break;
	                }
	                continue;
	            }
				
                if (binding.type == INPUT_TYPE.KEY) {
                    var key_pressed = keyboard_check(binding.key_code);
                    var mod_match = true;
                    
                    // Check modifiers
                    if (binding.modifiers & 1) { // Shift
                        mod_match = mod_match && keyboard_check(vk_shift);
                    }
                    if (binding.modifiers & 2) { // Ctrl
                        mod_match = mod_match && keyboard_check(vk_control);
                    }
                    if (binding.modifiers & 4) { // Alt
                        mod_match = mod_match && keyboard_check(vk_alt);
                    }
                    
                    if (key_pressed && mod_match) {
                        pressed = true;
                        if (action.consume_input) break;
                    }
                }
            }
            
            if (pressed != (input_states[? action_name].pressed)) {
                TriggerAction(action_name, pressed);
            }
        }
    };
    
    function ProcessMouse() {
        var action_keys = ds_map_keys_to_array(actions);
        for (var i = 0; i < array_length(action_keys); i++) {
            var action_name = action_keys[i];
            var action = actions[? action_name];
            if (!action.enabled) continue;
            
            for (var j = 0; j < ds_list_size(action.bindings); j++) {
                var binding = action.bindings[| j];
                if (binding.type == INPUT_TYPE.MOUSE_BUTTON) {
                    var pressed = mouse_check_button(binding.mouse_button);
                    
                    if (pressed && binding.mouse_region != undefined) { // Check region if specified
                        var mx = window_mouse_get_x();
                        var my = window_mouse_get_y();
                        pressed = binding.mouse_region.Contains(mx, my);
                    }
                    
                    if (pressed != (input_states[? action_name].pressed)) {
                        TriggerAction(action_name, pressed, { x: window_mouse_get_x(), y: window_mouse_get_y() });
                        if (action.consume_input) break;
                    }
                }
            }
        }
    };
    
    function ProcessGamepad(_gamepad_id) {
        var action_keys = ds_map_keys_to_array(actions);
        for (var i = 0; i < array_length(action_keys); i++) {
            var action_name = action_keys[i];
            var action = actions[? action_name];
            if (!action.enabled) continue;
            
            var pressed = false;
            var analog_value = 0;
            var analog_x = 0;
            var analog_y = 0;
            
            for (var j = 0; j < ds_list_size(action.bindings); j++) {
                var binding = action.bindings[| j];
				
	            // Handle chord bindings
	            if (binding.chord_bindings != undefined) {
	                if (CheckSequenceBinding(binding)) {
	                    pressed = true;
	                    if (action.consume_input) break;
	                }
	                continue;
	            }
                
                if (binding.type == INPUT_TYPE.GAMEPAD_BUTTON &&
                    binding.device == _gamepad_id) {
                    pressed = gamepad_button_check(_gamepad_id, binding.gamepad_button);
                    if (pressed && action.consume_input) break;
                    
                } else if (binding.type == INPUT_TYPE.GAMEPAD_AXIS &&
                           binding.device == _gamepad_id) {
                    var axis_value = gamepad_axis_value(_gamepad_id, binding.gamepad_axis);
                    
                    if (binding.axis_positive_only) {
                        axis_value = max(0, axis_value);
                    } else {
                        axis_value = abs(axis_value);
                    }
                    
                    if (axis_value >= binding.axis_threshold) {
                        if (binding.gamepad_axis <= GAMEPAD_AXIS.RIGHT_Y) {
                            // Axis is for vector movement
                            analog_x = gamepad_axis_value(_gamepad_id, GAMEPAD_AXIS.LEFT_X);
                            analog_y = gamepad_axis_value(_gamepad_id, GAMEPAD_AXIS.LEFT_Y);
                            var state = input_states[? action_name];
                            if (state != undefined) {
                                state.UpdateAnalog(analog_x, analog_y);
                            }
                        }
                        pressed = true;
                        analog_value = axis_value;
                    }
                }
            }
            
            if (binding.type == INPUT_TYPE.GAMEPAD_AXIS) {
                var state = input_states[? action_name];
                if (state != undefined && (analog_x != 0 || analog_y != 0)) {
                    state.UpdateAnalog(analog_x, analog_y);
                }
            } else if (pressed != (input_states[? action_name].pressed)) {
                TriggerAction(action_name, pressed, { value: analog_value });
            }
        }
    };
    
    // UTILITY & DEBUG METHODS
    function SetGamepadDeadzone(_deadzone) {
        gamepad_deadzone = clamp(_deadzone, 0, 1);
        return self;
    };
    
    function SetDoubleTapTime(_time) {
        double_tap_time = _time;
        return self;
    };
    
    function SetLongPressTime(_time) {
        long_press_time = _time;
        return self;
    };
    
    function EnableBuffering(_enabled = true) {
	    buffer_enabled = _enabled;
	    if (!_enabled) FlushBuffer();
	    return self;
	}

	function SetBufferDuration(_duration_seconds, _minimum = 0.033) {
	    buffer_duration = max(_minimum, _duration_seconds);  // Minimum 1 frame at 30fps
	    return self;
	}

	function SetBufferMaxSize(_size) {
	    buffer_max_size = max(1, _size);
	    return self;
	}
    
    function PrintBindings() {
        show_debug_message("=== Input Bindings ===");
        var action_keys = ds_map_keys_to_array(actions);
        for (var i = 0; i < array_length(action_keys); i++) {
            var action_name = action_keys[i];
            var action = actions[? action_name];
            show_debug_message("Action: " + action_name + " (enabled: " + string(action.enabled) + ")");
            
            for (var j = 0; j < ds_list_size(action.bindings); j++) {
                var binding = action.bindings[| j];
                show_debug_message("  - " + GetBindingString(binding));
            }
        }
        return self;
    };
    
    function GetBindingString(_binding) {
        switch(_binding.type) {
            case INPUT_TYPE.KEY:
                return "Keyboard: " + _binding.key_string;
            case INPUT_TYPE.MOUSE_BUTTON:
                return "Mouse Button: " + string(_binding.mouse_button);
            case INPUT_TYPE.GAMEPAD_BUTTON:
                return "Gamepad " + string(_binding.device) + " Button: " + string(_binding.gamepad_button);
            case INPUT_TYPE.GAMEPAD_AXIS:
                return "Gamepad " + string(_binding.device) + " Axis: " + string(_binding.gamepad_axis);
            case INPUT_TYPE.TOUCH_POINT:
                return "Touch: " + _binding.touch_gesture;
        }
        return "Unknown";
    };
    
    // SAVE & LOAD METHODS
    function SaveBindings(_filename) {
	    var save_data = {
	        version: "1.0",
	        settings: {
	            gamepad_deadzone: gamepad_deadzone,
	            double_tap_time: double_tap_time,
	            long_press_time: long_press_time,
	            repeat_delay: repeat_delay,
	            repeat_interval: repeat_interval,
	            axis_smoothing: axis_smoothing,
	            axis_smoothing_factor: axis_smoothing_factor
	        },
	        actions: {}
	    };
    
	    var action_keys = ds_map_keys_to_array(actions);
	    for (var i = 0; i < array_length(action_keys); i++) {
	        var action_name = action_keys[i];
	        var action = actions[? action_name];
	        var action_json = action.ToJSON();
	        variable_struct_set(save_data.actions, action_name, action_json);
	    }
    
	    return File.SaveJSON(_filename, save_data);
	}

	function LoadBindings(_filename, _clear_existing_actions = true) {
	    var save_data = File.LoadJSON(_filename);
	    if (save_data == undefined) return false;
    
	    if (variable_struct_exists(save_data, "settings")) {
	        var settings = variable_struct_get(save_data, "settings");
        
	        if (variable_struct_exists(settings, "gamepad_deadzone"))
	            gamepad_deadzone = variable_struct_get(settings, "gamepad_deadzone");
	        if (variable_struct_exists(settings, "double_tap_time"))
	            double_tap_time = variable_struct_get(settings, "double_tap_time");
	        if (variable_struct_exists(settings, "long_press_time"))
	            long_press_time = variable_struct_get(settings, "long_press_time");
	        if (variable_struct_exists(settings, "repeat_delay"))
	            repeat_delay = variable_struct_get(settings, "repeat_delay");
	        if (variable_struct_exists(settings, "repeat_interval"))
	            repeat_interval = variable_struct_get(settings, "repeat_interval");
	        if (variable_struct_exists(settings, "axis_smoothing"))
	            axis_smoothing = variable_struct_get(settings, "axis_smoothing");
	        if (variable_struct_exists(settings, "axis_smoothing_factor"))
	            axis_smoothing_factor = variable_struct_get(settings, "axis_smoothing_factor");
	    }
    
		if (_clear_existing_actions) {
		    var action_keys = ds_map_keys_to_array(actions);
		    for (var i = 0; i < array_length(action_keys); i++) {
		        var action_name = action_keys[i];
		        var action = actions[? action_name];
		        action.Free();
		        ds_map_delete(actions, action_name);
		        ds_map_delete(input_states, action_name);
		    }
		}
    
	    if (variable_struct_exists(save_data, "actions")) {
	        var actions_data = variable_struct_get(save_data, "actions");
	        var action_names = variable_struct_get_names(actions_data);
        
	        for (var i = 0; i < array_length(action_names); i++) {
	            var action_name = action_names[i];
	            var action_json = variable_struct_get(actions_data, action_name);
            
	            var config = new ActionConfig(action_name);
	            config.FromJSON(action_json);
	            var state = new InputState(config);
	            actions[? action_name] = config;
	            input_states[? action_name] = state;
	        }
	    }
    
	    return true;
	}

	function ExportBindingsToString() {
	    var save_data = {
	        version: variable_global_exists("__VERSION") ? variable_global_get("__VERSION") : "undefined",
	        settings: {
	            gamepad_deadzone: gamepad_deadzone,
	            double_tap_time: double_tap_time,
	            long_press_time: long_press_time,
	            repeat_delay: repeat_delay,
	            repeat_interval: repeat_interval,
	            axis_smoothing: axis_smoothing,
	            axis_smoothing_factor: axis_smoothing_factor
	        },
	        actions: {}
	    };
    
	    var action_keys = ds_map_keys_to_array(actions);
	    for (var i = 0; i < array_length(action_keys); i++) {
	        var action_name = action_keys[i];
	        var action = actions[? action_name];
	        var action_json = action.ToJSON();
	        variable_struct_set(save_data.actions, action_name, action_json);
	    }
    
	    return json_stringify(save_data);
	}

	function ImportBindingsFromString(_json_string, _clear_existing_actions = true) {
	    var save_data = json_parse(_json_string);
	    if (!is_struct(save_data)) return false;
    
	    if (variable_struct_exists(save_data, "settings")) {
	        var settings = variable_struct_get(save_data, "settings");
        
	        if (variable_struct_exists(settings, "gamepad_deadzone"))
	            gamepad_deadzone = variable_struct_get(settings, "gamepad_deadzone");
	        if (variable_struct_exists(settings, "double_tap_time"))
	            double_tap_time = variable_struct_get(settings, "double_tap_time");
	        if (variable_struct_exists(settings, "long_press_time"))
	            long_press_time = variable_struct_get(settings, "long_press_time");
	        if (variable_struct_exists(settings, "repeat_delay"))
	            repeat_delay = variable_struct_get(settings, "repeat_delay");
	        if (variable_struct_exists(settings, "repeat_interval"))
	            repeat_interval = variable_struct_get(settings, "repeat_interval");
	        if (variable_struct_exists(settings, "axis_smoothing"))
	            axis_smoothing = variable_struct_get(settings, "axis_smoothing");
	        if (variable_struct_exists(settings, "axis_smoothing_factor"))
	            axis_smoothing_factor = variable_struct_get(settings, "axis_smoothing_factor");
	    }
    
		if (_clear_existing_actions) {
		    var action_keys = ds_map_keys_to_array(actions);
		    for (var i = 0; i < array_length(action_keys); i++) {
		        var action_name = action_keys[i];
		        var action = actions[? action_name];
		        action.Free();
		        ds_map_delete(actions, action_name);
		        ds_map_delete(input_states, action_name);
		    }
		}
    
	    if (variable_struct_exists(save_data, "actions")) {
	        var actions_data = variable_struct_get(save_data, "actions");
	        var action_names = variable_struct_get_names(actions_data);
        
	        for (var i = 0; i < array_length(action_names); i++) {
	            var action_name = action_names[i];
	            var action_json = variable_struct_get(actions_data, action_name);
            
	            var config = new ActionConfig(action_name);
	            config.FromJSON(action_json);
	            var state = new InputState(config);
	            actions[? action_name] = config;
	            input_states[? action_name] = state;
	        }
	    }
    
	    return true;
	}
    
    // CLEANUP
    function Free() {
        var action_keys = ds_map_keys_to_array(actions);
        for (var i = 0; i < array_length(action_keys); i++) {
            actions[? action_keys[i]].Free();
        }
        ds_map_destroy_gmu(actions);
        ds_map_destroy_gmu(input_states);
        ds_list_destroy_gmu(input_events);
        ds_map_destroy_gmu(device_callbacks);
        ds_map_destroy_gmu(touches);
        ds_queue_destroy_gmu(input_buffer);
        ds_map_destroy_gmu(sequence_states);
    };
}

// LIGHTWEIGHT INPUT HANDLER
function Input() constructor {
    bindings = ds_map_create_gmu();
    BindKey = function(key, action) { bindings[? key] = action; return self; };
    function IsPressed(action) {
        var keys = ds_map_find_value(bindings, action);
        if (is_array(keys)) { for (var i=0;i<array_length(keys);i++) if (keyboard_check(keys[i])) return true; }
        else return keyboard_check(keys);
        return false;
    };
    function IsPressedOnce(action) {
        var keys = ds_map_find_value(bindings, action);
        if (is_array(keys)) { for (var i=0;i<array_length(keys);i++) if (keyboard_check_pressed(keys[i])) return true; }
        else return keyboard_check_pressed(keys);
        return false;
    };
    function Free() { ds_map_destroy_gmu(bindings); };
};