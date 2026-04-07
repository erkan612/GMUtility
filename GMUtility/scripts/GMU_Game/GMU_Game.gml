//  Quest System
function Quest(_name, _description, _onComplete, _onFail) constructor {
    id = IDGenerate().GUID();
    name = _name; description = _description; state = "inactive"; tasks = new TaskTracer(); onComplete = _onComplete; onFail = _onFail; rewards = undefined;
    function AddTask(task) { tasks.AddTask(task); return self; };
    function Start() { if (state=="inactive") state="active"; return self; };
    function Fail() { if (state=="active") { state="failed"; if (is_callable(onFail)) onFail(self); } return self; };
    function Update() { if (state=="active") { if (tasks.AreAllComplete()) { state="completed"; if (is_callable(onComplete)) onComplete(self); } } return self; };
    function Reset() { tasks.Reset(); state="inactive"; return self; };
    function Free() { Reset(); tasks.Free(); };
};

function QuestManager() constructor {
    templates = ds_map_create_gmu();
    function AddTemplate(template) { if (!ds_map_exists(templates, template.id)) templates[? template.id] = template; return self; };
    function RemoveTemplate(id) { if (ds_map_exists(templates, id)) ds_map_delete(templates, id); return self; };
    function GetTemplate(id) { return ds_map_exists(templates, id) ? templates[? id] : undefined; };
    function SpawnQuest(templateID, customOnComplete = undefined, customOnFail = undefined) {
        var template = GetTemplate(templateID);
        if (template == undefined) return undefined;
        var newQuest = new Quest(template.name, template.description, customOnComplete ?? template.onComplete, customOnFail ?? template.onFail);
        var keys = ds_map_keys(template.tasks.tasks);
        for (var i=0;i<array_length(keys);i++) {
            var t = template.tasks.tasks[? keys[i]];
            newQuest.AddTask(new Task(t.id, t.goal, t.onComplete));
        }
        array_delete(keys,0,array_length(keys));
        return newQuest;
    };
    function Clear() { ds_map_clear(templates); return self; };
    function Free() { var arr = ds_map_values_to_array(templates); array_foreach(arr, function(q){ q.Free(); }); ds_map_destroy_gmu(templates); };
};

function QuestTracker() constructor {
    quests = ds_map_create_gmu();
    function AddQuest(quest) { if (!ds_map_exists(quests, quest.id)) quests[? quest.id] = quest; return self; };
    function RemoveQuest(id) { if (ds_map_exists(quests, id)) ds_map_delete(quests, id); return self; };
    function GetQuest(id) { return ds_map_exists(quests, id) ? quests[? id] : undefined; };
    function Update() { var keys = ds_map_keys(quests); for (var i=0;i<array_length(keys);i++) { var q = quests[? keys[i]]; if (q.state=="active") q.Update(); } array_delete(keys,0,array_length(keys)); return self; };
    function GetActiveQuests() { var result = [], keys = ds_map_keys(quests); for (var i=0;i<array_length(keys);i++) { var q = quests[? keys[i]]; if (q.state=="active") array_push(result, q); } array_delete(keys,0,array_length(keys)); return result; };
    function GetCompletedQuests() { var result = [], keys = ds_map_keys(quests); for (var i=0;i<array_length(keys);i++) { var q = quests[? keys[i]]; if (q.state=="completed") array_push(result, q); } array_delete(keys,0,array_length(keys)); return result; };
    function Clear() { ds_map_clear(quests); return self; };
    function Free() { var arr = ds_map_values_to_array(quests); array_foreach(arr, function(q){ q.Free(); }); ds_map_destroy_gmu(quests); };
};

function AchievementManager() constructor {
    achievements = ds_map_create_gmu();  // id -> {name, progress, goal, unlocked, hidden}
    callbacks = ds_map_create_gmu();     // id -> on_unlock callback
    unlocked_count = 0;

    function Add(_id, _name, _goal = 1, _hidden = false, _on_unlock = undefined) {
        achievements[? _id] = {
            name: _name,
            progress: 0,
            goal: _goal,
            unlocked: false,
            hidden: _hidden,
            unlocked_at: undefined
        };
    
        if (_on_unlock != undefined) {
            callbacks[? _id] = _on_unlock;
        }
        return self;
    };

    function Progress(_id, _amount = 1) {
        if (!ds_map_exists(achievements, _id)) return self;
        var ach = achievements[? _id];
        if (ach.unlocked) return self;
    
        ach.progress = min(ach.progress + _amount, ach.goal);
    
        if (ach.progress >= ach.goal) {
            Unlock(_id);
        }
        return self;
    };

    function Unlock(_id) {
        if (!ds_map_exists(achievements, _id)) return self;
        var ach = achievements[? _id];
        if (ach.unlocked) return self;
    
        ach.unlocked = true;
        ach.unlocked_at = current_time;
        unlocked_count++;
    
        if (!ach.hidden) {
            show_debug_message("[Achievemnt Manager] Achievement Unlocked: " + ach.name);
            // might do ui trigger here ?
        }
    
        if (ds_map_exists(callbacks, _id)) {
            callbacks[? _id](_id);
        }
    
        return self;
    };

    function IsUnlocked(_id) {
        return ds_map_exists(achievements, _id) ? achievements[? _id].unlocked : false;
    };

    function GetProgress(_id) {
        if (!ds_map_exists(achievements, _id)) return 0;
        var ach = achievements[? _id];
        return ach.goal > 0 ? ach.progress / ach.goal : 0;
    };

    function GetAll() {
        var result = {};
        var keys = ds_map_keys_to_array(achievements);
        for (var i = 0; i < array_length(keys); i++) {
            var _id = keys[i];
            var ach = achievements[? _id];
            result[$ _id] = {
                progress: ach.progress,
                unlocked: ach.unlocked,
                unlocked_at: ach.unlocked_at
            };
        }
        return result;
    };

    function LoadFromSave(_save_data) {
        var keys = variable_struct_get_names(_save_data);
        for (var i = 0; i < array_length(keys); i++) {
            var _id = keys[i];
            if (ds_map_exists(achievements, _id)) {
                var saved = _save_data[$ _id];
                achievements[? _id].progress = saved.progress;
                achievements[? _id].unlocked = saved.unlocked;
                achievements[? _id].unlocked_at = saved.unlocked_at;
                if (saved.unlocked) unlocked_count++;
            }
        }
        return self;
    };

    function Reset() {
        var keys = ds_map_keys_to_array(achievements);
        for (var i = 0; i < array_length(keys); i++) {
            var ach = achievements[? keys[i]];
            ach.progress = 0;
            ach.unlocked = false;
            ach.unlocked_at = undefined;
        }
        unlocked_count = 0;
        return self;
    };

    function GetStats() {
        return {
            total: ds_map_size(achievements),
            unlocked: unlocked_count,
            percent: unlocked_count / max(1, ds_map_size(achievements))
        };
    };

    function Free() {
        ds_map_destroy_gmu(achievements);
        ds_map_destroy_gmu(callbacks);
    };
}

