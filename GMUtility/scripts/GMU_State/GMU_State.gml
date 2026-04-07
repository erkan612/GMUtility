// State Machine
function StateMachine(_initial_state) constructor {
    states = ds_map_create_gmu();
    current = _initial_state;
    previous = undefined;
    changed = false;

    function AddState(_name, _on_enter, _on_update, _on_exit) {
        states[? _name] = {
            exit: _on_exit,
            enter: _on_enter,
            update: _on_update,
        };
        return self;
    };

    function ChangeTo(_new_state, _data = undefined) {
        if (!ds_map_exists(states, _new_state)) {
            show_debug_message("[StateMachine] Unknown state: " + string(_new_state));
            return self;
        }
    
        if (current != undefined && ds_map_exists(states, current)) {
            var exit_fn = states[? current].exit;
            if (exit_fn != undefined) exit_fn(_data);
        }
    
        previous = current;
        current = _new_state;
        changed = true;
    
        var enter_fn = states[? current].enter;
        if (enter_fn != undefined) enter_fn(_data);
    
        return self;
    };

    function Update(_delta = 1/60) {
        changed = false;
        if (current != undefined && ds_map_exists(states, current)) {
            var update_fn = states[? current].update;
            if (update_fn != undefined) update_fn(_delta);
        }
        return self;
    };

    function Serialize() {
        return {
            current: current,
            previous: previous,
            state_names: ds_map_keys_to_array(states)
        };
    };

    function Deserialize(_data) {
        if (_data.current != undefined) current = _data.current;
        if (_data.previous != undefined) previous = _data.previous;
        return self;
    };

    function Visualize() {
        show_debug_message("=== State Machine ===");
        show_debug_message("Current: " + string(current));
        show_debug_message("Previous: " + string(previous));
        show_debug_message("Registered states: " + string(ds_map_keys_to_array(states)));
        return self;
    };

    function Free() {
        ds_map_destroy_gmu(states);
    };
	
	toString = function() {
		return $"State Machine: Current: {string(current)}, Previous: {string(previous)}, Registered states: {string(ds_map_keys_to_array(states))}";
	};
};

//  Patrol, FlagPatrol, ModePatrol, StatePatrol
function Patrol(initialState = -1) constructor {
    state = initialState; previousState = -1; flags = 0;
    function SetState(newState) { if (state!=newState) { previousState=state; state=newState; } return self; };
    function GetState() { return state; };
    function PrevState() { return previousState; };
    function IsState(target) { return state == target; };
    function ChangedState() { return state != previousState; };
    function ClearState() { state = -1; previousState = -1; return self; };
    function AddFlag() { for (var i=0;i<argument_count;i++) flags |= argument[i]; return self; };
    function RemoveFlag() { for (var i=0;i<argument_count;i++) flags &= ~argument[i]; return self; };
    function ToggleFlag() { for (var i=0;i<argument_count;i++) flags ^= argument[i]; return self; };
    function HasFlag(flag) { return (flags & flag) != 0; };
    function ClearFlags() { flags = 0; return self; };
    function GetFlags() { return flags; };
    function SetFlags(value) { flags = value; return self; };
};

function FlagPatrol() constructor {
    flags = 0;
    function Add() { for (var i=0;i<argument_count;i++) flags |= argument[i]; return self; };
    function Remove() { for (var i=0;i<argument_count;i++) flags &= ~argument[i]; return self; };
    function Toggle() { for (var i=0;i<argument_count;i++) flags ^= argument[i]; return self; };
    function Has(flag) { return (flags & flag) != 0; };
    function Clear() { flags = 0; return self; };
    function Get() { return flags; };
    function Set(value) { flags = value; return self; };
    toString = function() { return "Flags: " + string(flags); };
};

function ModePatrol() constructor {
    states = ds_map_create_gmu();
    state = undefined;
    previousState = undefined;
    function AddState(name) {
        if (!ds_map_exists(states, name)) ds_map_add(states, name, new FlagPatrol());
        return self;
    };
    function SetState(name) {
        if (state != name) { previousState = state; state = name; }
        return self;
    };
    function GetState() { return state; };
    function PrevState() { return previousState; };
    function HasState() { return state != undefined; };
    function Flag(name) {
        if (ds_map_exists(states, name)) return states[? name];
        show_debug_message("ModePatrol: State '" + name + "' does not exist.");
        return undefined;
    };
    function CurrentFlag() {
        if (state != undefined && ds_map_exists(states, state)) return states[? state];
        show_debug_message("ModePatrol: No current state set.");
        return undefined;
    };
    function ClearStates() {
        state = undefined; previousState = undefined;
        var keys = ds_map_keys_to_array(states);
        for (var i=0;i<array_length(keys);i++) states[? keys[i]].Clear();
        return self;
    };
    function Clear() { ClearStates(); ds_map_clear(states); return self; };
    function Free() { Clear(); ds_map_destroy_gmu(states); };
};

function StatePatrol(initialState = -1) constructor {
    state = initialState; previousState = -1;
    function Set(newState) { if (state!=newState) { previousState=state; state=newState; } return self; };
    function Get() { return state; };
    function Previous() { return previousState; };
    function Is(currentState) { return state == currentState; };
    function Changed() { return state != previousState; };
    function Clear() { state = -1; previousState = -1; return self; };
};

