

// Enums
enum QUEST_STATE {
    INACTIVE,           // Not started
    ACTIVE,             // Currently in progress
    COMPLETED,          // Finished successfully
    FAILED,             // Failed
    ABANDONED,          // Player gave up
    LOCKED,             // Prerequisites not met
    AVAILABLE           // Can be accepted
}

// Quest type enum
enum QUEST_TYPE {
    MAIN,               // Main story quest
    SIDE,               // Optional side quest
    REPEATABLE,         // Can be done multiple times
    DAILY,              // Daily quest
    EVENT,              // Time-limited event
    HIDDEN              // Secret quest
}

// Reward type enum
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

function GameContext() constructor {
    // Core systems
    player = undefined;              // Player instance or struct
    party = undefined;               // Party members (array or struct)
    
    // Inventory & Currency
    inventory = undefined;           // Inventory system
    currency = undefined;            // Currency system (or array for multiple currencies)
    
    // Progression
    flags = undefined;               // Flag system for game state
    
    // Stats
    statistics = ds_map_create_gmu(); // Tracked statistics
    
    // World
    currentLocation = undefined;     // Current map/area ID
    gameTime = 0;                    // Play time in seconds
    
    // Callbacks
    onRewardGiven = undefined;       // function(type, value, id)
    onQuestStateChanged = undefined; // function(quest, oldState, newState)
    onAchievementUnlocked = undefined; // function(achievementId)
    onStatChanged = undefined;       // function(statId, oldValue, newValue)
    
    //  Player queries
    function GetPlayerLevel() {
        if (player == undefined) return 1;
        
        if (is_struct(player) && variable_struct_exists(player, "GetLevel")) {
            return player.GetLevel();
        } else if (instance_exists(player) && variable_instance_exists(player, "level")) {
            return player.level;
        } else if (is_struct(player) && variable_struct_exists(player, "level")) {
            return player.level;
        }
        return 1;
    };
    
    function GetPlayerPosition() {
        if (player == undefined) return { x: 0, y: 0 };
        
        if (instance_exists(player)) {
            return { x: player.x, y: player.y };
        } else if (is_struct(player) && variable_struct_exists(player, "x")) {
            return { x: player.x, y: player.y };
        }
        return { x: 0, y: 0 };
    };
    
    function AddExperience(amount) {
        if (player == undefined) return false;
        
        if (is_struct(player) && variable_struct_exists(player, "AddExperience")) {
            player.AddExperience(amount);
            return true;
        } else if (instance_exists(player) && variable_instance_exists(player, "exp")) {
            player.exp += amount;
            return true;
        } else if (is_struct(player) && variable_struct_exists(player, "exp")) {
            player.exp += amount;
            return true;
        }
        return false;
    };
    
    //  Inventory queries
    function HasItem(itemId, count) {
        if (inventory == undefined) return false;
        
        if (is_struct(inventory) && variable_struct_exists(inventory, "HasItem")) {
            return inventory.HasItem(itemId, count);
        } else if (is_struct(inventory) && variable_struct_exists(inventory, "GetCount")) {
            return inventory.GetCount(itemId) >= count;
        }
        return false;
    };
    
    function GetItemCount(itemId) {
        if (inventory == undefined) return 0;
        
        if (is_struct(inventory) && variable_struct_exists(inventory, "GetCount")) {
            return inventory.GetCount(itemId);
        }
        return 0;
    };
    
    function AddItem(itemId, count) {
        if (inventory == undefined) return false;
        
        if (is_struct(inventory) && variable_struct_exists(inventory, "AddItem")) {
            return inventory.AddItem(itemId, count);
        } else if (is_struct(inventory) && variable_struct_exists(inventory, "Add")) {
            inventory.Add(itemId, count);
            return true;
        }
        return false;
    };
    
    function RemoveItem(itemId, count) {
        if (inventory == undefined) return false;
        
        if (is_struct(inventory) && variable_struct_exists(inventory, "RemoveItem")) {
            return inventory.RemoveItem(itemId, count);
        }
        return false;
    };
    
    //  Currency queries
    function GetCurrency(currencyId = "default") {
        if (currency == undefined) return 0;
        
        if (is_struct(currency) && variable_struct_exists(currency, "Get")) {
            return currency.Get(currencyId);
        } else if (is_real(currency)) {
            return currency;
        }
        return 0;
    };
    
    function AddCurrency(amount, currencyId = "default") {
        if (currency == undefined) return false;
        
        if (is_struct(currency) && variable_struct_exists(currency, "Add")) {
            currency.Add(amount, currencyId);
            
            if (onRewardGiven != undefined) {
                onRewardGiven(REWARD_TYPE.CURRENCY, amount, currencyId);
            }
            return true;
        } else if (is_real(currency)) {
            currency += amount;
            return true;
        }
        return false;
    };
    
    function SpendCurrency(amount, currencyId = "default") {
        if (currency == undefined) return false;
        
        if (is_struct(currency) && variable_struct_exists(currency, "Spend")) {
            return currency.Spend(amount, currencyId);
        } else if (is_real(currency) && currency >= amount) {
            currency -= amount;
            return true;
        }
        return false;
    };
    
    //  Flag queries
    function HasFlag(flagValue) {
        if (flags == undefined) return false;
        return flags.Has(flagValue);
    };
    
    function SetFlag(flagValue) {
        if (flags == undefined) {
            flags = new FlagPatrol();
        }
        flags.Add(flagValue);
        return self;
    };
    
    function ClearFlag(flagValue) {
        if (flags == undefined) return self;
        flags.Remove(flagValue);
        return self;
    };
    
    function ToggleFlag(flagValue) {
        if (flags == undefined) {
            flags = new FlagPatrol();
        }
        flags.Toggle(flagValue);
        return self;
    };
    
    function GetFlags() {
        if (flags == undefined) return 0;
        return flags.Get();
    };
    
    function SetFlags(value) {
        if (flags == undefined) {
            flags = new FlagPatrol();
        }
        flags.Set(value);
        return self;
    };
    
    function HasAllFlags(flagValues) {
        if (flags == undefined) return false;
        for (var i = 0; i < array_length(flagValues); i++) {
            if (!flags.Has(flagValues[i])) return false;
        }
        return true;
    };
    
    function HasAnyFlag(flagValues) {
        if (flags == undefined) return false;
        for (var i = 0; i < array_length(flagValues); i++) {
            if (flags.Has(flagValues[i])) return true;
        }
        return false;
    };
    
    //  Reputation queries
    function GetReputation(factionId) {
        var key = "rep_" + factionId;
        return statistics[? key] ?? 0;
    };
    
    function AddReputation(factionId, amount) {
        var key = "rep_" + factionId;
        var oldValue = statistics[? key] ?? 0;
        statistics[? key] = oldValue + amount;
        
        if (onStatChanged != undefined) {
            onStatChanged(key, oldValue, statistics[? key]);
        }
        return self;
    };
    
    function HasReputation(factionId, required) {
        return GetReputation(factionId) >= required;
    };
    
    //  Statistics tracking
    function IncrementStat(statId, amount = 1) {
        var oldValue = statistics[? statId] ?? 0;
        statistics[? statId] = oldValue + amount;
        
        if (onStatChanged != undefined) {
            onStatChanged(statId, oldValue, statistics[? statId]);
        }
        return self;
    };
    
    function GetStat(statId) {
        return statistics[? statId] ?? 0;
    };
    
    function SetStat(statId, value) {
        var oldValue = statistics[? statId] ?? 0;
        statistics[? statId] = value;
        
        if (onStatChanged != undefined) {
            onStatChanged(statId, oldValue, value);
        }
        return self;
    };
    
    //  Quest system integration
    function UnlockQuest(questId) {
        if (QuestManager != undefined) {
            QuestManager.UnlockQuest(questId);
        }
        return self;
    };
    
    function IsQuestCompleted(questId) {
        if (QuestTracker != undefined) {
            return QuestTracker.IsQuestCompleted(questId);
        }
        return false;
    };
    
    function GetQuest(questId) {
        if (QuestTracker != undefined) {
            return QuestTracker.GetQuest(questId);
        }
        return undefined;
    };
    
    //  Achievement system integration
    function UnlockAchievement(achievementId) {
        if (AchievementManager != undefined) {
            AchievementManager.Unlock(achievementId);
            
            if (onAchievementUnlocked != undefined) {
                onAchievementUnlocked(achievementId);
            }
        }
        return self;
    };
    
    function ProgressAchievement(achievementId, amount = 1) {
        if (AchievementManager != undefined) {
            AchievementManager.Progress(achievementId, amount);
        }
        return self;
    };
    
    //  Reward handling
    function GiveReward(type, value, id = undefined) {
        switch(type) {
            case REWARD_TYPE.EXPERIENCE:
                AddExperience(value);
                break;
                
            case REWARD_TYPE.CURRENCY:
                AddCurrency(value, id);
                break;
                
            case REWARD_TYPE.ITEM:
                AddItem(id, value);
                break;
                
            case REWARD_TYPE.SKILL_POINT:
                if (player != undefined && variable_struct_exists(player, "AddSkillPoint")) {
                    player.AddSkillPoint(value);
                }
                break;
                
            case REWARD_TYPE.UNLOCK_QUEST:
                UnlockQuest(id);
                break;
                
            case REWARD_TYPE.UNLOCK_ACHIEVEMENT:
                UnlockAchievement(id);
                break;
                
            case REWARD_TYPE.REPUTATION:
                AddReputation(id, value);
                break;
        }
        
        if (onRewardGiven != undefined) {
            onRewardGiven(type, value, id);
        }
        
        return self;
    };
    
    //  Update
    function Update(deltaTime = 1/60) {
        gameTime += deltaTime;
        
        // Update quest tracker if available
        if (QuestTracker != undefined) {
            QuestTracker.Update(self);
        }
    };
    
    //  Serialization
    function Serialize() {
        var data = {
            gameTime: gameTime,
            currentLocation: currentLocation,
            statistics: {},
            flags: {}
        };
        
        // Serialize statistics map
        var statKeys = ds_map_keys_to_array(statistics);
        for (var i = 0; i < array_length(statKeys); i++) {
            var key = statKeys[i];
            data.statistics[$ key] = statistics[? key];
        }
        
        // Serialize flags
        if (flags != undefined) {
            if (is_struct(flags) && variable_struct_exists(flags, "Serialize")) {
                data.flags = flags.Serialize();
            } else if (ds_exists(flags, ds_type_map)) {
                var flagKeys = ds_map_keys_to_array(flags);
                for (var i = 0; i < array_length(flagKeys); i++) {
                    var key = flagKeys[i];
                    data.flags[$ key] = flags[? key];
                }
            }
        }
        
        return data;
    };
    
    function Deserialize(_data) {
        gameTime = _data.gameTime ?? 0;
        currentLocation = _data.currentLocation;
        
        // Deserialize statistics
        var statKeys = variable_struct_get_names(_data.statistics);
        for (var i = 0; i < array_length(statKeys); i++) {
            var key = statKeys[i];
            statistics[? key] = _data.statistics[$ key];
        }
        
        // Deserialize flags
        if (_data.flags != undefined && flags != undefined) {
            if (is_struct(flags) && variable_struct_exists(flags, "Deserialize")) {
                flags.Deserialize(_data.flags);
            } else if (ds_exists(flags, ds_type_map)) {
                var flagKeys = variable_struct_get_names(_data.flags);
                for (var i = 0; i < array_length(flagKeys); i++) {
                    var key = flagKeys[i];
                    flags[? key] = _data.flags[$ key];
                }
            }
        }
        
        return self;
    };
    
    //  Cleanup
    function Free() {
        if (ds_exists(statistics, ds_type_map)) {
            ds_map_destroy_gmu(statistics);
        }
    };
    
    //  Debug
    function DebugDump() {
        show_debug_message("=== GameContext Debug Dump ===");
        show_debug_message($"Player Level: {GetPlayerLevel()}");
        show_debug_message($"Game Time: {gameTime}s");
        show_debug_message($"Location: {currentLocation ?? "Unknown"}");
        show_debug_message($"Statistics: {ds_map_size(statistics)} entries");
        show_debug_message("==============================");
    };
    
    toString = function() {
        return $"GameContext: Lvl {GetPlayerLevel()}, Time {gameTime}s";
    };
}

function Reward(_type, _value, _id = undefined) constructor {
    type = _type;
    value = _value;
    id = _id;
    customHandler = undefined;
    
    function SetCustomHandler(_handler) {
        customHandler = _handler;
        return self;
    };
    
    function Give(context) {
        if (type == REWARD_TYPE.CUSTOM && customHandler != undefined) {
            customHandler(context);
        } else if (context != undefined) {
            context.GiveReward(type, value, id);
        }
        return self;
    };
    
    function Serialize() {
        return {
            type: type,
            value: value,
            id: id
        };
    };
    
    static Deserialize = function(_data) {
        return new Reward(_data.type, _data.value, _data.id);
    };
    
    toString = function() {
        var typeNames = ["XP", "Currency", "Item", "Skill", "Quest", "Achievement", "Rep", "Custom"];
        return $"{typeNames[type]}: {value} {id ?? ""}";
    };
}

function RewardBundle() constructor {
    rewards = [];
    
    function Add(_type, _value, _id = undefined) {
        array_push(rewards, new Reward(_type, _value, _id));
        return self;
    };
    
    function AddReward(_reward) {
        array_push(rewards, _reward);
        return self;
    };
    
    function AddExperience(_amount) {
        return Add(REWARD_TYPE.EXPERIENCE, _amount);
    };
    
    function AddCurrency(_amount, _currencyId = "default") {
        return Add(REWARD_TYPE.CURRENCY, _amount, _currencyId);
    };
    
    function AddItem(_itemId, _count = 1) {
        return Add(REWARD_TYPE.ITEM, _count, _itemId);
    };
    
    function AddSkillPoint(_amount = 1) {
        return Add(REWARD_TYPE.SKILL_POINT, _amount);
    };
    
    function UnlockQuest(_questId) {
        return Add(REWARD_TYPE.UNLOCK_QUEST, 1, _questId);
    };
    
    function UnlockAchievement(_achievementId) {
        return Add(REWARD_TYPE.UNLOCK_ACHIEVEMENT, 1, _achievementId);
    };
    
    function AddReputation(_factionId, _amount) {
        return Add(REWARD_TYPE.REPUTATION, _amount, _factionId);
    };
    
    function AddCustom(_handler) {
        var reward = new Reward(REWARD_TYPE.CUSTOM, 0);
        reward.SetCustomHandler(_handler);
        array_push(rewards, reward);
        return self;
    };
    
    function Give(context) {
        for (var i = 0; i < array_length(rewards); i++) {
            rewards[i].Give(context);
        }
        return self;
    };
    
    function IsEmpty() {
        return array_length(rewards) == 0;
    };
    
    function Clear() {
        rewards = [];
        return self;
    };
    
    function Serialize() {
        var data = [];
        for (var i = 0; i < array_length(rewards); i++) {
            array_push(data, rewards[i].Serialize());
        }
        return data;
    };
    
    static Deserialize = function(_data) {
        var bundle = new RewardBundle();
        for (var i = 0; i < array_length(_data); i++) {
            bundle.AddReward(Reward.Deserialize(_data[i]));
        }
        return bundle;
    };
    
    toString = function() {
        if (array_length(rewards) == 0) return "No rewards";
        var str = "Rewards: ";
        for (var i = 0; i < array_length(rewards); i++) {
            str += rewards[i].ToString();
            if (i < array_length(rewards) - 1) str += ", ";
        }
        return str;
    };
}

function QuestPrerequisite(_type, _target, _value = 1) constructor {
    type = _type;
    target = _target;
    value = _value;
    customCheck = undefined;
    
    function SetCustomCheck(_check) {
        customCheck = _check;
        return self;
    };
    
    function IsMet(context) {
        if (context == undefined) return true;
        
        switch(type) {
            case "quest":
                return context.IsQuestCompleted(target);
                
            case "level":
                return context.GetPlayerLevel() >= value;
                
            case "item":
                return context.HasItem(target, value);
                
            case "reputation":
                return context.HasReputation(target, value);
                
            case "flag":
                return context.HasFlag(target);
                
            case "custom":
                if (customCheck != undefined) {
                    return customCheck(context);
                }
                return false;
        }
        return true;
    };
    
    function Serialize() {
        return {
            type: type,
            target: target,
            value: value
        };
    };
    
    static Deserialize = function(_data) {
        return new QuestPrerequisite(_data.type, _data.target, _data.value);
    };
    
    toString = function() {
        return $"Prerequisite[{type}]: {target} >= {value}";
    };
}

function QuestObjective(_id, _description, _goal = 1, _type = "generic") constructor {
    id = _id;
    description = _description;
    goal = _goal;
    type = _type;
    progress = 0;
    completed = false;
    hidden = false;
    optional = false;
    
    targetId = undefined;
    targetLocation = undefined;
    
    onProgress = undefined;
    onComplete = undefined;
    customUpdate = undefined;
    customCheck = undefined;
    
    function SetTarget(_targetId) {
        targetId = _targetId;
        return self;
    };
    
    function SetLocation(_x, _y, _radius = 32) {
        targetLocation = { x: _x, y: _y, radius: _radius };
        return self;
    };
    
    function SetHidden(_hidden = true) {
        hidden = _hidden;
        return self;
    };
    
    function SetOptional(_optional = true) {
        optional = _optional;
        return self;
    };
    
    function SetOnProgress(_callback) {
        onProgress = _callback;
        return self;
    };
    
    function SetOnComplete(_callback) {
        onComplete = _callback;
        return self;
    };
    
    function SetCustomCheck(_check) {
        customCheck = _check;
        return self;
    };
    
    function SetCustomUpdate(_update) {
        customUpdate = _update;
        return self;
    };
    
    function AddProgress(_amount = 1, _data = undefined) {
        if (completed) return self;
        
        progress = min(progress + _amount, goal);
        
        if (onProgress != undefined) {
            onProgress(self, progress, goal, _data);
        }
        
        if (progress >= goal && !completed) {
            completed = true;
            if (onComplete != undefined) {
                onComplete(self, _data);
            }
        }
        
        return self;
    };
    
    function SetProgress(_amount) {
        progress = min(_amount, goal);
        if (progress >= goal) completed = true;
        return self;
    };
    
    function Update(context) {
        if (completed) return self;
        
        if (customUpdate != undefined) {
            customUpdate(self, context);
        } else if (customCheck != undefined) {
            if (customCheck(context)) {
                AddProgress(1);
            }
        } else {
            switch(type) {
                case "reach":
                    if (targetLocation != undefined && context != undefined) {
                        var pos = context.GetPlayerPosition();
                        var dist = point_distance(pos.x, pos.y, targetLocation.x, targetLocation.y);
                        if (dist <= targetLocation.radius) {
                            AddProgress(goal);
                        }
                    }
                    break;
            }
        }
        
        return self;
    };
    
    function IsComplete() {
        return completed;
    };
    
    function IsRequired() {
        return !optional;
    };
    
    function GetProgressRatio() {
        return goal > 0 ? progress / goal : 0;
    };
    
    function GetDisplayText() {
        if (hidden) return "???";
        var status = completed ? "[✓]" : $"[{progress}/{goal}]";
        return $"{status} {description}";
    };
    
    function Reset() {
        progress = 0;
        completed = false;
        return self;
    };
    
    function Serialize() {
        return {
            id: id,
            progress: progress,
            completed: completed,
            hidden: hidden
        };
    };
    
    function Deserialize(_data) {
        progress = _data.progress;
        completed = _data.completed;
        hidden = _data.hidden;
        return self;
    };
    
    toString = function() {
        return GetDisplayText();
    };
}

function Quest(_name, _description, _onComplete, _onFail) constructor {
    id = IDGenerate().GUID();
    name = _name;
    description = _description;
    type = QUEST_TYPE.SIDE;
    
    state = QUEST_STATE.INACTIVE;
    acceptedTime = -1;
    completedTime = -1;
    expireTime = -1;
    
    objectives = ds_map_create_gmu();
    objectiveOrder = [];
    
    prerequisites = [];
    
    rewards = new RewardBundle();
    bonusRewards = new RewardBundle();
    
    nextQuest = undefined;
    childQuests = [];
    
    questGiver = undefined;
    questGiverLocation = undefined;
    
    startDialogue = undefined;
    progressDialogue = undefined;
    completeDialogue = undefined;
    
    onComplete = _onComplete;
    onFail = _onFail;
    onAccept = undefined;
    onAbandon = undefined;
    onObjectiveComplete = undefined;
    
    customData = undefined;
    
    // Configuration methods (unchanged - just returning self)
    function SetType(_type) { type = _type; return self; };
    function SetId(_id) { id = _id; return self; };
    function SetQuestGiver(_npcId, _location = undefined) { questGiver = _npcId; questGiverLocation = _location; return self; };
    function SetExpireTime(_seconds) { expireTime = _seconds; return self; };
    function SetNextQuest(_questId) { nextQuest = _questId; return self; };
    function AddChildQuest(_questId) { array_push(childQuests, _questId); return self; };
    
    // Prerequisites
    function AddPrerequisite(_type, _target, _value = 1) {
        array_push(prerequisites, new QuestPrerequisite(_type, _target, _value));
        return self;
    };
    
    function RequireQuest(_questId) { return AddPrerequisite("quest", _questId); };
    function RequireLevel(_level) { return AddPrerequisite("level", "", _level); };
    function RequireItem(_itemId, _count = 1) { return AddPrerequisite("item", _itemId, _count); };
    function RequireReputation(_factionId, _amount) { return AddPrerequisite("reputation", _factionId, _amount); };
    function RequireFlag(_flagName) { return AddPrerequisite("flag", _flagName); };
    
    function RequireCustom(_check) {
        var prereq = new QuestPrerequisite("custom", "", 1);
        prereq.SetCustomCheck(_check);
        array_push(prerequisites, prereq);
        return self;
    };
    
    function CheckPrerequisites(context) {
        for (var i = 0; i < array_length(prerequisites); i++) {
            if (!prerequisites[i].IsMet(context)) {
                return false;
            }
        }
        return true;
    };
    
    // Objectives
    function AddObjective(_objective) {
        objectives[? _objective.id] = _objective;
        array_push(objectiveOrder, _objective.id);
        return self;
    };
    
    function AddKillObjective(_id, _enemyId, _description, _count = 1) {
        var obj = new QuestObjective(_id, _description, _count, "kill");
        obj.SetTarget(_enemyId);
        return AddObjective(obj);
    };
    
    function AddCollectObjective(_id, _itemId, _description, _count = 1) {
        var obj = new QuestObjective(_id, _description, _count, "collect");
        obj.SetTarget(_itemId);
        return AddObjective(obj);
    };
    
    function AddTalkObjective(_id, _npcId, _description) {
        var obj = new QuestObjective(_id, _description, 1, "talk");
        obj.SetTarget(_npcId);
        return AddObjective(obj);
    };
    
    function AddReachObjective(_id, _x, _y, _radius, _description) {
        var obj = new QuestObjective(_id, _description, 1, "reach");
        obj.SetLocation(_x, _y, _radius);
        return AddObjective(obj);
    };
    
    function AddCustomObjective(_id, _description, _check) {
        var obj = new QuestObjective(_id, _description, 1, "custom");
        obj.SetCustomCheck(_check);
        return AddObjective(obj);
    };
    
    function GetObjective(_id) {
        return objectives[? _id];
    };
    
    function GetCurrentObjective() {
        for (var i = 0; i < array_length(objectiveOrder); i++) {
            var obj = objectives[? objectiveOrder[i]];
            if (!obj.IsComplete() && obj.IsRequired()) {
                return obj;
            }
        }
        return undefined;
    };
    
    function ProgressObjective(_id, _amount = 1, _data = undefined) {
        if (state != QUEST_STATE.ACTIVE) return self;
        
        var obj = objectives[? _id];
        if (obj != undefined) {
            obj.AddProgress(_amount, _data);
            
            if (onObjectiveComplete != undefined && obj.IsComplete()) {
                onObjectiveComplete(self, obj);
            }
        }
        return self;
    };
    
    function ProgressByType(_type, _target = undefined, _amount = 1) {
        if (state != QUEST_STATE.ACTIVE) return self;
        
        var keys = ds_map_keys_to_array(objectives);
        for (var i = 0; i < array_length(keys); i++) {
            var obj = objectives[? keys[i]];
            if (obj.type == _type && !obj.IsComplete()) {
                if (_target == undefined || obj.targetId == _target) {
                    obj.AddProgress(_amount);
                }
            }
        }
        return self;
    };
    
    // Rewards
    function AddReward(_type, _value, _id = undefined) { rewards.Add(_type, _value, _id); return self; };
    function AddBonusReward(_type, _value, _id = undefined) { bonusRewards.Add(_type, _value, _id); return self; };
    function GetRewards() { return rewards; };
    function GetBonusRewards() { return bonusRewards; };
    
    // Dialogue
    function SetStartDialogue(_dialogueId) { startDialogue = _dialogueId; return self; };
    function SetProgressDialogue(_dialogueId) { progressDialogue = _dialogueId; return self; };
    function SetCompleteDialogue(_dialogueId) { completeDialogue = _dialogueId; return self; };
    
    // State control
    function CanAccept(context) {
        return state == QUEST_STATE.AVAILABLE && CheckPrerequisites(context);
    };
    
    function Accept(context) {
        if (!CanAccept(context)) return false;
        
        state = QUEST_STATE.ACTIVE;
        acceptedTime = current_time;
        
        if (onAccept != undefined) {
            onAccept(self, context);
        }
        
        return true;
    };
    
    function Start() {
        if (state == QUEST_STATE.INACTIVE || state == QUEST_STATE.AVAILABLE) {
            state = QUEST_STATE.ACTIVE;
            acceptedTime = current_time;
        }
        return self;
    };
    
    function Fail() {
        if (state == QUEST_STATE.ACTIVE) {
            state = QUEST_STATE.FAILED;
            if (is_callable(onFail)) onFail(self);
        }
        return self;
    };
    
    function Abandon() {
        if (state == QUEST_STATE.ACTIVE) {
            state = QUEST_STATE.ABANDONED;
            if (onAbandon != undefined) onAbandon(self);
        }
        return self;
    };
    
    function Update(context) {
        if (state != QUEST_STATE.ACTIVE) return self;
        
        // Check expiration
        if (expireTime > 0) {
            var elapsed = (current_time - acceptedTime) / 1000000;
            if (elapsed >= expireTime) {
                Fail();
                return self;
            }
        }
        
        // Update all objectives
        var allRequiredComplete = true;
        var keys = ds_map_keys_to_array(objectives);
        
        for (var i = 0; i < array_length(keys); i++) {
            var obj = objectives[? keys[i]];
            obj.Update(context);
            
            if (obj.IsRequired() && !obj.IsComplete()) {
                allRequiredComplete = false;
            }
        }
        
        // Check completion
        if (allRequiredComplete) {
            Complete(context);
        }
        
        return self;
    };
    
    function Complete(context) {
        if (state != QUEST_STATE.ACTIVE) return self;
        
        state = QUEST_STATE.COMPLETED;
        completedTime = current_time;
        
        // Give rewards
        rewards.Give(context);
        
        // Give bonus rewards for completed optional objectives
        var keys = ds_map_keys_to_array(objectives);
        for (var i = 0; i < array_length(keys); i++) {
            var obj = objectives[? keys[i]];
            if (obj.optional && obj.IsComplete()) {
                bonusRewards.Give(context);
            }
        }
        
        // Unlock next quest
        if (nextQuest != undefined) {
            context.UnlockQuest(nextQuest);
        }
        
        // Unlock child quests
        for (var i = 0; i < array_length(childQuests); i++) {
            context.UnlockQuest(childQuests[i]);
        }
        
        if (is_callable(onComplete)) onComplete(self);
        
        return self;
    };
    
    function IsComplete() { return state == QUEST_STATE.COMPLETED; };
    function IsActive() { return state == QUEST_STATE.ACTIVE; };
    function IsAvailable() { return state == QUEST_STATE.AVAILABLE; };
    function IsLocked() { return state == QUEST_STATE.LOCKED; };
    
    // Serialization
    function Serialize() {
        var data = {
            id: id,
            state: state,
            acceptedTime: acceptedTime,
            completedTime: completedTime,
            objectives: {}
        };
        
        var keys = ds_map_keys_to_array(objectives);
        for (var i = 0; i < array_length(keys); i++) {
            var key = keys[i];
            data.objectives[$ key] = objectives[? key].Serialize();
        }
        
        return data;
    };
    
    function Deserialize(_data) {
        state = _data.state;
        acceptedTime = _data.acceptedTime;
        completedTime = _data.completedTime;
        
        var keys = variable_struct_get_names(_data.objectives);
        for (var i = 0; i < array_length(keys); i++) {
            var key = keys[i];
            if (ds_map_exists(objectives, key)) {
                objectives[? key].Deserialize(_data.objectives[$ key]);
            }
        }
        
        return self;
    };
    
    // Utility
    function Reset() {
        state = QUEST_STATE.INACTIVE;
        acceptedTime = -1;
        completedTime = -1;
        
        var keys = ds_map_keys_to_array(objectives);
        for (var i = 0; i < array_length(keys); i++) {
            objectives[? keys[i]].Reset();
        }
        return self;
    };
    
    function GetProgressRatio() {
        var total = 0;
        var completed = 0;
        var keys = ds_map_keys_to_array(objectives);
        
        for (var i = 0; i < array_length(keys); i++) {
            var obj = objectives[? keys[i]];
            if (obj.IsRequired()) {
                total += obj.goal;
                completed += obj.progress;
            }
        }
        
        return total > 0 ? completed / total : 0;
    };
    
    function GetSummary() {
        return {
            id: id,
            name: name,
            state: state,
            progress: GetProgressRatio(),
            objectives: GetObjectiveSummaries()
        };
    };
    
    function GetObjectiveSummaries() {
        var summaries = [];
        var keys = ds_map_keys_to_array(objectives);
        
        for (var i = 0; i < array_length(keys); i++) {
            var obj = objectives[? keys[i]];
            array_push(summaries, {
                id: obj.id,
                description: obj.description,
                progress: obj.progress,
                goal: obj.goal,
                completed: obj.completed,
                hidden: obj.hidden,
                optional: obj.optional
            });
        }
        
        return summaries;
    };
    
    function Free() {
        ds_map_destroy_gmu(objectives);
    };
    
    toString = function() {
        return $"Quest: {name} [{state}] - {GetProgressRatio() * 100}%";
    };
}

function QuestChain(_name) constructor {
    name = _name;
    quests = [];                // Quest IDs in order
    currentIndex = 0;
    autoAdvance = true;
    onChainComplete = undefined;
    onQuestComplete = undefined;
    
    function AddQuest(_questId) {
        array_push(quests, _questId);
        return self;
    };
    
    function SetAutoAdvance(_auto) {
        autoAdvance = _auto;
        return self;
    };
    
    function GetCurrentQuest() {
        if (currentIndex < array_length(quests)) {
            return quests[currentIndex];
        }
        return undefined;
    };
    
    function Advance() {
        currentIndex++;
        
        if (onQuestComplete != undefined) {
            onQuestComplete(quests[currentIndex - 1]);
        }
        
        if (IsComplete() && onChainComplete != undefined) {
            onChainComplete(self);
        }
        
        return self;
    };
    
    function IsComplete() {
        return currentIndex >= array_length(quests);
    };
    
    function GetProgress() {
        return {
            current: currentIndex,
            total: array_length(quests),
            currentQuest: GetCurrentQuest()
        };
    };
    
    function Reset() {
        currentIndex = 0;
        return self;
    };
    
    function Serialize() {
        return {
            currentIndex: currentIndex
        };
    };
    
    function Deserialize(_data) {
        currentIndex = _data.currentIndex;
        return self;
    };
    
    toString = function() {
        return $"QuestChain: {name} - {currentIndex}/{array_length(quests)}";
    };
}

function QuestManager() constructor {
    templates = ds_map_create_gmu();
    chains = ds_map_create_gmu();
    questCategories = ds_map_create_gmu();
    
    onQuestAccepted = undefined;
    onQuestCompleted = undefined;
    onQuestFailed = undefined;
    onQuestAbandoned = undefined;
    onObjectiveProgress = undefined;
    
    function RegisterTemplate(_template) {
        templates[? _template.id] = _template;
        return self;
    };
    
    function GetTemplate(_id) {
        return templates[? _id];
    };
    
    function HasTemplate(_id) {
        return ds_map_exists(templates, _id);
    };
    
    function RegisterChain(_chain) {
        chains[? _chain.name] = _chain;
        return self;
    };
    
    function GetChain(_name) {
        return chains[? _name];
    };
    
    function StartChain(_chainName, context) {
        var chain = chains[? _chainName];
        if (chain != undefined) {
            var firstQuest = chain.GetCurrentQuest();
            if (firstQuest != undefined) {
                return SpawnQuest(firstQuest);
            }
        }
        return undefined;
    };
    
    function SpawnQuest(_templateId, _customOnComplete = undefined, _customOnFail = undefined) {
        var template = GetTemplate(_templateId);
        if (template == undefined) return undefined;
        
        var newQuest = new Quest(
            template.name, 
            template.description, 
            _customOnComplete ?? template.onComplete, 
            _customOnFail ?? template.onFail
        );
        
        newQuest.SetId(template.id);
        newQuest.SetType(template.type);
        
        for (var i = 0; i < array_length(template.prerequisites); i++) {
            array_push(newQuest.prerequisites, template.prerequisites[i]);
        }
        
        var keys = ds_map_keys_to_array(template.objectives);
        for (var i = 0; i < array_length(keys); i++) {
            var key = keys[i];
            var templateObj = template.objectives[? key];
            
            var newObj = new QuestObjective(
                templateObj.id,
                templateObj.description,
                templateObj.goal,
                templateObj.type
            );
            newObj.SetTarget(templateObj.targetId);
            newObj.SetHidden(templateObj.hidden);
            newObj.SetOptional(templateObj.optional);
            if (templateObj.targetLocation != undefined) {
                newObj.SetLocation(
                    templateObj.targetLocation.x,
                    templateObj.targetLocation.y,
                    templateObj.targetLocation.radius
                );
            }
            
            newQuest.AddObjective(newObj);
        }
        
        newQuest.rewards = template.rewards;
        newQuest.bonusRewards = template.bonusRewards;
        newQuest.nextQuest = template.nextQuest;
        newQuest.childQuests = template.childQuests;
        
        newQuest.state = QUEST_STATE.AVAILABLE;
        
        return newQuest;
    };
    
    function UnlockQuest(_questId) {
        // This would notify the QuestTracker
        return self;
    };
    
    function SetOnQuestAccepted(_callback) { onQuestAccepted = _callback; return self; };
    function SetOnQuestCompleted(_callback) { onQuestCompleted = _callback; return self; };
    function SetOnQuestFailed(_callback) { onQuestFailed = _callback; return self; };
    function SetOnObjectiveProgress(_callback) { onObjectiveProgress = _callback; return self; };
    
    function Clear() {
        ds_map_clear(templates);
        ds_map_clear(chains);
        ds_map_clear(questCategories);
        return self;
    };
    
    function Free() {
        var arr = ds_map_values_to_array(templates);
        array_foreach(arr, function(q) { q.Free(); });
        
        ds_map_destroy_gmu(templates);
        ds_map_destroy_gmu(chains);
        ds_map_destroy_gmu(questCategories);
    };
    
    toString = function() {
        return $"QuestManager: {ds_map_size(templates)} templates, {ds_map_size(chains)} chains";
    };
}

function QuestTracker() constructor {
    quests = ds_map_create_gmu();
    completedQuests = [];
    activeQuestLimit = 10;
    
    onQuestAdded = undefined;
    onQuestRemoved = undefined;
    onQuestStateChanged = undefined;
    
    function AddQuest(_quest) {
        if (ds_map_exists(quests, _quest.id)) return self;
        if (GetActiveCount() >= activeQuestLimit) return self;
        
        quests[? _quest.id] = _quest;
        
        if (onQuestAdded != undefined) {
            onQuestAdded(_quest);
        }
        
        return self;
    };
    
    function RemoveQuest(_id) {
        if (!ds_map_exists(quests, _id)) return self;
        
        var quest = quests[? _id];
        ds_map_delete(quests, _id);
        
        if (onQuestRemoved != undefined) {
            onQuestRemoved(quest);
        }
        
        return self;
    };
    
    function GetQuest(_id) {
        return ds_map_exists(quests, _id) ? quests[? _id] : undefined;
    };
    
    function HasQuest(_id) {
        return ds_map_exists(quests, _id);
    };
    
    function IsQuestCompleted(_id) {
        for (var i = 0; i < array_length(completedQuests); i++) {
            if (completedQuests[i] == _id) return true;
        }
        
        if (ds_map_exists(quests, _id)) {
            return quests[? _id].IsComplete();
        }
        
        return false;
    };
    
    function AcceptQuest(_id, context) {
        var quest = GetQuest(_id);
        if (quest == undefined) return false;
        
        if (quest.Accept(context)) {
            if (onQuestStateChanged != undefined) {
                onQuestStateChanged(quest, QUEST_STATE.AVAILABLE, QUEST_STATE.ACTIVE);
            }
            return true;
        }
        return false;
    };
    
    function AbandonQuest(_id) {
        var quest = GetQuest(_id);
        if (quest == undefined) return false;
        
        quest.Abandon();
        
        if (onQuestStateChanged != undefined) {
            onQuestStateChanged(quest, QUEST_STATE.ACTIVE, QUEST_STATE.ABANDONED);
        }
        
        return true;
    };
    
    function CompleteQuest(_id, context) {
        var quest = GetQuest(_id);
        if (quest == undefined) return false;
        
        quest.Complete(context);
        
        array_push(completedQuests, _id);
        ds_map_delete(quests, _id);
        
        if (onQuestStateChanged != undefined) {
            onQuestStateChanged(quest, QUEST_STATE.ACTIVE, QUEST_STATE.COMPLETED);
        }
        
        return true;
    };
    
    function ProgressQuest(_questId, _objectiveId, _amount = 1, _data = undefined) {
        var quest = GetQuest(_questId);
        if (quest != undefined) {
            quest.ProgressObjective(_objectiveId, _amount, _data);
        }
        return self;
    };
    
    function ProgressByType(_type, _target = undefined, _amount = 1) {
        var keys = ds_map_keys_to_array(quests);
        for (var i = 0; i < array_length(keys); i++) {
            var quest = quests[? keys[i]];
            quest.ProgressByType(_type, _target, _amount);
        }
        return self;
    };
    
    function OnKill(_enemyId) { return ProgressByType("kill", _enemyId, 1); };
    function OnCollect(_itemId, _count = 1) { return ProgressByType("collect", _itemId, _count); };
    function OnTalk(_npcId) { return ProgressByType("talk", _npcId, 1); };
    
    function Update(context) {
        var keys = ds_map_keys_to_array(quests);
        
        for (var i = 0; i < array_length(keys); i++) {
            var quest = quests[? keys[i]];
            quest.Update(context);
            
            if (quest.IsComplete() && quest.state == QUEST_STATE.ACTIVE) {
                CompleteQuest(quest.id, context);
            }
        }
        
        return self;
    };
    
    function GetActiveQuests() {
        var result = [];
        var keys = ds_map_keys_to_array(quests);
        for (var i = 0; i < array_length(keys); i++) {
            var quest = quests[? keys[i]];
            if (quest.IsActive()) array_push(result, quest);
        }
        return result;
    };
    
    function GetAvailableQuests() {
        var result = [];
        var keys = ds_map_keys_to_array(quests);
        for (var i = 0; i < array_length(keys); i++) {
            var quest = quests[? keys[i]];
            if (quest.IsAvailable()) array_push(result, quest);
        }
        return result;
    };
    
    function GetCompletedQuests() { return completedQuests; };
    
    function GetActiveCount() {
        var count = 0;
        var keys = ds_map_keys_to_array(quests);
        for (var i = 0; i < array_length(keys); i++) {
            if (quests[? keys[i]].IsActive()) count++;
        }
        return count;
    };
    
    function GetAllQuestSummaries() {
        var summaries = [];
        var keys = ds_map_keys_to_array(quests);
        for (var i = 0; i < array_length(keys); i++) {
            array_push(summaries, quests[? keys[i]].GetSummary());
        }
        return summaries;
    };
    
    function Serialize() {
        var data = {
            completedQuests: completedQuests,
            quests: {}
        };
        
        var keys = ds_map_keys_to_array(quests);
        for (var i = 0; i < array_length(keys); i++) {
            var key = keys[i];
            data.quests[$ key] = quests[? key].Serialize();
        }
        
        return data;
    };
    
    function Deserialize(_data, _questManager) {
        completedQuests = _data.completedQuests;
        
        var keys = variable_struct_get_names(_data.quests);
        for (var i = 0; i < array_length(keys); i++) {
            var key = keys[i];
            
            if (_questManager != undefined) {
                var quest = _questManager.SpawnQuest(key);
                if (quest != undefined) {
                    quest.Deserialize(_data.quests[$ key]);
                    AddQuest(quest);
                }
            }
        }
        
        return self;
    };
    
    function Clear() {
        ds_map_clear(quests);
        completedQuests = [];
        return self;
    };
    
    function Free() {
        var arr = ds_map_values_to_array(quests);
        array_foreach(arr, function(q) { q.Free(); });
        ds_map_destroy_gmu(quests);
    };
    
    toString = function() {
        return $"QuestTracker: {GetActiveCount()} active, {array_length(completedQuests)} completed";
    };
}

function AchievementManager() constructor {
    achievements = ds_map_create_gmu();  // id -> {name, progress, goal, unlocked, hidden}
    callbacks = ds_map_create_gmu();     // id -> on_unlock callback
    categories = ds_map_create_gmu();    // category -> array of achievement IDs
    unlocked_count = 0;
    stats = ds_map_create_gmu();         // Tracked stats for achievements

    //  Achievement management
    function Add(_id, _name, _description = "", _goal = 1, _hidden = false, _category = "General", _on_unlock = undefined) {
        achievements[? _id] = {
            id: _id,
            name: _name,
            description: _description,
            progress: 0,
            goal: _goal,
            unlocked: false,
            hidden: _hidden,
            category: _category,
            unlocked_at: undefined,
            icon: undefined
        };
    
        // Add to category
        if (!ds_map_exists(categories, _category)) {
            categories[? _category] = [];
        }
        var catArray = categories[? _category];
        array_push(catArray, _id);
        categories[? _category] = catArray;
    
        if (_on_unlock != undefined) {
            callbacks[? _id] = _on_unlock;
        }
        return self;
    };
    
    function SetIcon(_id, _icon) {
        if (ds_map_exists(achievements, _id)) {
            achievements[? _id].icon = _icon;
        }
        return self;
    };
    
    function SetDescription(_id, _description) {
        if (ds_map_exists(achievements, _id)) {
            achievements[? _id].description = _description;
        }
        return self;
    };

    //  Progress tracking
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
    
    function SetProgress(_id, _amount) {
        if (!ds_map_exists(achievements, _id)) return self;
        var ach = achievements[? _id];
        if (ach.unlocked) return self;
    
        ach.progress = min(_amount, ach.goal);
    
        if (ach.progress >= ach.goal) {
            Unlock(_id);
        }
        return self;
    };
    
    function IncrementStat(_statId, _amount = 1) {
        var current = stats[? _statId] ?? 0;
        stats[? _statId] = current + _amount;
        return self;
    };
    
    function GetStat(_statId) {
        return stats[? _statId] ?? 0;
    };

    //  Unlocking
    function Unlock(_id) {
        if (!ds_map_exists(achievements, _id)) return self;
        var ach = achievements[? _id];
        if (ach.unlocked) return self;
    
        ach.unlocked = true;
        ach.unlocked_at = current_time;
        unlocked_count++;
    
        if (!ach.hidden) {
            show_debug_message($"[Achievement] Unlocked: {ach.name}");
            // UI notification would go here
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

    //  Queries
    function GetAll() {
        var result = {};
        var keys = ds_map_keys_to_array(achievements);
        for (var i = 0; i < array_length(keys); i++) {
            var _id = keys[i];
            var ach = achievements[? _id];
            result[$ _id] = {
                name: ach.name,
                description: ach.description,
                progress: ach.progress,
                goal: ach.goal,
                unlocked: ach.unlocked,
                unlocked_at: ach.unlocked_at,
                hidden: ach.hidden,
                category: ach.category
            };
        }
        return result;
    };
    
    function GetUnlocked() {
        var result = [];
        var keys = ds_map_keys_to_array(achievements);
        for (var i = 0; i < array_length(keys); i++) {
            var ach = achievements[? keys[i]];
            if (ach.unlocked) {
                array_push(result, keys[i]);
            }
        }
        return result;
    };
    
    function GetByCategory(_category) {
        if (!ds_map_exists(categories, _category)) return [];
        
        var result = [];
        var catArray = categories[? _category];
        for (var i = 0; i < array_length(catArray); i++) {
            var _id = catArray[i];
            var ach = achievements[? _id];
            if (!ach.hidden || ach.unlocked) {
                array_push(result, {
                    id: _id,
                    name: ach.name,
                    description: ach.description,
                    progress: ach.progress,
                    goal: ach.goal,
                    unlocked: ach.unlocked,
                    icon: ach.icon
                });
            }
        }
        return result;
    };
    
    function GetStats() {
        return {
            total: ds_map_size(achievements),
            unlocked: unlocked_count,
            percent: unlocked_count / max(1, ds_map_size(achievements)),
            stats: stats
        };
    };

    //  Serialization
    function Serialize() {
        var data = {
            achievements: {},
            stats: {},
            unlocked_count: unlocked_count
        };
        
        var keys = ds_map_keys_to_array(achievements);
        for (var i = 0; i < array_length(keys); i++) {
            var _id = keys[i];
            var ach = achievements[? _id];
            data.achievements[$ _id] = {
                progress: ach.progress,
                unlocked: ach.unlocked,
                unlocked_at: ach.unlocked_at
            };
        }
        
        var statKeys = ds_map_keys_to_array(stats);
        for (var i = 0; i < array_length(statKeys); i++) {
            var key = statKeys[i];
            data.stats[$ key] = stats[? key];
        }
        
        return data;
    };
    
    function Deserialize(_data) {
        unlocked_count = _data.unlocked_count ?? 0;
        
        var keys = variable_struct_get_names(_data.achievements);
        for (var i = 0; i < array_length(keys); i++) {
            var _id = keys[i];
            if (ds_map_exists(achievements, _id)) {
                var saved = _data.achievements[$ _id];
                achievements[? _id].progress = saved.progress;
                achievements[? _id].unlocked = saved.unlocked;
                achievements[? _id].unlocked_at = saved.unlocked_at;
            }
        }
        
        var statKeys = variable_struct_get_names(_data.stats);
        for (var i = 0; i < array_length(statKeys); i++) {
            var key = statKeys[i];
            stats[? key] = _data.stats[$ key];
        }
        
        return self;
    };

    //  Reset & Cleanup
    function Reset() {
        var keys = ds_map_keys_to_array(achievements);
        for (var i = 0; i < array_length(keys); i++) {
            var ach = achievements[? keys[i]];
            ach.progress = 0;
            ach.unlocked = false;
            ach.unlocked_at = undefined;
        }
        unlocked_count = 0;
        ds_map_clear(stats);
        return self;
    };
    
    function ResetStats() {
        ds_map_clear(stats);
        return self;
    };

    function Free() {
        ds_map_destroy_gmu(achievements);
        ds_map_destroy_gmu(callbacks);
        ds_map_destroy_gmu(categories);
        ds_map_destroy_gmu(stats);
    };
    
    toString = function() {
        return $"AchievementManager: {unlocked_count}/{ds_map_size(achievements)} unlocked";
    };
}

function SimpleInventory() constructor { //  SimpleInventory - Basic inventory system
    items = ds_map_create_gmu();        // itemId -> count
    maxSlots = 99;                      // Unlimited by default
    maxStackSize = 99;                  // Max items per stack
    
    // Callbacks
    onItemAdded = undefined;            // function(itemId, count, totalCount)
    onItemRemoved = undefined;          // function(itemId, count, totalCount)
    onInventoryFull = undefined;        // function(itemId, count)
    
    //  Item management
    function AddItem(itemId, count = 1) {
        if (count <= 0) return false;
        
        var currentCount = GetCount(itemId);
        var newCount = currentCount + count;
        
        // Check stack size limit
        if (newCount > maxStackSize) {
            if (onInventoryFull != undefined) {
                onInventoryFull(itemId, newCount - maxStackSize);
            }
            newCount = maxStackSize;
        }
        
        items[? itemId] = newCount;
        
        if (onItemAdded != undefined) {
            onItemAdded(itemId, count, newCount);
        }
        
        return true;
    };
    
    function RemoveItem(itemId, count = 1) {
        if (count <= 0) return false;
        if (!HasItem(itemId, count)) return false;
        
        var currentCount = GetCount(itemId);
        var newCount = currentCount - count;
        
        if (newCount <= 0) {
            ds_map_delete(items, itemId);
        } else {
            items[? itemId] = newCount;
        }
        
        if (onItemRemoved != undefined) {
            onItemRemoved(itemId, count, newCount);
        }
        
        return true;
    };
    
    function SetItem(itemId, count) {
        if (count <= 0) {
            ds_map_delete(items, itemId);
        } else {
            items[? itemId] = min(count, maxStackSize);
        }
        return self;
    };
    
    //  Queries
    function HasItem(itemId, count = 1) {
        return GetCount(itemId) >= count;
    };
    
    function GetCount(itemId) {
        return ds_map_exists(items, itemId) ? items[? itemId] : 0;
    };
    
    function GetAllItems() {
        var result = [];
        var keys = ds_map_keys_to_array(items);
        for (var i = 0; i < array_length(keys); i++) {
            var key = keys[i];
            array_push(result, { id: key, count: items[? key] });
        }
        return result;
    };
    
    function GetItemCount() {
        return ds_map_size(items);
    };
    
    function GetTotalItemCount() {
        var total = 0;
        var keys = ds_map_keys_to_array(items);
        for (var i = 0; i < array_length(keys); i++) {
            total += items[? keys[i]];
        }
        return total;
    };
    
    function IsFull() {
        return ds_map_size(items) >= maxSlots;
    };
    
    //  Configuration
    function SetMaxSlots(slots) {
        maxSlots = slots;
        return self;
    };
    
    function SetMaxStackSize(size) {
        maxStackSize = size;
        return self;
    };
    
    //  Utility
    function Clear() {
        ds_map_clear(items);
        return self;
    };
    
    function Serialize() {
        var data = {};
        var keys = ds_map_keys_to_array(items);
        for (var i = 0; i < array_length(keys); i++) {
            var key = keys[i];
            data[$ key] = items[? key];
        }
        return data;
    };
    
    function Deserialize(_data) {
        Clear();
        var keys = variable_struct_get_names(_data);
        for (var i = 0; i < array_length(keys); i++) {
            var key = keys[i];
            items[? key] = _data[$ key];
        }
        return self;
    };
    
    function Free() {
        ds_map_destroy_gmu(items);
    };
    
    toString = function() {
        return $"SimpleInventory: {GetItemCount()} types, {GetTotalItemCount()} total items";
    };
}

function SimpleCurrency() constructor { //  SimpleCurrency - Basic currency system (supports multiple currencies)
    currencies = ds_map_create_gmu();    // currencyId -> amount
    defaultCurrency = "gold";
    
    // Callbacks
    onCurrencyChanged = undefined;       // function(currencyId, oldAmount, newAmount, delta)
    
    //  Currency management
    function Add(amount, currencyId = undefined) {
        currencyId = currencyId ?? defaultCurrency;
        if (amount <= 0) return false;
        
        var oldAmount = Get(currencyId);
        var newAmount = oldAmount + amount;
        currencies[? currencyId] = newAmount;
        
        if (onCurrencyChanged != undefined) {
            onCurrencyChanged(currencyId, oldAmount, newAmount, amount);
        }
        
        return true;
    };
    
    function Spend(amount, currencyId = undefined) {
        currencyId = currencyId ?? defaultCurrency;
        if (amount <= 0) return false;
        if (!Has(amount, currencyId)) return false;
        
        var oldAmount = Get(currencyId);
        var newAmount = oldAmount - amount;
        currencies[? currencyId] = newAmount;
        
        if (onCurrencyChanged != undefined) {
            onCurrencyChanged(currencyId, oldAmount, newAmount, -amount);
        }
        
        return true;
    };
    
    function Set(amount, currencyId = undefined) {
        currencyId = currencyId ?? defaultCurrency;
        if (amount < 0) amount = 0;
        
        var oldAmount = Get(currencyId);
        currencies[? currencyId] = amount;
        
        if (onCurrencyChanged != undefined) {
            onCurrencyChanged(currencyId, oldAmount, amount, amount - oldAmount);
        }
        
        return self;
    };
    
    //  Queries
    function Get(currencyId = undefined) {
        currencyId = currencyId ?? defaultCurrency;
        return ds_map_exists(currencies, currencyId) ? currencies[? currencyId] : 0;
    };
    
    function Has(amount, currencyId = undefined) {
        return Get(currencyId) >= amount;
    };
    
    function GetAll() {
        var result = {};
        var keys = ds_map_keys_to_array(currencies);
        for (var i = 0; i < array_length(keys); i++) {
            var key = keys[i];
            result[$ key] = currencies[? key];
        }
        return result;
    };
    
    function GetCurrencyTypes() {
        return ds_map_keys_to_array(currencies);
    };
    
    //  Configuration
    function SetDefaultCurrency(currencyId) {
        defaultCurrency = currencyId;
        return self;
    };
    
    //  Utility
    function Clear() {
        ds_map_clear(currencies);
        return self;
    };
    
    function Serialize() {
        var data = {};
        var keys = ds_map_keys_to_array(currencies);
        for (var i = 0; i < array_length(keys); i++) {
            var key = keys[i];
            data[$ key] = currencies[? key];
        }
        return data;
    };
    
    function Deserialize(_data) {
        Clear();
        var keys = variable_struct_get_names(_data);
        for (var i = 0; i < array_length(keys); i++) {
            var key = keys[i];
            currencies[? key] = _data[$ key];
        }
        return self;
    };
    
    function Free() {
        ds_map_destroy_gmu(currencies);
    };
    
    toString = function() {
        var str = "SimpleCurrency: ";
        var keys = ds_map_keys_to_array(currencies);
        for (var i = 0; i < array_length(keys); i++) {
            str += $"{keys[i]}={currencies[? keys[i]]}";
            if (i < array_length(keys) - 1) str += ", ";
        }
        return str;
    };
}

function SimplePlayer() constructor { //  SimplePlayer - Basic player stats for quest system
    x = 0;
    y = 0;
    level = 1;
    exp = 0;
    expToNextLevel = 100;
    skillPoints = 0;
    
    // Callbacks
    onLevelUp = undefined;               // function(oldLevel, newLevel)
    onExpGained = undefined;             // function(amount, currentExp, expToNext)
    
    //  Position
    function SetPosition(_x, _y) {
        x = _x;
        y = _y;
        return self;
    };
    
    //  Level & Experience
    function GetLevel() {
        return level;
    };
    
    function AddExperience(amount) {
        if (amount <= 0) return self;
        
        exp += amount;
        
        if (onExpGained != undefined) {
            onExpGained(amount, exp, expToNextLevel);
        }
        
        // Check for level up
        while (exp >= expToNextLevel) {
            LevelUp();
        }
        
        return self;
    };
    
    function LevelUp() {
        var oldLevel = level;
        exp -= expToNextLevel;
        level++;
        expToNextLevel = CalculateExpForLevel(level + 1);
        skillPoints++;
        
        if (onLevelUp != undefined) {
            onLevelUp(oldLevel, level);
        }
        
        return self;
    };
    
    function CalculateExpForLevel(targetLevel) {
        // Simple formula: 100 * level
        return targetLevel * 100;
    };
    
    function SetLevel(_level) {
        level = max(1, _level);
        expToNextLevel = CalculateExpForLevel(level + 1);
        return self;
    };
    
    function GetExpProgress() {
        return exp / expToNextLevel;
    };
    
    //  Skill Points
    function AddSkillPoint(amount = 1) {
        skillPoints += amount;
        return self;
    };
    
    function SpendSkillPoint(amount = 1) {
        if (skillPoints >= amount) {
            skillPoints -= amount;
            return true;
        }
        return false;
    };
    
    function GetSkillPoints() {
        return skillPoints;
    };
    
    //  Serialization
    function Serialize() {
        return {
            x: x,
            y: y,
            level: level,
            exp: exp,
            expToNextLevel: expToNextLevel,
            skillPoints: skillPoints
        };
    };
    
    function Deserialize(_data) {
        x = _data.x ?? 0;
        y = _data.y ?? 0;
        level = _data.level ?? 1;
        exp = _data.exp ?? 0;
        expToNextLevel = _data.expToNextLevel ?? 100;
        skillPoints = _data.skillPoints ?? 0;
        return self;
    };
    
    toString = function() {
        return $"SimplePlayer: Lvl {level} ({exp}/{expToNextLevel} XP), {skillPoints} SP";
    };
}
