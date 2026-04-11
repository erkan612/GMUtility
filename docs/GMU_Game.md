

# GMU_Game

Game-specific progression systems for GameMaker. This module provides a complete quest system with prerequisites, objectives, rewards, and chains, plus an achievement manager with progress tracking and unlock callbacks. All systems revolve around a central `GameContext` dependency container.

## Table of Contents

- [Overview](#overview)
- [GameContext](#gamecontext)
  - [Built-in Systems](#built-in-systems)
  - [Player Management](#player-management)
  - [Inventory Management](#inventory-management)
  - [Currency Management](#currency-management)
  - [Flag Management](#flag-management)
  - [Statistics & Reputation](#statistics--reputation)
  - [Serialization](#serialization)
- [Quest System](#quest-system)
  - [QUEST_STATE Enum](#quest_state-enum)
  - [QUEST_TYPE Enum](#quest_type-enum)
  - [QuestObjective](#questobjective)
  - [QuestPrerequisite](#questprerequisite)
  - [Reward & RewardBundle](#reward--rewardbundle)
  - [Quest](#quest)
  - [QuestChain](#questchain)
  - [QuestManager](#questmanager)
  - [QuestTracker](#questtracker)
- [Achievement Manager](#achievement-manager)
- [Built-in Game Systems](#built-in-game-systems)
  - [SimplePlayer](#simpleplayer)
  - [SimpleInventory](#simpleinventory)
  - [SimpleCurrency](#simplecurrency)
- [Complete Examples](#complete-examples)

---

## Overview

The GMU_Game module provides a complete game progression framework:

### Quest System
- Multi-objective quests with prerequisites
- Quest chains and sequential progression
- Reward bundles (XP, currency, items, unlocks)
- Optional and hidden objectives
- Time-limited quests with expiration
- Quest giver and dialogue integration
- Full serialization support

### Achievement Manager
- Progress-based achievements with goals
- Hidden achievements support
- Category organization
- Statistic tracking
- Unlock callbacks
- Save/load integration

### GameContext
- Central dependency container
- Built-in player, inventory, currency, and flag systems
- Statistic and reputation tracking
- Event callbacks for rewards and progression
- Full serialization support

---

## GameContext

The `GameContext` class serves as the central dependency hub for all game systems. It provides a unified interface for player data, inventory, currency, flags, and progression tracking.

### Constructor

```gml
new GameContext()
```

```gml
var Game = new GameContext();
Game.InitializeDefaults();  // Creates default systems if not provided
```

---

### Built-in Systems

The `InitializeDefaults()` method creates default implementations for any system not explicitly provided:

```gml
function InitializeDefaults() {
    if (player == undefined) player = new SimplePlayer();
    if (inventory == undefined) inventory = new SimpleInventory();
    if (currency == undefined) currency = new SimpleCurrency();
    if (flags == undefined) flags = new FlagPatrol();
    if (questManager == undefined) questManager = new QuestManager();
    if (questTracker == undefined) questTracker = new QuestTracker();
    if (achievementManager == undefined) achievementManager = new AchievementManager();
    return self;
}
```

---

### Player Management

#### GetPlayerLevel()

Gets the current player level.

```gml
var level = Game.GetPlayerLevel();
```

**Returns:** Player level (default: 1)

---

#### GetPlayerPosition()

Gets the current player position.

```gml
var pos = Game.GetPlayerPosition();
show_debug_message($"Player at: {pos.x}, {pos.y}");
```

**Returns:** Struct with `x` and `y` properties.

---

#### AddExperience(amount)

Adds experience to the player.

```gml
Game.AddExperience(100);
```

**Returns:** `true` if experience was added.

---

### Inventory Management

#### HasItem(itemId, count)

Checks if the player has a specific item.

```gml
if (Game.HasItem("health_potion", 3)) {
    // Player has at least 3 potions
}
```

**Returns:** `true` if item count met.

---

#### GetItemCount(itemId)

Gets the count of a specific item.

```gml
var potionCount = Game.GetItemCount("health_potion");
```

**Returns:** Number of items owned.

---

#### AddItem(itemId, count)

Adds items to inventory.

```gml
Game.AddItem("health_potion", 5);
Game.AddItem("ancient_sword", 1);
```

**Returns:** `true` if items were added.

---

#### RemoveItem(itemId, count)

Removes items from inventory.

```gml
if (Game.RemoveItem("health_potion", 1)) {
    // Potion consumed
}
```

**Returns:** `true` if items were removed.

---

### Currency Management

#### GetCurrency(currencyId = "default")

Gets current currency amount.

```gml
var gold = Game.GetCurrency("gold");
var gems = Game.GetCurrency("gems");
```

**Returns:** Currency amount (default: 0)

---

#### AddCurrency(amount, currencyId = "default")

Adds currency.

```gml
Game.AddCurrency(100, "gold");
Game.AddCurrency(5, "gems");
```

**Returns:** `true` if currency was added.

---

#### SpendCurrency(amount, currencyId = "default")

Spends currency.

```gml
if (Game.SpendCurrency(50, "gold")) {
    // Purchase successful
}
```

**Returns:** `true` if sufficient funds.

---

### Flag Management

The GameContext uses `FlagPatrol` for bitwise flag operations.

#### HasFlag(flagValue)

Checks if a flag is set.

```gml
if (Game.HasFlag(GAME_FLAG.TUTORIAL_COMPLETE)) {
    // Skip tutorial
}
```

**Returns:** `true` if flag is set.

---

#### SetFlag(flagValue)

Sets a flag.

```gml
Game.SetFlag(GAME_FLAG.MET_BLACKSMITH);
Game.SetFlag(GAME_FLAG.FOUND_ANCIENT_SWORD);
```

**Returns:** `self` for chaining.

---

#### ClearFlag(flagValue)

Clears a flag.

```gml
Game.ClearFlag(GAME_FLAG.MET_BLACKSMITH);
```

**Returns:** `self` for chaining.

---

#### ToggleFlag(flagValue)

Toggles a flag.

```gml
Game.ToggleFlag(GAME_FLAG.UNLOCKED_FAST_TRAVEL);
```

**Returns:** `self` for chaining.

---

#### GetFlags()

Gets the raw flags integer value (for saving).

```gml
var rawFlags = Game.GetFlags();
```

**Returns:** Integer bitmask of all flags.

---

#### SetFlags(value)

Sets all flags from a raw integer value (for loading).

```gml
Game.SetFlags(7);  // Sets flags for bits 1, 2, 4
```

**Returns:** `self` for chaining.

---

#### HasAllFlags(flagValues)

Checks if all specified flags are set.

```gml
if (Game.HasAllFlags([GAME_FLAG.FOUND_SWORD, GAME_FLAG.DEFEATED_BOSS])) {
    // Unlock final dungeon
}
```

**Returns:** `true` if all flags are set.

---

#### HasAnyFlag(flagValues)

Checks if any specified flag is set.

```gml
if (Game.HasAnyFlag([GAME_FLAG.FOUND_KEY, GAME_FLAG.PICKED_LOCK])) {
    // Player can open door
}
```

**Returns:** `true` if any flag is set.

---

### Statistics & Reputation

#### IncrementStat(statId, amount = 1)

Increments a tracked statistic.

```gml
Game.IncrementStat("enemies_killed");
Game.IncrementStat("distance_traveled", 10);
```

**Returns:** `self` for chaining.

---

#### GetStat(statId)

Gets a statistic value.

```gml
var kills = Game.GetStat("enemies_killed");
```

**Returns:** Statistic value.

---

#### SetStat(statId, value)

Sets a statistic value.

```gml
Game.SetStat("highest_combo", 50);
```

**Returns:** `self` for chaining.

---

#### GetReputation(factionId)

Gets reputation with a faction.

```gml
var rep = Game.GetReputation("thieves_guild");
```

**Returns:** Reputation value.

---

#### AddReputation(factionId, amount)

Adds reputation with a faction.

```gml
Game.AddReputation("thieves_guild", 10);
```

**Returns:** `self` for chaining.

---

#### HasReputation(factionId, required)

Checks if reputation meets requirement.

```gml
if (Game.HasReputation("thieves_guild", 50)) {
    // Access to special merchant
}
```

**Returns:** `true` if reputation met.

---

### Quest System Integration

#### UnlockQuest(questId)

Unlocks a quest.

```gml
Game.UnlockQuest("ancient_sword_quest");
```

**Returns:** `self` for chaining.

---

#### IsQuestCompleted(questId)

Checks if a quest is completed.

```gml
if (Game.IsQuestCompleted("tutorial")) {
    // Skip tutorial
}
```

**Returns:** `true` if quest completed.

---

#### GetQuest(questId)

Gets a quest instance.

```gml
var quest = Game.GetQuest("main_quest");
if (quest != undefined) {
    show_debug_message($"Quest progress: {quest.GetProgressRatio() * 100}%");
}
```

**Returns:** Quest instance or `undefined`.

---

### Achievement System Integration

#### UnlockAchievement(achievementId)

Unlocks an achievement.

```gml
Game.UnlockAchievement("first_kill");
```

**Returns:** `self` for chaining.

---

#### ProgressAchievement(achievementId, amount = 1)

Adds progress to an achievement.

```gml
Game.ProgressAchievement("slayer", 1);
Game.ProgressAchievement("collector", 5);
```

**Returns:** `self` for chaining.

---

### Reward Handling

#### GiveReward(type, value, id = undefined)

Gives a reward to the player.

```gml
Game.GiveReward(REWARD_TYPE.EXPERIENCE, 100);
Game.GiveReward(REWARD_TYPE.CURRENCY, 500, "gold");
Game.GiveReward(REWARD_TYPE.ITEM, 1, "ancient_sword");
Game.GiveReward(REWARD_TYPE.UNLOCK_QUEST, 1, "new_quest_id");
```

**Returns:** `self` for chaining.

---

### Serialization

#### Serialize()

Serializes the GameContext state.

```gml
var data = Game.Serialize();
File.SaveJSON("save.json", { context: data });
```

**Returns:** Struct with serialized data.

---

#### Deserialize(data)

Deserializes the GameContext state.

```gml
var saveData = File.LoadJSON("save.json");
Game.Deserialize(saveData.context);
```

**Returns:** `self` for chaining.

---

### Update

#### Update(deltaTime = 1/60)

Updates the GameContext (quests, time tracking).

```gml
// In Step event
Game.Update(1 / game_get_speed(gamespeed_fps));
```

**Returns:** `self` for chaining.

---

### Callbacks

The GameContext supports several optional callbacks:

```gml
Game.onRewardGiven = function(type, value, id) {
    show_debug_message($"Reward: {type} - {value} {id}");
};

Game.onQuestStateChanged = function(quest, oldState, newState) {
    show_debug_message($"Quest {quest.name}: {oldState} -> {newState}");
};

Game.onAchievementUnlocked = function(achievementId) {
    show_message($"Achievement Unlocked: {achievementId}");
};

Game.onStatChanged = function(statId, oldValue, newValue) {
    show_debug_message($"Stat {statId}: {oldValue} -> {newValue}");
};
```

---

### Cleanup

#### Free()

Cleans up the GameContext.

```gml
Game.Free();
```

---

## Quest System

### QUEST_STATE Enum

Quest states for tracking progression.

```gml
enum QUEST_STATE {
    INACTIVE,           // Not started
    ACTIVE,             // Currently in progress
    COMPLETED,          // Finished successfully
    FAILED,             // Failed
    ABANDONED,          // Player gave up
    LOCKED,             // Prerequisites not met
    AVAILABLE           // Can be accepted
}
```

---

### QUEST_TYPE Enum

Quest types for categorization.

```gml
enum QUEST_TYPE {
    MAIN,               // Main story quest
    SIDE,               // Optional side quest
    REPEATABLE,         // Can be done multiple times
    DAILY,              // Daily quest
    EVENT,              // Time-limited event
    HIDDEN              // Secret quest
}
```

---

### REWARD_TYPE Enum

Reward types for quest completion.

```gml
enum REWARD_TYPE {
    EXPERIENCE,
    CURRENCY,
    ITEM,
    SKILL_POINT,
    UNLOCK_QUEST,
    UNLOCK_ACHIEVEMENT,
    REPUTATION,
    CUSTOM
}
```

---

### QuestObjective

A single objective within a quest.

#### Constructor

```gml
new QuestObjective(id, description, goal = 1, type = "generic")
```

**Parameters:**
- `id` - Objective identifier
- `description` - Display description
- `goal` - Target progress value (default: 1)
- `type` - Objective type: "kill", "collect", "talk", "reach", "wait", "custom"

```gml
var obj = new QuestObjective("kill_wolves", "Defeat Wolves", 5, "kill");
obj.SetTarget("enemy_wolf");
```

---

#### Methods

##### SetTarget(targetId)

Sets the target ID for the objective.

```gml
obj.SetTarget("enemy_wolf");
obj.SetTarget("item_potion");
obj.SetTarget("npc_blacksmith");
```

**Returns:** `self` for chaining.

---

##### SetLocation(x, y, radius = 32)

Sets a location target (for "reach" objectives).

```gml
obj.SetLocation(100, 200, 50);
```

**Returns:** `self` for chaining.

---

##### SetHidden(hidden = true)

Sets whether the objective is hidden.

```gml
obj.SetHidden(true);
```

**Returns:** `self` for chaining.

---

##### SetOptional(optional = true)

Sets whether the objective is optional.

```gml
obj.SetOptional(true);
```

**Returns:** `self` for chaining.

---

##### SetOnProgress(callback)

Sets a callback for progress updates.

```gml
obj.SetOnProgress(function(self, progress, goal, data) {
    show_debug_message($"Progress: {progress}/{goal}");
});
```

**Returns:** `self` for chaining.

---

##### SetOnComplete(callback)

Sets a callback for objective completion.

```gml
obj.SetOnComplete(function(self, data) {
    show_message("Objective complete!");
});
```

**Returns:** `self` for chaining.

---

##### SetCustomCheck(check)

Sets a custom check function for completion.

```gml
obj.SetCustomCheck(function(context) {
    return context.GetStat("special_condition") >= 10;
});
```

**Returns:** `self` for chaining.

---

##### AddProgress(amount = 1, data = undefined)

Adds progress to the objective.

```gml
obj.AddProgress();
obj.AddProgress(3);
obj.AddProgress(1, { source: "enemy" });
```

**Returns:** `self` for chaining.

---

##### IsComplete()

Checks if the objective is complete.

```gml
if (obj.IsComplete()) {
    // Objective finished
}
```

**Returns:** `true` if complete.

---

##### GetProgressRatio()

Gets the current progress ratio (0-1).

```gml
var percent = obj.GetProgressRatio() * 100;
```

**Returns:** Float between 0.0 and 1.0.

---

##### GetDisplayText()

Gets the display text for the objective.

```gml
var text = obj.GetDisplayText();  // "[3/5] Defeat Wolves" or "[✓] Defeat Wolves"
```

**Returns:** Formatted display string.

---

### QuestPrerequisite

A condition that must be met before a quest becomes available.

#### Constructor

```gml
new QuestPrerequisite(type, target, value = 1)
```

**Parameters:**
- `type` - "quest", "level", "item", "reputation", "flag", "custom"
- `target` - Quest ID, item ID, faction ID, flag value, etc.
- `value` - Required value (default: 1)

```gml
var prereq = new QuestPrerequisite("level", "", 5);
var prereq2 = new QuestPrerequisite("quest", "tutorial_complete");
var prereq3 = new QuestPrerequisite("item", "ancient_key", 1);
```

---

#### Methods

##### SetCustomCheck(check)

Sets a custom check function.

```gml
prereq.SetCustomCheck(function(context) {
    return context.GetStat("special_unlock") >= 1;
});
```

**Returns:** `self` for chaining.

---

##### IsMet(context)

Checks if the prerequisite is met.

```gml
if (prereq.IsMet(Game)) {
    // Prerequisite satisfied
}
```

**Returns:** `true` if condition met.

---

### Reward & RewardBundle

#### Reward

A single reward granted on quest completion.

```gml
new Reward(type, value, id = undefined)
```

```gml
var reward = new Reward(REWARD_TYPE.EXPERIENCE, 100);
var reward2 = new Reward(REWARD_TYPE.CURRENCY, 500, "gold");
var reward3 = new Reward(REWARD_TYPE.ITEM, 1, "ancient_sword");
```

---

#### RewardBundle

A collection of rewards.

```gml
new RewardBundle()
```

##### Methods

```gml
var bundle = new RewardBundle();

// Add rewards
bundle.AddExperience(100);
bundle.AddCurrency(500, "gold");
bundle.AddItem("health_potion", 3);
bundle.AddSkillPoint(1);
bundle.UnlockQuest("new_quest");
bundle.UnlockAchievement("quest_master");
bundle.AddReputation("village", 50);

// Add custom reward
bundle.AddCustom(function(context) {
    context.SetFlag(GAME_FLAG.SPECIAL_REWARD);
});

// Give all rewards
bundle.Give(Game);

// Check if empty
if (!bundle.IsEmpty()) {
    // Has rewards
}
```

---

### Quest

A complete quest with objectives, prerequisites, and rewards.

#### Constructor

```gml
new Quest(name, description, onComplete, onFail)
```

**Parameters:**
- `name` - Quest name
- `description` - Quest description
- `onComplete` - Completion callback
- `onFail` - Failure callback

```gml
var quest = new Quest(
    "The Lost Sword",
    "Find the ancient sword and return it to the blacksmith.",
    function(quest) {
        show_message("Quest Complete!");
    },
    function(quest) {
        show_message("Quest Failed!");
    }
);
```

---

#### Configuration Methods

```gml
quest.SetId("lost_sword");
quest.SetType(QUEST_TYPE.MAIN);
quest.SetQuestGiver("npc_blacksmith");
quest.SetExpireTime(3600);  // 1 hour
quest.SetNextQuest("blacksmith_reward");
quest.AddChildQuest("optional_dungeon");

// Dialogue
quest.SetStartDialogue("blacksmith_quest_start");
quest.SetProgressDialogue("blacksmith_quest_progress");
quest.SetCompleteDialogue("blacksmith_quest_complete");
```

---

#### Prerequisite Methods

```gml
quest.RequireLevel(5);
quest.RequireQuest("tutorial_complete");
quest.RequireItem("ancient_key", 1);
quest.RequireReputation("village", 25);
quest.RequireFlag(GAME_FLAG.MET_BLACKSMITH);
quest.RequireCustom(function(context) {
    return context.GetStat("special_condition") >= 1;
});
```

---

#### Objective Methods

```gml
// Add objectives
quest.AddKillObjective("kill_wolves", "enemy_wolf", "Defeat 5 Wolves", 5);
quest.AddCollectObjective("collect_herbs", "item_herb", "Collect 3 Herbs", 3);
quest.AddTalkObjective("talk_elder", "npc_elder", "Speak with the Village Elder");
quest.AddReachObjective("reach_altar", 500, 300, 50, "Reach the Ancient Altar");
quest.AddCustomObjective("special", "Complete special task", function(context) {
    return context.HasFlag(GAME_FLAG.SPECIAL_COMPLETE);
});

// Progress objectives
quest.ProgressObjective("kill_wolves", 1);
quest.ProgressByType("kill", "enemy_wolf", 1);

// Get objective
var obj = quest.GetObjective("kill_wolves");
var current = quest.GetCurrentObjective();
```

---

#### Reward Methods

```gml
quest.AddReward(REWARD_TYPE.EXPERIENCE, 1000);
quest.AddReward(REWARD_TYPE.CURRENCY, 500, "gold");
quest.AddReward(REWARD_TYPE.ITEM, 1, "ancient_sword");

quest.AddBonusReward(REWARD_TYPE.CURRENCY, 100, "gold");  // For optional objectives
```

---

#### State Control Methods

```gml
// Check if can accept
if (quest.CanAccept(Game)) {
    quest.Accept(Game);
}

quest.Start();
quest.Fail();
quest.Abandon();
quest.Update(Game);
quest.Complete(Game);

// Query state
if (quest.IsComplete()) { }
if (quest.IsActive()) { }
if (quest.IsAvailable()) { }
if (quest.IsLocked()) { }
```

---

#### Utility Methods

```gml
quest.Reset();
var progress = quest.GetProgressRatio();  // 0-1
var summary = quest.GetSummary();
var objectives = quest.GetObjectiveSummaries();
```

---

### QuestChain

A series of quests that must be completed in order.

#### Constructor

```gml
new QuestChain(name)
```

```gml
var chain = new QuestChain("Main Story");
chain.AddQuest("prologue");
chain.AddQuest("chapter_1");
chain.AddQuest("chapter_2");
chain.AddQuest("finale");
chain.SetAutoAdvance(true);
```

---

#### Methods

```gml
chain.AddQuest("quest_id");
chain.SetAutoAdvance(true);

var current = chain.GetCurrentQuest();
chain.Advance();

if (chain.IsComplete()) {
    // Chain finished
}

var progress = chain.GetProgress();
chain.Reset();
```

---

### QuestManager

Manages quest templates and spawns quest instances.

#### Constructor

```gml
new QuestManager()
```

```gml
var questManager = new QuestManager();
```

---

#### Methods

```gml
// Register template
questManager.RegisterTemplate(quest);

// Get template
var template = questManager.GetTemplate("quest_id");

// Check if exists
if (questManager.HasTemplate("quest_id")) { }

// Register chain
questManager.RegisterChain(chain);
var chain = questManager.GetChain("Main Story");

// Start chain
questManager.StartChain("Main Story", Game);

// Spawn quest from template
var spawned = questManager.SpawnQuest("quest_id");
var spawnedWithCallbacks = questManager.SpawnQuest("quest_id",
    function(q) { /* custom complete */ },
    function(q) { /* custom fail */ }
);

// Clear and cleanup
questManager.Clear();
questManager.Free();
```

---

### QuestTracker

Tracks player's active and completed quests.

#### Constructor

```gml
new QuestTracker()
```

```gml
var questTracker = new QuestTracker();
```

---

#### Methods

```gml
// Add/remove quests
questTracker.AddQuest(quest);
questTracker.RemoveQuest("quest_id");

// Get quest
var quest = questTracker.GetQuest("quest_id");
if (questTracker.HasQuest("quest_id")) { }

// Check completion
if (questTracker.IsQuestCompleted("quest_id")) { }

// Accept/abandon/complete
questTracker.AcceptQuest("quest_id", Game);
questTracker.AbandonQuest("quest_id");
questTracker.CompleteQuest("quest_id", Game);

// Progress quests
questTracker.ProgressQuest("quest_id", "objective_id", 1);
questTracker.ProgressByType("kill", "enemy_wolf", 1);

// Convenience methods
questTracker.OnKill("enemy_wolf");
questTracker.OnCollect("item_potion", 3);
questTracker.OnTalk("npc_blacksmith");

// Update all quests
questTracker.Update(Game);

// Query quests
var active = questTracker.GetActiveQuests();
var available = questTracker.GetAvailableQuests();
var completed = questTracker.GetCompletedQuests();
var count = questTracker.GetActiveCount();
var summaries = questTracker.GetAllQuestSummaries();

// Clear and cleanup
questTracker.Clear();
questTracker.Free();
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

#### Methods

```gml
// Add achievement
achievements.Add("first_kill", "First Blood", "Defeat your first enemy", 1, false, "Combat");
achievements.Add("slayer", "Slayer", "Defeat 100 enemies", 100, false, "Combat");
achievements.Add("secret", "???", "Find the secret", 1, true, "Hidden");

// Set icon and description
achievements.SetIcon("first_kill", spr_achievement_kill);
achievements.SetDescription("slayer", "Become a true slayer");

// Progress achievements
achievements.Progress("first_kill");
achievements.Progress("slayer", 5);
achievements.SetProgress("collector", 25);

// Unlock achievement
achievements.Unlock("special_event");

// Query achievements
if (achievements.IsUnlocked("first_kill")) { }
var progress = achievements.GetProgress("slayer");  // 0-1

// Get all achievements
var all = achievements.GetAll();
var unlocked = achievements.GetUnlocked();
var byCategory = achievements.GetByCategory("Combat");

// Statistics
achievements.IncrementStat("enemies_killed");
achievements.IncrementStat("items_collected", 5);
var kills = achievements.GetStat("enemies_killed");

// Get stats
var stats = achievements.GetStats();
// { total: 10, unlocked: 3, percent: 0.3, stats: {...} }

// Serialization
var data = achievements.Serialize();
achievements.Deserialize(data);

// Reset and cleanup
achievements.Reset();
achievements.ResetStats();
achievements.Free();
```

---

## Built-in Game Systems

### SimplePlayer

Basic player stats for the quest system.

```gml
new SimplePlayer()
```

```gml
var player = new SimplePlayer();

// Position
player.SetPosition(100, 200);

// Level and experience
var level = player.GetLevel();
player.AddExperience(50);
player.SetLevel(5);
var progress = player.GetExpProgress();  // 0-1

// Skill points
player.AddSkillPoint(1);
if (player.SpendSkillPoint()) { }
var sp = player.GetSkillPoints();

// Callbacks
player.onLevelUp = function(oldLevel, newLevel) {
    show_message($"Level Up! {oldLevel} -> {newLevel}");
};
player.onExpGained = function(amount, currentExp, expToNext) {
    show_debug_message($"+{amount} XP ({currentExp}/{expToNext})");
};

// Serialization
var data = player.Serialize();
player.Deserialize(data);
```

---

### SimpleInventory

Basic inventory system.

```gml
new SimpleInventory()
```

```gml
var inventory = new SimpleInventory();

// Configuration
inventory.SetMaxSlots(50);
inventory.SetMaxStackSize(99);

// Item management
inventory.AddItem("potion", 5);
inventory.RemoveItem("potion", 1);
inventory.SetItem("key", 1);

// Queries
if (inventory.HasItem("potion", 3)) { }
var count = inventory.GetItemCount("potion");
var allItems = inventory.GetAllItems();
var types = inventory.GetItemCount();
var total = inventory.GetTotalItemCount();

if (inventory.IsFull()) { }

// Callbacks
inventory.onItemAdded = function(itemId, count, totalCount) {
    show_debug_message($"Added {count} {itemId} (Total: {totalCount})");
};
inventory.onItemRemoved = function(itemId, count, totalCount) {
    show_debug_message($"Removed {count} {itemId} (Remaining: {totalCount})");
};
inventory.onInventoryFull = function(itemId, count) {
    show_message("Inventory full!");
};

// Serialization
var data = inventory.Serialize();
inventory.Deserialize(data);

// Cleanup
inventory.Clear();
inventory.Free();
```

---

### SimpleCurrency

Basic currency system supporting multiple currencies.

```gml
new SimpleCurrency()
```

```gml
var currency = new SimpleCurrency();

// Configuration
currency.SetDefaultCurrency("gold");

// Currency management
currency.Add(100, "gold");
currency.Add(5, "gems");
currency.Spend(50, "gold");
currency.Set(1000, "gold");

// Queries
var gold = currency.Get("gold");
var gems = currency.Get("gems");
if (currency.Has(100, "gold")) { }

var all = currency.GetAll();
var types = currency.GetCurrencyTypes();

// Callbacks
currency.onCurrencyChanged = function(currencyId, oldAmount, newAmount, delta) {
    show_debug_message($"{currencyId}: {oldAmount} -> {newAmount} ({delta:+0;-0})");
};

// Serialization
var data = currency.Serialize();
currency.Deserialize(data);

// Cleanup
currency.Clear();
currency.Free();
```

---

## Complete Examples

### Example 1: Full Game Setup

```gml
// Create Event - Initialize everything
globalvar Game;
Game = new GameContext();
Game.InitializeDefaults();

// Set up callbacks
Game.onRewardGiven = function(type, value, id) {
    show_debug_message($"Reward: {type} - {value} {id}");
};

Game.onQuestStateChanged = function(quest, oldState, newState) {
    if (newState == QUEST_STATE.COMPLETED) {
        show_message($"Quest Complete: {quest.name}");
    }
};

Game.onAchievementUnlocked = function(achievementId) {
    var ach = Game.achievementManager.achievements[? achievementId];
    show_message($"Achievement Unlocked: {ach.name}");
};

// Define game flags
enum GAME_FLAG {
    TUTORIAL_COMPLETE      = 1 << 0,
    MET_BLACKSMITH         = 1 << 1,
    FOUND_ANCIENT_SWORD    = 1 << 2,
    DEFEATED_BOSS          = 1 << 3
}

// Create quest templates
function CreateQuests() {
    var quest = new Quest("The Lost Sword", "Find the ancient sword");
    quest.SetId("lost_sword")
        .SetType(QUEST_TYPE.MAIN)
        .RequireLevel(5)
        .RequireFlag(GAME_FLAG.MET_BLACKSMITH)
        .AddKillObjective("kill_wolves", "enemy_wolf", "Defeat 5 Wolves", 5)
        .AddCollectObjective("find_sword", "item_ancient_sword", "Find the Ancient Sword", 1)
        .AddReward(REWARD_TYPE.EXPERIENCE, 1000)
        .AddReward(REWARD_TYPE.CURRENCY, 500, "gold")
        .AddReward(REWARD_TYPE.ITEM, 1, "item_steel_armor")
        .SetNextQuest("blacksmith_reward");
    
    Game.questManager.RegisterTemplate(quest);
}

// Create achievements
function CreateAchievements() {
    Game.achievementManager.Add("first_kill", "First Blood", "Defeat an enemy", 1);
    Game.achievementManager.Add("wolf_slayer", "Wolf Slayer", "Defeat 10 wolves", 10);
    Game.achievementManager.Add("sword_master", "Sword Master", "Find the ancient sword", 1, true);
}

CreateQuests();
CreateAchievements();

// Step Event - Update
Game.Update(1 / game_get_speed(gamespeed_fps));

// Cleanup Event
Game.Free();
```

---

### Example 2: Quest Giver NPC

```gml
// NPC Create Event
questId = "lost_sword";
state = "idle";

// NPC Step Event
var quest = Game.questTracker.GetQuest(questId);

if (quest == undefined) {
    // Quest not yet spawned - spawn it
    var spawned = Game.questManager.SpawnQuest(questId);
    Game.questTracker.AddQuest(spawned);
    quest = spawned;
}

switch (quest.state) {
    case QUEST_STATE.AVAILABLE:
        if (place_meeting(x, y, obj_player) && keyboard_check_pressed(vk_space)) {
            if (quest.CanAccept(Game)) {
                Game.questTracker.AcceptQuest(questId, Game);
                show_message($"Quest Accepted: {quest.name}");
            } else {
                show_message("You don't meet the requirements.");
            }
        }
        break;
        
    case QUEST_STATE.ACTIVE:
        if (place_meeting(x, y, obj_player) && keyboard_check_pressed(vk_space)) {
            if (quest.IsComplete()) {
                Game.questTracker.CompleteQuest(questId, Game);
                show_message($"Quest Complete: {quest.name}");
            } else {
                var current = quest.GetCurrentObjective();
                show_message($"Current objective: {current.GetDisplayText()}");
            }
        }
        break;
        
    case QUEST_STATE.COMPLETED:
        // Quest already turned in
        break;
}

// NPC Draw Event
draw_self();

var quest = Game.questTracker.GetQuest(questId);
if (quest != undefined) {
    draw_set_color(c_white);
    
    if (quest.state == QUEST_STATE.AVAILABLE) {
        draw_sprite(spr_exclamation, 0, x, y - 40);
    } else if (quest.state == QUEST_STATE.ACTIVE && quest.IsComplete()) {
        draw_sprite(spr_question, 0, x, y - 40);
    }
}
```

---

### Example 3: Quest Journal UI

```gml
// Draw Event - Quest Journal
function DrawQuestJournal(x, y, width, height) {
    var active = Game.questTracker.GetActiveQuests();
    
    draw_set_color(c_black);
    draw_rectangle(x, y, x + width, y + height, false);
    draw_set_color(c_white);
    draw_rectangle(x, y, x + width, y + height, true);
    
    var textY = y + 10;
    draw_text(x + 10, textY, "=== ACTIVE QUESTS ===");
    textY += 30;
    
    for (var i = 0; i < array_length(active); i++) {
        var quest = active[i];
        
        // Quest title
        draw_set_color(c_yellow);
        draw_text(x + 10, textY, quest.name);
        textY += 20;
        
        // Objectives
        var objectives = quest.GetObjectiveSummaries();
        for (var j = 0; j < array_length(objectives); j++) {
            var obj = objectives[j];
            
            if (obj.hidden) {
                draw_set_color(c_gray);
                draw_text(x + 20, textY, "???");
            } else {
                var color = obj.completed ? c_green : c_white;
                draw_set_color(color);
                
                var text = $"[{obj.progress}/{obj.goal}] {obj.description}";
                if (obj.optional) text += " (Optional)";
                draw_text(x + 20, textY, text);
                
                // Progress bar
                if (!obj.completed) {
                    var barWidth = 100;
                    var progressWidth = barWidth * (obj.progress / obj.goal);
                    draw_set_color(c_gray);
                    draw_rectangle(x + 200, textY, x + 200 + barWidth, textY + 10, true);
                    draw_set_color(c_blue);
                    draw_rectangle(x + 200, textY, x + 200 + progressWidth, textY + 10, false);
                }
            }
            textY += 15;
        }
        
        textY += 10;
    }
    
    if (array_length(active) == 0) {
        draw_set_color(c_gray);
        draw_text(x + 10, textY, "No active quests");
    }
}
```

---

### Example 4: Save/Load System

```gml
function SaveGame(slot) {
    var saveData = {
        version: "1.0",
        timestamp: GetUnixDateTime(date_current_datetime()),
        context: Game.Serialize(),
        player: Game.player.Serialize(),
        inventory: Game.inventory.Serialize(),
        currency: Game.currency.Serialize(),
        questTracker: Game.questTracker.Serialize(),
        achievements: Game.achievementManager.Serialize()
    };
    
    return File.SaveJSON($"save_slot_{slot}.json", saveData);
}

function LoadGame(slot) {
    var saveData = File.LoadJSON($"save_slot_{slot}.json");
    if (saveData == undefined) return false;
    
    Game.Deserialize(saveData.context);
    Game.player.Deserialize(saveData.player);
    Game.inventory.Deserialize(saveData.inventory);
    Game.currency.Deserialize(saveData.currency);
    Game.questTracker.Deserialize(saveData.questTracker, Game.questManager);
    Game.achievementManager.Deserialize(saveData.achievements);
    
    return true;
}

function GetSaveSlots() {
    var slots = [];
    for (var i = 0; i < 10; i++) {
        if (file_exists($"save_slot_{i}.json")) {
            var data = File.LoadJSON($"save_slot_{i}.json");
            array_push(slots, {
                slot: i,
                timestamp: data.timestamp,
                playerLevel: data.player.level
            });
        }
    }
    return slots;
}
```

---

### Example 5: Daily Quest System

```gml
function DailyQuestManager() constructor {
    dailyQuests = [];
    lastRefresh = 0;
    refreshInterval = 86400; // 24 hours
    
    templates = ["daily_kills", "daily_collection", "daily_crafting"];
    
    function CheckRefresh() {
        var currentTime = GetUnixDateTime(date_current_datetime());
        
        if (currentTime - lastRefresh >= refreshInterval) {
            Refresh();
            lastRefresh = currentTime;
        }
    }
    
    function Refresh() {
        // Clear old quests
        for (var i = 0; i < array_length(dailyQuests); i++) {
            Game.questTracker.RemoveQuest(dailyQuests[i].id);
        }
        dailyQuests = [];
        
        // Generate new quests
        var count = 3;
        for (var i = 0; i < count; i++) {
            var templateId = templates[irandom(array_length(templates) - 1)];
            var quest = Game.questManager.SpawnQuest(templateId);
            
            quest.SetType(QUEST_TYPE.DAILY);
            quest.onComplete = function(q) {
                Game.AddCurrency(100, "gold");
                Game.AddExperience(50);
                show_message("Daily quest complete! +100 gold, +50 XP");
            };
            
            Game.questTracker.AddQuest(quest);
            quest.Accept(Game);
            array_push(dailyQuests, quest);
        }
    }
    
    function GetTimeRemaining() {
        var currentTime = GetUnixDateTime(date_current_datetime());
        return max(0, refreshInterval - (currentTime - lastRefresh));
    }
    
    function FormatTime(seconds) {
        var hours = floor(seconds / 3600);
        var minutes = floor((seconds % 3600) / 60);
        return $"{hours}h {minutes}m";
    }
    
    return {
        CheckRefresh: CheckRefresh,
        Refresh: Refresh,
        GetTimeRemaining: GetTimeRemaining,
        FormatTime: FormatTime
    };
}

// Usage
globalvar DailyQuests;
DailyQuests = new DailyQuestManager();

// In Step event
DailyQuests.CheckRefresh();

// Display time
var remaining = DailyQuests.GetTimeRemaining();
draw_text(10, 10, $"Daily reset in: {DailyQuests.FormatTime(remaining)}");
```
