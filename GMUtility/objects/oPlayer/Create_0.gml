grav = 0.65;
canJump = false;

InputManager.CreateAction("move_left");
InputManager.CreateAction("move_right");
InputManager.CreateAction("jump");

InputManager.BindKey("move_left", ord("A"));
InputManager.BindKey("move_right", ord("D"));
InputManager.BindKey("jump", vk_space);

InputManager.BindActionMethodJustPressed("jump", function() {
	if (oPlayer.canJump) {
		vspeed = -12;
	}
	else {
		InputManager.BufferAction("jump", BUFFERED_CALL.ACTION_JUST_PRESSED);
	}
});

function DebugPrintGamepadConstants() {
    show_debug_message("=== GAMEPAD BUTTON CONSTANTS (Real Values) ===");
    
    // Face buttons
    show_debug_message("gp_face1 (A/Cross): " + string(real(gp_face1)));
    show_debug_message("gp_face2 (B/Circle): " + string(real(gp_face2)));
    show_debug_message("gp_face3 (X/Square): " + string(real(gp_face3)));
    show_debug_message("gp_face4 (Y/Triangle): " + string(real(gp_face4)));
    
    // Shoulder buttons
    show_debug_message("gp_shoulderl (LB/L1): " + string(real(gp_shoulderl)));
    show_debug_message("gp_shoulderlb (LT/L2): " + string(real(gp_shoulderlb)));
    show_debug_message("gp_shoulderr (RB/R1): " + string(real(gp_shoulderr)));
    show_debug_message("gp_shoulderrb (RT/R2): " + string(real(gp_shoulderrb)));
    
    // System buttons
    show_debug_message("gp_select (Select/Touchpad): " + string(real(gp_select)));
    show_debug_message("gp_start (Start/Options): " + string(real(gp_start)));
    show_debug_message("gp_home (Home/Guide): " + string(real(gp_home)));
    
    // Stick clicks
    show_debug_message("gp_stickl (Left Stick Click): " + string(real(gp_stickl)));
    show_debug_message("gp_stickr (Right Stick Click): " + string(real(gp_stickr)));
    
    // D-pad
    show_debug_message("gp_padu (D-pad Up): " + string(real(gp_padu)));
    show_debug_message("gp_padd (D-pad Down): " + string(real(gp_padd)));
    show_debug_message("gp_padl (D-pad Left): " + string(real(gp_padl)));
    show_debug_message("gp_padr (D-pad Right): " + string(real(gp_padr)));
    
    // PlayStation touchpad
    show_debug_message("gp_touchpadbutton (Touchpad Button): " + string(real(gp_touchpadbutton)));
    
    // Xbox Elite paddles
    show_debug_message("gp_paddler (Right Upper Paddle/P1): " + string(real(gp_paddler)));
    show_debug_message("gp_paddlel (Left Upper Paddle/P3): " + string(real(gp_paddlel)));
    show_debug_message("gp_paddlerb (Right Lower Paddle/P2): " + string(real(gp_paddlerb)));
    show_debug_message("gp_paddlelb (Left Lower Paddle/P4): " + string(real(gp_paddlelb)));
    
    // Extra buttons
    show_debug_message("gp_extra1: " + string(real(gp_extra1)));
    show_debug_message("gp_extra2: " + string(real(gp_extra2)));
    show_debug_message("gp_extra3: " + string(real(gp_extra3)));
    show_debug_message("gp_extra4: " + string(real(gp_extra4)));
    show_debug_message("gp_extra5: " + string(real(gp_extra5)));
    show_debug_message("gp_extra6: " + string(real(gp_extra6)));
    
    show_debug_message(" ");
    show_debug_message("=== GAMEPAD AXIS CONSTANTS (Real Values) ===");
    
    // Standard analog sticks
    show_debug_message("gp_axislh (Left Stick X): " + string(real(gp_axislh)));
    show_debug_message("gp_axislv (Left Stick Y): " + string(real(gp_axislv)));
    show_debug_message("gp_axisrh (Right Stick X): " + string(real(gp_axisrh)));
    show_debug_message("gp_axisrv (Right Stick Y): " + string(real(gp_axisrv)));
    
    show_debug_message(" ");
    show_debug_message("=== DUALSHOCK/DUALSENSE MOTION SENSORS (Real Values) ===");
    show_debug_message("Note: These only work on PS4/PS5 with DualSense controller");
    
    // Acceleration
    show_debug_message("gp_axis_acceleration_x: " + string(real(gp_axis_acceleration_x)));
    show_debug_message("gp_axis_acceleration_y: " + string(real(gp_axis_acceleration_y)));
    show_debug_message("gp_axis_acceleration_z: " + string(real(gp_axis_acceleration_z)));
    
    // Angular velocity (gyro)
    show_debug_message("gp_axis_angular_velocity_x: " + string(real(gp_axis_angular_velocity_x)));
    show_debug_message("gp_axis_angular_velocity_y: " + string(real(gp_axis_angular_velocity_y)));
    show_debug_message("gp_axis_angular_velocity_z: " + string(real(gp_axis_angular_velocity_z)));
    
    // Orientation (quaternion)
    show_debug_message("gp_axis_orientation_x: " + string(real(gp_axis_orientation_x)));
    show_debug_message("gp_axis_orientation_y: " + string(real(gp_axis_orientation_y)));
    show_debug_message("gp_axis_orientation_z: " + string(real(gp_axis_orientation_z)));
    show_debug_message("gp_axis_orientation_w: " + string(real(gp_axis_orientation_w)));
    
    show_debug_message(" ");
    show_debug_message("=== SUMMARY ===");
    show_debug_message("Total Button Constants: 31");
    show_debug_message("Total Axis Constants: 15");
}

DebugPrintGamepadConstants();