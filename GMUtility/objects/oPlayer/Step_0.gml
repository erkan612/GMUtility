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

var mov_dir = (InputManager.IsPressed("move_right") - InputManager.IsPressed("move_left"));

if (mov_dir != 0) {
    face_right = mov_dir > 0;
    image_xscale = face_right ? 1 : -1;
}

hspeed = 0;
if (abs(mov_dir) > 0) {
    var target_speed = mov_dir * moveSpeed;
    var step = sign(target_speed);
    
    repeat (abs(target_speed)) {
        if (!place_meeting(x + step, y - 1, oBlock)) {
            hspeed = target_speed;
        }
    }
}

var grounded = place_meeting(x, y + 1, oBlock);
var is_moving = abs(hspeed) > 0.5;

if (grounded) {
    if (is_moving) {
        var walk_anim = anims.Get("walk");
        if (walk_anim != undefined) {
            walk_anim.speed = abs(hspeed) / moveSpeed * 0.25;
        }
        anims.Set("walk", 0.15);
    } else {
        anims.Set("idle", 0.2);
    }
} else {
    if (vspeed < 0) {
        anims.Set("jump", 0.1);
    } else {
        anims.Set("fall", 0.15);
    }
}
