

//  Command Manager
function CommandManager() constructor {
    cmdList = ds_list_create_gmu();
    commandActions = ds_map_create_gmu();
    categories = ds_map_create_gmu();
    debugMode = false;
    historyEnabled = false;

    undoStack = undefined;
    redoStack = undefined;

    function RegisterAction(cmd, handler, category = "default") {
        commandActions[? cmd] = handler;
    
        if (!ds_map_exists(categories, category)) {
            categories[? category] = ds_list_create_gmu();
        }
        ds_list_add(categories[? category], cmd);
    
        return self;
    };

    function GetAction(cmd) {
        return commandActions[? cmd];
    };

    function Push(cmd, data = undefined) {
        var cmdData = { command: cmd, data: data };
        ds_list_add(cmdList, cmdData);
    
        if (historyEnabled) {
            if (undoStack == undefined) {
                undoStack = ds_stack_create_gmu();
                redoStack = ds_stack_create_gmu();
            }
            ds_stack_push(undoStack, cmdData);
            ds_stack_clear(redoStack);
        }
    
        return self;
    };

    function PushDelayed(cmd, delayFrames = 0, data = undefined) {
        if (delayFrames <= 0) {
            Push(cmd, data);
        } else {
            ds_list_add(cmdList, { command: cmd, data: data, delay: delayFrames, timer: 0 });
        }
        return self;
    };

    function PushFront(cmd, data = undefined) {
        ds_list_insert(cmdList, 0, { command: cmd, data: data });
        return self;
    };

    function Execute() {
        var i = 0;
        while (i < ds_list_size(cmdList)) {
            var cd = cmdList[| i];
        
            if (cd.delay != undefined) {
                cd.timer++;
                if (cd.timer >= cd.delay) {
                    if (ds_map_exists(commandActions, cd.command)) {
                        if (debugMode) {
                            show_debug_message("[CMD] Executing delayed: " + string(cd.command) + " (delay: " + cd.delay + ")");
                        }
                        ExecuteSafe(commandActions[? cd.command], cd.data);
                    } else {
                        show_debug_message("[CMD] Undefined delayed command: " + string(cd.command));
                    }
                    ds_list_delete(cmdList, i);
                    continue;
                }
                i++;
                continue;
            }
        
            if (ds_map_exists(commandActions, cd.command)) {
                if (debugMode) {
                    show_debug_message("[CMD] Executing: " + string(cd.command) + " | Data: " + string(cd.data));
                }
                ExecuteSafe(commandActions[? cd.command], cd.data);
            } else {
                show_debug_message("[CMD] Undefined command: " + string(cd.command));
            }
            ds_list_delete(cmdList, i);
        }
        return self;
    };

    function ExecuteCategory(category) {
        if (!ds_map_exists(categories, category)) {
            if (debugMode) show_debug_message("[CMD] Category not found: " + category);
            return self;
        }
    
        var cmds = categories[? category];
        for (var i = 0; i < ds_list_size(cmds); i++) {
            var cmd = cmds[| i];
            if (ds_map_exists(commandActions, cmd)) {
                if (debugMode) show_debug_message("[CMD] Executing category '" + category + "': " + string(cmd));
                ExecuteSafe(commandActions[? cmd]);
            }
        }
        return self;
    };

    function Clear() {
        ds_list_clear(cmdList);
        return self;
    };

    function ClearCategory(category) {
        if (!ds_map_exists(categories, category)) return self;
    
        var cmdsToKeep = ds_list_create_gmu();
        var categoryCmds = categories[? category];
    
        var cmdLookup = ds_map_create_gmu();
        for (var i = 0; i < ds_list_size(categoryCmds); i++) {
            cmdLookup[? ds_list_find_value(categoryCmds, i)] = true;
        }
    
        for (var i = 0; i < ds_list_size(cmdList); i++) {
            var cmd = cmdList[| i];
            if (!ds_map_exists(cmdLookup, cmd.command)) {
                ds_list_add(cmdsToKeep, cmd);
            }
        }
    
        ds_list_destroy_gmu(cmdList);
        cmdList = cmdsToKeep;
        ds_map_destroy_gmu(cmdLookup);
    
        if (debugMode) show_debug_message("[CMD] Cleared category: " + category);
        return self;
    };

    function Chain(commands) {
        if (!is_array(commands)) return self;
        for (var i = 0; i < array_length(commands); i++) {
            var cmd = commands[i];
            if (cmd.delay != undefined) {
                PushDelayed(cmd.cmd, cmd.delay, cmd.data);
            } else {
                Push(cmd.cmd, cmd.data);
            }
        }
        return self;
    };

    function Undo() {
        if (!historyEnabled || undoStack == undefined || ds_stack_empty(undoStack)) {
            if (debugMode) show_debug_message("[CMD] Nothing to undo");
            return self;
        }
    
        var last = ds_stack_pop(undoStack);
        ds_stack_push(redoStack, last);
    
        var inverseCmd = last.command + "_INVERSE";
        if (ds_map_exists(commandActions, inverseCmd)) {
            if (debugMode) show_debug_message("[CMD] Undoing: " + string(last.command));
            ExecuteSafe(commandActions[? inverseCmd], last.data);
        } else {
            show_debug_message("[CMD] No inverse command registered for: " + string(last.command));
        }
        return self;
    };

    function Redo() {
        if (!historyEnabled || redoStack == undefined || ds_stack_empty(redoStack)) {
            if (debugMode) show_debug_message("[CMD] Nothing to redo");
            return self;
        }
    
        var last = ds_stack_pop(redoStack);
        ds_stack_push(undoStack, last);
    
        if (ds_map_exists(commandActions, last.command)) {
            if (debugMode) show_debug_message("[CMD] Redoing: " + string(last.command));
            ExecuteSafe(commandActions[? last.command], last.data);
        }
        return self;
    };

    function EnableDebug(enabled = true) {
        debugMode = enabled;
        if (debugMode) show_debug_message("[CMD] Debug mode enabled");
        return self;
    };

    function EnableHistory(enabled = true) {
        historyEnabled = enabled;
        if (enabled) {
            if (undoStack == undefined) {
                undoStack = ds_stack_create_gmu();
                redoStack = ds_stack_create_gmu();
            }
            if (debugMode) show_debug_message("[CMD] History tracking enabled");
        }
        return self;
    };

    function GetQueueSize() {
        return ds_list_size(cmdList);
    };

    function GetCommandCount() {
        return ds_map_size(commandActions);
    };

    function GetCategories() {
        return ds_map_keys_to_array(categories);
    };

    function GetCommandsInCategory(category) {
        if (!ds_map_exists(categories, category)) return [];
        return ds_list_to_array(categories[? category]);
    };

    function Reset() {
        Clear();
        ds_map_clear(commandActions);
    
        var cats = ds_map_values_to_array(categories);
        for (var i = 0; i < array_length(cats); i++) {
            ds_list_destroy_gmu(cats[i]);
        }
        ds_map_clear(categories);
    
        if (historyEnabled) {
            if (undoStack != undefined) ds_stack_destroy_gmu(undoStack);
            if (redoStack != undefined) ds_stack_destroy_gmu(redoStack);
            undoStack = undefined;
            redoStack = undefined;
        }
    
        cmdList = ds_list_create_gmu();
        categories = ds_map_create_gmu();
        commandActions = ds_map_create_gmu();
    
        return self;
    };

    function Free() {
        ds_list_destroy_gmu(cmdList);
        ds_map_destroy_gmu(commandActions);
    
        var cats = ds_map_values_to_array(categories);
        for (var i = 0; i < array_length(cats); i++) {
            ds_list_destroy_gmu(cats[i]);
        }
        ds_map_destroy_gmu(categories);
    
        if (historyEnabled) {
            if (undoStack != undefined) ds_stack_destroy_gmu(undoStack);
            if (redoStack != undefined) ds_stack_destroy_gmu(redoStack);
        }
    };

    toString = function() {
        return "CommandManager: " + string(ds_list_size(cmdList)) + " queued, " + 
               string(ds_map_size(commandActions)) + " registered commands, " +
               string(ds_map_size(categories)) + " categories";
    };
};

function CommandChain() constructor {
    commands = [];

    function Then(cmd, data = undefined, delay = 0) {
        array_push(commands, { cmd: cmd, data: data, delay: delay });
        return self;
    };

    function ThenWait(frames) {
        array_push(commands, { cmd: "WAIT", delay: frames });
        return self;
    };

    function Execute(manager) {
        manager.Chain(commands);
        return self;
    };

    function Clear() {
        commands = [];
        return self;
    };
};