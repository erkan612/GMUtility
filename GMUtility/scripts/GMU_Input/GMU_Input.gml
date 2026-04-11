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
    BACK									= 3,
    FORWARD									= 4
}

enum GAMEPAD_BUTTON {
    // Face buttons (Xbox: A/B/X/Y, PlayStation: Cross/Circle/Square/Triangle)
    FACE1									= 32769,   // gp_face1 - Xbox A, PlayStation Cross
    FACE2									= 32770,   // gp_face2 - Xbox B, PlayStation Circle  
    FACE3									= 32771,   // gp_face3 - Xbox X, PlayStation Square
    FACE4									= 32772,   // gp_face4 - Xbox Y, PlayStation Triangle
    
    // Shoulder buttons & triggers
    SHOULDER_L								= 32773,   // gp_shoulderl - Left shoulder button (LB/L1)
    SHOULDER_R								= 32774,   // gp_shoulderr - Right shoulder button (RB/R1)
    SHOULDER_LB								= 32775,   // gp_shoulderlb - Left shoulder trigger (LT/L2)
    SHOULDER_RB								= 32776,   // gp_shoulderrb - Right shoulder trigger (RT/R2)
    
    // System buttons
    SELECT									= 32777,   // gp_select - Select/Back/Touchpad press
    START									= 32778,   // gp_start - Start/Options button
    HOME									= 32799,   // gp_home - Home/Guide button (Xbox/PS/Switch logo)
    
    // Stick clicks (pressing the analog sticks as buttons)
    STICK_L									= 32779,   // gp_stickl - Left stick click (L3)
    STICK_R									= 32780,   // gp_stickr - Right stick click (R3)
    
    // D-pad directions
    DPAD_UP									= 32781,   // gp_padu - D-pad up
    DPAD_DOWN								= 32782,   // gp_padd - D-pad down
    DPAD_LEFT								= 32783,   // gp_padl - D-pad left
    DPAD_RIGHT								= 32784,   // gp_padr - D-pad right
    
    // Extra buttons (general purpose)
    EXTRA1									= 32800,   // gp_extra1
    EXTRA2									= 32801,   // gp_extra2
    EXTRA3									= 32802,   // gp_extra3
    EXTRA4									= 32803,   // gp_extra4
    
    // Xbox Elite controller paddles
    PADDLE_R								= 32804,   // gp_paddler - Right upper/primary paddle (P1)
    PADDLE_L								= 32805,   // gp_paddlel - Left upper/primary paddle (P3)
    PADDLE_RB								= 32806,   // gp_paddlerb - Right lower/secondary paddle (P2)
    PADDLE_LB								= 32807,   // gp_paddlelb - Left lower/secondary paddle (P4)
    
    // PlayStation specific
    TOUCHPAD								= 32808,   // gp_touchpadbutton - PS4/PS5 touchpad button
    
    // More extra buttons
    EXTRA5									= 32809,   // gp_extra5
    EXTRA6									= 32810    // gp_extra6
}

enum GAMEPAD_BUTTON_XBOX {
    A										= GAMEPAD_BUTTON.FACE1,      // 32769
    B										= GAMEPAD_BUTTON.FACE2,      // 32770
    X										= GAMEPAD_BUTTON.FACE3,      // 32771
    Y										= GAMEPAD_BUTTON.FACE4,      // 32772
											
    LB										= GAMEPAD_BUTTON.SHOULDER_L, // 32773
    RB										= GAMEPAD_BUTTON.SHOULDER_R, // 32774
    LT										= GAMEPAD_BUTTON.SHOULDER_LB,// 32775
    RT										= GAMEPAD_BUTTON.SHOULDER_RB,// 32776
											
    BACK									= GAMEPAD_BUTTON.SELECT,     // 32777
    START									= GAMEPAD_BUTTON.START,      // 32778
    GUIDE									= GAMEPAD_BUTTON.HOME,       // 32799
											
    LEFT_STICK								= GAMEPAD_BUTTON.STICK_L,    // 32779
    RIGHT_STICK								= GAMEPAD_BUTTON.STICK_R,    // 32780
											
    DPAD_UP									= GAMEPAD_BUTTON.DPAD_UP,    // 32781
    DPAD_DOWN								= GAMEPAD_BUTTON.DPAD_DOWN,  // 32782
    DPAD_LEFT								= GAMEPAD_BUTTON.DPAD_LEFT,  // 32783
    DPAD_RIGHT								= GAMEPAD_BUTTON.DPAD_RIGHT, // 32784
    
    // Xbox Elite paddles
    PADDLE_1								= GAMEPAD_BUTTON.PADDLE_R,   // 32804 (Right upper)
    PADDLE_2								= GAMEPAD_BUTTON.PADDLE_RB,  // 32806 (Right lower)
    PADDLE_3								= GAMEPAD_BUTTON.PADDLE_L,   // 32805 (Left upper)
    PADDLE_4								= GAMEPAD_BUTTON.PADDLE_LB   // 32807 (Left lower)
}

enum GAMEPAD_BUTTON_PS {
    CROSS									= GAMEPAD_BUTTON.FACE1,      // 32769 (X on Xbox)
    CIRCLE									= GAMEPAD_BUTTON.FACE2,      // 32770 (B on Xbox)
    SQUARE									= GAMEPAD_BUTTON.FACE3,      // 32771 (X on Xbox)
    TRIANGLE								= GAMEPAD_BUTTON.FACE4,      // 32772 (Y on Xbox)
											
    L1										= GAMEPAD_BUTTON.SHOULDER_L, // 32773
    R1										= GAMEPAD_BUTTON.SHOULDER_R, // 32774
    L2										= GAMEPAD_BUTTON.SHOULDER_LB,// 32775
    R2										= GAMEPAD_BUTTON.SHOULDER_RB,// 32776
											
    SHARE									= GAMEPAD_BUTTON.SELECT,     // 32777 (Share on PS4/PS5)
    OPTIONS									= GAMEPAD_BUTTON.START,      // 32778 (Options on PS4/PS5)
    PS										= GAMEPAD_BUTTON.HOME,       // 32799 (PlayStation button)
											
    L3										= GAMEPAD_BUTTON.STICK_L,    // 32779 (Left stick click)
    R3										= GAMEPAD_BUTTON.STICK_R,    // 32780 (Right stick click)
											
    DPAD_UP									= GAMEPAD_BUTTON.DPAD_UP,    // 32781
    DPAD_DOWN								= GAMEPAD_BUTTON.DPAD_DOWN,  // 32782
    DPAD_LEFT								= GAMEPAD_BUTTON.DPAD_LEFT,  // 32783
    DPAD_RIGHT								= GAMEPAD_BUTTON.DPAD_RIGHT, // 32784
											
    TOUCHPAD								= GAMEPAD_BUTTON.TOUCHPAD    // 32808 (Touchpad click)
}

enum GAMEPAD_BUTTON_SWITCH {
    B										= GAMEPAD_BUTTON.FACE1,      // 32769 (Bottom button on Switch)
    A										= GAMEPAD_BUTTON.FACE2,      // 32770 (Right button on Switch)
    Y										= GAMEPAD_BUTTON.FACE3,      // 32771 (Top button on Switch)
    X										= GAMEPAD_BUTTON.FACE4,      // 32772 (Left button on Switch)
											
    L										= GAMEPAD_BUTTON.SHOULDER_L, // 32773
    R										= GAMEPAD_BUTTON.SHOULDER_R, // 32774
    ZL										= GAMEPAD_BUTTON.SHOULDER_LB,// 32775
    ZR										= GAMEPAD_BUTTON.SHOULDER_RB,// 32776
											
    MINUS									= GAMEPAD_BUTTON.SELECT,     // 32777 (- button)
    PLUS									= GAMEPAD_BUTTON.START,      // 32778 (+ button)
    HOME									= GAMEPAD_BUTTON.HOME,       // 32799 (Home button)
											
    LEFT_STICK								= GAMEPAD_BUTTON.STICK_L,    // 32779
    RIGHT_STICK								= GAMEPAD_BUTTON.STICK_R,    // 32780
											
    DPAD_UP									= GAMEPAD_BUTTON.DPAD_UP,    // 32781
    DPAD_DOWN								= GAMEPAD_BUTTON.DPAD_DOWN,  // 32782
    DPAD_LEFT								= GAMEPAD_BUTTON.DPAD_LEFT,  // 32783
    DPAD_RIGHT								= GAMEPAD_BUTTON.DPAD_RIGHT, // 32784
											
    CAPTURE									= GAMEPAD_BUTTON.EXTRA1      // 32800 (Capture button on Switch)
}

enum GAMEPAD_AXIS {
    // Standard analog sticks
    LEFT_X									= 32785,   // gp_axislh - Left stick horizontal (X-axis)
    LEFT_Y									= 32786,   // gp_axislv - Left stick vertical (Y-axis)
    RIGHT_X									= 32787,   // gp_axisrh - Right stick horizontal (X-axis)
    RIGHT_Y									= 32788,   // gp_axisrv - Right stick vertical (Y-axis)
    
    // PlayStation DualSense motion sensors (PS4/PS5 only)
    ACCELERATION_X							= 32789,   // gp_axis_acceleration_x
    ACCELERATION_Y							= 32790,   // gp_axis_acceleration_y
    ACCELERATION_Z							= 32791,   // gp_axis_acceleration_z
    
    GYRO_X									= 32792,   // gp_axis_angular_velocity_x
    GYRO_Y									= 32793,   // gp_axis_angular_velocity_y
    GYRO_Z									= 32794,   // gp_axis_angular_velocity_z
    
    ORIENTATION_X							= 32795,   // gp_axis_orientation_x
    ORIENTATION_Y							= 32796,   // gp_axis_orientation_y
    ORIENTATION_Z							= 32797,   // gp_axis_orientation_z
    ORIENTATION_W							= 32798    // gp_axis_orientation_w
}

enum GAMEPAD_AXIS_XBOX {
    LEFT_X									= GAMEPAD_AXIS.LEFT_X,       // 32785
    LEFT_Y									= GAMEPAD_AXIS.LEFT_Y,       // 32786
    RIGHT_X									= GAMEPAD_AXIS.RIGHT_X,      // 32787
    RIGHT_Y									= GAMEPAD_AXIS.RIGHT_Y       // 32788
}

enum GAMEPAD_AXIS_PS {
    LEFT_X									= GAMEPAD_AXIS.LEFT_X,       // 32785
    LEFT_Y									= GAMEPAD_AXIS.LEFT_Y,       // 32786
    RIGHT_X									= GAMEPAD_AXIS.RIGHT_X,      // 32787
    RIGHT_Y									= GAMEPAD_AXIS.RIGHT_Y,      // 32788
    
    // DualSense motion sensors
    ACCELERATION_X							= GAMEPAD_AXIS.ACCELERATION_X,  // 32789
    ACCELERATION_Y							= GAMEPAD_AXIS.ACCELERATION_Y,  // 32790
    ACCELERATION_Z							= GAMEPAD_AXIS.ACCELERATION_Z,  // 32791
											
    GYRO_X									= GAMEPAD_AXIS.GYRO_X,       // 32792
    GYRO_Y									= GAMEPAD_AXIS.GYRO_Y,       // 32793
    GYRO_Z									= GAMEPAD_AXIS.GYRO_Z,       // 32794
											
    ORIENTATION_X							= GAMEPAD_AXIS.ORIENTATION_X,// 32795
    ORIENTATION_Y							= GAMEPAD_AXIS.ORIENTATION_Y,// 32796
    ORIENTATION_Z							= GAMEPAD_AXIS.ORIENTATION_Z,// 32797
    ORIENTATION_W							= GAMEPAD_AXIS.ORIENTATION_W // 32798
}

enum GAMEPAD_AXIS_SWITCH {
    LEFT_X									= GAMEPAD_AXIS.LEFT_X,       // 32785
    LEFT_Y									= GAMEPAD_AXIS.LEFT_Y,       // 32786
    RIGHT_X									= GAMEPAD_AXIS.RIGHT_X,      // 32787
    RIGHT_Y									= GAMEPAD_AXIS.RIGHT_Y       // 32788
}

enum GAMEPAD_TYPE {
	NONE, 
	PLAYSTATION, 
	XBOX, 
	SWITCH
}

enum INPUT_MODIFIER {
    NONE									= 0,
    SHIFT									= 1 << 0,
    CTRL									= 1 << 1,
    ALT										= 1 << 2,
    ANY										= 1 << 3
}

enum MOUSE_WHEEL {
    UP,
    DOWN,
    LEFT,
    RIGHT
}

enum BUFFERED_CALL {
	NONE									= 0,
	ACTION									= 1 << 0,
	ACTION_JUST_PRESSED						= 1 << 1,
	ACTION_JUST_RELEASED					= 1 << 2,
	ACTION_DOUBLE_TAPPED					= 1 << 3
}


function InputManager() constructor {
    actions = ds_map_create();
    input_states = ds_map_create();
	
    mouse_wheel_delta_x = 0;
    mouse_wheel_delta_y = 0;
    mouse_wheel_last_up = false;
    mouse_wheel_last_down = false;
    wheel_accumulator_x = 0;
    wheel_accumulator_y = 0;
    
    function InputBinding() constructor {
        input_type = INPUT_TYPE.KEY;
        input_device = INPUT_DEVICE.KEYBOARD;
        input_id = 0;
        
        mouse_button = MOUSE_BUTTON.LEFT;
        wheel_direction = MOUSE_WHEEL.UP;
        wheel_threshold = 1; // number of scroll ticks needed
        
        // region checking for mouse
        region_x = 0;
        region_y = 0;
        regionW_w = 0;
        region_h = 0;
        use_region = false;
		
		// gamepad
		gamepad_button = GAMEPAD_BUTTON.FACE1;
		gamepad_axis = GAMEPAD_AXIS.LEFT_X;
		axis_threshold = 0.5;
		axis_positive_only = false;
		
		modifiers = INPUT_MODIFIER.NONE;
		
		chord_bindings = [];
		chord_mode = "all"; // "all", "any"
    };
    
    function ActionConfig(actionName) constructor {
        name = actionName;
        bindings = [];
        is_enabled = true;
		action = undefined;
		action_just_pressed = undefined;
		action_just_released = undefined;
		is_buffered = false;
		buffered_call = BUFFERED_CALL.NONE; // TODO: add death timer
		deadzone = 0.2;
		curve_power = 1.0;  // 1 = linear, 2 = exponential
		smooth_factor = 0.85;
		double_tap_window = 0.3;   // seconds
		long_press_time = 0.5;     // seconds
		action_double_tapped = undefined;
        
        AddBinding = function(binding) {
            array_push(bindings, binding);
            return self;
        };
		
		BindMethod = function(methodAction) {
			action = methodAction;
		};
		
		BindMethodJustPressed = function(methodActionJustPressed) {
			action_just_pressed = methodActionJustPressed;
		};
		
		BindMethodJustReleased = function(methodActionJustReleased) {
			action_just_released = methodActionJustReleased;
		};
    };
    
    function InputState(_config) constructor {
        config = _config;
        pressed = false;
        just_pressed = false;
        just_released = false;
        
        // for mouse wheel (non-latching state)
        wheel_value = 0;		// number of scroll ticks this frame
		
	    // analog tracking
	    value = 0;				// 0-1 for triggers or dominant axis
	    vector_x = 0;			// for 2D movement
	    vector_y = 0;
	    magnitude = 0;
	    angle = 0;
		
		press_time = 0;
		release_time = 0;
		press_count = 0;
		last_press_time = 0;
		long_press_timer = 0;
		double_tapped = false;
		long_pressed = false;
    };
    
    function CreateAction(name, methodAction = undefined, methodActionJustPressed = undefined, methodActionJustReleased = undefined) {
        if (ds_map_exists(actions, name)) {
            return actions[? name];
        };
        
        var config = new ActionConfig(name);
        var state = new InputState(config);
        actions[? name] = config;
        input_states[? name] = state;
        
		if (methodAction != undefined) {
			BindActionMethod(name, methodAction);
		};
        
		if (methodActionJustPressed != undefined) {
			BindActionMethodJustPressed(name, methodActionJustPressed);
		};
        
		if (methodActionJustReleased != undefined) {
			BindActionMethodJustReleased(name, methodActionJustReleased);
		};
		
        return config;
    };
	
	function GetAction(name) {
		return actions[? name];
	};
	
	function BufferAction(name, flags) {
		actions[? name].is_buffered = true;
		actions[? name].buffered_call = flags;
		return self;
	};
    
    function InputBindingFromKey(keyCode, device = INPUT_DEVICE.KEYBOARD, modifiers = INPUT_MODIFIER.NONE) {
        var binding = new InputBinding();
        binding.input_type = INPUT_TYPE.KEY;
        binding.input_device = device;
        binding.input_id = keyCode;
		binding.modifiers = modifiers;
        return binding;
    };
    
    function InputBindingFromMouseButton(button, useRegion = false, rx = 0, ry = 0, rw = 0, rh = 0, modifiers = INPUT_MODIFIER.NONE) {
        var binding = new InputBinding();
        binding.input_type = INPUT_TYPE.MOUSE_BUTTON;
        binding.input_device = INPUT_DEVICE.MOUSE;
        binding.mouse_button = button;
		binding.modifiers = modifiers;
        
        if (useRegion) {
            binding.use_region = true;
            binding.region_x = rx;
            binding.region_y = ry;
            binding.region_w = rw;
            binding.region_h = rh;
        };
        
        return binding;
    };
    
    function InputBindingFromMouseWheel(direction, threshold = 1, modifiers = INPUT_MODIFIER.NONE) {
        var binding = new InputBinding();
        binding.input_type = INPUT_TYPE.MOUSE_WHEEL;
        binding.input_device = INPUT_DEVICE.MOUSE;
        binding.wheel_direction = direction;
        binding.wheel_threshold = threshold;
		binding.modifiers = modifiers;
        return binding;
    };
	
	function InputBindingFromGamepadButton(button, gamepad_id = 0, modifiers = INPUT_MODIFIER.NONE) {
	    var binding = new InputBinding();
	    binding.input_type = INPUT_TYPE.GAMEPAD_BUTTON;
	    binding.input_device = gamepad_id;
	    binding.gamepad_button = button;
		binding.modifiers = modifiers;
	    return binding;
	};

	function InputBindingFromGamepadAxis(axis, threshold = 0.5, positive_only = false, gamepad_id = 0, modifiers = INPUT_MODIFIER.NONE) {
	    var binding = new InputBinding();
	    binding.input_type = INPUT_TYPE.GAMEPAD_AXIS;
	    binding.input_device = gamepad_id;
	    binding.gamepad_axis = axis;
	    binding.axis_threshold = threshold;
	    binding.axis_positive_only = positive_only;
		binding.modifiers = modifiers;
	    return binding;
	};
	
	function InputBindingFromChord(bindings_array, mode = "all") {
	    var binding = new InputBinding();
	    binding.chord_bindings = bindings_array;
	    binding.chord_mode = mode;
	    return binding;
	};
	
	function BindActionMethod(actionName, methodAction) {
		var action = actions[? actionName];
		action.action = actionMethod;
	};
	
	function BindActionMethodJustPressed(actionName, methodActionJustPressed) {
		var action = actions[? actionName];
		action.action_just_pressed = methodActionJustPressed;
	};
	
	function BindActionMethodJustReleased(actionName, methodActionJustReleased) {
		var action = actions[? actionName];
		action.action_just_released = methodActionJustReleased;
	};
    
    function BindKey(actionName, keyCode, device = INPUT_DEVICE.KEYBOARD) {
        var action = actions[? actionName];
        if (action == undefined) { 
            // Auto-create action if it doesn't exist
            action = CreateAction(actionName);
        };
        
        action.AddBinding(InputBindingFromKey(keyCode, device));
        return self;
    };
    
    function BindMouseButton(actionName, button, useRegion = false, rx = 0, ry = 0, rw = 0, rh = 0) {
        var action = actions[? actionName];
        if (action == undefined) { 
            action = CreateAction(actionName);
        };
        
        action.AddBinding(InputBindingFromMouseButton(button, useRegion, rx, ry, rw, rh));
        return self;
    };
    
    function BindMouseWheel(actionName, direction, threshold = 1) {
        var action = actions[? actionName];
        if (action == undefined) { 
            action = CreateAction(actionName);
        };
        
        action.AddBinding(InputBindingFromMouseWheel(direction, threshold));
        return self;
    };
	
	function BindGamepadButton(actionName, button, gamepad_id = 0) {
	    var action = GetAction(actionName);
	    if (action == undefined) action = CreateAction(actionName);
	    action.AddBinding(InputBindingFromGamepadButton(button, gamepad_id));
	    return self;
	};

	function BindGamepadAxis(actionName, axis, threshold = 0.5, positive_only = false, gamepad_id = 0) {
	    var action = GetAction(actionName);
	    if (action == undefined) action = CreateAction(actionName);
	    action.AddBinding(InputBindingFromGamepadAxis(axis, threshold, positive_only, gamepad_id));
	    return self;
	};
    
    function Update(dt = 1/60) {
        // reset one-frame flags
        var action_keys = ds_map_keys_to_array(input_states);
        for (var i = 0; i < array_length(action_keys); i++) {
            var state = input_states[? action_keys[i]];
            if (state != undefined) {
                state.just_pressed = false;
                state.just_released = false;
                state.wheel_value = 0;
            };
        };
        
        UpdateMouseWheelDelta();
		
        ProcessActions();
		
	    UpdateTimers(dt);
    };
	
	function UpdateTimers(dt) {
	    var action_keys = ds_map_keys_to_array(input_states);
	    for (var i = 0; i < array_length(action_keys); i++) {
	        var state = input_states[? action_keys[i]];
	        if (state != undefined && state.pressed) {
	            state.long_press_timer += dt;
	            if (state.long_press_timer >= GetAction(action_keys[i]).long_press_time) {
	                state.long_pressed = true;
	            }
	        }
	    }
	};
	
	function ProcessActions() {
        var actionKeys = ds_map_keys_to_array(actions);
        for (var i = 0; i < array_length(actionKeys); i++) {
            var actionName = actionKeys[i];
            var action = actions[? actionName];
            if (!action.is_enabled) continue;
			
			var temp_vector_x = 0;
			var temp_vector_y = 0;
            
            var pressed = false;
            for (var j = 0; j < array_length(action.bindings); j++) {
                var binding = action.bindings[j];
				
				if (array_length(binding.chord_bindings) > 0) {
				    if (CheckChord(binding)) {
				        pressed = true;
				        if (action.consume) break;
				    }
				    continue;
				}
                
				switch (binding.input_type) {
				case INPUT_TYPE.KEY: {
                    if (keyboard_check(binding.input_id) && CheckModifiers(binding)) {
                        pressed = true;
                    };
				} break;
				case INPUT_TYPE.MOUSE_BUTTON: {
                    var buttonPressed = false;
                    switch(binding.mouse_button) {
                        case MOUSE_BUTTON.LEFT:
                            buttonPressed = mouse_check_button(mb_left);
                            break;
                        case MOUSE_BUTTON.RIGHT:
                            buttonPressed = mouse_check_button(mb_right);
                            break;
                        case MOUSE_BUTTON.MIDDLE:
                            buttonPressed = mouse_check_button(mb_middle);
                            break;
                        case MOUSE_BUTTON.BACK:
                            buttonPressed = mouse_check_button(mb_side1);
                            break;
                        case MOUSE_BUTTON.FORWARD:
                            buttonPressed = mouse_check_button(mb_side2);
                            break;
                    };
                    
                    if (buttonPressed && CheckMouseRegion(binding)) {
                        pressed = true;
                        break;
                    };
				} break;
				case INPUT_TYPE.MOUSE_WHEEL: {
                    var shouldTrigger = false;
                    var wheelValue = 0;
                    
                    switch(binding.wheel_direction) {
                        case MOUSE_WHEEL.UP:
                            if (mouse_wheel_delta_y > 0) {
                                wheel_accumulator_y = max(0, wheel_accumulator_y);
                                if (wheel_accumulator_y >= binding.wheel_threshold) {
                                    shouldTrigger = true;
                                    wheelValue = wheel_accumulator_y;
                                    wheel_accumulator_y = 0;
                                };
                            };
                            break;
                            
                        case MOUSE_WHEEL.DOWN:
                            if (mouse_wheel_delta_y < 0) {
                                wheel_accumulator_y = min(0, wheel_accumulator_y);
                                if (abs(wheel_accumulator_y) >= binding.wheel_threshold) {
                                    shouldTrigger = true;
                                    wheelValue = abs(wheel_accumulator_y);
                                    wheel_accumulator_y = 0;
                                };
                            };
                            break;
                    };
                    
                    if (shouldTrigger) {
                        var state = input_states[? actionName];
                        if (state != undefined) {
                            state.just_pressed = true;
                            state.pressed = true;
                            state.wheel_value = wheelValue;
                        };
                        break;
                    };
				} break;
				case INPUT_TYPE.GAMEPAD_BUTTON: {
				    var gid = binding.input_device;
				    if (gamepad_button_check(gid, binding.gamepad_button)) {
				        pressed = true;
				    };
				} break;

				case INPUT_TYPE.GAMEPAD_AXIS: {
				    var gid = binding.input_device;
				    var axis_value = gamepad_axis_value(gid, binding.gamepad_axis);
					
				    if (binding.gamepad_axis == GAMEPAD_AXIS.LEFT_X) {
				        temp_vector_x = axis_value;
				    } else if (binding.gamepad_axis == GAMEPAD_AXIS.LEFT_Y) {
				        temp_vector_y = axis_value;
				    }
					
				    if (binding.axis_positive_only) axis_value = max(0, axis_value);
				    if (abs(axis_value) >= binding.axis_threshold) {
				        pressed = true;
				    };
				} break;
				};
            };
			
            var state = input_states[? actionName];
			
			if (temp_vector_x != 0 || temp_vector_y != 0) {
			    var len = sqrt(temp_vector_x * temp_vector_x + temp_vector_y * temp_vector_y);
			    if (len < action.deadzone) {
			        temp_vector_x = 0;
			        temp_vector_y = 0;
			        len = 0;
			    } else {
			        var t = (len - action.deadzone) / (1 - action.deadzone);
			        temp_vector_x = (temp_vector_x / len) * t;
			        temp_vector_y = (temp_vector_y / len) * t;
			        len = t;
			    }
    
			    if (action.curve_power != 1.0 && len > 0) {
			        var curved = pow(len, action.curve_power);
			        temp_vector_x = (temp_vector_x / len) * curved;
			        temp_vector_y = (temp_vector_y / len) * curved;
			        len = curved;
			    }
    
			    state.vector_x = temp_vector_x;
			    state.vector_y = temp_vector_y;
			    state.magnitude = len;
			    state.angle = arctan2(temp_vector_y, temp_vector_x);
			    state.value = max(abs(temp_vector_x), abs(temp_vector_y));
			}
			
			if (action.action != undefined && pressed && !(action.is_buffered && (action.buffered_call & BUFFERED_CALL.ACTION) != 0)) {
				action.action();
			};
            
            if (state != undefined) {
                if (pressed && !state.pressed) {
                    state.just_pressed = true;
                    state.pressed = true;
				    state.press_time = current_time;
				    state.press_count++;
					
				    var time_since_last = (state.press_time - state.last_press_time) / 1000000.0;
				    if (time_since_last < action.double_tap_window && state.press_count > 1) {
				        state.double_tapped = true;
				        if (action.action_double_tapped != undefined && !(action.is_buffered && (action.buffered_call & BUFFERED_CALL.ACTION_DOUBLE_TAPPED) != 0)) {
				            action.action_double_tapped();
				        }
				    }
				    state.last_press_time = state.press_time;
					
					if (action.action_just_pressed != undefined && !(action.is_buffered && (action.buffered_call & BUFFERED_CALL.ACTION_JUST_PRESSED) != 0)) {
						action.action_just_pressed();
					};
                } else if (!pressed && state.pressed) {
                    state.just_released = true;
                    state.pressed = false;
					
					if (action.action_just_released != undefined && !(action.is_buffered && (action.buffered_call & BUFFERED_CALL.ACTION_JUST_RELEASED) != 0)) {
						action.action_just_released();
					};
                };
            };
			
			if (action.is_buffered) {
				action.is_buffered = false;
				var call = action.buffered_call;
				action.buffered_call = BUFFERED_CALL.NONE;
				
				if ((call & BUFFERED_CALL.ACTION) != 0) {
					if (action.action != undefined) { action.action(); };
				}
				
				if ((call & BUFFERED_CALL.ACTION_JUST_PRESSED) != 0) {
					if (action.action_just_pressed != undefined) { action.action_just_pressed(); };
				}
				
				if ((call & BUFFERED_CALL.ACTION_JUST_RELEASED) != 0) {
					if (action.action_just_released != undefined) { action.action_just_released(); };
				}
				
				if ((call & BUFFERED_CALL.ACTION_DOUBLE_TAPPED) != 0) {
					if (action.action_double_tapped != undefined) { action.action_double_tapped(); };
				}
			};
        };
	};
	
	function CheckChord(binding) {
	    if (array_length(binding.chord_bindings) == 0) return false;
    
	    switch(binding.chord_mode) {
	        case "all": {
	            for (var i = 0; i < array_length(binding.chord_bindings); i++) {
	                if (!CheckSingleBinding(binding.chord_bindings[i])) 
	                    return false;
	            }
	            return true;
			} break;
            
	        case "any": {
	            for (var i = 0; i < array_length(binding.chord_bindings); i++) {
	                if (CheckSingleBinding(binding.chord_bindings[i])) 
	                    return true;
	            }
	            return false;
			} break;
	    }
	    return false;
	};
	
	function CheckSingleBinding(binding) {
	    if (array_length(binding.chord_bindings) > 0) {
	        return CheckChord(binding);
	    }
    
	    switch(binding.input_type) {
	        case INPUT_TYPE.KEY: {
	            return keyboard_check(binding.input_id) && CheckModifiers(binding);
	        } break;
        
	        case INPUT_TYPE.MOUSE_BUTTON: {
	            var buttonPressed = false;
	            switch(binding.mouse_button) {
	                case MOUSE_BUTTON.LEFT:
	                    buttonPressed = mouse_check_button(mb_left);
	                    break;
	                case MOUSE_BUTTON.RIGHT:
	                    buttonPressed = mouse_check_button(mb_right);
	                    break;
	                case MOUSE_BUTTON.MIDDLE:
	                    buttonPressed = mouse_check_button(mb_middle);
	                    break;
	                case MOUSE_BUTTON.BACK:
	                    buttonPressed = mouse_check_button(mb_side1);
	                    break;
	                case MOUSE_BUTTON.FORWARD:
	                    buttonPressed = mouse_check_button(mb_side2);
	                    break;
	            }
	            return buttonPressed && CheckMouseRegion(binding) && CheckModifiers(binding);
	        } break;
        
	        case INPUT_TYPE.MOUSE_WHEEL: {
	            var delta = 0;
	            switch(binding.wheel_direction) {
	                case MOUSE_WHEEL.UP: { delta = mouse_wheel_delta_y; } break;
	                case MOUSE_WHEEL.DOWN: { delta = -mouse_wheel_delta_y; } break;
	            }
	            return delta > 0 && CheckModifiers(binding);
	        } break;
        
	        case INPUT_TYPE.GAMEPAD_BUTTON: {
	            var gid = binding.input_device;
	            return gamepad_button_check(gid, binding.gamepad_button) && CheckModifiers(binding);
	        } break;
        
	        case INPUT_TYPE.GAMEPAD_AXIS: {
	            var gid = binding.input_device;
	            var axis_value = gamepad_axis_value(gid, binding.gamepad_axis);
	            if (binding.axis_positive_only) axis_value = max(0, axis_value);
	            return abs(axis_value) >= binding.axis_threshold && CheckModifiers(binding);
	        } break;
        
	        case INPUT_TYPE.TOUCH_POINT: {
	            return TouchGetNumbers() > 0;
	        } break;
	    }
    
	    return false;
	};
	
	function CheckModifiers(binding) {
	    if (binding.modifiers == INPUT_MODIFIER.NONE) return true;
    
	    if ((binding.modifiers & INPUT_MODIFIER.SHIFT) && !keyboard_check(vk_shift)) 
	        return false;
	    if ((binding.modifiers & INPUT_MODIFIER.CTRL) && !keyboard_check(vk_control)) 
	        return false;
	    if ((binding.modifiers & INPUT_MODIFIER.ALT) && !keyboard_check(vk_alt)) 
	        return false;
    
	    return true;
	};
    
    // Query functions
    function IsPressed(actionName) {
        var state = input_states[? actionName];
        return state != undefined && state.pressed;
    };
    
    function IsJustPressed(actionName) {
        var state = input_states[? actionName];
        return state != undefined && state.just_pressed;
    };
    
    function IsJustReleased(actionName) {
        var state = input_states[? actionName];
        return state != undefined && state.just_released;
    };
	
	function GetValue(actionName) {
	    var state = input_states[? actionName];
	    return state != undefined ? state.value : 0;
	};

	function GetVector(actionName) {
	    var state = input_states[? actionName];
	    if (state == undefined) return { x: 0, y: 0 };
	    return { x: state.vector_x, y: state.vector_y };
	};

	function GetMagnitude(actionName) {
	    var state = input_states[? actionName];
	    return state != undefined ? state.magnitude : 0;
	};

	function GetAngle(actionName) {
	    var state = input_states[? actionName];
	    return state != undefined ? state.angle : 0;
	};
	
	function IsDoubleTapped(actionName) {
	    var state = input_states[? actionName];
	    return state != undefined && state.double_tapped;
	};

	function IsLongPressed(actionName) {
	    var state = input_states[? actionName];
	    return state != undefined && state.long_pressed;
	};
	
	// Others
    function UpdateMouseWheelDelta() {
        var current_up = mouse_wheel_up();
        var current_down = mouse_wheel_down();
        
        var delta_y = 0;
        if (current_up && !mouse_wheel_last_up) {
            delta_y = 1;   // Up is positive
        };
        if (current_down && !mouse_wheel_last_down) {
            delta_y = -1;  // Down is negative
        };
        
        mouse_wheel_last_up = current_up;
        mouse_wheel_last_down = current_down;
        
        mouse_wheel_delta_y = delta_y;
        
        if (delta_y != 0) {
            wheel_accumulator_y += delta_y;
        } else {
            if (wheel_accumulator_y > 0) wheel_accumulator_y -= 0.1;
            if (wheel_accumulator_y < 0) wheel_accumulator_y += 0.1;
            if (abs(wheel_accumulator_y) < 0.1) wheel_accumulator_y = 0;
        };
        
        mouse_wheel_delta_x = 0;
    };
    
    function CheckMouseRegion(binding) {
        if (!binding.use_region) return true;
        
        var mx = window_mouse_get_x();
        var my = window_mouse_get_y();
        
        return (mx >= binding.region_x && mx <= binding.region_x + binding.region_w &&
                my >= binding.region_y && my <= binding.region_y + binding.region_h);
    };
	
	function TouchGetNumbers() {
		var _count = 0;
		
		for (var i = 0; i < 5; i++) {
			_count += device_mouse_check_button(i, mb_left) == true;
		};
		
		return _count;
	};
	
	function GamepadButtonToString(button) {
	    switch(button) {
	        case GAMEPAD_BUTTON.FACE1: return "FACE1 (A/Cross)";
	        case GAMEPAD_BUTTON.FACE2: return "FACE2 (B/Circle)";
	        case GAMEPAD_BUTTON.FACE3: return "FACE3 (X/Square)";
	        case GAMEPAD_BUTTON.FACE4: return "FACE4 (Y/Triangle)";
	        case GAMEPAD_BUTTON.SHOULDER_L: return "SHOULDER_L (LB/L1)";
	        case GAMEPAD_BUTTON.SHOULDER_R: return "SHOULDER_R (RB/R1)";
	        case GAMEPAD_BUTTON.SHOULDER_LB: return "SHOULDER_LB (LT/L2)";
	        case GAMEPAD_BUTTON.SHOULDER_RB: return "SHOULDER_RB (RT/R2)";
	        case GAMEPAD_BUTTON.SELECT: return "SELECT (Select/Touchpad)";
	        case GAMEPAD_BUTTON.START: return "START (Start/Options)";
	        case GAMEPAD_BUTTON.HOME: return "HOME (Home/Guide)";
	        case GAMEPAD_BUTTON.STICK_L: return "STICK_L (L3/Left Stick)";
	        case GAMEPAD_BUTTON.STICK_R: return "STICK_R (R3/Right Stick)";
	        case GAMEPAD_BUTTON.DPAD_UP: return "DPAD_UP";
	        case GAMEPAD_BUTTON.DPAD_DOWN: return "DPAD_DOWN";
	        case GAMEPAD_BUTTON.DPAD_LEFT: return "DPAD_LEFT";
	        case GAMEPAD_BUTTON.DPAD_RIGHT: return "DPAD_RIGHT";
	        case GAMEPAD_BUTTON.TOUCHPAD: return "TOUCHPAD";
	        case GAMEPAD_BUTTON.PADDLE_L: return "PADDLE_L (Left Paddle)";
	        case GAMEPAD_BUTTON.PADDLE_R: return "PADDLE_R (Right Paddle)";
	        case GAMEPAD_BUTTON.PADDLE_LB: return "PADDLE_LB (Left Lower Paddle)";
	        case GAMEPAD_BUTTON.PADDLE_RB: return "PADDLE_RB (Right Lower Paddle)";
	        default: return "UNKNOWN";
	    }
	}

	function GamepadAxisToString(axis) {
	    switch(axis) {
	        case GAMEPAD_AXIS.LEFT_X: return "LEFT_X (Left Stick Horizontal)";
	        case GAMEPAD_AXIS.LEFT_Y: return "LEFT_Y (Left Stick Vertical)";
	        case GAMEPAD_AXIS.RIGHT_X: return "RIGHT_X (Right Stick Horizontal)";
	        case GAMEPAD_AXIS.RIGHT_Y: return "RIGHT_Y (Right Stick Vertical)";
	        case GAMEPAD_AXIS.ACCELERATION_X: return "ACCELERATION_X";
	        case GAMEPAD_AXIS.ACCELERATION_Y: return "ACCELERATION_Y";
	        case GAMEPAD_AXIS.ACCELERATION_Z: return "ACCELERATION_Z";
	        case GAMEPAD_AXIS.GYRO_X: return "GYRO_X";
	        case GAMEPAD_AXIS.GYRO_Y: return "GYRO_Y";
	        case GAMEPAD_AXIS.GYRO_Z: return "GYRO_Z";
	        case GAMEPAD_AXIS.ORIENTATION_X: return "ORIENTATION_X";
	        case GAMEPAD_AXIS.ORIENTATION_Y: return "ORIENTATION_Y";
	        case GAMEPAD_AXIS.ORIENTATION_Z: return "ORIENTATION_Z";
	        case GAMEPAD_AXIS.ORIENTATION_W: return "ORIENTATION_W";
	        default: return "UNKNOWN";
	    }
	}
	
	function GetPlatformButtonName(button, platform) {
	    switch(platform) {
	        case GAMEPAD_TYPE.XBOX:
	            switch(button) {
	                case GAMEPAD_BUTTON_XBOX.A: return "A";
	                case GAMEPAD_BUTTON_XBOX.B: return "B";
	                case GAMEPAD_BUTTON_XBOX.X: return "X";
	                case GAMEPAD_BUTTON_XBOX.Y: return "Y";
	                case GAMEPAD_BUTTON_XBOX.LB: return "LB";
	                case GAMEPAD_BUTTON_XBOX.RB: return "RB";
	                case GAMEPAD_BUTTON_XBOX.LT: return "LT";
	                case GAMEPAD_BUTTON_XBOX.RT: return "RT";
	                case GAMEPAD_BUTTON_XBOX.BACK: return "Back";
	                case GAMEPAD_BUTTON_XBOX.START: return "Start";
	                case GAMEPAD_BUTTON_XBOX.GUIDE: return "Guide";
	                case GAMEPAD_BUTTON_XBOX.LEFT_STICK: return "Left Stick";
	                case GAMEPAD_BUTTON_XBOX.RIGHT_STICK: return "Right Stick";
	                case GAMEPAD_BUTTON_XBOX.DPAD_UP: return "D-Pad Up";
	                case GAMEPAD_BUTTON_XBOX.DPAD_DOWN: return "D-Pad Down";
	                case GAMEPAD_BUTTON_XBOX.DPAD_LEFT: return "D-Pad Left";
	                case GAMEPAD_BUTTON_XBOX.DPAD_RIGHT: return "D-Pad Right";
	                default: return "Unknown";
	            }
            
	        case GAMEPAD_TYPE.PLAYSTATION:
	            switch(button) {
	                case GAMEPAD_BUTTON_PS.CROSS: return "Cross";
	                case GAMEPAD_BUTTON_PS.CIRCLE: return "Circle";
	                case GAMEPAD_BUTTON_PS.SQUARE: return "Square";
	                case GAMEPAD_BUTTON_PS.TRIANGLE: return "Triangle";
	                case GAMEPAD_BUTTON_PS.L1: return "L1";
	                case GAMEPAD_BUTTON_PS.R1: return "R1";
	                case GAMEPAD_BUTTON_PS.L2: return "L2";
	                case GAMEPAD_BUTTON_PS.R2: return "R2";
	                case GAMEPAD_BUTTON_PS.SHARE: return "Share";
	                case GAMEPAD_BUTTON_PS.OPTIONS: return "Options";
	                case GAMEPAD_BUTTON_PS.PS: return "PS Button";
	                case GAMEPAD_BUTTON_PS.L3: return "L3";
	                case GAMEPAD_BUTTON_PS.R3: return "R3";
	                case GAMEPAD_BUTTON_PS.TOUCHPAD: return "Touchpad";
	                default: return "Unknown";
	            }
            
	        case GAMEPAD_TYPE.SWITCH:
	            switch(button) {
	                case GAMEPAD_BUTTON_SWITCH.A: return "A";
	                case GAMEPAD_BUTTON_SWITCH.B: return "B";
	                case GAMEPAD_BUTTON_SWITCH.X: return "X";
	                case GAMEPAD_BUTTON_SWITCH.Y: return "Y";
	                case GAMEPAD_BUTTON_SWITCH.L: return "L";
	                case GAMEPAD_BUTTON_SWITCH.R: return "R";
	                case GAMEPAD_BUTTON_SWITCH.ZL: return "ZL";
	                case GAMEPAD_BUTTON_SWITCH.ZR: return "ZR";
	                case GAMEPAD_BUTTON_SWITCH.MINUS: return "Minus";
	                case GAMEPAD_BUTTON_SWITCH.PLUS: return "Plus";
	                case GAMEPAD_BUTTON_SWITCH.HOME: return "Home";
	                case GAMEPAD_BUTTON_SWITCH.CAPTURE: return "Capture";
	                default: return "Unknown";
	            }
	    }
	    return "Unknown";
	}

	function GetConnectedControllerType(gamepad_id = 0) {
	    if (!gamepad_is_connected(gamepad_id)) return GAMEPAD_TYPE.NONE;
    
	    if (gamepad_button_check(gamepad_id, GAMEPAD_BUTTON.TOUCHPAD) != undefined) {
	        return GAMEPAD_TYPE.PLAYSTATION;
	    }
    
	    if (gamepad_button_check(gamepad_id, GAMEPAD_BUTTON.EXTRA1) != undefined) {
	        return GAMEPAD_TYPE.SWITCH;
	    }
    
	    return GAMEPAD_TYPE.XBOX;
	}
	
    // Destroy
    function Free() {
        ds_map_destroy(actions);
        ds_map_destroy(input_states);
    };
};

function Input() constructor {
    bindings = ds_map_create();
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
    function Free() { ds_map_destroy(bindings); };
};

