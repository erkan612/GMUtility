/*********************************************************************************************
*                                        MIT License                                         *
*--------------------------------------------------------------------------------------------*
* Copyright (c) 2026 erkan612                                                                *
*                                                                                            *
* Permission is hereby granted, free of charge, to any person obtaining a copy of this       *
* software and associated documentation files (the "Software"), to deal in the Software      *
* without restriction, including without limitation the rights to use, copy, modify, merge,  *
* publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons *
* to whom the Software is furnished to do so, subject to the following conditions:           *
*                                                                                            *
* The above copyright notice and this permission notice shall be included in all copies or   *
* substantial portions of the Software.                                                      *
*                                                                                            *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,        *
* INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR   *
* PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE  *
* FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR       *
* OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER     *
* DEALINGS IN THE SOFTWARE.                                                                  *
**********************************************************************************************
*--------------------------------------------------------------------------------------------*
*   		**********************************************************************           *
*   		 ██████╗ ███╗   ███╗██╗   ██╗████████╗██╗██╗     ██╗████████╗██╗   ██╗		     *
*   		██╔════╝ ████╗ ████║██║   ██║╚══██╔══╝██║██║     ██║╚══██╔══╝╚██╗ ██╔╝		     *
*   		██║  ███╗██╔████╔██║██║   ██║   ██║   ██║██║     ██║   ██║    ╚████╔╝ 		     *
*   		██║   ██║██║╚██╔╝██║██║   ██║   ██║   ██║██║     ██║   ██║     ╚██╔╝  		     *
*   		╚██████╔╝██║ ╚═╝ ██║╚██████╔╝   ██║   ██║███████╗██║   ██║      ██║   		     *
*   		 ╚═════╝ ╚═╝     ╚═╝ ╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝   ╚═╝      ╚═╝   		     *
*   							Utility framework for GameMaker								 *
*   						             Version 1.0.0										 *
*   																                         *
*   						              by erkan612					                     *
*   		**********************************************************************           *
*********************************************************************************************/

#macro GMU_NAMESPACES_INIT globalvar MemoryTracker; MemoryTracker = new MemoryTracker(); globalvar InputManager; InputManager = new InputManager(); globalvar Input; Input = new Input(); globalvar MemoryLeakDetector; MemoryLeakDetector = new MemoryLeakDetector(); globalvar CommandManager; CommandManager = new CommandManager(); globalvar InterfaceAccess; InterfaceAccess = new InterfaceAccess(); globalvar IDGenerate; IDGenerate = new IDGenerate
#macro GMU_NAMESPACES_CLEANUP MemoryLeakDetector.Free(); CommandManager.Free(); InterfaceAccess.Free(); MemoryTracker.CleanupAll

// Memory Tracker - for data structures
function MemoryTracker() constructor {
    tracked_maps = ds_list_create();		// Track ds_maps
    tracked_lists = ds_list_create();		// Track ds_lists
    tracked_queues = ds_list_create();		// Track ds_queues
    tracked_stacks = ds_list_create();		// Track ds_stacks
    tracked_grids = ds_list_create();		// Track ds_grids
    tracked_priorities = ds_list_create();	// Track ds_priorities
    
    function RegisterMap(_map, _owner = undefined) {
        if (!is_undefined(_map) && ds_exists(_map, ds_type_map)) {
            ds_list_add(tracked_maps, { map: _map, owner: _owner });
        }
        return _map;
    };
    
    function RegisterList(_list, _owner = undefined) {
        if (!is_undefined(_list) && ds_exists(_list, ds_type_list)) {
            ds_list_add(tracked_lists, { list: _list, owner: _owner });
        }
        return _list;
    };
    
    function RegisterQueue(_queue, _owner = undefined) {
        if (!is_undefined(_queue) && ds_exists(_queue, ds_type_queue)) {
            ds_list_add(tracked_queues, { queue: _queue, owner: _owner });
        }
        return _queue;
    };
    
    function RegisterStack(_stack, _owner = undefined) {
        if (!is_undefined(_stack) && ds_exists(_stack, ds_type_stack)) {
            ds_list_add(tracked_stacks, { stack: _stack, owner: _owner });
        }
        return _stack;
    };
    
    function RegisterGrid(_grid, _owner = undefined) {
        if (!is_undefined(_grid) && ds_exists(_grid, ds_type_grid)) {
            ds_list_add(tracked_grids, { grid: _grid, owner: _owner });
        }
        return _grid;
    };
    
    function RegisterPriority(_priority, _owner = undefined) {
        if (!is_undefined(_priority) && ds_exists(_priority, ds_type_priority)) {
            ds_list_add(tracked_priorities, { priority: _priority, owner: _owner });
        }
        return _priority;
    };
    
    function Unregister(_struct) {
        var lists = [tracked_maps, tracked_lists, tracked_queues, tracked_stacks, tracked_grids, tracked_priorities];
        var keys = ["map", "list", "queue", "stack", "grid", "priority"];
        
        for (var i = 0; i < array_length(lists); i++) {
            var list = lists[i];
            var key = keys[i];
            for (var j = ds_list_size(list) - 1; j >= 0; j--) {
                var entry = list[| j];
                if (entry[$ key] == _struct) {
                    ds_list_delete(list, j);
                    return true;
                }
            }
        }
        return false;
    };
    
    function CleanupOwner(_owner) {
        var total_freed = 0;
        var cleanup_list = function(_list, _key) {
            for (var i = ds_list_size(_list) - 1; i >= 0; i--) {
                var entry = _list[| i];
                if (entry.owner == _owner) {
                    var struct = entry[$ _key];
                    if (ds_exists(struct, ds_type_map)) ds_map_destroy(struct);
                    else if (ds_exists(struct, ds_type_list)) ds_list_destroy(struct);
                    else if (ds_exists(struct, ds_type_queue)) ds_queue_destroy(struct);
                    else if (ds_exists(struct, ds_type_stack)) ds_stack_destroy(struct);
                    else if (ds_exists(struct, ds_type_grid)) ds_grid_destroy(struct);
                    else if (ds_exists(struct, ds_type_priority)) ds_priority_destroy(struct);
                    ds_list_delete(_list, i);
                    total_freed++;
                }
            }
        };
        
        cleanup_list(tracked_maps, "map");
        cleanup_list(tracked_lists, "list");
        cleanup_list(tracked_queues, "queue");
        cleanup_list(tracked_stacks, "stack");
        cleanup_list(tracked_grids, "grid");
        cleanup_list(tracked_priorities, "priority");
        
        return total_freed;
    };
    
    function CleanupAll() {
        self.total_freed = 0;
        
        var destroy_list = function(_list, _type, _key) {
            for (var i = 0; i < ds_list_size(_list); i++) {
                var entry = _list[| i];
                var struct = entry[$ _key];
                if (ds_exists(struct, _type)) {
                    switch(_type) {
                        case ds_type_map: ds_map_destroy(struct); break;
                        case ds_type_list: ds_list_destroy(struct); break;
                        case ds_type_queue: ds_queue_destroy(struct); break;
                        case ds_type_stack: ds_stack_destroy(struct); break;
                        case ds_type_grid: ds_grid_destroy(struct); break;
                        case ds_type_priority: ds_priority_destroy(struct); break;
                    }
                    MemoryTracker.total_freed++;
                }
            }
        };
        
        destroy_list(tracked_maps, ds_type_map, "map");
        destroy_list(tracked_lists, ds_type_list, "list");
        destroy_list(tracked_queues, ds_type_queue, "queue");
        destroy_list(tracked_stacks, ds_type_stack, "stack");
        destroy_list(tracked_grids, ds_type_grid, "grid");
        destroy_list(tracked_priorities, ds_type_priority, "priority");
        
        ds_list_destroy(tracked_maps);
        ds_list_destroy(tracked_lists);
        ds_list_destroy(tracked_queues);
        ds_list_destroy(tracked_stacks);
        ds_list_destroy(tracked_grids);
        ds_list_destroy(tracked_priorities);
        
    };
    
    function GetStats() {
        return {
            maps: ds_list_size(tracked_maps),
            lists: ds_list_size(tracked_lists),
            queues: ds_list_size(tracked_queues),
            stacks: ds_list_size(tracked_stacks),
            grids: ds_list_size(tracked_grids),
            priorities: ds_list_size(tracked_priorities),
            total: ds_list_size(tracked_maps) + ds_list_size(tracked_lists) + 
                   ds_list_size(tracked_queues) + ds_list_size(tracked_stacks) +
                   ds_list_size(tracked_grids) + ds_list_size(tracked_priorities)
        };
    };
};

function WeakCallback(_target, _method) constructor {
    Target = _target;
    Method = _method;
    
    function Execute(_data = undefined) {
        if (instance_exists(Target)) {
            return Method(Target, _data);
        } else if (is_struct(Target) && Target != undefined) {
            return Method(Target, _data);
        }
        return undefined;
    };
    
    function IsValid() {
        return (instance_exists(Target) || (is_struct(Target) && Target != undefined));
    };
};

function MemoryLeakDetector() constructor {
    snapshots = ds_map_create();
    
    function TakeSnapshot(_name = "snapshot_" + string(GetUnixDateTime(date_current_datetime()))) {
        var stats = MemoryTracker.GetStats();
        var snapshot = {
            name: _name,
            timestamp: GetUnixDateTime(date_current_datetime()),
            stats: { 
                maps: stats.maps, 
                lists: stats.lists, 
                queues: stats.queues,
                stacks: stats.stacks,
                grids: stats.grids,
                priorities: stats.priorities,
                total: stats.total
            }
        };
        snapshots[? _name] = snapshot;
        return snapshot;
    };
    
    function CompareSnapshots(_snapshot1, _snapshot2) {
        var s1 = snapshots[? _snapshot1];
        var s2 = snapshots[? _snapshot2];
        if (s1 == undefined || s2 == undefined) return undefined;
        
        return {
            maps_diff: s2.stats.maps - s1.stats.maps,
            lists_diff: s2.stats.lists - s1.stats.lists,
            queues_diff: s2.stats.queues - s1.stats.queues,
            stacks_diff: s2.stats.stacks - s1.stats.stacks,
            grids_diff: s2.stats.grids - s1.stats.grids,
            priorities_diff: s2.stats.priorities - s1.stats.priorities,
            total_diff: s2.stats.total - s1.stats.total
        };
    };
    
    function DetectLeaks(_baseline_snapshot) {
        var current = TakeSnapshot("current");
        var diff = CompareSnapshots(_baseline_snapshot, "current");
        if (diff.total_diff > 0) {
            show_debug_message("Potential memory leak detected! " + string(diff.total_diff) + " structures since baseline");
        }
        return diff;
    };
    
    function Free() {
        ds_map_destroy(snapshots);
    };
};

//  File Helpers & JSON
globalvar File;
File = {
    SaveString: function(filename, str) {
        var f = file_text_open_write(filename);
        if (f==-1) return false;
        file_text_write_string(f, str);
        file_text_close(f);
        return true;
    },
    LoadString: function(filename) {
        if (!file_exists(filename)) return "";
        var f = file_text_open_read(filename);
        if (f==-1) return "";
        var str = file_text_read_string(f);
        file_text_close(f);
        return str;
    },
    SaveJSON: function(filename, struct) {
        return File.SaveString(filename, json_stringify(struct));
    },
    LoadJSON: function(filename) {
        var str = File.LoadString(filename);
        if (str=="") return undefined;
        return json_parse(str);
    },
    Delete: function(filename) { return file_delete(filename); }
};

