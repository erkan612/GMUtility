if (vspeed > 0) { // Moving down
    if (place_meeting(x, y + vspeed, oBlock)) {
        // Move to exact contact point
        while (!place_meeting(x, y + sign(vspeed), oBlock)) {
            y += sign(vspeed);
        }
        vspeed = 0;
        canJump = true;
    } else {
        vspeed += grav;
    }
} else { // Moving up or not moving
    if (place_meeting(x, y + vspeed, oBlock)) {
        vspeed = 0;
		canJump = true;
    } else {
        vspeed += grav;
		canJump = false;
    }
}

hspeed = (InputManager.IsPressed("move_right") - InputManager.IsPressed("move_left")) * 3;

if (place_meeting(x + hspeed, y - 1, oBlock) || place_meeting(x + hspeed, y - 1, oBlock)) {
	hspeed = 0;
}
