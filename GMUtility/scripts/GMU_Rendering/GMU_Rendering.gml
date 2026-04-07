//  Camera System
function Camera(_index, _resolution, _object = -1, _position = {x:0,y:0}, _border = {x:0,y:0}, _angle = 0, _spd = {x:-1,y:-1}) constructor {
    index = _index;
    resolution = _resolution;
    object = _object;
    position = _position;
    angle = _angle;
    spd = _spd;
    border = _border;
    shake_magnitude = 0;
    shake_decay = 0.9;
    shake_offset_x = 0;
    shake_offset_y = 0;
    zoom = 1;
    target_zoom = 1;
    zoom_speed = 0.1;

    camera = camera_create_view(position.x, position.y, resolution.width, resolution.height, angle, object, spd.x, spd.y, border.x, border.y);
    view_enabled = true;
    view_visible[index] = true;

    function Set() {
        view_set_camera(index, camera);
        return self;
    };
    function Shake(magnitude, decay = 0.9) {
        shake_magnitude = magnitude;
        shake_decay = decay;
        return self;
    };
    function SetZoom(target, speed = 0.1) {
        target_zoom = target;
        zoom_speed = speed;
        return self;
    };
    function Update() {
        if (abs(zoom - target_zoom) > 0.01) zoom = lerp(zoom, target_zoom, zoom_speed);
        else zoom = target_zoom;

        if (shake_magnitude > 0) {
            shake_offset_x = random_range(-shake_magnitude, shake_magnitude);
            shake_offset_y = random_range(-shake_magnitude, shake_magnitude);
            shake_magnitude *= shake_decay;
            if (shake_magnitude < 0.1) shake_magnitude = 0;
        } else {
            shake_offset_x = 0;
            shake_offset_y = 0;
        }

        var view_w = resolution.width / zoom;
        var view_h = resolution.height / zoom;
        var view_x = position.x + shake_offset_x - view_w/2;
        var view_y = position.y + shake_offset_y - view_h/2;
        camera_set_view_pos(camera, view_x, view_y);
        camera_set_view_size(camera, view_w, view_h);
        camera_set_view_angle(camera, angle);
        return self;
    };
    function Free() {
        camera_destroy(camera);
    };
};

//  Animation System
function Animation(_animation, _speed = 1, _onUpdate = undefined) constructor {
    animation = _animation;
    speed = _speed;
    onUpdate = _onUpdate;

    function Update(_object) {
        _object.sprite_index = animation;
        _object.image_speed = speed;
        if (onUpdate != undefined) onUpdate(self, _object);
    };
};

function AnimPack(_object) constructor {
    object = _object;
    animations = ds_map_create_gmu();
    current = undefined;

    function Add(name, anim) {
        animations[? name] = anim;
        return self;
    };
    function Get(name) {
        return animations[? name];
    };
    function Exists(name) {
        return ds_map_exists(animations, name);
    };
    function Set(name) {
        if (!Exists(name)) return self;
        current = animations[? name];
        return self;
    };
    function Update() {
        if (current != undefined) current.Update(object);
        return self;
    };
    function Free() {
        var keys = ds_map_keys_to_array(animations);
        for (var i = 0; i < array_length(keys); i++) delete animations[? keys[i]];
        ds_map_destroy_gmu(animations);
    };
};

