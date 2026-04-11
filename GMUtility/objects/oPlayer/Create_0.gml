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
