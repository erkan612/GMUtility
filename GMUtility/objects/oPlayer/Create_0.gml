grav = 0.65;
canJump = false;
moveSpeed = 3;
hspeed = 0;
vspeed = 0;
face_right = true;

InputManager.CreateAction("move_left");
InputManager.CreateAction("move_right");
InputManager.CreateAction("jump");

InputManager.BindKey("move_left", ord("A"));
InputManager.BindKey("move_right", ord("D"));
InputManager.BindKey("jump", vk_space);

InputManager.BindActionMethodJustPressed("jump", function() {
    if (oPlayer.canJump) {
        vspeed = -12;
        canJump = false;
    } else {
        InputManager.BufferAction("jump", BUFFERED_CALL.ACTION_JUST_PRESSED);
    }
});

anims = new AnimPack(self);

anims.Add("idle", spr_player_idle, 0.15)
     .Add("walk", spr_player_walk, 0.25)
     .Add("jump", spr_player_jump, 0.2)
     .Add("fall", spr_player_fall, 0.2)
     .SetDefault("idle");

anims.Get("idle")
     .SetPlaybackMode(ANIM_PLAYBACK.LOOP);

anims.Get("walk")
     .SetPlaybackMode(ANIM_PLAYBACK.LOOP);

anims.Get("jump")
     .SetPlaybackMode(ANIM_PLAYBACK.ONCE);

anims.Get("fall")
     .SetPlaybackMode(ANIM_PLAYBACK.LOOP);
