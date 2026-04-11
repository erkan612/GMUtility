if (vspeed > 0) {
    if (place_meeting(x, y + vspeed, oBlock)) {
        while (!place_meeting(x, y + sign(vspeed), oBlock)) {
            y += sign(vspeed);
        }
        vspeed = 0;
        canJump = true;
    } else {
        vspeed += grav;
    }
} else {
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
