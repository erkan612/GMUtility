# GMU_Game

Game-specific progression systems for GameMaker. This module provides a quest system with task tracking and an achievement manager with progress tracking and unlock callbacks.

## Table of Contents

- [Overview](#overview)
- [Quest System](#quest-system)
  - [Task](#task)
  - [TaskTracer](#tasktracer)
  - [Quest](#quest)
  - [QuestManager](#questmanager)
  - [QuestTracker](#questtracker)
- [Achievement Manager](#achievement-manager)
  - [Adding Achievements](#adding-achievements)
  - [Updating Progress](#updating-progress)
  - [Querying Achievements](#querying-achievements)
  - [Save and Load](#save-and-load)
- [Complete Examples](#complete-examples)

---

## Overview

The GMU_Game module provides two major systems for game progression:

### Quest System
- Task-based quests with progress tracking
- Quest templates for reusable quest definitions
- Quest states (inactive, active, completed, failed)
- Completion and failure callbacks
- Quest manager for template management
- Quest tracker for active quest management

### Achievement Manager
- Progress-based achievements with goals
- Hidden achievements support
- Unlock callbacks
- Save/load integration
- Progress tracking and statistics

---

## Quest System

### TASK_STATE Enum

Task states for tracking progress.

```gml
enum TASK_STATE {
    PENDING,        // Not started yet
    ACTIVE,         // Currently in progress
    COMPLETED,      // Successfully finished
    FAILED,         // Failed to complete
    ABANDONED,      // Player gave up
    LOCKED,         // Cannot start yet (requirements not met)
    UNLOCKED,       // Available but not started
    REWARDED,       // Completed and rewards claimed
    HIDDEN,         // Secret task not yet revealed
    TIMED_OUT,      // Failed due to time limit
    SKIPPED,        // Bypassed (for debug or story reasons)
    REPEATABLE,     // Can be done multiple times
    ON_HOLD,        // Temporarily paused
    RESET,          // Reset to pending state
    UPGRADED        // Task was improved/replaced
}
```

---

### Task

A single objective within a quest.

#### Constructor

```gml
new Task(id, goal = 1, onComplete = undefined)
```

**Parameters:**
- `id` - Task identifier string
- `goal` - Target progress value (default: 1)
- `onComplete` - Optional callback when task completes

```gml
var task = new Task("collect_coins", 10, function(data) {
    show_debug_message("Collected all coins!");
});
```

---

#### Methods

##### SetState(state)

Sets the task state.

```gml
task.SetState(TASK_STATE.ACTIVE);
task.SetState(TASK_STATE.COMPLETED);
```

**Returns:** `self` for chaining.

---

##### AddProgress(amount = 1, data = undefined)

Adds progress to the task.

```gml
// Increment by 1
task.AddProgress();

// Increment by specific amount
task.AddProgress(5);

// Pass data to completion callback
task.AddProgress(1, { source: "enemy" });
```

**Returns:** `self` for chaining.

---

##### Reset()

Resets the task to pending state with zero progress.

```gml
task.Reset();
```

**Returns:** `self` for chaining.

---

##### IsComplete()

Checks if the task is complete.

```gml
if (task.IsComplete()) {
    // Task finished
}
```

**Returns:** `true` if state is COMPLETED.

---

##### GetProgressRatio()

Gets the current progress as a ratio (0-1).

```gml
var percent = task.GetProgressRatio() * 100;
draw_text(x, y, $"Progress: {percent}%");
```

**Returns:** Float between 0.0 and 1.0.

---

##### Properties

```gml
task.id        // Task identifier
task.state     // Current TASK_STATE
task.progress  // Current progress value
task.goal      // Target progress value
task.onComplete // Completion callback
```

---

### TaskTracer

Manages a collection of tasks.

#### Constructor

```gml
new TaskTracer()
```

```gml
var tasks = new TaskTracer();
```

---

#### Methods

##### AddTask(task)

Adds a task to the tracer.

```gml
tasks.AddTask(new Task("kill_goblins", 5));
tasks.AddTask(new Task("collect_herbs", 3));
tasks.AddTask(new Task("reach_location", 1));
```

**Returns:** `self` for chaining.

---

##### RemoveTask(id)

Removes a task by ID.

```gml
tasks.RemoveTask("kill_goblins");
```

**Returns:** `self` for chaining.

---

##### GetTask(id)

Gets a task by ID.

```gml
var task = tasks.GetTask("collect_herbs");
if (task != undefined) {
    task.AddProgress();
}
```

**Returns:** Task instance or `undefined`.

---

##### AreAllComplete()

Checks if all tasks are complete.

```gml
if (tasks.AreAllComplete()) {
    // All quest objectives met
    CompleteQuest();
}
```

**Returns:** `true` if all tasks are COMPLETED.

---

##### Clear()

Clears all tasks.

```gml
tasks.Clear();
```

**Returns:** `self` for chaining.

---

##### Free()

Cleans up the task tracer.

```gml
tasks.Free();
```

---

### Quest

A complete quest with multiple tasks.

#### Constructor

```gml
new Quest(name, description, onComplete, onFail)
```

**Parameters:**
- `name` - Quest name
- `description` - Quest description
- `onComplete` - Callback when quest completes
- `onFail` - Callback when quest fails

```gml
var quest = new Quest(
    "The Goblin Threat",
    "Clear the forest of goblins and collect their stolen goods.",
    function(quest) {
        GiveReward(quest.rewards);
        show_message("Quest Complete!");
    },
    function(quest) {
        show_message("Quest Failed!");
    }
);
```

---

#### Methods

##### AddTask(task)

Adds a task to the quest.

```gml
quest.AddTask(new Task("kill_goblins", 5));
quest.AddTask(new Task("collect_goods", 3));
quest.AddTask(new Task("rescue_villager", 1));
```

**Returns:** `self` for chaining.

---

##### Start()

Starts the quest (changes state from inactive to active).

```gml
quest.Start();
```

**Returns:** `self` for chaining.

---

##### Fail()

Fails the quest and calls the onFail callback.

```gml
quest.Fail();
```

**Returns:** `self` for chaining.

---

##### Update()

Updates the quest (checks for completion).

```gml
// Call each frame for active quests
quest.Update();
```

**Returns:** `self` for chaining.

---

##### Reset()

Resets the quest and all tasks to initial state.

```gml
quest.Reset();
```

**Returns:** `self` for chaining.

---

##### Free()

Cleans up the quest.

```gml
quest.Free();
```

---

##### Properties

```gml
quest.id           // Unique GUID
quest.name         // Quest name
quest.description  // Quest description
quest.state        // "inactive", "active", "completed", "failed"
quest.tasks        // TaskTracer instance
quest.rewards      // Optional rewards data
quest.onComplete   // Completion callback
quest.onFail       // Failure callback
```

---

### QuestManager

Manages quest templates and spawns quest instances.

#### Constructor

```gml
new QuestManager()
```

```gml
var quest_manager = new QuestManager();
```

---

#### Methods

##### AddTemplate(template)

Adds a quest template.

```gml
// Create a template quest
var template = new Quest(
    "Gather Resources",
    "Collect wood and stone for the village.",
    undefined,
    undefined
);
template.AddTask(new Task("collect_wood", 10));
template.AddTask(new Task("collect_stone", 5));

quest_manager.AddTemplate(template);
```

**Returns:** `self` for chaining.

---

##### RemoveTemplate(id)

Removes a quest template by ID.

```gml
quest_manager.RemoveTemplate(template.id);
```

**Returns:** `self` for chaining.

---

##### GetTemplate(id)

Gets a quest template by ID.

```gml
var template = quest_manager.GetTemplate(quest_id);
```

**Returns:** Quest template or `undefined`.

---

##### SpawnQuest(templateID, customOnComplete = undefined, customOnFail = undefined)

Creates a new quest instance from a template.

```gml
// Spawn with template callbacks
var quest = quest_manager.SpawnQuest(template.id);

// Spawn with custom callbacks
var quest = quest_manager.SpawnQuest(template.id,
    function(q) {
        // Custom completion logic
        player.xp += 100;
    },
    function(q) {
        // Custom failure logic
        player.reputation -= 10;
    }
);
```

**Returns:** New Quest instance or `undefined`.

---

##### Clear()

Clears all templates.

```gml
quest_manager.Clear();
```

**Returns:** `self` for chaining.

---

##### Free()

Cleans up the quest manager.

```gml
quest_manager.Free();
```

---

### QuestTracker

Tracks active and completed quests for a player.

#### Constructor

```gml
new QuestTracker()
```

```gml
var quest_tracker = new QuestTracker();
```

---

#### Methods

##### AddQuest(quest)

Adds a quest to the tracker.

```gml
var quest = quest_manager.SpawnQuest("gather_resources");
quest_tracker.AddQuest(quest);
```

**Returns:** `self` for chaining.

---

##### RemoveQuest(id)

Removes a quest by ID.

```gml
quest_tracker.RemoveQuest(quest.id);
```

**Returns:** `self` for chaining.

---

##### GetQuest(id)

Gets a quest by ID.

```gml
var quest = quest_tracker.GetQuest(quest_id);
```

**Returns:** Quest instance or `undefined`.

---

##### Update()

Updates all active quests.

```gml
// In Step event
quest_tracker.Update();
```

**Returns:** `self` for chaining.

---

##### GetActiveQuests()

Gets all active quests.

```gml
var active = quest_tracker.GetActiveQuests();
for (var i = 0; i < array_length(active); i++) {
    draw_text(10, 10 + i * 20, active[i].name);
}
```

**Returns:** Array of active Quest instances.

---

##### GetCompletedQuests()

Gets all completed quests.

```gml
var completed = quest_tracker.GetCompletedQuests();
show_debug_message($"Completed {array_length(completed)} quests");
```

**Returns:** Array of completed Quest instances.

---

##### Clear()

Clears all quests.

```gml
quest_tracker.Clear();
```

**Returns:** `self` for chaining.

---

##### Free()

Cleans up the quest tracker.

```gml
quest_tracker.Free();
```

---

## Achievement Manager

### AchievementManager

Manages achievements with progress tracking and unlock callbacks.

#### Constructor

```gml
new AchievementManager()
```

```gml
var achievements = new AchievementManager();
```

---

### Adding Achievements

#### Add(id, name, goal = 1, hidden = false, on_unlock = undefined)

Adds a new achievement.

```gml
// Simple achievement
achievements.Add("first_kill", "First Blood", 1);

// Achievement with goal
achievements.Add("goblin_slayer", "Goblin Slayer", 50, false, function(id) {
    show_message("Achievement Unlocked: Goblin Slayer!");
    UnlockReward("goblin_slayer_sword");
});

// Hidden achievement
achievements.Add("secret_ending", "???", 1, true, function(id) {
    show_message("Secret Achievement: True Ending Unlocked!");
});
```

**Parameters:**
- `id` - Achievement identifier
- `name` - Display name
- `goal` - Progress required to unlock (default: 1)
- `hidden` - Whether achievement is hidden (default: false)
- `on_unlock` - Optional callback when unlocked

**Returns:** `self` for chaining.

---

### Updating Progress

#### Progress(id, amount = 1)

Adds progress to an achievement.

```gml
// Increment by 1
achievements.Progress("first_kill");

// Increment by specific amount
achievements.Progress("goblin_slayer", 3);

// Will auto-unlock when progress reaches goal
achievements.Progress("collector", 1);
```

**Returns:** `self` for chaining.

---

#### Unlock(id)

Manually unlocks an achievement.

```gml
achievements.Unlock("special_event");
```

**Returns:** `self` for chaining.

---

### Querying Achievements

#### IsUnlocked(id)

Checks if an achievement is unlocked.

```gml
if (achievements.IsUnlocked("goblin_slayer")) {
    // Player has this achievement
}
```

**Returns:** `true` if unlocked.

---

#### GetProgress(id)

Gets the current progress ratio (0-1).

```gml
var progress = achievements.GetProgress("goblin_slayer");
draw_sprite_ext(spr_progress_bar, 0, x, y, progress, 1, 0, c_white, 1);
```

**Returns:** Float between 0.0 and 1.0.

---

#### GetAll()

Gets all achievements with their progress.

```gml
var all = achievements.GetAll();
var keys = variable_struct_get_names(all);
for (var i = 0; i < array_length(keys); i++) {
    var ach = all[$ keys[i]];
    show_debug_message($"{keys[i]}: {ach.progress} - Unlocked: {ach.unlocked}");
}
```

**Returns:** Struct with achievement data.

---

#### GetStats()

Gets achievement statistics.

```gml
var stats = achievements.GetStats();
show_debug_message($"Total: {stats.total}");
show_debug_message($"Unlocked: {stats.unlocked}");
show_debug_message($"Percent: {stats.percent * 100}%");
```

**Returns:** Struct with `total`, `unlocked`, and `percent`.

---

### Save and Load

#### LoadFromSave(save_data)

Loads achievement progress from save data.

```gml
var save_data = File.LoadJSON("save.json");
if (save_data != undefined && save_data.achievements != undefined) {
    achievements.LoadFromSave(save_data.achievements);
}
```

**Returns:** `self` for chaining.

---

#### Reset()

Resets all achievements to initial state.

```gml
achievements.Reset();
```

**Returns:** `self` for chaining.

---

#### Free()

Cleans up the achievement manager.

```gml
achievements.Free();
```

---

## Complete Examples

### Example 1: Simple Quest System Setup

```gml
// Create Event - Setup quest system
global.quest_manager = new QuestManager();
global.quest_tracker = new QuestTracker();

// Create quest templates
function CreateQuestTemplates() {
    // Kill quest template
    var kill_template = new Quest(
        "Exterminator",
        "Eliminate the threat.",
        undefined,
        undefined
    );
    kill_template.AddTask(new Task("kill_enemies", 5));
    global.quest_manager.AddTemplate(kill_template);
    
    // Collection quest template
    var collect_template = new Quest(
        "Gatherer",
        "Collect the required items.",
        undefined,
        undefined
    );
    collect_template.AddTask(new Task("collect_items", 10));
    global.quest_manager.AddTemplate(collect_template);
    
    // Multi-task quest template
    var rescue_template = new Quest(
        "Rescue Mission",
        "Save the villagers and defeat the bandits.",
        function(q) {
            player.reputation += 50;
            show_message("You saved the village!");
        },
        function(q) {
            player.reputation -= 20;
            show_message("You failed to save the village...");
        }
    );
    rescue_template.AddTask(new Task("rescue_villagers", 3));
    rescue_template.AddTask(new Task("defeat_bandit_leader", 1));
    rescue_template.AddTask(new Task("recover_stolen_goods", 5));
    global.quest_manager.AddTemplate(rescue_template);
}

// Accept quest from NPC
function AcceptQuest(template_id) {
    var quest = global.quest_manager.SpawnQuest(template_id);
    quest.Start();
    global.quest_tracker.AddQuest(quest);
    return quest;
}

// Step Event - Update quests
global.quest_tracker.Update();

// Track quest progress
function OnEnemyKilled(enemy_type) {
    var active_quests = global.quest_tracker.GetActiveQuests();
    for (var i = 0; i < array_length(active_quests); i++) {
        var task = active_quests[i].tasks.GetTask("kill_enemies");
        if (task != undefined) {
            task.AddProgress();
        }
        
        if (enemy_type == "bandit_leader") {
            var leader_task = active_quests[i].tasks.GetTask("defeat_bandit_leader");
            if (leader_task != undefined) {
                leader_task.AddProgress();
            }
        }
    }
}

function OnItemCollected(item_type) {
    var active_quests = global.quest_tracker.GetActiveQuests();
    for (var i = 0; i < array_length(active_quests); i++) {
        var task = active_quests[i].tasks.GetTask("collect_items");
        if (task != undefined) {
            task.AddProgress();
        }
        
        if (item_type == "stolen_goods") {
            var goods_task = active_quests[i].tasks.GetTask("recover_stolen_goods");
            if (goods_task != undefined) {
                goods_task.AddProgress();
            }
        }
    }
}

function OnVillagerRescued() {
    var active_quests = global.quest_tracker.GetActiveQuests();
    for (var i = 0; i < array_length(active_quests); i++) {
        var task = active_quests[i].tasks.GetTask("rescue_villagers");
        if (task != undefined) {
            task.AddProgress();
        }
    }
}
```

### Example 2: Quest UI Display

```gml
// Draw Event - Quest Journal
function DrawQuestJournal(x, y) {
    var active = global.quest_tracker.GetActiveQuests();
    
    draw_set_color(c_white);
    draw_text(x, y, "=== ACTIVE QUESTS ===");
    y += 30;
    
    for (var i = 0; i < array_length(active); i++) {
        var quest = active[i];
        
        // Quest title
        draw_set_color(c_yellow);
        draw_text(x, y, quest.name);
        y += 20;
        
        // Quest description
        draw_set_color(c_gray);
        draw_text(x + 10, y, quest.description);
        y += 20;
        
        // Tasks
        var task_keys = ds_map_keys_to_array(quest.tasks.tasks);
        for (var j = 0; j < array_length(task_keys); j++) {
            var task = quest.tasks.GetTask(task_keys[j]);
            var progress_text = $"{task.progress}/{task.goal}";
            
            if (task.IsComplete()) {
                draw_set_color(c_green);
                draw_text(x + 20, y, $"[✓] {task.id}: {progress_text}");
            } else {
                draw_set_color(c_white);
                draw_text(x + 20, y, $"[ ] {task.id}: {progress_text}");
                
                // Progress bar
                var bar_width = 100;
                var progress_width = bar_width * task.GetProgressRatio();
                draw_rectangle(x + 200, y, x + 200 + bar_width, y + 10, true);
                draw_set_color(c_blue);
                draw_rectangle(x + 200, y, x + 200 + progress_width, y + 10, false);
            }
            y += 15;
        }
        
        y += 10;
    }
    
    if (array_length(active) == 0) {
        draw_set_color(c_gray);
        draw_text(x, y, "No active quests");
    }
}
```

### Example 3: Achievement System Integration

```gml
// Create Event - Setup achievements
global.achievements = new AchievementManager();

function SetupAchievements() {
    // Combat achievements
    global.achievements.Add("first_blood", "First Blood", 1, false, OnAchievementUnlocked);
    global.achievements.Add("slayer", "Slayer", 100, false, OnAchievementUnlocked);
    global.achievements.Add("boss_slayer", "Boss Slayer", 10, false, OnAchievementUnlocked);
    
    // Collection achievements
    global.achievements.Add("collector", "Collector", 50, false, OnAchievementUnlocked);
    global.achievements.Add("completionist", "Completionist", 200, true, OnAchievementUnlocked);
    
    // Exploration achievements
    global.achievements.Add("explorer", "Explorer", 20, false, OnAchievementUnlocked);
    global.achievements.Add("secret_finder", "???", 5, true, function(id) {
        show_message("Secret Achievement: Master Explorer!");
        OnAchievementUnlocked(id);
    });
}

function OnAchievementUnlocked(id) {
    var ach = global.achievements.achievements[? id];
    
    // Show notification
    var notification = instance_create_layer(0, 0, "UI", obj_achievement_popup);
    notification.text = ach.name;
    notification.icon = GetAchievementIcon(id);
    
    // Play sound
    AudioManager.PlaySFX(snd_achievement);
    
    // Save progress
    SaveGame();
}

// Track achievement progress
function OnEnemyKilled() {
    total_kills++;
    global.achievements.Progress("first_blood");
    global.achievements.Progress("slayer");
}

function OnBossKilled() {
    global.achievements.Progress("boss_slayer");
}

function OnItemCollected() {
    total_collected++;
    global.achievements.Progress("collector");
    global.achievements.Progress("completionist");
}

function OnAreaDiscovered() {
    global.achievements.Progress("explorer");
}

function OnSecretFound() {
    global.achievements.Progress("secret_finder");
}

// Achievement popup object
// Create Event
function AchievementPopup(_text, _icon) {
    text = _text;
    icon = _icon;
    y = -50;
    target_y = 10;
    alpha = 0;
    timer = 180;
}

// Step Event
y = lerp(y, target_y, 0.2);
alpha = min(alpha + 0.05, 1);
timer--;

if (timer <= 0) {
    target_y = -50;
    if (y <= -40) {
        instance_destroy();
    }
}

// Draw Event
draw_set_alpha(alpha);
draw_set_color(c_black);
draw_rectangle(100, y, 500, y + 40, false);
draw_set_color(c_gold);
draw_rectangle(100, y, 500, y + 40, true);

if (icon != -1) {
    draw_sprite(icon, 0, 110, y + 5);
}

draw_set_color(c_white);
draw_set_font(fnt_achievement);
draw_text(150, y + 10, "Achievement Unlocked!");
draw_text(150, y + 25, text);

draw_set_alpha(1);
```

### Example 4: Save/Load Integration

```gml
function SaveGame(slot) {
    var save_data = {
        version: "1.0",
        timestamp: GetUnixDateTime(date_current_datetime()),
        player: {
            name: player_name,
            level: player_level,
            xp: player_xp,
            position: { x: obj_player.x, y: obj_player.y }
        },
        quests: SerializeQuests(),
        achievements: global.achievements.GetAll()
    };
    
    return File.SaveJSON($"save_slot_{slot}.json", save_data);
}

function SerializeQuests() {
    var quest_data = {
        active: [],
        completed: []
    };
    
    // Serialize active quests
    var active = global.quest_tracker.GetActiveQuests();
    for (var i = 0; i < array_length(active); i++) {
        var q = active[i];
        var serialized = {
            id: q.id,
            template_id: q.template_id,
            state: q.state,
            tasks: {}
        };
        
        var task_keys = ds_map_keys_to_array(q.tasks.tasks);
        for (var j = 0; j < array_length(task_keys); j++) {
            var task = q.tasks.GetTask(task_keys[j]);
            serialized.tasks[$ task.id] = {
                state: task.state,
                progress: task.progress
            };
        }
        
        array_push(quest_data.active, serialized);
    }
    
    // Serialize completed quests
    var completed = global.quest_tracker.GetCompletedQuests();
    for (var i = 0; i < array_length(completed); i++) {
        array_push(quest_data.completed, completed[i].id);
    }
    
    return quest_data;
}

function LoadGame(slot) {
    var save_data = File.LoadJSON($"save_slot_{slot}.json");
    if (save_data == undefined) return false;
    
    // Load player data
    player_name = save_data.player.name;
    player_level = save_data.player.level;
    player_xp = save_data.player.xp;
    obj_player.x = save_data.player.position.x;
    obj_player.y = save_data.player.position.y;
    
    // Load achievements
    global.achievements.LoadFromSave(save_data.achievements);
    
    // Load quests
    DeserializeQuests(save_data.quests);
    
    return true;
}

function DeserializeQuests(quest_data) {
    global.quest_tracker.Clear();
    
    // Restore active quests
    for (var i = 0; i < array_length(quest_data.active); i++) {
        var q_data = quest_data.active[i];
        var template = global.quest_manager.GetTemplate(q_data.template_id);
        
        if (template != undefined) {
            var quest = global.quest_manager.SpawnQuest(q_data.template_id);
            quest.id = q_data.id;
            quest.state = q_data.state;
            
            // Restore task progress
            var task_keys = variable_struct_get_names(q_data.tasks);
            for (var j = 0; j < array_length(task_keys); j++) {
                var task_data = q_data.tasks[$ task_keys[j]];
                var task = quest.tasks.GetTask(task_keys[j]);
                if (task != undefined) {
                    task.state = task_data.state;
                    task.progress = task_data.progress;
                }
            }
            
            global.quest_tracker.AddQuest(quest);
        }
    }
}
```

### Example 5: Daily Quest System

```gml
function DailyQuestManager() constructor {
    daily_quests = [];
    last_refresh = 0;
    refresh_interval = 86400; // 24 hours in seconds
    
    var templates = [
        "daily_kills",
        "daily_collection",
        "daily_exploration"
    ];
    
    function CheckRefresh() {
        var current_time = GetUnixDateTime(date_current_datetime());
        
        if (current_time - last_refresh >= refresh_interval) {
            RefreshDailyQuests();
            last_refresh = current_time;
        }
    }
    
    function RefreshDailyQuests() {
        // Clear old daily quests
        for (var i = 0; i < array_length(daily_quests); i++) {
            global.quest_tracker.RemoveQuest(daily_quests[i].id);
        }
        daily_quests = [];
        
        // Generate new daily quests
        var num_quests = 3;
        for (var i = 0; i < num_quests; i++) {
            var template_id = templates[irandom(array_length(templates) - 1)];
            var quest = global.quest_manager.SpawnQuest(template_id,
                function(q) {
                    // Daily quest reward
                    player.gold += 100;
                    player.xp += 50;
                    show_message($"Daily quest complete! +100 gold, +50 XP");
                }
            );
            
            quest.Start();
            global.quest_tracker.AddQuest(quest);
            array_push(daily_quests, quest);
        }
    }
    
    function GetTimeUntilRefresh() {
        var current_time = GetUnixDateTime(date_current_datetime());
        return max(0, refresh_interval - (current_time - last_refresh));
    }
    
    function FormatTimeRemaining(seconds) {
        var hours = floor(seconds / 3600);
        var minutes = floor((seconds % 3600) / 60);
        return $"{hours}h {minutes}m";
    }
    
    return {
        CheckRefresh: CheckRefresh,
        RefreshDailyQuests: RefreshDailyQuests,
        GetTimeUntilRefresh: GetTimeUntilRefresh,
        FormatTimeRemaining: FormatTimeRemaining
    };
}

// Usage
var daily_manager = new DailyQuestManager();

// In Step event
daily_manager.CheckRefresh();

// Display time until refresh
var time_left = daily_manager.GetTimeUntilRefresh();
draw_text(10, 10, $"Daily quests refresh in: {daily_manager.FormatTimeRemaining(time_left)}");
```
