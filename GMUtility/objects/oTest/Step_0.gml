InputManager.Update(delta_time);

if (InputManager.IsJustPressed("zoom_in")) {
	show_debug_message("up");
}

if (InputManager.IsJustPressed("zoom_out")) {
	show_debug_message("down");
}
