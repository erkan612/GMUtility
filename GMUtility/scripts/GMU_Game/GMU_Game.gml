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

enum QUEST_TYPE {
    MAIN,               // Main story quest
    SIDE,               // Optional side quest
    REPEATABLE,         // Can be done multiple times
    DAILY,              // Daily quest
    EVENT,              // Time-limited event
    HIDDEN              // Secret quest
}

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

function Reward(_type, _value, _id = undefined) constructor {
    type = _type;
    value = _value;
    id = _id;                       // For items, quest IDs, etc.
    customHandler = undefined;      // For CUSTOM type
    
    function SetCustomHandler(_handler) {
        customHandler = _handler;
        return self;
    };
    
    function Give(_target = undefined) {
        switch(type) {
            case REWARD_TYPE.EXPERIENCE:
                if (is_struct(_target) && struct_has_method(_target, "AddExperience")) {
                    _target.AddExperience(value);
                } else if (instance_exists(_target)) {
                    _target.exp += value;
                }
                break;
                
            case REWARD_TYPE.CURRENCY:
                if (variable_global_exists("currency")) {
                    global.currency += value;
                }
                break;
                
            case REWARD_TYPE.ITEM:
                if (is_struct(_target) && struct_has_method(_target, "AddItem")) {
                    _target.AddItem(id, value);
                } else {
                    // Fallback: global inventory
                    if (variable_global_exists("inventory")) {
                        global.inventory.Add(id, value);
                    }
                }
                break;
                
            case REWARD_TYPE.SKILL_POINT:
                if (is_struct(_target) && struct_has_method(_target, "AddSkillPoint")) {
                    _target.AddSkillPoint(value);
                }
                break;
                
            case REWARD_TYPE.UNLOCK_QUEST:
                if (variable_global_exists("QuestManager")) {
                    global.QuestManager.UnlockQuest(id);
                }
                break;
                
            case REWARD_TYPE.UNLOCK_ACHIEVEMENT:
                if (variable_global_exists("AchievementManager")) {
                    global.AchievementManager.Unlock(id);
                }
                break;
                
            case REWARD_TYPE.REPUTATION:
                if (is_struct(_target) && struct_has_method(_target, "AddReputation")) {
                    _target.AddReputation(id, value);
                }
                break;
                
            case REWARD_TYPE.CUSTOM:
                if (customHandler != undefined) {
                    customHandler(_target);
                }
                break;
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
        var reward = new Reward(_data.type, _data.value, _data.id);
        return reward;
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
    
    function AddCurrency(_amount) {
        return Add(REWARD_TYPE.CURRENCY, _amount);
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
    
    function Give(_target = undefined) {
        for (var i = 0; i < array_length(rewards); i++) {
            rewards[i].Give(_target);
        }
        return self;
    };
    
    function GetTotalExperience() {
        var total = 0;
        for (var i = 0; i < array_length(rewards); i++) {
            if (rewards[i].type == REWARD_TYPE.EXPERIENCE) total += rewards[i].value;
        }
        return total;
    };
    
    function GetTotalCurrency() {
        var total = 0;
        for (var i = 0; i < array_length(rewards); i++) {
            if (rewards[i].type == REWARD_TYPE.CURRENCY) total += rewards[i].value;
        }
        return total;
    };
    
    function GetItems() {
        var items = [];
        for (var i = 0; i < array_length(rewards); i++) {
            if (rewards[i].type == REWARD_TYPE.ITEM) {
                array_push(items, { id: rewards[i].id, count: rewards[i].value });
            }
        }
        return items;
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

function QuestPrerequisite(_type, _target, _value = 1) constructor {//  QuestPrerequisite - Condition that must be met to start quest
    type = _type;           // "quest", "level", "item", "reputation", "flag", "custom"
    target = _target;       // Quest ID, level number, item ID, flag name, etc.
    value = _value;         // Required value
    customCheck = undefined;
    
    function SetCustomCheck(_check) {
        customCheck = _check;
        return self;
    };
    
    function IsMet(_player = undefined) {
        switch(type) {
            case "quest":
                if (variable_global_exists("QuestTracker")) {
                    var quest = global.QuestTracker.GetQuest(target);
                    return quest != undefined && quest.state == QUEST_STATE.COMPLETED;
                }
                return false;
                
            case "level":
                if (is_struct(_player) && struct_has_method(_player, "GetLevel")) {
                    return _player.GetLevel() >= value;
                } else if (instance_exists(_player)) {
                    return _player.level >= value;
                } else if (variable_global_exists("playerLevel")) {
                    return global.playerLevel >= value;
                }
                return false;
                
            case "item":
                if (is_struct(_player) && struct_has_method(_player, "HasItem")) {
                    return _player.HasItem(target, value);
                } else if (variable_global_exists("inventory")) {
                    return global.inventory.GetCount(target) >= value;
                }
                return false;
                
            case "reputation":
                if (is_struct(_player) && struct_has_method(_player, "GetReputation")) {
                    return _player.GetReputation(target) >= value;
                }
                return false;
                
            case "flag":
                if (variable_global_exists("flags")) {
                    return global.flags.Has(target);
                }
                return false;
                
            case "custom":
                if (customCheck != undefined) {
                    return customCheck(_player);
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

function QuestObjective(_id, _description, _goal = 1, _type = "generic") constructor { //  QuestObjective - Single objective within a quest
    id = _id;
    description = _description;
    goal = _goal;
    type = _type;               // "kill", "collect", "talk", "reach", "wait", "custom"
    progress = 0;
    completed = false;
    hidden = false;             // Hidden until revealed
    optional = false;           // Optional objective
    
    // Target tracking
    targetId = undefined;       // Enemy ID, item ID, NPC ID, etc.
    targetLocation = undefined; // { x, y, radius } for "reach" type
    
    // Callbacks
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
        
        var oldProgress = progress;
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
    
    function Update(_player = undefined) {
        if (completed) return self;
        
        if (customUpdate != undefined) {
            customUpdate(self, _player);
        } else if (customCheck != undefined) {
            if (customCheck(_player)) {
                AddProgress(1);
            }
        } else {
            // Auto-update based on type
            switch(type) {
                case "reach":
                    if (targetLocation != undefined && _player != undefined) {
                        var dist = point_distance(_player.x, _player.y, 
                                                   targetLocation.x, targetLocation.y);
                        if (dist <= targetLocation.radius) {
                            AddProgress(goal); // Complete immediately
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

function Quest(_name, _description, _onComplete, _onFail) constructor { //  Quest - Main quest class
    id = IDGenerate().GUID();
    name = _name;
    description = _description;
    type = QUEST_TYPE.SIDE;
    
    // State
    state = QUEST_STATE.INACTIVE;
    acceptedTime = -1;
    completedTime = -1;
    expireTime = -1;                // -1 = never expires
    
    // Objectives
    objectives = ds_map_create_gmu();
    objectiveOrder = [];            // For sequential objectives
    
    // Prerequisites
    prerequisites = [];
    
    // Rewards
    rewards = new RewardBundle();
    bonusRewards = new RewardBundle();  // For optional objectives
    
    // Dependencies
    nextQuest = undefined;          // Quest ID to unlock after completion
    childQuests = [];               // Quests unlocked by this one
    
    // Giver info
    questGiver = undefined;         // NPC ID or name
    questGiverLocation = undefined;
    
    // Dialogue/Story
    startDialogue = undefined;
    progressDialogue = undefined;
    completeDialogue = undefined;
    
    // Callbacks
    onComplete = _onComplete;
    onFail = _onFail;
    onAccept = undefined;
    onAbandon = undefined;
    onObjectiveComplete = undefined;
    
    // Custom data
    customData = undefined;
    
    //  Configuration methods
    function SetType(_type) {
        type = _type;
        return self;
    };
    
    function SetId(_id) {
        id = _id;
        return self;
    };
    
    function SetQuestGiver(_npcId, _location = undefined) {
        questGiver = _npcId;
        questGiverLocation = _location;
        return self;
    };
    
    function SetExpireTime(_seconds) {
        expireTime = _seconds;
        return self;
    };
    
    function SetNextQuest(_questId) {
        nextQuest = _questId;
        return self;
    };
    
    function AddChildQuest(_questId) {
        array_push(childQuests, _questId);
        return self;
    };
    
    //  Prerequisites
    function AddPrerequisite(_type, _target, _value = 1) {
        array_push(prerequisites, new QuestPrerequisite(_type, _target, _value));
        return self;
    };
    
    function RequireQuest(_questId) {
        return AddPrerequisite("quest", _questId);
    };
    
    function RequireLevel(_level) {
        return AddPrerequisite("level", "", _level);
    };
    
    function RequireItem(_itemId, _count = 1) {
        return AddPrerequisite("item", _itemId, _count);
    };
    
    function RequireReputation(_factionId, _amount) {
        return AddPrerequisite("reputation", _factionId, _amount);
    };
    
    function RequireFlag(_flagName) {
        return AddPrerequisite("flag", _flagName);
    };
    
    function RequireCustom(_check) {
        var prereq = new QuestPrerequisite("custom", "", 1);
        prereq.SetCustomCheck(_check);
        array_push(prerequisites, prereq);
        return self;
    };
    
    function CheckPrerequisites(_player = undefined) {
        for (var i = 0; i < array_length(prerequisites); i++) {
            if (!prerequisites[i].IsMet(_player)) {
                return false;
            }
        }
        return true;
    };
    
    //  Objectives
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
    
    function AddWaitObjective(_id, _seconds, _description) {
        var obj = new QuestObjective(_id, _description, _seconds, "wait");
        obj.SetCustomUpdate(function(self, player) {
            self.timer = is_undefined(self.timer) ? 0 : self.timer + delta_time;
            if (self.timer >= self.goal) {
                self.AddProgress(self.goal);
            }
        });
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
    
    //  Rewards
    function AddReward(_type, _value, _id = undefined) {
        rewards.Add(_type, _value, _id);
        return self;
    };
    
    function AddBonusReward(_type, _value, _id = undefined) {
        bonusRewards.Add(_type, _value, _id);
        return self;
    };
    
    function GetRewards() {
        return rewards;
    };
    
    function GetBonusRewards() {
        return bonusRewards;
    };
    
    //  Dialogue
    function SetStartDialogue(_dialogueId) {
        startDialogue = _dialogueId;
        return self;
    };
    
    function SetProgressDialogue(_dialogueId) {
        progressDialogue = _dialogueId;
        return self;
    };
    
    function SetCompleteDialogue(_dialogueId) {
        completeDialogue = _dialogueId;
        return self;
    };
    
    //  State control
    function CanAccept(_player = undefined) {
        return state == QUEST_STATE.AVAILABLE && CheckPrerequisites(_player);
    };
    
    function Accept(_player = undefined) {
        if (!CanAccept(_player)) return false;
        
        state = QUEST_STATE.ACTIVE;
        acceptedTime = current_time;
        
        if (onAccept != undefined) {
            onAccept(self, _player);
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
    
    function Update(_player = undefined) {
        if (state != QUEST_STATE.ACTIVE) return self;
        
        // Check expiration
        if (expireTime > 0) {
            var elapsed = (current_time - acceptedTime) / 1000000; // microseconds to seconds
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
            obj.Update(_player);
            
            if (obj.IsRequired() && !obj.IsComplete()) {
                allRequiredComplete = false;
            }
        }
        
        // Check completion
        if (allRequiredComplete) {
            Complete(_player);
        }
        
        return self;
    };
    
    function Complete(_player = undefined) {
        if (state != QUEST_STATE.ACTIVE) return self;
        
        state = QUEST_STATE.COMPLETED;
        completedTime = current_time;
        
        // Give rewards
        rewards.Give(_player);
        
        // Give bonus rewards for completed optional objectives
        var keys = ds_map_keys_to_array(objectives);
        for (var i = 0; i < array_length(keys); i++) {
            var obj = objectives[? keys[i]];
            if (obj.optional && obj.IsComplete()) {
                bonusRewards.Give(_player);
            }
        }
        
        // Unlock next quest
        if (nextQuest != undefined && variable_global_exists("QuestManager")) {
            global.QuestManager.UnlockQuest(nextQuest);
        }
        
        // Unlock child quests
        for (var i = 0; i < array_length(childQuests); i++) {
            if (variable_global_exists("QuestManager")) {
                global.QuestManager.UnlockQuest(childQuests[i]);
            }
        }
        
        if (is_callable(onComplete)) onComplete(self);
        
        return self;
    };
    
    function IsComplete() {
        return state == QUEST_STATE.COMPLETED;
    };
    
    function IsActive() {
        return state == QUEST_STATE.ACTIVE;
    };
    
    function IsAvailable() {
        return state == QUEST_STATE.AVAILABLE;
    };
    
    function IsLocked() {
        return state == QUEST_STATE.LOCKED;
    };
    
    //  Serialization
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
    
    //  Utility
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

function QuestChain(_name) constructor { //  QuestChain - Series of quests that must be completed in order
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

function QuestManager() constructor { //  QuestManager - Manages all quests and templates
    templates = ds_map_create_gmu();     // Quest templates by ID
    chains = ds_map_create_gmu();        // Quest chains by ID
    questCategories = ds_map_create_gmu(); // Quests by category
    
    // Events
    onQuestAccepted = undefined;
    onQuestCompleted = undefined;
    onQuestFailed = undefined;
    onQuestAbandoned = undefined;
    onObjectiveProgress = undefined;
    
    //  Template management
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
    
    //  Chain management
    function RegisterChain(_chain) {
        chains[? _chain.name] = _chain;
        return self;
    };
    
    function GetChain(_name) {
        return chains[? _name];
    };
    
    function StartChain(_chainName) {
        var chain = chains[? _chainName];
        if (chain != undefined) {
            var firstQuest = chain.GetCurrentQuest();
            if (firstQuest != undefined) {
                return SpawnQuest(firstQuest);
            }
        }
        return undefined;
    };
    
    //  Quest spawning
    function SpawnQuest(_templateId, _customOnComplete = undefined, _customOnFail = undefined) {
        var template = GetTemplate(_templateId);
        if (template == undefined) return undefined;
        
        // Create a new quest instance from template
        var newQuest = new Quest(
            template.name, 
            template.description, 
            _customOnComplete ?? template.onComplete, 
            _customOnFail ?? template.onFail
        );
        
        // Copy properties
        newQuest.SetId(template.id);
        newQuest.SetType(template.type);
        
        // Copy prerequisites
        for (var i = 0; i < array_length(template.prerequisites); i++) {
            array_push(newQuest.prerequisites, template.prerequisites[i]);
        }
        
        // Copy objectives
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
        
        // Copy rewards
        newQuest.rewards = template.rewards;
        newQuest.bonusRewards = template.bonusRewards;
        newQuest.nextQuest = template.nextQuest;
        newQuest.childQuests = template.childQuests;
        
        // Set state to AVAILABLE (will be unlocked if prereqs met)
        newQuest.state = QUEST_STATE.AVAILABLE;
        
        return newQuest;
    };
    
    function UnlockQuest(_questId) {
        // This would be called when prerequisites are met
        // Implementation depends on how quests are stored
        if (variable_global_exists("QuestTracker")) {
            var quest = global.QuestTracker.GetQuest(_questId);
            if (quest != undefined) {
                quest.state = QUEST_STATE.AVAILABLE;
            }
        }
        return self;
    };
    
    //  Event handlers
    function SetOnQuestAccepted(_callback) {
        onQuestAccepted = _callback;
        return self;
    };
    
    function SetOnQuestCompleted(_callback) {
        onQuestCompleted = _callback;
        return self;
    };
    
    function SetOnQuestFailed(_callback) {
        onQuestFailed = _callback;
        return self;
    };
    
    function SetOnObjectiveProgress(_callback) {
        onObjectiveProgress = _callback;
        return self;
    };
    
    //  Cleanup
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

function QuestTracker() constructor { //  QuestTracker - Tracks player's active and completed quests
    quests = ds_map_create_gmu();           // All tracked quests
    completedQuests = [];                   // List of completed quest IDs
    activeQuestLimit = 10;                  // Max active quests
    
    // Events
    onQuestAdded = undefined;
    onQuestRemoved = undefined;
    onQuestStateChanged = undefined;
    
    //  Quest management
    function AddQuest(_quest) {
        if (ds_map_exists(quests, _quest.id)) {
            show_debug_message($"[QuestTracker] Quest {_quest.id} already tracked");
            return self;
        }
        
        if (GetActiveCount() >= activeQuestLimit) {
            show_debug_message($"[QuestTracker] Cannot add quest - active limit reached");
            return self;
        }
        
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
    
    //  Quest actions
    function AcceptQuest(_id, _player = undefined) {
        var quest = GetQuest(_id);
        if (quest == undefined) return false;
        
        if (quest.Accept(_player)) {
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
    
    function CompleteQuest(_id, _player = undefined) {
        var quest = GetQuest(_id);
        if (quest == undefined) return false;
        
        quest.Complete(_player);
        
        // Move to completed list
        array_push(completedQuests, _id);
        ds_map_delete(quests, _id);
        
        if (onQuestStateChanged != undefined) {
            onQuestStateChanged(quest, QUEST_STATE.ACTIVE, QUEST_STATE.COMPLETED);
        }
        
        return true;
    };
    
    //  Progress tracking
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
    
    // Kill tracking convenience
    function OnKill(_enemyId) {
        return ProgressByType("kill", _enemyId, 1);
    };
    
    // Collect tracking convenience
    function OnCollect(_itemId, _count = 1) {
        return ProgressByType("collect", _itemId, _count);
    };
    
    // Talk tracking convenience
    function OnTalk(_npcId) {
        return ProgressByType("talk", _npcId, 1);
    };
    
    //  Update
    function Update(_player = undefined) {
        var keys = ds_map_keys_to_array(quests);
        
        for (var i = 0; i < array_length(keys); i++) {
            var quest = quests[? keys[i]];
            var oldState = quest.state;
            
            quest.Update(_player);
            
            // Check for auto-completion
            if (quest.IsComplete() && quest.state == QUEST_STATE.ACTIVE) {
                CompleteQuest(quest.id, _player);
            }
        }
        
        return self;
    };
    
    //  Queries
    function GetActiveQuests() {
        var result = [];
        var keys = ds_map_keys_to_array(quests);
        
        for (var i = 0; i < array_length(keys); i++) {
            var quest = quests[? keys[i]];
            if (quest.IsActive()) {
                array_push(result, quest);
            }
        }
        
        return result;
    };
    
    function GetAvailableQuests() {
        var result = [];
        var keys = ds_map_keys_to_array(quests);
        
        for (var i = 0; i < array_length(keys); i++) {
            var quest = quests[? keys[i]];
            if (quest.IsAvailable()) {
                array_push(result, quest);
            }
        }
        
        return result;
    };
    
    function GetCompletedQuests() {
        return completedQuests;
    };
    
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
    
    //  Serialization
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
            
            // Spawn quest from template then deserialize state
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
    
    //  Cleanup
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

function AchievementManager() constructor { //  AchievementManager - Tracks achievements and progress
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