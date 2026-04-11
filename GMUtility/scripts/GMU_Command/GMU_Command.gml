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
    
    function RegisterCommand(cmd, commandObject, category = "default") {
        commandActions[? cmd] = commandObject;
    
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
                        ExecuteCommand(cd.command, cd.data);
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
                ExecuteCommand(cd.command, cd.data);
            } else {
                show_debug_message("[CMD] Undefined command: " + string(cd.command));
            }
            ds_list_delete(cmdList, i);
        }
        return self;
    };
    
    function ExecuteCommand(cmd, data) {
        var action = commandActions[? cmd];
        
        if (is_struct(action) && struct_has_method(action, "execute")) {
            ExecuteSafe(action.execute, data);
        } else if (is_method(action) || is_callable(action)) {
            ExecuteSafe(action, data);
        } else {
            show_debug_message("[CMD] Invalid command action: " + string(cmd));
        }
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
                ExecuteCommand(cmd, undefined);
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
    
        var action = commandActions[? last.command];
        
        if (is_struct(action) && struct_has_method(action, "undo")) {
            if (debugMode) show_debug_message("[CMD] Undoing: " + string(last.command));
            ExecuteSafe(action.undo, last.data);
        } else {
            var inverseCmd = last.command + "_INVERSE";
            if (ds_map_exists(commandActions, inverseCmd)) {
                if (debugMode) show_debug_message("[CMD] Undoing (legacy): " + string(last.command));
                var inverseAction = commandActions[? inverseCmd];
                if (is_struct(inverseAction) && struct_has_method(inverseAction, "execute")) {
                    ExecuteSafe(inverseAction.execute, last.data);
                } else {
                    ExecuteSafe(inverseAction, last.data);
                }
            } else {
                show_debug_message("[CMD] No undo method registered for: " + string(last.command));
            }
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
            ExecuteCommand(last.command, last.data);
        }
        return self;
    };
    
    function CanUndo(cmd) {
        if (!ds_map_exists(commandActions, cmd)) return false;
        
        var action = commandActions[? cmd];
        
        if (is_struct(action) && struct_has_method(action, "undo")) {
            return true;
        }
        
        var inverseCmd = cmd + "_INVERSE";
        if (ds_map_exists(commandActions, inverseCmd)) {
            return true;
        }
        
        return false;
    };
    
    function GetUndoCount() {
        if (!historyEnabled || undoStack == undefined) return 0;
        return ds_stack_size(undoStack);
    };
    
    function GetRedoCount() {
        if (!historyEnabled || redoStack == undefined) return 0;
        return ds_stack_size(redoStack);
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
        var undoCount = GetUndoCount();
        var redoCount = GetRedoCount();
        return "CommandManager: " + string(ds_list_size(cmdList)) + " queued, " + 
               string(ds_map_size(commandActions)) + " registered commands, " +
               string(ds_map_size(categories)) + " categories, " +
               string(undoCount) + " undo, " + string(redoCount) + " redo";
    };
};

function Command(_execute, _undo) constructor { // classic
    execute = _execute;
    undo = _undo;
    
    function IsValid() {
        return is_callable(execute) && is_callable(undo);
    };
    
    function Do(data = undefined) {
        if (is_callable(execute)) {
            return execute(data);
        }
        return undefined;
    };
    
    function Undo(data = undefined) {
        if (is_callable(undo)) {
            return undo(data);
        }
        return undefined;
    };
    
    toString = function() {
        return "Command: " + string(execute) + " / " + string(undo);
    };
};

function StateCommand(_getState, _setState, _data) constructor { // reversible command that stores state, useful for property changes
    oldState = undefined;
    getState = _getState;
    setState = _setState;
    data = _data;
    
    function Capture() {
        if (is_callable(getState)) {
            oldState = getState(data);
        }
        return self;
    };
    
    function Execute() {
        Capture();
        if (is_callable(setState)) {
            setState(data);
        }
        return self;
    };
    
    function Undo() {
        if (oldState != undefined && is_callable(setState)) {
            var revertData = {
                target: data.target,
                property: data.property,
                value: oldState
            };
            setState(revertData);
        }
        return self;
    };
    
    function ToCommand() {
        return new Command(
            function(d) { Execute(); },
            function(d) { Undo(); }
        );
    };
};

function CommandBatch(_name = "Batch") constructor { // multiple commands treated as one undoable action
    name = _name;
    commands = [];
    
    function Add(cmd, data = undefined) {
        array_push(commands, { cmd: cmd, data: data });
        return self;
    };
    
    function AddCommand(commandObject, data = undefined) {
        array_push(commands, { commandObject: commandObject, data: data });
        return self;
    };
    
    function Execute(manager) {
        for (var i = 0; i < array_length(commands); i++) {
            var item = commands[i];
            if (item.cmd != undefined) {
                manager.Push(item.cmd, item.data);
            } else if (item.commandObject != undefined) {
                // Direct execution without queuing
                item.commandObject.execute(item.data);
            }
        }
        return self;
    };
    
    function ToCommand() {
        var cmdList = commands;
        
        return new Command(
            function(data) {
                for (var i = 0; i < array_length(cmdList); i++) {
                    var item = cmdList[i];
                    if (item.commandObject != undefined) {
                        item.commandObject.execute(item.data);
                    }
                }
            },
            function(data) {
                for (var i = array_length(cmdList) - 1; i >= 0; i--) {
                    var item = cmdList[i];
                    if (item.commandObject != undefined && struct_has_method(item.commandObject, "undo")) {
                        item.commandObject.undo(item.data);
                    }
                }
            }
        );
    };
    
    function Clear() {
        commands = [];
        return self;
    };
    
    function Size() {
        return array_length(commands);
    };
    
    toString = function() {
        return "CommandBatch '" + name + "': " + string(array_length(commands)) + " commands";
    };
};

function CommandChain() constructor {
    commands = [];

    function Then(cmd, data = undefined, delay = 0) {
        array_push(commands, { cmd: cmd, data: data, delay: delay });
        return self;
    };
    
    function ThenCommand(commandObject, data = undefined, delay = 0) {
        array_push(commands, { commandObject: commandObject, data: data, delay: delay });
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
    
    function Size() {
        return array_length(commands);
    };
};

function Commands() { // helper to create common command types
    function PropertyChange(target, property, newValue) {
        var oldValue = undefined;
        var isCaptured = false;
        
        return new Command(
            function(data) {
                if (!isCaptured) {
                    if (is_struct(target)) {
                        oldValue = target[$ property];
                    } else if (instance_exists(target)) {
                        oldValue = variable_instance_get(target, property);
                    }
                    isCaptured = true;
                }
                
                if (is_struct(target)) {
                    target[$ property] = newValue;
                } else if (instance_exists(target)) {
                    variable_instance_set(target, property, newValue);
                }
            },
            function(data) {
                if (oldValue != undefined) {
                    if (is_struct(target)) {
                        target[$ property] = oldValue;
                    } else if (instance_exists(target)) {
                        variable_instance_set(target, property, oldValue);
                    }
                }
            }
        );
    };
    
    function PropertyChanges(target, propertyMap) {
        var oldValues = undefined;
        var isCaptured = false;
        
        return new Command(
            function(data) {
                if (!isCaptured) {
                    oldValues = {};
                    var keys = variable_struct_get_names(propertyMap);
                    for (var i = 0; i < array_length(keys); i++) {
                        var prop = keys[i];
                        if (is_struct(target)) {
                            oldValues[$ prop] = target[$ prop];
                        } else if (instance_exists(target)) {
                            oldValues[$ prop] = variable_instance_get(target, prop);
                        }
                    }
                    isCaptured = true;
                }
                
                var keys = variable_struct_get_names(propertyMap);
                for (var i = 0; i < array_length(keys); i++) {
                    var prop = keys[i];
                    var val = propertyMap[$ prop];
                    if (is_struct(target)) {
                        target[$ prop] = val;
                    } else if (instance_exists(target)) {
                        variable_instance_set(target, prop, val);
                    }
                }
            },
            function(data) {
                if (oldValues != undefined) {
                    var keys = variable_struct_get_names(oldValues);
                    for (var i = 0; i < array_length(keys); i++) {
                        var prop = keys[i];
                        var val = oldValues[$ prop];
                        if (is_struct(target)) {
                            target[$ prop] = val;
                        } else if (instance_exists(target)) {
                            variable_instance_set(target, prop, val);
                        }
                    }
                }
            }
        );
    };
    
    function FunctionCall(doFunc, undoFunc) {
        return new Command(doFunc, undoFunc);
    };
    
    function SpawnInstance(object, x, y, layer) {
        var createdInstance = -1;
        
        return new Command(
            function(data) {
                createdInstance = instance_create_layer(x, y, layer, object);
                return createdInstance;
            },
            function(data) {
                if (instance_exists(createdInstance)) {
                    instance_destroy(createdInstance);
                    createdInstance = -1;
                }
            }
        );
    };
    
    function DestroyInstance(instance) {
        var destroyedId = instance;
        var destroyedType = object_get_name(instance.object_index);
        var destroyedX = instance.x;
        var destroyedY = instance.y;
        var destroyedLayer = instance.layer;
        var wasDestroyed = false;
        
        return new Command(
            function(data) {
                if (instance_exists(destroyedId)) {
                    instance_destroy(destroyedId);
                    wasDestroyed = true;
                }
            },
            function(data) {
                if (wasDestroyed) {
                    var newInst = instance_create_layer(destroyedX, destroyedY, destroyedLayer, 
                                                        asset_get_index(destroyedType));
                    wasDestroyed = false;
                    return newInst;
                }
                return undefined;
            }
        );
    };
    
    function ValueChange(getter, setter, newValue) {
        var oldValue = undefined;
        var isCaptured = false;
        
        return new Command(
            function(data) {
                if (!isCaptured && is_callable(getter)) {
                    oldValue = getter();
                    isCaptured = true;
                }
                if (is_callable(setter)) {
                    setter(newValue);
                }
            },
            function(data) {
                if (oldValue != undefined && is_callable(setter)) {
                    setter(oldValue);
                }
            }
        );
    };
    
    function ArrayAdd(arr, item) {
        var addedIndex = -1;
        
        return new Command(
            function(data) {
                array_push(arr, item);
                addedIndex = array_length(arr) - 1;
            },
            function(data) {
                if (addedIndex >= 0 && addedIndex < array_length(arr)) {
                    array_delete(arr, addedIndex, 1);
                    addedIndex = -1;
                }
            }
        );
    };
    
    function ArrayRemove(arr, index) {
        var removedItem = undefined;
        
        return new Command(
            function(data) {
                if (index >= 0 && index < array_length(arr)) {
                    removedItem = arr[index];
                    array_delete(arr, index, 1);
                }
            },
            function(data) {
                if (removedItem != undefined) {
                    array_insert(arr, index, removedItem);
                    removedItem = undefined;
                }
            }
        );
    };
    
    function MapSet(map, key, value) {
        var oldValue = undefined;
        var hadOldValue = false;
        var isCaptured = false;
        
        return new Command(
            function(data) {
                if (!isCaptured) {
                    hadOldValue = ds_map_exists(map, key);
                    if (hadOldValue) {
                        oldValue = map[? key];
                    }
                    isCaptured = true;
                }
                map[? key] = value;
            },
            function(data) {
                if (hadOldValue) {
                    map[? key] = oldValue;
                } else {
                    ds_map_delete(map, key);
                }
            }
        );
    };
    
    function ListAdd(list, value) {
        var addedIndex = -1;
        
        return new Command(
            function(data) {
                ds_list_add(list, value);
                addedIndex = ds_list_size(list) - 1;
            },
            function(data) {
                if (addedIndex >= 0 && addedIndex < ds_list_size(list)) {
                    ds_list_delete(list, addedIndex);
                    addedIndex = -1;
                }
            }
        );
    };
    
    function ListRemove(list, index) {
        var removedValue = undefined;
        
        return new Command(
            function(data) {
                if (index >= 0 && index < ds_list_size(list)) {
                    removedValue = list[| index];
                    ds_list_delete(list, index);
                }
            },
            function(data) {
                if (removedValue != undefined) {
                    ds_list_insert(list, index, removedValue);
                    removedValue = undefined;
                }
            }
        );
    };
};
