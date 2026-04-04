/*********************************************************************************************
*                                        MIT License                                         *
*--------------------------------------------------------------------------------------------*
* Copyright (c) 2025 erkan612                                                                *
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
*   					 ***********************************************                     *
*   					 ██╗  ██╗██╗███████╗███╗   ███╗███████╗████████╗		             *
*   					 ██║ ██╔╝██║██╔════╝████╗ ████║██╔════╝╚══██╔══╝		             *
*   					 █████╔╝ ██║███████╗██╔████╔██║█████╗     ██║   		             *
*   					 ██╔═██╗ ██║╚════██║██║╚██╔╝██║██╔══╝     ██║   		             *
*   					 ██║  ██╗██║███████║██║ ╚═╝ ██║███████╗   ██║   		             *
*   					 ╚═╝  ╚═╝╚═╝╚══════╝╚═╝     ╚═╝╚══════╝   ╚═╝   		             *
*   							Utility framework for GameMaker								 *
*   						             Version 1.0.0										 *
*   																                         *
*   						              by erkan612					                     *
*   					 ***********************************************                     *
*********************************************************************************************/


// KISMET NAMESPACE
#macro KISMET_NAMESPACE_INIT				globalvar MemoryTracker; MemoryTracker = new MemoryTracker(); globalvar KISMET; KISMET = new KISMET
#macro KISMET_VERSION						"1.0.0"

// CMD Macros
#macro CMD_PAUSE							KISMET.DefaultCommandManager.Push(KISMET_COMMAND.GAME_PAUSE)
#macro CMD_RESUME							KISMET.DefaultCommandManager.Push(KISMET_COMMAND.GAME_RESUME)
#macro CMD_QUIT								KISMET.DefaultCommandManager.Push(KISMET_COMMAND.GAME_QUIT)
#macro CMD_RESTART							KISMET.DefaultCommandManager.Push(KISMET_COMMAND.GAME_RESTART)
#macro CMD_TOGGLE_PAUSE						KISMET.DefaultCommandManager.Push(KISMET_COMMAND.GAME_TOGGLE_PAUSE)

#macro CMD_ROOM_RESTART						KISMET.DefaultCommandManager.Push(KISMET_COMMAND.ROOM_RESTART)
#macro CMD_ROOM_PREV						KISMET.DefaultCommandManager.Push(KISMET_COMMAND.ROOM_PREVIOUS)
#macro CMD_ROOM_NEXT						KISMET.DefaultCommandManager.Push(KISMET_COMMAND.ROOM_NEXT)

#macro CMD_PLAYER_JUMP						KISMET.DefaultCommandManager.Push(KISMET_COMMAND.PLAYER_JUMP)
#macro CMD_PLAYER_ATTACK					KISMET.DefaultCommandManager.Push(KISMET_COMMAND.PLAYER_ATTACK)
#macro CMD_PLAYER_INTERACT					KISMET.DefaultCommandManager.Push(KISMET_COMMAND.PLAYER_INTERACT)
#macro CMD_PLAYER_DASH						KISMET.DefaultCommandManager.Push(KISMET_COMMAND.PLAYER_DASH)

#macro CMD_UI_OPEN_MENU						KISMET.DefaultCommandManager.Push(KISMET_COMMAND.UI_OPEN_MENU)
#macro CMD_UI_CLOSE_MENU					KISMET.DefaultCommandManager.Push(KISMET_COMMAND.UI_CLOSE_MENU)
#macro CMD_UI_TOGGLE_INVENTORY				KISMET.DefaultCommandManager.Push(KISMET_COMMAND.UI_TOGGLE_INVENTORY)

#macro CMD_AUDIO_STOP_MUSIC					KISMET.DefaultCommandManager.Push(KISMET_COMMAND.AUDIO_STOP_MUSIC)
#macro CMD_AUDIO_MUTE						KISMET.DefaultCommandManager.Push(KISMET_COMMAND.AUDIO_MUTE)
#macro CMD_AUDIO_UNMUTE						KISMET.DefaultCommandManager.Push(KISMET_COMMAND.AUDIO_UNMUTE)

#macro CMD_CAMERA_ZOOM_IN					KISMET.DefaultCommandManager.Push(KISMET_COMMAND.CAMERA_ZOOM_IN)
#macro CMD_CAMERA_ZOOM_OUT					KISMET.DefaultCommandManager.Push(KISMET_COMMAND.CAMERA_ZOOM_OUT)
#macro CMD_CAMERA_RESET						KISMET.DefaultCommandManager.Push(KISMET_COMMAND.CAMERA_RESET)

#macro CMD_TIME_NORMAL						KISMET.DefaultCommandManager.Push(KISMET_COMMAND.TIME_NORMAL)

#macro CMD_SCREENSHOT						KISMET.DefaultCommandManager.Push(KISMET_COMMAND.SYSTEM_SCREENSHOT)
#macro CMD_TOGGLE_FULLSCREEN				KISMET.DefaultCommandManager.Push(KISMET_COMMAND.SYSTEM_FULLSCREEN)
#macro CMD_DEBUG_INFO						KISMET.DefaultCommandManager.Push(KISMET_COMMAND.SYSTEM_DEBUG_INFO)

function CMD_ROOM(room) { KISMET.DefaultCommandManager.Push(KISMET_COMMAND.ROOM_GOTO, room); }

function CMD_PLAYER_SKILL(skillNum) { KISMET.DefaultCommandManager.Push(KISMET_COMMAND.PLAYER_SKILL_1 + (skillNum - 1)); }

function CMD_AUDIO_PLAY_MUSIC(music) { KISMET.DefaultCommandManager.Push(KISMET_COMMAND.AUDIO_PLAY_MUSIC, music); }
function CMD_AUDIO_PLAY_SFX(sfx) { KISMET.DefaultCommandManager.Push(KISMET_COMMAND.AUDIO_PLAY_SFX, sfx); }

function CMD_CAMERA_SHAKE(magnitude, decay = 0.9) { KISMET.DefaultCommandManager.Push(KISMET_COMMAND.CAMERA_SHAKE, { mag: magnitude, decay: decay }); }

function CMD_TIME_SLOW_MOTION(factor) { KISMET.DefaultCommandManager.Push(KISMET_COMMAND.TIME_SLOW_MOTION, factor); }

function CMD_ADD_GOLD(amount) { KISMET.DefaultCommandManager.Push(KISMET_COMMAND.ECONOMY_ADD_GOLD, amount); }
function CMD_REMOVE_GOLD(amount) { KISMET.DefaultCommandManager.Push(KISMET_COMMAND.ECONOMY_REMOVE_GOLD, amount); }
function CMD_ADD_ITEM(itemId, amount = 1) { KISMET.DefaultCommandManager.Push(KISMET_COMMAND.INVENTORY_ADD_ITEM, { id: itemId, amount: amount }); }
function CMD_REMOVE_ITEM(itemId, amount = 1) { KISMET.DefaultCommandManager.Push(KISMET_COMMAND.INVENTORY_REMOVE_ITEM, { id: itemId, amount: amount }); }

function KISMET_TRACKED_OBJECT(__constructor) { KISMET.TrackedObject.CreateTracked(__constructor); }
function KISMET_WEAK_CALLBACK(__target, __method) { return new KISMET.WeakCallback(__target, __method); }
function KISMET_MEMORY_STATS() { show_debug_message("KISMET Memory: " + string(KISMET.Memory.GetStats())) }

// Other Macros
function IS_KISMET_DEBUG_ENABLED() { if (variable_global_exists("KISMET_DEBUG") && variable_global_get("KISMET_DEBUG") == true) { return true }; }

// ENUMS
enum KISMET_MOVEMENT {
	NONE									= 0, 
	LEFT									= -1, 
	RIGHT									= 1, 
	UP										= -1, 
	DOWN									= 1
}
enum KISMET_GAME_STATE {
    BOOT,
    INIT,
    LOADING,
    
    TITLE,
    MAIN_MENU,
    OPTIONS,
    
    PLAY,
    PAUSE,
    RESUME,
    TRANSITION,
    
    GAMEOVER,
    VICTORY,
    DEFEAT,
    GAME_COMPLETE,
    
    CUTSCENE,
    DIALOGUE,
    CINEMATIC,
    FREEZE,
    SLOW_MOTION,
    
    INVENTORY,
    SHOP,
    CRAFTING,
    SKILL_TREE,
    QUEST_LOG,
    JOURNAL,
    MAP,
    SETTINGS,
    SAVE_MENU,
    LOAD_MENU,
    
    LOBBY,
    MATCHMAKING,
    IN_GAME_MENU,
    SPECTATE,
    
    DEBUG,
    SANDBOX,
    TESTING
}
enum KISMET_ALIGNMENT {
    LEFT,
    CENTER,
    RIGHT,
    
    TOP,
    MIDDLE,
    BOTTOM,
    
    TOP_LEFT,
    TOP_CENTER,
    TOP_RIGHT,
    MIDDLE_LEFT,
    MIDDLE_CENTER,
    MIDDLE_RIGHT,
    BOTTOM_LEFT,
    BOTTOM_CENTER,
    BOTTOM_RIGHT,
    
    JUSTIFY,
    AUTO
}
enum KISMET_TASK_STATE {
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
enum KISMET_COMMAND {
    UI_CLOSE_NPC,
    UI_CLOSE_MENU,
    UI_OPEN_MENU,
    UI_CLOSE_DIALOG,
    UI_OPEN_DIALOG,
    UI_TOGGLE_INVENTORY,
    UI_OPEN_SHOP,
    UI_CLOSE_SHOP,
    UI_OPEN_SETTINGS,
    UI_CLOSE_SETTINGS,
    UI_OPEN_STATS,
    UI_CLOSE_STATS,
    UI_OPEN_SKILL_TREE,
    UI_CLOSE_SKILL_TREE,
    UI_OPEN_QUEST_LOG,
    UI_CLOSE_QUEST_LOG,
    UI_OPEN_MAIN_MENU,
    UI_CLOSE_MAIN_MENU,
    UI_OPEN_PAUSE_MENU,
    UI_CLOSE_PAUSE_MENU,
    UI_OPEN_CONFIRM_DIALOG,
    UI_CLOSE_CONFIRM_DIALOG,
    UI_TOOLTIP_SHOW,
    UI_TOOLTIP_HIDE,
    UI_NOTIFICATION_PUSH,
    UI_NOTIFICATION_CLEAR,
    UI_HUD_HIDE,
    UI_HUD_SHOW,
    UI_TOGGLE_HUD,
    UI_CURSOR_SET,
    UI_CURSOR_RESET,
    UI_FADE_IN,
    UI_FADE_OUT,
    
    GAME_PAUSE,
    GAME_RESUME,
    GAME_SAVE,
    GAME_LOAD,
    GAME_QUIT,
    GAME_RESTART,
    GAME_TOGGLE_PAUSE,
    GAME_START,
    GAME_OVER,
    GAME_WIN,
    GAME_LOSE,
    GAME_RESET,
    GAME_CLEAR_DATA,
    GAME_NEW_GAME,
    GAME_CONTINUE,
    GAME_SAVE_QUIT,
    GAME_AUTO_SAVE,
    GAME_AUTO_LOAD,
    
    ROOM_GOTO,
    ROOM_RESTART,
    ROOM_PREVIOUS,
    ROOM_NEXT,
    ROOM_RELOAD,
    ROOM_GOTO_PERSISTENT,
    ROOM_TRANSITION_IN,
    ROOM_TRANSITION_OUT,
    ROOM_CLEAR_CACHE,
    ROOM_PRELOAD,
    ROOM_UNLOAD,
    
    AUDIO_PLAY_SFX,
    AUDIO_PLAY_MUSIC,
    AUDIO_STOP_MUSIC,
    AUDIO_STOP_SFX,
    AUDIO_STOP_ALL,
    AUDIO_MUTE,
    AUDIO_UNMUTE,
    AUDIO_TOGGLE_MUTE,
    AUDIO_VOLUME_UP,
    AUDIO_VOLUME_DOWN,
    AUDIO_VOLUME_SET_MUSIC,
    AUDIO_VOLUME_SET_SFX,
    AUDIO_VOLUME_SET_MASTER,
    AUDIO_FADE_IN_MUSIC,
    AUDIO_FADE_OUT_MUSIC,
    AUDIO_CROSSFADE_MUSIC,
    AUDIO_RESUME_MUSIC,
    AUDIO_PAUSE_MUSIC,
    AUDIO_SET_PITCH_SFX,
    AUDIO_SET_PAN_SFX,
    
    PLAYER_JUMP,
    PLAYER_ATTACK,
    PLAYER_INTERACT,
    PLAYER_DASH,
    PLAYER_SKILL_1,
    PLAYER_SKILL_2,
    PLAYER_SKILL_3,
    PLAYER_SKILL_4,
    PLAYER_SKILL_5,
    PLAYER_SKILL_ULTIMATE,
    PLAYER_DODGE,
    PLAYER_BLOCK,
    PLAYER_PARRY,
    PLAYER_CROUCH,
    PLAYER_STAND,
    PLAYER_SLIDE,
    PLAYER_CLIMB,
    PLAYER_SWIM,
    PLAYER_TELEPORT,
    PLAYER_INVINCIBLE_ON,
    PLAYER_INVINCIBLE_OFF,
    PLAYER_HEAL,
    PLAYER_DAMAGE,
    PLAYER_KILL,
    PLAYER_RESPAWN,
    PLAYER_USE_ITEM,
    PLAYER_EQUIP_ITEM,
    PLAYER_UNEQUIP_ITEM,
    PLAYER_DROP_ITEM,
    PLAYER_LEVEL_UP,
    PLAYER_ADD_EXP,
    PLAYER_REMOVE_EXP,
    PLAYER_ADD_GOLD,
    PLAYER_REMOVE_GOLD,
    PLAYER_ADD_GEMS,
    PLAYER_REMOVE_GEMS,
    
    MOVEMENT_ENABLE,
    MOVEMENT_DISABLE,
    MOVEMENT_SET_SPEED,
    MOVEMENT_SET_GRAVITY,
    MOVEMENT_SET_JUMP_FORCE,
    MOVEMENT_SET_DASH_FORCE,
    MOVEMENT_RESET,
    
    CAMERA_SHAKE,
    CAMERA_ZOOM_IN,
    CAMERA_ZOOM_OUT,
    CAMERA_RESET,
    CAMERA_LOCK,
    CAMERA_UNLOCK,
    CAMERA_FOLLOW_SET,
    CAMERA_FOLLOW_CLEAR,
    CAMERA_FOLLOW_PLAYER,
    CAMERA_FOLLOW_OBJECT,
    CAMERA_SET_BOUNDS,
    CAMERA_CLEAR_BOUNDS,
    CAMERA_SET_ANGLE,
    CAMERA_RESET_ANGLE,
    CAMERA_PAN_TO,
    CAMERA_PAN_TO_PLAYER,
    CAMERA_PAN_TO_OBJECT,
    CAMERA_STOP_PAN,
    CAMERA_SET_ZOOM,
    CAMERA_SMOOTH_ZOOM,
    
    TIME_SLOW_MOTION,
    TIME_NORMAL,
    TIME_FAST_FORWARD,
    TIME_FREEZE,
    TIME_UNFREEZE,
    TIME_SET_SCALE,
    TIME_RESET_SCALE,
    TIME_STOP,
    TIME_RESUME,
    TIME_WARP,
    
    SYSTEM_SCREENSHOT,
    SYSTEM_FULLSCREEN,
    SYSTEM_CONSOLE_TOGGLE,
    SYSTEM_DEBUG_INFO,
    SYSTEM_TOGGLE_FPS,
    SYSTEM_CLEAR_CACHE,
    SYSTEM_SHOW_FPS,
    SYSTEM_HIDE_FPS,
    SYSTEM_MEMORY_CLEAN,
    SYSTEM_LOG_CLEAR,
    SYSTEM_LOG_SAVE,
    SYSTEM_REBOOT,
    SYSTEM_SHUTDOWN,
    SYSTEM_VSYNC_ON,
    SYSTEM_VSYNC_OFF,
    SYSTEM_LIMIT_FPS,
    SYSTEM_UNLIMIT_FPS,
    
    CUTSCENE_START,
    CUTSCENE_END,
    CUTSCENE_SKIP,
    CUTSCENE_PAUSE,
    CUTSCENE_RESUME,
    DIALOGUE_NEXT,
    DIALOGUE_SKIP,
    DIALOGUE_AUTO,
    DIALOGUE_SET_SPEED,
    DIALOGUE_RESET_SPEED,
    DIALOGUE_START,
    DIALOGUE_END,
    DIALOGUE_SET_PORTRAIT,
    DIALOGUE_CLEAR_PORTRAIT,
    
    ECONOMY_ADD_GOLD,
    ECONOMY_REMOVE_GOLD,
    ECONOMY_ADD_GEMS,
    ECONOMY_REMOVE_GEMS,
    ECONOMY_ADD_EXP,
    ECONOMY_REMOVE_EXP,
    ECONOMY_ADD_REPUTATION,
    ECONOMY_REMOVE_REPUTATION,
    ECONOMY_SET_GOLD,
    ECONOMY_SET_GEMS,
    ECONOMY_SET_EXP,
    ECONOMY_RESET,
    
    INVENTORY_ADD_ITEM,
    INVENTORY_REMOVE_ITEM,
    INVENTORY_EQUIP,
    INVENTORY_UNEQUIP,
    INVENTORY_SORT,
    INVENTORY_CLEAR,
    INVENTORY_USE_ITEM,
    INVENTORY_DROP_ITEM,
    INVENTORY_CRAFT_ITEM,
    INVENTORY_UPGRADE_ITEM,
    INVENTORY_SELL_ITEM,
    INVENTORY_BUY_ITEM,
    
    QUEST_START,
    QUEST_COMPLETE,
    QUEST_FAIL,
    QUEST_UPDATE,
    QUEST_ABANDON,
    QUEST_RESTART,
    QUEST_REWARD_CLAIM,
    QUEST_TRACK_ON,
    QUEST_TRACK_OFF,
    QUEST_NEXT_STAGE,
    QUEST_PREV_STAGE,
    
    NPC_SPAWN,
    NPC_DESPAWN,
    NPC_INTERACT,
    NPC_SET_DIALOGUE,
    NPC_SET_ROUTE,
    NPC_FOLLOW_PLAYER,
    NPC_STOP_FOLLOW,
    NPC_ATTACK,
    NPC_DEFEND,
    NPC_FLEE,
    NPC_DIE,
    NPC_RESURRECT,
    NPC_SET_FACTION,
    NPC_SET_AI_ENABLED,
    NPC_SET_AI_DISABLED,
    
    COMBAT_START,
    COMBAT_END,
    COMBAT_ENTER,
    COMBAT_EXIT,
    COMBAT_PLAYER_ATTACK,
    COMBAT_PLAYER_DEFEND,
    COMBAT_PLAYER_USE_SKILL,
    COMBAT_PLAYER_USE_ITEM,
    COMBAT_PLAYER_RUN,
    COMBAT_ENEMY_SPAWN,
    COMBAT_ENEMY_DESPAWN,
    COMBAT_SET_TURN,
    COMBAT_END_TURN,
    COMBAT_CALCULATE_DAMAGE,
    COMBAT_APPLY_DAMAGE,
    COMBAT_HEAL,
    COMBAT_CRITICAL_HIT,
    COMBAT_MISS,
    COMBAT_BLOCK,
    COMBAT_COUNTER,
    COMBAT_STATUS_APPLY,
    COMBAT_STATUS_REMOVE,
    COMBAT_STATUS_CLEAR,
    
    PARTY_ADD_MEMBER,
    PARTY_REMOVE_MEMBER,
    PARTY_SWAP_LEADER,
    PARTY_HEAL_ALL,
    PARTY_REVIVE_ALL,
    PARTY_BUFF_ALL,
    PARTY_DEBUFF_ALL,
    PARTY_SET_FORMATION,
    PARTY_RESET,
    
    SAVE_CREATE,
    SAVE_LOAD,
    SAVE_DELETE,
    SAVE_OVERWRITE,
    SAVE_SLOT_SELECT,
    SAVE_SLOT_CLEAR,
    SAVE_EXPORT,
    SAVE_IMPORT,
    SAVE_AUTO_ENABLE,
    SAVE_AUTO_DISABLE,
    
    NETWORK_CONNECT,
    NETWORK_DISCONNECT,
    NETWORK_RECONNECT,
    NETWORK_SEND_DATA,
    NETWORK_BROADCAST,
    NETWORK_HOST_CREATE,
    NETWORK_HOST_CLOSE,
    NETWORK_JOIN_ROOM,
    NETWORK_LEAVE_ROOM,
    NETWORK_KICK_PLAYER,
    NETWORK_BAN_PLAYER,
    NETWORK_MUTE_PLAYER,
    NETWORK_UNMUTE_PLAYER,
    
    ACHIEVEMENT_UNLOCK,
    ACHIEVEMENT_PROGRESS,
    ACHIEVEMENT_RESET,
    ACHIEVEMENT_SHOW_NOTIFICATION,
    ACHIEVEMENT_HIDE_NOTIFICATION,
    
    WEATHER_SET,
    WEATHER_CLEAR,
    WEATHER_RAIN_START,
    WEATHER_RAIN_STOP,
    WEATHER_SNOW_START,
    WEATHER_SNOW_STOP,
    WEATHER_FOG_START,
    WEATHER_FOG_STOP,
    WEATHER_THUNDER_START,
    WEATHER_THUNDER_STOP,
    ENVIRONMENT_SET_TIME,
    ENVIRONMENT_SET_CYCLE,
    ENVIRONMENT_SET_BRIGHTNESS,
    ENVIRONMENT_SET_CONTRAST,
    
    DEBUG_TOGGLE,
    DEBUG_LOG_ENABLE,
    DEBUG_LOG_DISABLE,
    DEBUG_WATCH_ADD,
    DEBUG_WATCH_REMOVE,
    DEBUG_BREAKPOINT_SET,
    DEBUG_BREAKPOINT_CLEAR,
    DEBUG_STEP_INTO,
    DEBUG_STEP_OVER,
    DEBUG_STEP_OUT,
    DEBUG_CONTINUE,
    DEBUG_STOP,
    DEBUG_SPAWN_OBJECT,
    DEBUG_DESTROY_OBJECT,
    DEBUG_SET_VARIABLE,
    DEBUG_GET_VARIABLE,
    DEBUG_CALL_FUNCTION,
    DEBUG_PROFILE_START,
    DEBUG_PROFILE_END,
    DEBUG_PROFILE_REPORT,
    
    INPUT_BLOCK,
    INPUT_UNBLOCK,
    INPUT_REMAP_KEY,
    INPUT_RESET_KEYS,
    INPUT_SET_SENSITIVITY,
    INPUT_VIBRATE,
    INPUT_STOP_VIBRATION,
    INPUT_CURSOR_LOCK,
    INPUT_CURSOR_UNLOCK,
    INPUT_CURSOR_HIDE,
    INPUT_CURSOR_SHOW,
    
    RENDER_SET_RESOLUTION,
    RENDER_SET_ANTIALIASING,
    RENDER_SET_SHADER,
    RENDER_CLEAR_SHADER,
    RENDER_POST_PROCESS_ENABLE,
    RENDER_POST_PROCESS_DISABLE,
    RENDER_TAKE_SCREENSHOT,
    RENDER_RECORD_START,
    RENDER_RECORD_STOP,
    RENDER_SET_BRIGHTNESS,
    RENDER_SET_CONTRAST,
    RENDER_SET_SATURATION,
    RENDER_RESET_SETTINGS,
    
    EFFECT_SPAWN,
    EFFECT_DESPAWN,
    EFFECT_CLEAR_ALL,
    PARTICLE_SYSTEM_START,
    PARTICLE_SYSTEM_STOP,
    PARTICLE_SYSTEM_PAUSE,
    PARTICLE_SYSTEM_RESUME,
    PARTICLE_EMITTER_ENABLE,
    PARTICLE_EMITTER_DISABLE,
    
    ANIMATION_PLAY,
    ANIMATION_STOP,
    ANIMATION_PAUSE,
    ANIMATION_RESUME,
    ANIMATION_SET_SPEED,
    ANIMATION_SET_FRAME,
    ANIMATION_NEXT_FRAME,
    ANIMATION_PREV_FRAME,
    ANIMATION_LOOP_ENABLE,
    ANIMATION_LOOP_DISABLE,
    
    PHYSICS_ENABLE,
    PHYSICS_DISABLE,
    PHYSICS_SET_GRAVITY,
    PHYSICS_SET_WORLD_SCALE,
    PHYSICS_CLEAR_FORCES,
    PHYSICS_APPLY_FORCE,
    PHYSICS_APPLY_IMPULSE,
    PHYSICS_SET_BOUNCE,
    PHYSICS_SET_FRICTION,
    PHYSICS_SET_DENSITY,
    PHYSICS_SET_KINEMATIC,
    PHYSICS_SET_STATIC,
    PHYSICS_SET_DYNAMIC,
    
    // CUSTOM COMMANDS (User defined, starting from 1000)
    CUSTOM_START = 1000,
    CUSTOM_1,
    CUSTOM_2,
    CUSTOM_3,
    CUSTOM_4,
    CUSTOM_5,
    CUSTOM_6,
    CUSTOM_7,
    CUSTOM_8,
    CUSTOM_9,
    CUSTOM_10,
    CUSTOM_END
}
enum KISMET_PLAYER_MOVEMENT_FLAGS {
    CAN_MOVE                                = 1 << 0,
    CAN_RUN									= 1 << 1,
    CAN_DASH								= 1 << 2,
    CAN_JUMP								= 1 << 3,
    CAN_DOUBLE_JUMP							= 1 << 4,
    CAN_WALL_JUMP							= 1 << 5,
    CAN_CLIMB								= 1 << 6,
    CAN_SWIM								= 1 << 7,
    CAN_CROUCH								= 1 << 8,
    CAN_SLIDE								= 1 << 9,
    CAN_ROLL								= 1 << 10,
    CAN_WALL_SLIDE							= 1 << 11,
    CAN_GLIDE								= 1 << 12,
    CAN_FLY									= 1 << 13,
    CAN_TELEPORT							= 1 << 14,
    CAN_GRAPPLING_HOOK						= 1 << 15,
    
    IS_MOVING								= 1 << 16,
    IS_RUNNING								= 1 << 17,
    IS_DASHING								= 1 << 18,
    IS_AIRBORNE								= 1 << 19,
    IS_WALL_SLIDING							= 1 << 20,
    IS_CROUCHING							= 1 << 21,
    IS_SLIDING								= 1 << 22,
    IS_CLIMBING								= 1 << 23,
    IS_SWIMMING								= 1 << 24,
    IS_GLIDING								= 1 << 25,
    IS_FLYING								= 1 << 26,
    IS_KNOCKED_BACK							= 1 << 27,
    IS_RAGDOLL								= 1 << 28,
    IS_GROUNDED								= 1 << 29,
    IS_SLOWED_MOVEMENT						= 1 << 30,
    IS_HASTED_MOVEMENT						= 1 << 31,
}
enum KISMET_PLAYER_INTERACTION_FLAGS {
    CAN_INTERACT							= 1 << 0,
    IS_INTERACTING							= 1 << 1,
    INTERACT_COOLDOWN						= 1 << 2,
    CAN_TALK								= 1 << 3,
    CAN_TRADE								= 1 << 4,
    CAN_OPEN_CHESTS							= 1 << 5,
    CAN_COLLECT								= 1 << 6,
    CAN_PICKUP								= 1 << 7,
    CAN_USE_LEVERS							= 1 << 8,
    CAN_READ_SIGNS							= 1 << 9,
    CAN_EXAMINE_OBJECTS						= 1 << 10,
    IS_INTERACT_RANGE						= 1 << 11,
    INTERACT_PROMPT_SHOWN					= 1 << 12,
											
    INVINCIBLE								= 1 << 13,
    INVULNERABLE							= 1 << 14,
    IS_ATTACKING							= 1 << 15,
    IS_CHARGING_ATTACK						= 1 << 16,
    IS_BLOCKING								= 1 << 17,
    IS_PARRYING								= 1 << 18,
    IS_DODGING								= 1 << 19,
    CAN_TAKE_DAMAGE							= 1 << 20,
    CAN_CRIT								= 1 << 21,
    CAN_BLOCK                               = 1 << 22,
    CAN_DODGE                               = 1 << 23,
    CAN_PARRY                               = 1 << 24,
    IS_CASTING								= 1 << 25,
    IS_CHANNELING							= 1 << 26,
    IS_ON_COOLDOWN							= 1 << 27,
    IS_STAGGERED							= 1 << 28,
    IS_EXECUTING							= 1 << 29,
    CAN_COUNTER								= 1 << 30,
    IS_COUNTERING							= 1 << 31,
}											
enum KISMET_PLAYER_STATUS_EFFECT_FLAGS {	
    IS_STUNNED								= 1 << 0,
    IS_SLOWED								= 1 << 1,
    IS_POISONED								= 1 << 2,
    IS_ON_FIRE								= 1 << 3,
    IS_FROZEN								= 1 << 4,
    IS_BLEEDING								= 1 << 5,
    IS_HASTED								= 1 << 6,
    IS_SHIELDED								= 1 << 7,
    IS_CURSED								= 1 << 8,
    IS_BLESSED								= 1 << 9,
    IS_REGENERATING							= 1 << 10,
    IS_WEAKENED								= 1 << 11,
    IS_STRENGTHENED							= 1 << 12,
    IS_CONFUSED								= 1 << 13,
    IS_CHARMED								= 1 << 14,
    IS_FEARED								= 1 << 15,
    IS_SILENCED								= 1 << 16,
    IS_ROOTED								= 1 << 17,
    IS_BLIND								= 1 << 18,
    IS_HEXED								= 1 << 19,
    IS_BURNING								= 1 << 20,
    IS_SHOCKED								= 1 << 21,
    IS_DROWNING								= 1 << 22,
    IS_EXHAUSTED							= 1 << 23,
    IS_INSPIRED								= 1 << 24,
    IS_PROTECTED							= 1 << 25,
    IS_VULNERABLE							= 1 << 26,
    IS_ENRAGED								= 1 << 27,
    IS_CALM									= 1 << 28,
    IS_INVISIBLE							= 1 << 29,
    IS_ETHEREAL								= 1 << 30,
    IS_POSSESSED							= 1 << 31,
}											
enum KISMET_PLAYER_UI_AND_INPUT_FLAGS {		
    UI_FOCUSED								= 1 << 0,
    INPUT_DISABLED							= 1 << 1,
    DIALOGUE_ACTIVE							= 1 << 2,
    MENU_OPEN								= 1 << 3,
    CUTSCENE_ACTIVE							= 1 << 4,
    UI_HIDDEN								= 1 << 5,
    INPUT_BUFFERING							= 1 << 6,
    INPUT_LOCKED							= 1 << 7,
    CURSOR_VISIBLE							= 1 << 8,
    CURSOR_LOCKED							= 1 << 9,
    GAMEPAD_ACTIVE							= 1 << 10,
    KEYBOARD_ACTIVE							= 1 << 11,
    TOUCH_ACTIVE							= 1 << 12,
    UI_DRAGGING								= 1 << 13,
    UI_HOVERING								= 1 << 14,
    UI_SELECTING							= 1 << 15,
    TUTORIAL_ACTIVE							= 1 << 16,
    NOTIFICATION_SHOWN						= 1 << 17,
    TOOLTIP_SHOWN							= 1 << 18,
    DEBUG_OVERLAY_VISIBLE					= 1 << 19,
    CONSOLE_OPEN							= 1 << 20,
}											
enum KISMET_PLAYER_SPECIAL_ABILITY_FLAGS {	
    CAN_STEALTH								= 1 << 21,
    IS_STEALTHED							= 1 << 22,
    CAN_DETECT_HIDDEN						= 1 << 23,
    IS_DETECTING							= 1 << 24,
    CAN_DOUBLE_JUMP_AIR						= 1 << 25,
    CAN_WALL_RUN							= 1 << 26,
    IS_WALL_RUNNING							= 1 << 27,
    CAN_SLOW_TIME							= 1 << 28,
    TIME_SLOWED_ACTIVE						= 1 << 29,
    CAN_STOP_TIME							= 1 << 30,
    TIME_STOPPED_ACTIVE						= 1 << 31
}

enum KISMET_INPUT_DEVICE {
    KEYBOARD,
    MOUSE,
    GAMEPAD_1,
    GAMEPAD_2,
    GAMEPAD_3,
    GAMEPAD_4,
    TOUCH,
    ANY
}

enum KISMET_INPUT_TYPE {
    KEY,
    MOUSE_BUTTON,
    GAMEPAD_BUTTON,
    GAMEPAD_AXIS,
    MOUSE_AXIS,
    TOUCH_POINT
}

enum KISMET_INPUT_STATE {
    JUST_PRESSED,
    PRESSED,
    JUST_RELEASED,
    RELEASED,
    DOUBLE_TAPPED,
    LONG_PRESSED
}

enum KISMET_MOUSE_BUTTON {
    LEFT									= 0,
    RIGHT									= 1,
    MIDDLE									= 2,
    MBACK									= 3,
    MFORWARD								= 4
}

enum KISMET_GAMEPAD_BUTTON {
    A										= 0,
    B										= 1,
    X										= 2,
    Y										= 3,
    LB										= 4,
    RB										= 5,
    LT										= 6,
    RT										= 7,
    BACK									= 8,
    START									= 9,
    L_STICK									= 10,
    R_STICK									= 11,
    DPAD_UP									= 12,
    DPAD_DOWN								= 13,
    DPAD_LEFT								= 14,
    DPAD_RIGHT								= 15,
    GUIDE									= 16
}

enum KISMET_GAMEPAD_AXIS {
    LEFT_X									= 0,
    LEFT_Y									= 1,
    RIGHT_X									= 2,
    RIGHT_Y									= 3,
    LEFT_TRIGGER							= 4,
    RIGHT_TRIGGER							= 5
}

function ds_map_create_kismet() {
    var _map = ds_map_create();
    return MemoryTracker.RegisterMap(_map);
};

function ds_list_create_kismet() {
    var _list = ds_list_create();
    return MemoryTracker.RegisterList(_list);
};

function ds_queue_create_kismet() {
    var _queue = ds_queue_create();
    return MemoryTracker.RegisterQueue(_queue);
};

function ds_stack_create_kismet() {
    var _stack = ds_stack_create();
    return MemoryTracker.RegisterStack(_stack);
};

function ds_grid_create_kismet(w, h) {
    var _grid = ds_grid_create(w, h);
    return MemoryTracker.RegisterGrid(_grid);
};

function ds_priority_create_kismet() {
    var _priority = ds_priority_create();
    return MemoryTracker.RegisterPriority(_priority);
};

function ds_map_destroy_kismet(id) {
    MemoryTracker.Unregister(id);
    ds_map_destroy(id);
};

function ds_list_destroy_kismet(id) {
    MemoryTracker.Unregister(id);
    ds_list_destroy(id);
};

function ds_queue_destroy_kismet(id) {
    MemoryTracker.Unregister(id);
    ds_queue_destroy(id);
};

function ds_stack_destroy_kismet(id) {
    MemoryTracker.Unregister(id);
   ds_stack_destroy(id);
};

function ds_grid_destroy_kismet(id) {
    MemoryTracker.Unregister(id);
    ds_grid_destroy(id);
};

function ds_priority_destroy_kismet(id) {
    MemoryTracker.Unregister(id);
    ds_priority_destroy(id);
};

// Memory Tracker - Automatically tracks all 'ds_*' structures
function MemoryTracker() constructor {
    tracked_maps = ds_list_create();		// Track ds_maps
    tracked_lists = ds_list_create();		// Track ds_lists
    tracked_queues = ds_list_create();		// Track ds_queues
    tracked_stacks = ds_list_create();		// Track ds_stacks
    tracked_grids = ds_list_create();		// Track ds_grids
    tracked_priorities = ds_list_create();	// Track ds_priorities
    
    RegisterMap = function(_map, _owner = undefined) {
        if (!is_undefined(_map) && ds_exists(_map, ds_type_map)) {
            ds_list_add(tracked_maps, { map: _map, owner: _owner });
        }
        return _map;
    };
    
    RegisterList = function(_list, _owner = undefined) {
        if (!is_undefined(_list) && ds_exists(_list, ds_type_list)) {
            ds_list_add(tracked_lists, { list: _list, owner: _owner });
        }
        return _list;
    };
    
    RegisterQueue = function(_queue, _owner = undefined) {
        if (!is_undefined(_queue) && ds_exists(_queue, ds_type_queue)) {
            ds_list_add(tracked_queues, { queue: _queue, owner: _owner });
        }
        return _queue;
    };
    
    RegisterStack = function(_stack, _owner = undefined) {
        if (!is_undefined(_stack) && ds_exists(_stack, ds_type_stack)) {
            ds_list_add(tracked_stacks, { stack: _stack, owner: _owner });
        }
        return _stack;
    };
    
    RegisterGrid = function(_grid, _owner = undefined) {
        if (!is_undefined(_grid) && ds_exists(_grid, ds_type_grid)) {
            ds_list_add(tracked_grids, { grid: _grid, owner: _owner });
        }
        return _grid;
    };
    
    RegisterPriority = function(_priority, _owner = undefined) {
        if (!is_undefined(_priority) && ds_exists(_priority, ds_type_priority)) {
            ds_list_add(tracked_priorities, { priority: _priority, owner: _owner });
        }
        return _priority;
    };
    
    Unregister = function(_struct) {
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
    
    CleanupOwner = function(_owner) {
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
        
        if (total_freed > 0 && IS_KISMET_DEBUG_ENABLED()) {
            show_debug_message("[KISMET] Cleaned up " + string(total_freed) + " structures for owner: " + string(_owner));
        }
        return total_freed;
    };
    
    CleanupAll = function() {
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
        
        if (IS_KISMET_DEBUG_ENABLED()) {
            show_debug_message("[KISMET] Total structures freed: " + string(total_freed));
        }
    };
    
    GetStats = function() {
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

function KISMETInputManager() constructor {
    actions = ds_map_create_kismet();        // Action name -> ActionConfig
    input_states = ds_map_create_kismet();   // Action name -> current state
    input_events = ds_list_create_kismet();  // Queue for input events
    device_callbacks = ds_map_create_kismet(); // Device-specific callbacks
    
    // Global settings
    gamepad_deadzone = 0.2;
    double_tap_time = 0.3;      // Seconds
    long_press_time = 0.5;      // Seconds
    repeat_delay = 0.5;         // Seconds before repeat starts
    repeat_interval = 0.05;     // Seconds between repeats
    
    // Touch tracking
    touches = ds_map_create_kismet();
    next_touch_id = 0;
    
    // Axis smoothing
    axis_smoothing = false;
    axis_smoothing_factor = 0.85;
    
    function ActionConfig(_name) constructor {
        name = _name;
        bindings = ds_list_create_kismet();     // List of InputBinding
        device_priorities = ds_map_create_kismet(); // Device -> priority (lower = higher priority)
        enabled = true;
        consume_input = false;      // If true, other actions won't receive this input
        tags = ds_list_create_kismet();
        
        // Analog settings
        analog_smoothing = 0.0;     // 0-1 smoothing factor
        analog_curve = 1.0;         // Power curve for analog response
        invert_x = false;
        invert_y = false;
        swap_axes = false;
        
        // Digital settings
        digital_delay = 0.0;        // Delay before action triggers
        digital_hold = false;        // Action stays active while held
        
        AddBinding = function(binding) {
            ds_list_add(bindings, binding);
            return self;
        };
        
        SetPriority = function(device, priority) {
            device_priorities[? device] = priority;
            return self;
        };
        
        AddTag = function(tag) {
            ds_list_add(tags, tag);
            return self;
        };
        
        Free = function() {
            for (var i = 0; i < ds_list_size(bindings); i++) {
                var binding = bindings[| i];
                binding.Free();
            }
            ds_list_destroy_kismet(bindings);
            ds_map_destroy_kismet(device_priorities);
            ds_list_destroy_kismet(tags);
        };
    }
    
    function InputBinding() constructor {
        type = KISMET_INPUT_TYPE.KEY;
        device = KISMET_INPUT_DEVICE.KEYBOARD;
        
        // For keys/buttons
        key_code = 0;
        key_string = "";
        modifiers = 0;  // shift, ctrl, alt flags
        
        // For mouse
        mouse_button = KISMET_MOUSE_BUTTON.LEFT;
        mouse_region = undefined;  // Rect for region-specific mouse input
        
        // For gamepad
        gamepad_button = KISMET_GAMEPAD_BUTTON.A;
        gamepad_axis = KISMET_GAMEPAD_AXIS.LEFT_X;
        axis_threshold = 0.5;      // For digital triggers from analog
        axis_positive_only = false;
        
        // For touch
        touch_region = undefined;
        touch_gesture = "";  // "tap", "swipe", "pinch", etc.
        
        // Settings
        invert = false;
        scale = 1.0;
        deadzone = 0.0;
        
        Free = function() {
            // Nothing dynamic to clean
        };
    }
        
    function InputBindingFromKey(_key, _modifiers = 0, _device = KISMET_INPUT_DEVICE.KEYBOARD) {
        var binding = new InputBinding();
        binding.type = KISMET_INPUT_TYPE.KEY;
        binding.device = _device;
        binding.key_code = ord(_key);
        binding.key_string = _key;
        binding.modifiers = _modifiers;
        return binding;
    };
    
    function InputBindingFromMouse(_button, _region = undefined) {
        var binding = new InputBinding();
        binding.type = KISMET_INPUT_TYPE.MOUSE_BUTTON;
        binding.device = KISMET_INPUT_DEVICE.MOUSE;
        binding.mouse_button = _button;
        binding.mouse_region = _region;
        return binding;
    };
    
    function InputBindingFromGamepadButton(_button, _gamepad_id = 0) {
        var binding = new InputBinding();
        binding.type = KISMET_INPUT_TYPE.GAMEPAD_BUTTON;
        binding.device = _gamepad_id;
        binding.gamepad_button = _button;
        return binding;
    };
    
    function InputBindingFromGamepadAxis(_axis, _threshold = 0.5, _positive_only = false, _gamepad_id = 0) {
        var binding = new InputBinding();
        binding.type = KISMET_INPUT_TYPE.GAMEPAD_AXIS;
        binding.device = _gamepad_id;
        binding.gamepad_axis = _axis;
        binding.axis_threshold = _threshold;
        binding.axis_positive_only = _positive_only;
        return binding;
    };
    
    function InputBindingFromTouch(_region = undefined, _gesture = "tap") {
        var binding = new InputBinding();
        binding.type = KISMET_INPUT_TYPE.TOUCH_POINT;
        binding.device = KISMET_INPUT_DEVICE.TOUCH;
        binding.touch_region = _region;
        binding.touch_gesture = _gesture;
        return binding;
    };
    
    function InputState(_config) constructor {
        config = _config;
        
        // Digital state
        pressed = false;
        just_pressed = false;
        just_released = false;
        press_time = 0;
        release_time = 0;
        press_count = 0;
        last_press_time = 0;
        
        // Analog state
        value = 0;
        raw_value = 0;
        smoothed_value = 0;
        vector_x = 0;
        vector_y = 0;
        raw_vector_x = 0;
        raw_vector_y = 0;
        angle = 0;
        magnitude = 0;
        
        // Timing
        double_tapped = false;
        long_pressed = false;
        hold_timer = 0;
        repeat_timer = 0;
        
        Reset = function() {
            pressed = false;
            just_pressed = false;
            just_released = false;
            value = 0;
            vector_x = 0;
            vector_y = 0;
            magnitude = 0;
            double_tapped = false;
            long_pressed = false;
        };
        
        UpdateAnalog = function(x, y) {
            raw_vector_x = x;
            raw_vector_y = y;
            
            if (config.swap_axes) {
                var temp = x;
                x = y;
                y = temp;
            }
            
            if (config.invert_x) x = -x;
            if (config.invert_y) y = -y;
            
            // Apply deadzone
            var magnitude = sqrt(x*x + y*y);
            if (magnitude < gamepad_deadzone) {
                x = 0;
                y = 0;
                magnitude = 0;
            } else {
                // Scale from deadzone to 1
                var t = (magnitude - gamepad_deadzone) / (1 - gamepad_deadzone);
                magnitude = t;
                if (magnitude > 0) {
                    x = (x / magnitude) * t;
                    y = (y / magnitude) * t;
                }
            }
            
            // Apply curve
            if (config.analog_curve != 1.0) {
                var curved = pow(magnitude, config.analog_curve);
                if (magnitude > 0) {
                    x = (x / magnitude) * curved;
                    y = (y / magnitude) * curved;
                }
                magnitude = curved;
            }
            
            vector_x = x;
            vector_y = y;
            this.magnitude = magnitude;
            angle = arctan2(y, x);
            
            // Update value (for single-axis actions)
            if (abs(x) > abs(y)) {
                value = x;
            } else {
                value = y;
            }
        };
        
        UpdateDigital = function(_pressed, delta_time) {
            if (_pressed && !pressed) {
                // Just pressed
                just_pressed = true;
                pressed = true;
                press_time = current_time;
                press_count++;
                
                // Double tap detection
                if (press_time - last_press_time < double_tap_time * 1000000) {
                    double_tapped = true;
                } else {
                    double_tapped = false;
                }
                last_press_time = press_time;
                
                // Long press timer
                long_pressed = false;
                hold_timer = 0;
                repeat_timer = 0;
                
            } else if (!_pressed && pressed) {
                // Just released
                just_released = true;
                pressed = false;
                release_time = current_time;
                
                if (hold_timer >= long_press_time && !long_pressed) { // Check if long press was achieved
                    long_pressed = true;
                }
                
            } else if (_pressed && pressed) {
                // Held
                just_pressed = false;
                just_released = false;
                
                // Long press detection
                hold_timer += delta_time;
                if (hold_timer >= long_press_time && !long_pressed) {
                    long_pressed = true;
                }
                
                // Repeat detection (for keyboard repeat behavior)
                if (repeat_timer <= 0 && hold_timer > repeat_delay) {
                    repeat_timer = repeat_interval;
                    just_pressed = true;  // Simulate another press
                } else if (repeat_timer > 0) {
                    repeat_timer -= delta_time;
                }
            } else {
                just_pressed = false;
                just_released = false;
                double_tapped = false;
            }
        };
    }
    
    // Public Methods
    function CreateAction(_name) {
        if (ds_map_exists(actions, _name)) {
            if (IS_KISMET_DEBUG_ENABLED()) show_debug_message("[Input] Action already exists: " + _name);
            return actions[? _name];
        }
        
        var config = new ActionConfig(_name);
        var state = new InputState(config);
        actions[? _name] = config;
        input_states[? _name] = state;
        
        if (IS_KISMET_DEBUG_ENABLED()) show_debug_message("[Input] Created action: " + _name);
        return config;
    };
    
    function GetAction(_name) {
        return ds_map_exists(actions, _name) ? actions[? _name] : undefined;
    };
    
    function BindKey(_action_name, _key, _modifiers = 0, _device = KISMET_INPUT_DEVICE.KEYBOARD) {
        var action = GetAction(_action_name);
        if (action == undefined) action = CreateAction(_action_name);
        action.AddBinding(InputBindingFromKey(_key, _modifiers, _device));
        return self;
    };
    
    function BindMouse(_action_name, _button, _region = undefined) {
        var action = GetAction(_action_name);
        if (action == undefined) action = CreateAction(_action_name);
        action.AddBinding(InputBindingFromMouse(_button, _region));
        return self;
    };
    
    function BindGamepadButton(_action_name, _button, _gamepad_id = 0) {
        var action = GetAction(_action_name);
        if (action == undefined) action = CreateAction(_action_name);
        action.AddBinding(InputBindingFromGamepadButton(_button, _gamepad_id));
        return self;
    };
    
    function BindGamepadAxis(_action_name, _axis, _threshold = 0.5, _positive_only = false, _gamepad_id = 0) {
        var action = GetAction(_action_name);
        if (action == undefined) action = CreateAction(_action_name);
        action.AddBinding(InputBindingFromGamepadAxis(_axis, _threshold, _positive_only, _gamepad_id));
        return self;
    };
    
    function BindTouch(_action_name, _region = undefined, _gesture = "tap") {
        var action = GetAction(_action_name);
        if (action == undefined) action = CreateAction(_action_name);
        action.AddBinding(InputBindingFromTouch(_region, _gesture));
        return self;
    };
    
    // Query Methods
    function IsPressed(_action_name) {
        if (!ds_map_exists(input_states, _action_name)) return false;
        var action = GetAction(_action_name);
        if (!action.enabled) return false;
        return input_states[? _action_name].pressed;
    };
    
    function IsJustPressed(_action_name) {
        if (!ds_map_exists(input_states, _action_name)) return false;
        var action = GetAction(_action_name);
        if (!action.enabled) return false;
        return input_states[? _action_name].just_pressed;
    };
    
    function IsJustReleased(_action_name) {
        if (!ds_map_exists(input_states, _action_name)) return false;
        var action = GetAction(_action_name);
        if (!action.enabled) return false;
        return input_states[? _action_name].just_released;
    };
    
    function IsDoubleTapped(_action_name) {
        if (!ds_map_exists(input_states, _action_name)) return false;
        var action = GetAction(_action_name);
        if (!action.enabled) return false;
        return input_states[? _action_name].double_tapped;
    };
    
    function IsLongPressed(_action_name) {
        if (!ds_map_exists(input_states, _action_name)) return false;
        var action = GetAction(_action_name);
        if (!action.enabled) return false;
        return input_states[? _action_name].long_pressed;
    };
    
    function GetValue(_action_name) {
        if (!ds_map_exists(input_states, _action_name)) return 0;
        return input_states[? _action_name].value;
    };
    
    function GetVector(_action_name) {
        if (!ds_map_exists(input_states, _action_name)) return { x: 0, y: 0 };
        var state = input_states[? _action_name];
        return { x: state.vector_x, y: state.vector_y };
    };
    
    function GetMagnitude(_action_name) {
        if (!ds_map_exists(input_states, _action_name)) return 0;
        return input_states[? _action_name].magnitude;
    };
    
    function GetAngle(_action_name) {
        if (!ds_map_exists(input_states, _action_name)) return 0;
        return input_states[? _action_name].angle;
    };
    
    function GetPressDuration(_action_name) {
        if (!ds_map_exists(input_states, _action_name)) return 0;
        var state = input_states[? _action_name];
        if (!state.pressed) return 0;
        return (current_time - state.press_time) / 1000000.0;
    };
    
    // Enable/Disable Actions
    function EnableAction(_action_name) {
        var action = GetAction(_action_name);
        if (action != undefined) action.enabled = true;
        return self;
    };
    
    function DisableAction(_action_name) {
        var action = GetAction(_action_name);
        if (action != undefined) action.enabled = false;
        return self;
    };
    
    function EnableAllActions() {
        var keys = ds_map_keys_to_array(actions);
        for (var i = 0; i < array_length(keys); i++) {
            actions[? keys[i]].enabled = true;
        }
        return self;
    };
    
    function DisableAllActions() {
        var keys = ds_map_keys_to_array(actions);
        for (var i = 0; i < array_length(keys); i++) {
            actions[? keys[i]].enabled = false;
        }
        return self;
    };
    
    // Global Settings
    function SetGamepadDeadzone(_deadzone) {
        gamepad_deadzone = clamp(_deadzone, 0, 1);
        return self;
    };
    
    function SetDoubleTapTime(_time) {
        double_tap_time = _time;
        return self;
    };
    
    function SetLongPressTime(_time) {
        long_press_time = _time;
        return self;
    };
    
    // Touch Handling
    function UpdateTouches() {
        var touch_count = touch_get_number();
        var active_touches = ds_map_create_kismet();
        
        for (var i = 0; i < touch_count; i++) {
            var touch_id = touch_get_id(i);
            var touch_x = touch_get_x(i);
            var touch_y = touch_get_y(i);
            var touch_pressure = touch_get_pressure(i);
            
            if (!ds_map_exists(touches, touch_id)) {
                var touch = {
                    id: touch_id,
                    x: touch_x,
                    y: touch_y,
                    start_x: touch_x,
                    start_y: touch_y,
                    pressure: touch_pressure,
                    start_time: current_time,
                    active: true,
                    tap: false,
                    swipe: false,
                    swipe_vector: { x: 0, y: 0 }
                };
                touches[? touch_id] = touch;
                
                // Check for tap
                touch.tap = true;
                
                // Trigger touch events
                ProcessTouchBinding("tap", touch);
                
            } else {
                var touch = touches[? touch_id];
                touch.x = touch_x;
                touch.y = touch_y;
                touch.pressure = touch_pressure;
                touch.active = true;
                active_touches[? touch_id] = touch;
                
                // Check for swipe
                var dx = touch.x - touch.start_x;
                var dy = touch.y - touch.start_y;
                var distance = sqrt(dx*dx + dy*dy);
                var duration = (current_time - touch.start_time) / 1000000.0;
                
                if (distance > 20 && duration < 0.5 && !touch.swipe) {
                    touch.swipe = true;
                    touch.swipe_vector = { x: dx, y: dy };
                    ProcessTouchBinding("swipe", touch);
                }
            }
        }
        
        // Remove ended touches
        var touch_ids = ds_map_keys_to_array(touches);
        for (var i = 0; i < array_length(touch_ids); i++) {
            var _id = touch_ids[i];
            if (!ds_map_exists(active_touches, _id)) {
                ds_map_delete(touches, _id);
            }
        }
        
        ds_map_destroy_kismet(active_touches);
    };
    
    function ProcessTouchBinding(_gesture, _touch) {
        var action_keys = ds_map_keys_to_array(actions);
        for (var i = 0; i < array_length(action_keys); i++) {
            var action_name = action_keys[i];
            var action = actions[? action_name];
            if (!action.enabled) continue;
            
            for (var j = 0; j < ds_list_size(action.bindings); j++) {
                var binding = action.bindings[| j];
                if (binding.type == KISMET_INPUT_TYPE.TOUCH_POINT &&
                    binding.touch_gesture == _gesture) {
                    
                    // Check region if specified
                    if (binding.touch_region != undefined) {
                        if (binding.touch_region.Contains(_touch.x, _touch.y)) {
                            TriggerAction(action_name, true, _touch);
                        }
                    } else {
                        TriggerAction(action_name, true, _touch);
                    }
                }
            }
        }
    };
    
    // Internal Methods
    function TriggerAction(_action_name, _pressed, _data = undefined) {
        var state = input_states[? _action_name];
        if (state == undefined) return;
        
        var event = {
            action: _action_name,
            pressed: _pressed,
            data: _data,
            time: current_time
        };
        ds_list_add(input_events, event);
    };
    
    function Update(delta_time = 1/60) {
        // Reset frame-based states
        var action_keys = ds_map_keys_to_array(input_states);
        for (var i = 0; i < array_length(action_keys); i++) {
            var state = input_states[? action_keys[i]];
            if (state != undefined) {
                state.just_pressed = false;
                state.just_released = false;
                state.double_tapped = false;
            }
        }
        
        ProcessKeyboard();
        
        ProcessMouse();
        
        for (var i = 0; i < 4; i++) {
            if (gamepad_is_connected(i)) {
                ProcessGamepad(i);
            }
        }
        
        if (os_type == os_android || os_type == os_ios) {
            UpdateTouches();
        }
        
        while (ds_list_size(input_events) > 0) {
            var event = input_events[| 0];
            var state = input_states[? event.action];
            if (state != undefined) {
                state.UpdateDigital(event.pressed, delta_time);
            }
            ds_list_delete(input_events, 0);
        }
    };
    
    function ProcessKeyboard() {
        var action_keys = ds_map_keys_to_array(actions);
        for (var i = 0; i < array_length(action_keys); i++) {
            var action_name = action_keys[i];
            var action = actions[? action_name];
            if (!action.enabled) continue;
            
            var pressed = false;
            for (var j = 0; j < ds_list_size(action.bindings); j++) {
                var binding = action.bindings[| j];
                if (binding.type == KISMET_INPUT_TYPE.KEY) {
                    var key_pressed = keyboard_check(binding.key_code);
                    var mod_match = true;
                    
                    // Check modifiers
                    if (binding.modifiers & 1) { // Shift
                        mod_match = mod_match && keyboard_check(vk_shift);
                    }
                    if (binding.modifiers & 2) { // Ctrl
                        mod_match = mod_match && keyboard_check(vk_control);
                    }
                    if (binding.modifiers & 4) { // Alt
                        mod_match = mod_match && keyboard_check(vk_alt);
                    }
                    
                    if (key_pressed && mod_match) {
                        pressed = true;
                        if (action.consume_input) break;
                    }
                }
            }
            
            if (pressed != (input_states[? action_name].pressed)) {
                TriggerAction(action_name, pressed);
            }
        }
    };
    
    function ProcessMouse() {
        var action_keys = ds_map_keys_to_array(actions);
        for (var i = 0; i < array_length(action_keys); i++) {
            var action_name = action_keys[i];
            var action = actions[? action_name];
            if (!action.enabled) continue;
            
            for (var j = 0; j < ds_list_size(action.bindings); j++) {
                var binding = action.bindings[| j];
                if (binding.type == KISMET_INPUT_TYPE.MOUSE_BUTTON) {
                    var pressed = mouse_check_button(binding.mouse_button);
                    
                    if (pressed && binding.mouse_region != undefined) { // Check region if specified
                        var mx = window_mouse_get_x();
                        var my = window_mouse_get_y();
                        pressed = binding.mouse_region.Contains(mx, my);
                    }
                    
                    if (pressed != (input_states[? action_name].pressed)) {
                        TriggerAction(action_name, pressed, { x: window_mouse_get_x(), y: window_mouse_get_y() });
                        if (action.consume_input) break;
                    }
                }
            }
        }
    };
    
    function ProcessGamepad(_gamepad_id) {
        var action_keys = ds_map_keys_to_array(actions);
        for (var i = 0; i < array_length(action_keys); i++) {
            var action_name = action_keys[i];
            var action = actions[? action_name];
            if (!action.enabled) continue;
            
            var pressed = false;
            var analog_value = 0;
            var analog_x = 0;
            var analog_y = 0;
            
            for (var j = 0; j < ds_list_size(action.bindings); j++) {
                var binding = action.bindings[| j];
                
                if (binding.type == KISMET_INPUT_TYPE.GAMEPAD_BUTTON &&
                    binding.device == _gamepad_id) {
                    pressed = gamepad_button_check(_gamepad_id, binding.gamepad_button);
                    if (pressed && action.consume_input) break;
                    
                } else if (binding.type == KISMET_INPUT_TYPE.GAMEPAD_AXIS &&
                           binding.device == _gamepad_id) {
                    var axis_value = gamepad_axis_value(_gamepad_id, binding.gamepad_axis);
                    
                    if (binding.axis_positive_only) {
                        axis_value = max(0, axis_value);
                    } else {
                        axis_value = abs(axis_value);
                    }
                    
                    if (axis_value >= binding.axis_threshold) {
                        if (binding.gamepad_axis <= KISMET_GAMEPAD_AXIS.RIGHT_Y) {
                            // Axis is for vector movement
                            analog_x = gamepad_axis_value(_gamepad_id, KISMET_GAMEPAD_AXIS.LEFT_X);
                            analog_y = gamepad_axis_value(_gamepad_id, KISMET_GAMEPAD_AXIS.LEFT_Y);
                            var state = input_states[? action_name];
                            if (state != undefined) {
                                state.UpdateAnalog(analog_x, analog_y);
                            }
                        }
                        pressed = true;
                        analog_value = axis_value;
                    }
                }
            }
            
            if (binding.type == KISMET_INPUT_TYPE.GAMEPAD_AXIS) {
                // Handle analog continuously
                var state = input_states[? action_name];
                if (state != undefined && (analog_x != 0 || analog_y != 0)) {
                    state.UpdateAnalog(analog_x, analog_y);
                }
            } else if (pressed != (input_states[? action_name].pressed)) {
                TriggerAction(action_name, pressed, { value: analog_value });
            }
        }
    };
    
    function PrintBindings() {
        show_debug_message("=== Input Bindings ===");
        var action_keys = ds_map_keys_to_array(actions);
        for (var i = 0; i < array_length(action_keys); i++) {
            var action_name = action_keys[i];
            var action = actions[? action_name];
            show_debug_message("Action: " + action_name + " (enabled: " + string(action.enabled) + ")");
            
            for (var j = 0; j < ds_list_size(action.bindings); j++) {
                var binding = action.bindings[| j];
                show_debug_message("  - " + GetBindingString(binding));
            }
        }
        return self;
    };
    
    function GetBindingString(_binding) {
        switch(_binding.type) {
            case KISMET_INPUT_TYPE.KEY:
                return "Keyboard: " + _binding.key_string;
            case KISMET_INPUT_TYPE.MOUSE_BUTTON:
                return "Mouse Button: " + string(_binding.mouse_button);
            case KISMET_INPUT_TYPE.GAMEPAD_BUTTON:
                return "Gamepad " + string(_binding.device) + " Button: " + string(_binding.gamepad_button);
            case KISMET_INPUT_TYPE.GAMEPAD_AXIS:
                return "Gamepad " + string(_binding.device) + " Axis: " + string(_binding.gamepad_axis);
            case KISMET_INPUT_TYPE.TOUCH_POINT:
                return "Touch: " + _binding.touch_gesture;
        }
        return "Unknown";
    };
    
    function Free() {
        var action_keys = ds_map_keys_to_array(actions);
        for (var i = 0; i < array_length(action_keys); i++) {
            actions[? action_keys[i]].Free();
        }
        ds_map_destroy_kismet(actions);
        ds_map_destroy_kismet(input_states);
        ds_list_destroy_kismet(input_events);
        ds_map_destroy_kismet(device_callbacks);
        ds_map_destroy_kismet(touches);
    };
}

function KISMET() constructor {
	InputManager = new KISMETInputManager();
	
    // Object Owner Tracking
    function TrackedObject() constructor {
        __kismet_id = IDGenerate().GUID();
        
        Cleanup = function() {
            MemoryTracker.CleanupOwner(__kismet_id);
        };
        
        static CreateTracked = function(_constructor) {
            var obj = new _constructor();
            return obj;
        };
    };
	
	//  InterfaceAccess – dynamic registry
	function InterfaceAccess() constructor {
	    m_elements = ds_map_create_kismet();
    
	    Add = function(name, element) {
	        ds_map_add(m_elements, name, element);
	        return self;
	    };
	    Get = function(name) {
	        return m_elements[? name];
	    };
	    Set = function(name, element) {
	        m_elements[? name] = element;
	        return self;
	    };
	    Exists = function(name) {
	        return ds_map_exists(m_elements, name);
	    };
	    Remove = function(name) {
	        if (ds_map_exists(m_elements, name)) {
	            ds_map_delete(m_elements, name);
	        }
	        return self;
	    };
	    GetKeys = function() {
	        return ds_map_keys_to_array(m_elements);
	    };
	    Clear = function() {
	        ds_map_clear(m_elements);
	        return self;
	    };
	    Free = function() {
	        ds_map_destroy(m_elements);
	    };
	};
	
	function AutoCleanup() constructor {
        __cleanup_registered = false;
        
        RegisterForCleanup = function(_obj) {
            if (!__cleanup_registered) {
                // Register a room end event for automatic cleanup
                if (!variable_global_exists("__kismet_cleanup_manager")) {
                    global.__kismet_cleanup_manager = self;
                }
                __cleanup_registered = true;
            }
        };
        
        OnRoomEnd = function() {
            if (DebugMode) {
                var stats = MemoryTracker.GetStats();
                show_debug_message("[KISMET] Room ended - Memory stats: Maps:" + string(stats.maps) + " Lists:" + string(stats.lists) + " Queues:" + string(stats.queues) + " Stacks:" + string(stats.stacks) + " Grids:" + string(stats.grids) + " Priorities:" + string(stats.priorities));
            }
        };
    };
    
    function WeakCallback(_target, _method) constructor {
        Target = _target;
        Method = _method;
        
        Execute = function(_data = undefined) {
            if (instance_exists(Target)) {
                return Method(Target, _data);
            } else if (is_struct(Target) && Target != undefined) {
                return Method(Target, _data);
            } else if (DebugMode) {
                show_debug_message("[KISMET] WeakCallback target no longer exists");
            }
            return undefined;
        };
        
        IsValid = function() {
            return (instance_exists(Target) || (is_struct(Target) && Target != undefined));
        };
    };
    
	// Memory Leak Detection
    function MemoryLeakDetector() constructor {
        snapshots = ds_map_create();
        
        TakeSnapshot = function(_name = "snapshot_" + string(GetUnixDateTime(date_current_datetime()))) {
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
        
        CompareSnapshots = function(_snapshot1, _snapshot2) {
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
        
        DetectLeaks = function(_baseline_snapshot) {
            var current = TakeSnapshot("current");
            var diff = CompareSnapshots(_baseline_snapshot, "current");
            if (diff.total_diff > 0 && DebugMode) {
                show_debug_message("[KISMET] Potential memory leak detected! " + string(diff.total_diff) + " structures since baseline");
            }
            return diff;
        };
        
        Free = function() {
            ds_map_destroy(snapshots);
        };
    };
    
    LeakDetector = new MemoryLeakDetector();

	//  Animation System
	function Animation(_animation, _speed = 1, _onUpdate = undefined) constructor {
	    animation = _animation;
	    speed = _speed;
	    onUpdate = _onUpdate;

	    Update = function(_object) {
	        _object.sprite_index = animation;
	        _object.image_speed = speed;
	        if (onUpdate != undefined) onUpdate(self, _object);
	    };
	};

	function AnimPack(_object) constructor {
	    object = _object;
	    animations = ds_map_create_kismet();
	    current = undefined;

	    Add = function(name, anim) {
	        animations[? name] = anim;
	        return self;
	    };
	    Get = function(name) {
	        return animations[? name];
	    };
	    Exists = function(name) {
	        return ds_map_exists(animations, name);
	    };
	    Set = function(name) {
	        if (!Exists(name)) return self;
	        current = animations[? name];
	        return self;
	    };
	    Update = function() {
	        if (current != undefined) current.Update(object);
	        return self;
	    };
	    Free = function() {
	        var keys = ds_map_keys_to_array(animations);
	        for (var i = 0; i < array_length(keys); i++) delete animations[? keys[i]];
	        ds_map_destroy_kismet(animations);
	    };
	};

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

	    Set = function() {
	        view_set_camera(index, camera);
	        return self;
	    };
	    Shake = function(magnitude, decay = 0.9) {
	        shake_magnitude = magnitude;
	        shake_decay = decay;
	        return self;
	    };
	    SetZoom = function(target, speed = 0.1) {
	        target_zoom = target;
	        zoom_speed = speed;
	        return self;
	    };
	    Update = function() {
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
	    Free = function() {
	        camera_destroy(camera);
	    };
	};

	//  Movement
	function Movement(_speed = 5, _accel = 0, _damping = 0) constructor {
	    h = 0; v = 0;
	    speed = _speed;
	    accel = _accel;
	    damping = _damping;
	    vel_x = 0; vel_y = 0;

	    Update = function(object) {
	        var target_x = h * speed;
	        var target_y = v * speed;
	        if (accel > 0) {
	            vel_x = approach(vel_x, target_x, accel);
	            vel_y = approach(vel_y, target_y, accel);
	        } else {
	            vel_x = target_x;
	            vel_y = target_y;
	        }
	        if (h == 0 && damping > 0) vel_x = approach(vel_x, 0, damping);
	        if (v == 0 && damping > 0) vel_y = approach(vel_y, 0, damping);
	        if (vel_x != 0 && vel_y != 0) {
	            var len = sqrt(vel_x*vel_x + vel_y*vel_y);
	            if (len > speed) {
	                vel_x = vel_x / len * speed;
	                vel_y = vel_y / len * speed;
	            }
	        }
	        object.hspeed = vel_x;
	        object.vspeed = vel_y;
	        return self;
	    };
	    function approach(val, target, step) {
	        if (val < target) return min(val + step, target);
	        if (val > target) return max(val - step, target);
	        return target;
	    }
	};

	//  Patrol, FlagPatrol, ModePatrol, StatePatrol
	function Patrol(initialState = -1) constructor {
	    state = initialState; previousState = -1; flags = 0;
	    SetState = function(newState) { if (state!=newState) { previousState=state; state=newState; } return self; };
	    GetState = function() { return state; };
	    PrevState = function() { return previousState; };
	    IsState = function(target) { return state == target; };
	    ChangedState = function() { return state != previousState; };
	    ClearState = function() { state = -1; previousState = -1; return self; };
	    AddFlag = function() { for (var i=0;i<argument_count;i++) flags |= argument[i]; return self; };
	    RemoveFlag = function() { for (var i=0;i<argument_count;i++) flags &= ~argument[i]; return self; };
	    ToggleFlag = function() { for (var i=0;i<argument_count;i++) flags ^= argument[i]; return self; };
	    HasFlag = function(flag) { return (flags & flag) != 0; };
	    ClearFlags = function() { flags = 0; return self; };
	    GetFlags = function() { return flags; };
	    SetFlags = function(value) { flags = value; return self; };
	};

	function FlagPatrol() constructor {
	    flags = 0;
	    Add = function() { for (var i=0;i<argument_count;i++) flags |= argument[i]; return self; };
	    Remove = function() { for (var i=0;i<argument_count;i++) flags &= ~argument[i]; return self; };
	    Toggle = function() { for (var i=0;i<argument_count;i++) flags ^= argument[i]; return self; };
	    Has = function(flag) { return (flags & flag) != 0; };
	    Clear = function() { flags = 0; return self; };
	    Get = function() { return flags; };
	    Set = function(value) { flags = value; return self; };
	    toString = function() { return "Flags: " + string(flags); };
	};

	function ModePatrol() constructor {
	    states = ds_map_create_kismet();
	    state = undefined;
	    previousState = undefined;
	    AddState = function(name) {
	        if (!ds_map_exists(states, name)) ds_map_add(states, name, new FlagPatrol());
	        return self;
	    };
	    SetState = function(name) {
	        if (state != name) { previousState = state; state = name; }
	        return self;
	    };
	    GetState = function() { return state; };
	    PrevState = function() { return previousState; };
	    HasState = function() { return state != undefined; };
	    Flag = function(name) {
	        if (ds_map_exists(states, name)) return states[? name];
	        show_debug_message("ModePatrol: State '" + name + "' does not exist.");
	        return undefined;
	    };
	    CurrentFlag = function() {
	        if (state != undefined && ds_map_exists(states, state)) return states[? state];
	        show_debug_message("ModePatrol: No current state set.");
	        return undefined;
	    };
	    ClearStates = function() {
	        state = undefined; previousState = undefined;
	        var keys = ds_map_keys_to_array(states);
	        for (var i=0;i<array_length(keys);i++) states[? keys[i]].Clear();
	        return self;
	    };
	    Clear = function() { ClearStates(); ds_map_clear(states); return self; };
	    Free = function() { Clear(); ds_map_destroy_kismet(states); };
	};

	function StatePatrol(initialState = -1) constructor {
	    state = initialState; previousState = -1;
	    Set = function(newState) { if (state!=newState) { previousState=state; state=newState; } return self; };
	    Get = function() { return state; };
	    Previous = function() { return previousState; };
	    Is = function(currentState) { return state == currentState; };
	    Changed = function() { return state != previousState; };
	    Clear = function() { state = -1; previousState = -1; return self; };
	};

	//  Task & TaskTracer
	function Task(id, _goal = 1, _onComplete = undefined) constructor {
	    id = id; state = KISMET_TASK_STATE.PENDING; progress = 0; goal = _goal; onComplete = _onComplete;
	    SetState = function(_state) { state = _state; return self; };
	    AddProgress = function(amount = 1, data = undefined) {
	        if (state == KISMET_TASK_STATE.COMPLETED || state == KISMET_TASK_STATE.FAILED) return self;
	        progress += amount;
	        if (progress >= goal) {
	            progress = goal;
	            state = KISMET_TASK_STATE.COMPLETED;
	            if (onComplete != undefined) onComplete(data);
	        }
	        return self;
	    };
	    Reset = function() { state = KISMET_TASK_STATE.PENDING; progress = 0; return self; };
	    IsComplete = function() { return state == KISMET_TASK_STATE.COMPLETED; };
	    GetProgressRatio = function() { return goal > 0 ? progress / goal : 0; };
	};

	function TaskTracer() constructor {
	    tasks = ds_map_create_kismet();
	    AddTask = function(task) { tasks[? task.id] = task; return self; };
	    RemoveTask = function(id) { if (ds_map_exists(tasks, id)) ds_map_delete(tasks, id); return self; };
	    GetTask = function(id) { return ds_map_exists(tasks, id) ? tasks[? id] : undefined; };
	    AreAllComplete = function() {
	        var keys = ds_map_keys_to_array(tasks);
	        for (var i=0;i<array_length(keys);i++) if (!tasks[? keys[i]].IsComplete()) { array_delete(keys,0,array_length(keys)); return false; }
	        array_delete(keys,0,array_length(keys));
	        return true;
	    };
	    Clear = function() { ds_map_clear(tasks); return self; };
	    Free = function() { ds_map_destroy_kismet(tasks); };
	};

	//  Quest System
	function Quest(_name, _description, _onComplete, _onFail) constructor {
	    id = IDGenerate().GUID();
	    name = _name; description = _description; state = "inactive"; tasks = new TaskTracer(); onComplete = _onComplete; onFail = _onFail; rewards = undefined;
	    AddTask = function(task) { tasks.AddTask(task); return self; };
	    Start = function() { if (state=="inactive") state="active"; return self; };
	    Fail = function() { if (state=="active") { state="failed"; if (is_callable(onFail)) onFail(self); } return self; };
	    Update = function() { if (state=="active") { if (tasks.AreAllComplete()) { state="completed"; if (is_callable(onComplete)) onComplete(self); } } return self; };
	    Reset = function() { tasks.Reset(); state="inactive"; return self; };
	    Free = function() { Reset(); tasks.Free(); };
	};

	function QuestManager() constructor {
	    templates = ds_map_create_kismet();
	    AddTemplate = function(template) { if (!ds_map_exists(templates, template.id)) templates[? template.id] = template; return self; };
	    RemoveTemplate = function(id) { if (ds_map_exists(templates, id)) ds_map_delete(templates, id); return self; };
	    GetTemplate = function(id) { return ds_map_exists(templates, id) ? templates[? id] : undefined; };
	    SpawnQuest = function(templateID, customOnComplete = undefined, customOnFail = undefined) {
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
	    Clear = function() { ds_map_clear(templates); return self; };
	    Free = function() { var arr = ds_map_values_to_array(templates); array_foreach(arr, function(q){ q.Free(); }); ds_map_destroy_kismet(templates); };
	};

	function QuestTracker() constructor {
	    quests = ds_map_create_kismet();
	    AddQuest = function(quest) { if (!ds_map_exists(quests, quest.id)) quests[? quest.id] = quest; return self; };
	    RemoveQuest = function(id) { if (ds_map_exists(quests, id)) ds_map_delete(quests, id); return self; };
	    GetQuest = function(id) { return ds_map_exists(quests, id) ? quests[? id] : undefined; };
	    Update = function() { var keys = ds_map_keys(quests); for (var i=0;i<array_length(keys);i++) { var q = quests[? keys[i]]; if (q.state=="active") q.Update(); } array_delete(keys,0,array_length(keys)); return self; };
	    GetActiveQuests = function() { var result = [], keys = ds_map_keys(quests); for (var i=0;i<array_length(keys);i++) { var q = quests[? keys[i]]; if (q.state=="active") array_push(result, q); } array_delete(keys,0,array_length(keys)); return result; };
	    GetCompletedQuests = function() { var result = [], keys = ds_map_keys(quests); for (var i=0;i<array_length(keys);i++) { var q = quests[? keys[i]]; if (q.state=="completed") array_push(result, q); } array_delete(keys,0,array_length(keys)); return result; };
	    Clear = function() { ds_map_clear(quests); return self; };
	    Free = function() { var arr = ds_map_values_to_array(quests); array_foreach(arr, function(q){ q.Free(); }); ds_map_destroy_kismet(quests); };
	};

	//  Command Manager
	function CommandManager() constructor {
	    cmdList = ds_list_create_kismet();
	    commandActions = ds_map_create_kismet();
	    categories = ds_map_create_kismet();
	    debugMode = false;
	    historyEnabled = false;
    
	    undoStack = undefined;
	    redoStack = undefined;
    
	    RegisterAction = function(cmd, handler, category = "default") {
	        commandActions[? cmd] = handler;
        
	        if (!ds_map_exists(categories, category)) {
	            categories[? category] = ds_list_create_kismet();
	        }
	        ds_list_add(categories[? category], cmd);
        
	        return self;
	    };
    
	    GetAction = function(cmd) {
	        return commandActions[? cmd];
	    };
    
	    Push = function(cmd, data = undefined) {
	        var cmdData = { command: cmd, data: data };
	        ds_list_add(cmdList, cmdData);
        
	        if (historyEnabled) {
	            if (undoStack == undefined) {
	                undoStack = ds_stack_create_kismet();
	                redoStack = ds_stack_create_kismet();
	            }
	            ds_stack_push(undoStack, cmdData);
	            ds_stack_clear(redoStack);
	        }
        
	        return self;
	    };
    
	    PushDelayed = function(cmd, delayFrames = 0, data = undefined) {
	        if (delayFrames <= 0) {
	            Push(cmd, data);
	        } else {
	            ds_list_add(cmdList, { command: cmd, data: data, delay: delayFrames, timer: 0 });
	        }
	        return self;
	    };
    
	    PushFront = function(cmd, data = undefined) {
	        ds_list_insert(cmdList, 0, { command: cmd, data: data });
	        return self;
	    };
    
	    Execute = function() {
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
    
	    ExecuteCategory = function(category) {
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
    
	    Clear = function() {
	        ds_list_clear(cmdList);
	        return self;
	    };
    
	    ClearCategory = function(category) {
	        if (!ds_map_exists(categories, category)) return self;
        
	        var cmdsToKeep = ds_list_create_kismet();
	        var categoryCmds = categories[? category];
        
	        var cmdLookup = ds_map_create_kismet();
	        for (var i = 0; i < ds_list_size(categoryCmds); i++) {
	            cmdLookup[? ds_list_find_value(categoryCmds, i)] = true;
	        }
        
	        for (var i = 0; i < ds_list_size(cmdList); i++) {
	            var cmd = cmdList[| i];
	            if (!ds_map_exists(cmdLookup, cmd.command)) {
	                ds_list_add(cmdsToKeep, cmd);
	            }
	        }
        
	        ds_list_destroy_kismet(cmdList);
	        cmdList = cmdsToKeep;
	        ds_map_destroy_kismet(cmdLookup);
        
	        if (debugMode) show_debug_message("[CMD] Cleared category: " + category);
	        return self;
	    };
    
	    Chain = function(commands) {
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
    
	    Undo = function() {
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
    
	    Redo = function() {
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
    
	    EnableDebug = function(enabled = true) {
	        debugMode = enabled;
	        if (debugMode) show_debug_message("[CMD] Debug mode enabled");
	        return self;
	    };
    
	    EnableHistory = function(enabled = true) {
	        historyEnabled = enabled;
	        if (enabled) {
	            if (undoStack == undefined) {
	                undoStack = ds_stack_create_kismet();
	                redoStack = ds_stack_create_kismet();
	            }
	            if (debugMode) show_debug_message("[CMD] History tracking enabled");
	        }
	        return self;
	    };
    
	    GetQueueSize = function() {
	        return ds_list_size(cmdList);
	    };
    
	    GetCommandCount = function() {
	        return ds_map_size(commandActions);
	    };
    
	    GetCategories = function() {
	        return ds_map_keys_to_array(categories);
	    };
    
	    GetCommandsInCategory = function(category) {
	        if (!ds_map_exists(categories, category)) return [];
	        return ds_list_to_array(categories[? category]);
	    };
    
	    Clear = function() {
	        ds_list_clear(cmdList);
	        return self;
	    };
    
	    Reset = function() {
	        Clear();
	        ds_map_clear(commandActions);
        
	        var cats = ds_map_values_to_array(categories);
	        for (var i = 0; i < array_length(cats); i++) {
	            ds_list_destroy_kismet(cats[i]);
	        }
	        ds_map_clear(categories);
        
	        if (historyEnabled) {
	            if (undoStack != undefined) ds_stack_destroy_kismet(undoStack);
	            if (redoStack != undefined) ds_stack_destroy_kismet(redoStack);
	            undoStack = undefined;
	            redoStack = undefined;
	        }
        
	        cmdList = ds_list_create_kismet();
	        categories = ds_map_create_kismet();
	        commandActions = ds_map_create_kismet();
        
	        return self;
	    };
    
	    Free = function() {
	        ds_list_destroy_kismet(cmdList);
	        ds_map_destroy_kismet(commandActions);
        
	        var cats = ds_map_values_to_array(categories);
	        for (var i = 0; i < array_length(cats); i++) {
	            ds_list_destroy_kismet(cats[i]);
	        }
	        ds_map_destroy_kismet(categories);
        
	        if (historyEnabled) {
	            if (undoStack != undefined) ds_stack_destroy_kismet(undoStack);
	            if (redoStack != undefined) ds_stack_destroy_kismet(redoStack);
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
    
	    Then = function(cmd, data = undefined, delay = 0) {
	        array_push(commands, { cmd: cmd, data: data, delay: delay });
	        return self;
	    };
    
	    ThenWait = function(frames) {
	        array_push(commands, { cmd: "WAIT", delay: frames });
	        return self;
	    };
    
	    Execute = function(manager = DefaultCommandManager) {
	        manager.Chain(commands);
	        return self;
	    };
    
	    Clear = function() {
	        commands = [];
	        return self;
	    };
	};

	//  ID Generator
	function IDGenerate() constructor {
	    GUID = function() {
	        var chars = "0123456789abcdef", guid = "";
	        for (var i=0;i<32;i++) guid += string_char_at(chars, irandom_range(1,string_length(chars)));
	        guid = string_insert("-", string_insert("-", string_insert("-", string_insert("-", guid,9),14),19),24);
	        return guid;
	    };
	    UUID = function() {
	        var chars = "0123456789abcdef", s = array_create(32);
	        for (var i=0;i<32;i++) s[i] = string_char_at(chars, irandom_range(1,string_length(chars)));
	        s[12] = "4"; var variant = irandom_range(8,11); s[16] = string_char_at(chars, variant+1);
	        var uuid = ""; for (var i=0;i<32;i++) uuid += s[i];
	        uuid = string_insert("-", string_insert("-", string_insert("-", string_insert("-", uuid,9),14),19),24);
	        return uuid;
	    };
	    Incremental = function(prefix="", start=0) { var counter=start; return function(){ counter++; return prefix+string(counter); }; };
	    Timestamped = function(prefix="") { return prefix+string(GetUnixDateTime(date_current_datetime())); };
	    ShortHash = function(input) {
	        var hash=0;
	        for (var i=1;i<=string_length(input);i++) hash = (hash*31 + ord(string_char_at(input,i))) mod 1000000007;
	        return string(abs(hash));
	    };
	};

	//  Timer System
	function Timer(_duration, _onComplete, _loop = false, _onUpdate = undefined) constructor {
	    duration = _duration; remaining = _duration; onComplete = _onComplete; loop = _loop; onUpdate = _onUpdate; active = true; paused = false;
	    Update = function(delta = 1) {
	        if (!active || paused) return self;
	        remaining -= delta;
	        if (onUpdate != undefined) onUpdate(self);
	        if (remaining <= 0) {
	            if (loop) { remaining += duration; if (onComplete != undefined) onComplete(self); }
	            else { active = false; if (onComplete != undefined) onComplete(self); }
	        }
	        return self;
	    };
	    Reset = function() { remaining = duration; active = true; paused = false; return self; };
	    Pause = function() { paused = true; return self; };
	    Resume = function() { paused = false; return self; };
	    Stop = function() { active = false; return self; };
	};

	//  Object Pooling
	function ObjectPool(_objectName, _size, _layer = "Instances") constructor {
	    objectName = _objectName; layer = _layer; pool = ds_queue_create_kismet();
	    for (var i=0;i<_size;i++) {
	        var inst = instance_create_layer(0,0,layer,objectName);
	        instance_deactivate_object(inst);
	        ds_queue_enqueue(pool, inst);
	    }
	    Get = function(x, y, activate = true) {
	        var inst = ds_queue_empty(pool) ? instance_create_layer(x,y,layer,objectName) : ds_queue_dequeue(pool);
	        if (activate) instance_activate_object(inst);
	        inst.x = x; inst.y = y;
	        return inst;
	    };
	    Return = function(inst) { instance_deactivate_object(inst); ds_queue_enqueue(pool, inst); return self; };
	    Free = function() { while (!ds_queue_empty(pool)) instance_destroy(ds_queue_dequeue(pool)); ds_queue_destroy_kismet(pool); };
	};

	//  Color Struct (RGBA + hex)
	function Color(_r=0, _g=0, _b=0, _a=1) constructor {
	    r=_r; g=_g; b=_b; a=_a;
	    static FromHex = function(hex) {
	        if (string_char_at(hex,1)=="#") hex = string_delete(hex,1,1);
	        var r = hex_to_dec(string_copy(hex,1,2))/255;
	        var g = hex_to_dec(string_copy(hex,3,2))/255;
	        var b = hex_to_dec(string_copy(hex,5,2))/255;
	        var a = string_length(hex)>=8 ? hex_to_dec(string_copy(hex,7,2))/255 : 1;
	        return new Color(r,g,b,a);
	    };
	    ToHex = function(includeAlpha=false) {
	        var rh = string_format(floor(r*255),1,0);
	        var gh = string_format(floor(g*255),1,0);
	        var bh = string_format(floor(b*255),1,0);
	        if (includeAlpha) { var ah = string_format(floor(a*255),1,0); return "#"+rh+gh+bh+ah; }
	        return "#"+rh+gh+bh;
	    };
	    ToArray = function() { return [r,g,b,a]; };
	    static FromArray = function(arr) { return new Color(arr[0],arr[1],arr[2],arr[3]??1); };
	    static White = function() { return new Color(1,1,1,1); };
	    static Black = function() { return new Color(0,0,0,1); };
	    static Red = function() { return new Color(1,0,0,1); };
	    static Green = function() { return new Color(0,1,0,1); };
	    static Blue = function() { return new Color(0,0,1,1); };
	    static Yellow = function() { return new Color(1,1,0,1); };
	    static Magenta = function() { return new Color(1,0,1,1); };
	    static Cyan = function() { return new Color(0,1,1,1); };
	};

	//  Rect Struct
	function Rect(_x=0, _y=0, _w=0, _h=0) constructor {
	    x=_x; y=_y; w=_w; h=_h;
	    Contains = function(px, py) { return px>=x && px<=x+w && py>=y && py<=y+h; };
	    Intersects = function(other) { return !(other.x > x+w || other.x+other.w < x || other.y > y+h || other.y+other.h < y); };
	    Expand = function(amt) { x-=amt; y-=amt; w+=amt*2; h+=amt*2; return self; };
	    Clone = function() { return new Rect(x,y,w,h); };
	};
	
	// State Machine
	function StateMachine(_initial_state) constructor {
	    states = ds_map_create_kismet();
	    current = _initial_state;
	    previous = undefined;
	    changed = false;
    
	    AddState = function(_name, _on_enter, _on_update, _on_exit) {
	        states[? _name] = {
	            enter: _on_enter,
	            update: _on_update,
	            exit: _on_exit
	        };
	        return self;
	    };
    
	    ChangeTo = function(_new_state, _data = undefined) {
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
    
	    Update = function(_delta = 1/60) {
	        changed = false;
	        if (current != undefined && ds_map_exists(states, current)) {
	            var update_fn = states[? current].update;
	            if (update_fn != undefined) update_fn(_delta);
	        }
	        return self;
	    };
    
	    Serialize = function() {
	        return {
	            current: current,
	            previous: previous,
	            state_names: ds_map_keys_to_array(states)
	        };
	    };
    
	    Deserialize = function(_data) {
	        if (_data.current != undefined) current = _data.current;
	        if (_data.previous != undefined) previous = _data.previous;
	        return self;
	    };
    
	    Visualize = function() {
	        show_debug_message("=== State Machine ===");
	        show_debug_message("Current: " + string(current));
	        show_debug_message("Previous: " + string(previous));
	        show_debug_message("Registered states: " + string(ds_map_keys_to_array(states)));
	        return self;
	    };
		
		toString = function() {
			Visualize();
		};
    
	    Free = function() {
	        ds_map_destroy_kismet(states);
	    };
	}
	
	function AchievementManager() constructor {
	    achievements = ds_map_create_kismet();  // id -> {name, progress, goal, unlocked, hidden}
	    callbacks = ds_map_create_kismet();     // id -> on_unlock callback
	    unlocked_count = 0;
    
	    Add = function(_id, _name, _goal = 1, _hidden = false, _on_unlock = undefined) {
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
    
	    Progress = function(_id, _amount = 1) {
	        if (!ds_map_exists(achievements, _id)) return self;
	        var ach = achievements[? _id];
	        if (ach.unlocked) return self;
        
	        ach.progress = min(ach.progress + _amount, ach.goal);
        
	        if (ach.progress >= ach.goal) {
	            Unlock(_id);
	        }
	        return self;
	    };
    
	    Unlock = function(_id) {
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
    
	    IsUnlocked = function(_id) {
	        return ds_map_exists(achievements, _id) ? achievements[? _id].unlocked : false;
	    };
    
	    GetProgress = function(_id) {
	        if (!ds_map_exists(achievements, _id)) return 0;
	        var ach = achievements[? _id];
	        return ach.goal > 0 ? ach.progress / ach.goal : 0;
	    };
    
	    GetAll = function() {
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
    
	    LoadFromSave = function(_save_data) {
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
    
	    Reset = function() {
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
    
	    GetStats = function() {
	        return {
	            total: ds_map_size(achievements),
	            unlocked: unlocked_count,
	            percent: unlocked_count / max(1, ds_map_size(achievements))
	        };
	    };
    
	    Free = function() {
	        ds_map_destroy_kismet(achievements);
	        ds_map_destroy_kismet(callbacks);
	    };
	}
	
	// SaveManager (simplified)
	function SaveManager() constructor {
	    slots = 10;
	    current_slot = 0;
	    auto_save_enabled = false;
	    auto_save_timer = 0;
	    auto_save_interval = 300; // seconds
    
	    Save = function(_slot, _data, _thumbnail = undefined) { // Simple save
	        var save_data = {
	            version: KISMET_VERSION,
	            timestamp: GetUnixDateTime(date_current_datetime()),
	            data: _data,
	            thumbnail: _thumbnail,
	            checksum: "" // simple checksum
	        };
        
	        save_data.checksum = string_hash(json_stringify(_data)); // simple checksum (just for validation)
        
	        var file_name = "save_slot_" + string(_slot) + ".kismet";
	        var success = File.SaveJSON(file_name, save_data);
        
	        if (success && IS_KISMET_DEBUG_ENABLED()) {
	            show_debug_message("[Save] Slot " + string(_slot) + " saved");
	        }
        
	        return success;
	    };
    
	    // Simple load
	    Load = function(_slot) {
	        var file_name = "save_slot_" + string(_slot) + ".kismet";
	        var save_data = File.LoadJSON(file_name);
        
	        if (save_data == undefined) return undefined;
        
	        // Verify checksum
	        var expected = string_hash(json_stringify(save_data.data));
	        if (save_data.checksum != expected) {
	            show_debug_message("[Save] Corrupted save slot " + string(_slot));
	            return undefined;
	        }
        
	        current_slot = _slot;
	        return save_data.data;
	    };
    
	    Exists = function(_slot) {
	        var file_name = "save_slot_" + string(_slot) + ".kismet";
	        return file_exists(file_name);
	    };
    
	    Delete = function(_slot) {
	        var file_name = "save_slot_" + string(_slot) + ".kismet";
	        if (file_exists(file_name)) {
	            file_delete(file_name);
	            return true;
	        }
	        return false;
	    };
    
	    GetSaveList = function() {
	        var saves = [];
	        for (var i = 0; i < slots; i++) {
	            if (Exists(i)) {
	                var file_name = "save_slot_" + string(i) + ".kismet";
	                var data = File.LoadJSON(file_name);
	                if (data != undefined) {
	                    array_push(saves, {
	                        slot: i,
	                        timestamp: data.timestamp,
	                        has_thumbnail: data.thumbnail != undefined
	                    });
	                }
	            }
	        }
	        return saves;
	    };
    
	    // Auto-save (call in Step event)
	    UpdateAutoSave = function(_delta, _get_data_function) {
	        if (!auto_save_enabled) return;
        
	        auto_save_timer += _delta;
	        if (auto_save_timer >= auto_save_interval) {
	            auto_save_timer = 0;
	            if (_get_data_function != undefined) {
	                var data = _get_data_function();
	                Save(current_slot, data);
	            }
	        }
	    };
    
	    EnableAutoSave = function(_interval_seconds = 300) {
	        auto_save_enabled = true;
	        auto_save_interval = _interval_seconds;
	        auto_save_timer = 0;
	        return self;
	    };
    
	    DisableAutoSave = function() {
	        auto_save_enabled = false;
	        return self;
	    };
	}
	
	// Profiler
	function Profiler() constructor {
	    markers = ds_map_create_kismet();     // name -> {total_time, call_count, min, max, samples}
	    current_marker = undefined;
	    start_time = 0;
	    enabled = true;
    
	    Begin = function(_name) {
	        if (!enabled) return self;
        
	        if (ds_map_exists(markers, _name)) {
	            current_marker = markers[? _name];
	        } else {
	            current_marker = {
	                total_time: 0,
	                call_count: 0,
	                min_time: Infinity,
	                max_time: 0,
	                samples: ds_list_create_kismet(),
	                name: _name
	            };
	            markers[? _name] = current_marker;
	        }
        
	        current_marker.call_count++;
	        start_time = current_time;
	        return self;
	    };
    
	    End = function() {
	        if (!enabled || current_marker == undefined) return self;
        
	        var elapsed = (current_time - start_time) / 1000.0; // milliseconds
	        current_marker.total_time += elapsed;
        
	        if (elapsed < current_marker.min_time) current_marker.min_time = elapsed;
	        if (elapsed > current_marker.max_time) current_marker.max_time = elapsed;
        
	        // Keep last 60 samples for average
	        if (ds_list_size(current_marker.samples) >= 60) {
	            ds_list_delete(current_marker.samples, 0);
	        }
	        ds_list_add(current_marker.samples, elapsed);
        
	        current_marker = undefined;
	        return self;
	    };
    
	    GetData = function() {
	        var result = {};
	        var keys = ds_map_keys_to_array(markers);
        
	        for (var i = 0; i < array_length(keys); i++) {
	            var m = markers[? keys[i]];
            
	            // Calculate average from samples
	            var avg = 0;
	            for (var j = 0; j < ds_list_size(m.samples); j++) {
	                avg += m.samples[| j];
	            }
	            avg = avg / max(1, ds_list_size(m.samples));
            
	            result[$ m.name] = {
	                total_ms: m.total_time,
	                calls: m.call_count,
	                avg_ms: avg,
	                min_ms: m.min_time,
	                max_ms: m.max_time,
	                percent: 0 // Calculate after
	            };
	        }
        
	        // Calculate percentages
	        var total_time = 0;
	        keys = ds_map_keys_to_array(markers);
	        for (var i = 0; i < array_length(keys); i++) {
	            total_time += result[$ keys[i]].total_ms;
	        }
        
	        for (var i = 0; i < array_length(keys); i++) {
	            result[$ keys[i]].percent = (result[$ keys[i]].total_ms / total_time) * 100;
	        }
        
	        return result;
	    };
    
	    GetReport = function() {
	        var data = GetData();
	        var keys = variable_struct_get_names(data);
        
	        // Sort by total time (descending)
	        for (var i = 0; i < array_length(keys) - 1; i++) {
	            for (var j = i + 1; j < array_length(keys); j++) {
	                if (data[$ keys[i]].total_ms < data[$ keys[j]].total_ms) {
	                    var temp = keys[i];
	                    keys[i] = keys[j];
	                    keys[j] = temp;
	                }
	            }
	        }
        
	        var report = "=== Performance Profile ===\n";
	        for (var i = 0; i < array_length(keys); i++) {
	            var d = data[$ keys[i]];
	            report += string(keys[i]) + ": " + string(d.total_ms) + "ms (" + string(d.percent) + "%) - Avg: " + string(d.avg_ms) + "ms, Calls: " + string(d.calls) + "\n";
	        }
        
	        return report;
	    };
    
	    Reset = function() {
	        var keys = ds_map_keys_to_array(markers);
	        for (var i = 0; i < array_length(keys); i++) {
	            var m = markers[? keys[i]];
	            ds_list_destroy_kismet(m.samples);
	        }
	        ds_map_clear(markers);
	        current_marker = undefined;
	        return self;
	    };
    
	    SetEnabled = function(_enabled) {
	        enabled = _enabled;
	        return self;
	    };
    
	    Free = function() {
	        Reset();
	        ds_map_destroy_kismet(markers);
	    };
	}

	//  File Helpers & JSON
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

	//  Input Handler (generic)
	function Input() constructor {
	    bindings = ds_map_create_kismet();
	    BindKey = function(key, action) { bindings[? key] = action; return self; };
	    IsPressed = function(action) {
	        var keys = ds_map_find_value(bindings, action);
	        if (is_array(keys)) { for (var i=0;i<array_length(keys);i++) if (keyboard_check(keys[i])) return true; }
	        else return keyboard_check(keys);
	        return false;
	    };
	    IsPressedOnce = function(action) {
	        var keys = ds_map_find_value(bindings, action);
	        if (is_array(keys)) { for (var i=0;i<array_length(keys);i++) if (keyboard_check_pressed(keys[i])) return true; }
	        else return keyboard_check_pressed(keys);
	        return false;
	    };
	    Free = function() { ds_map_destroy_kismet(bindings); };
	};

	//  Drawing Helpers
	Draw = { // Needs to be improved
	    HealthBar: function(x, y, w, h, percent, backColor, fillColor, borderColor = c_black) {
	        var prev = draw_get_color();
	        draw_set_color(borderColor);
	        draw_rectangle(x-1,y-1,x+w+1,y+h+1,false);
	        draw_set_color(backColor);
	        draw_rectangle(x,y,x+w,y+h,false);
	        draw_set_color(fillColor);
	        draw_rectangle(x,y,x+w*percent,y+h,false);
	        draw_set_color(prev);
	    },
	    OutlinedText: function(text, x, y, outlineColor, textColor, thickness=1) {
	        var prev = draw_get_color();
	        draw_set_color(outlineColor);
	        for (var dx=-thickness;dx<=thickness;dx++) for (var dy=-thickness;dy<=thickness;dy++) if (dx!=0 || dy!=0) draw_text(x+dx,y+dy,text);
	        draw_set_color(textColor);
	        draw_text(x,y,text);
	        draw_set_color(prev);
	    },
	    DropShadowText: function(text, x, y, shadowColor, textColor, offsetX=2, offsetY=2) {
	        var prev = draw_get_color();
	        draw_set_color(shadowColor);
	        draw_text(x+offsetX,y+offsetY,text);
	        draw_set_color(textColor);
	        draw_text(x,y,text);
	        draw_set_color(prev);
	    },
	    CenteredText: function(text, x, y) {
	        var ha = draw_get_halign(), va = draw_get_valign();
	        draw_set_halign(fa_center); draw_set_valign(fa_middle);
	        draw_text(x,y,text);
	        draw_set_halign(ha); draw_set_valign(va);
	    }
	};

	//  Data Pack (XML)
	function DataPack() constructor {
	    root = undefined;
	    current_node = undefined;
    
	    building = false;
	    builder_stack = ds_stack_create_kismet();
    
	    Clear = function() {
	        if (root != undefined) FreeNode(root);
	        root = undefined;
	        current_node = undefined;
	        ds_stack_clear(builder_stack);
	        building = false;
	        return self;
	    };
    
	    NewDocument = function(root_tag = "root") {
	        Clear();
	        root = new XMLNode(root_tag);
	        current_node = root;
	        building = true;
	        return self;
	    };
    
	    PushTag = function(tag, attributes = undefined) {
		    if (!building) {
		        show_debug_message("[DataPack] Error: Not building a document. Call NewDocument() first.");
		        return self;
		    }
    
		    var new_node = new XMLNode(tag);
		    if (attributes != undefined) {
		        var attr_names = variable_struct_get_names(attributes);
		        for (var i = 0; i < array_length(attr_names); i++) {
		            var key = attr_names[i];
		            var value = variable_struct_get(attributes, key);
		            new_node.SetAttribute(key, value);
		        }
		    }
    
		    if (current_node != undefined) {
		        current_node.AddChild(new_node);
		    } else {
		        root = new_node;
		    }
    
		    ds_stack_push(builder_stack, current_node);
		    current_node = new_node;
		    return self;
		};
    
	    AddContent = function(content) {
	        if (!building || current_node == undefined) {
	            show_debug_message("[DataPack] Error: No active tag to add content to.");
	            return self;
	        }
        
	        if (is_struct(content) || is_array(content)) {
	            current_node.AddContent(json_stringify(content));
	        } else if (is_bool(content)) {
	            current_node.AddContent(content ? "true" : "false");
	        } else if (is_real(content) && !is_int64(content)) {
	            current_node.AddContent(string_format(content, 1, 6));
	        } else {
	            current_node.AddContent(string(content));
	        }
        
	        return self;
	    };
    
	    AddCDATA = function(content) {
	        if (!building || current_node == undefined) return self;
	        current_node.AddCDATA(content);
	        return self;
	    };
    
	    PopTag = function() {
	        if (!building || ds_stack_empty(builder_stack)) {
	            show_debug_message("[DataPack] Error: No tag to pop.");
	            return self;
	        }
	        current_node = ds_stack_pop(builder_stack);
	        return self;
	    };
    
	    GetString = function(pretty = true) {
	        if (root == undefined) return "";
	        return root.ToString(pretty ? 0 : -1);
	    };
    
	    Parse = function(xml_string) {
	        Clear();
	        var parser = new XMLParser();
	        var result = parser.Parse(xml_string);
        
	        if (result != undefined && result.success) {
	            root = result.root;
	            building = false;
	            return root;
	        }
        
	        show_debug_message("[DataPack] Parse error: " + result.error);
	        return undefined;
	    };
    
	    static LoadFromFile = function(filename) {
	        if (!file_exists(filename)) {
	            show_debug_message("[DataPack] File not found: " + filename);
	            return undefined;
	        }
        
	        var f = file_text_open_read(filename);
	        if (f == -1) {
	            show_debug_message("[DataPack] Cannot open file: " + filename);
	            return undefined;
	        }
        
	        var content = "";
	        while (!file_text_eof(f)) {
	            content += file_text_read_string(f);
	            if (!file_text_eof(f)) content += "\n";
	            file_text_readln(f);
	        }
	        file_text_close(f);
        
	        var pack = new DataPack();
	        pack.Parse(content);
	        return pack;
	    };
    
	    SaveToFile = function(filename, pretty = true) {
	        if (root == undefined) return false;
	        return KISMET.File.SaveString(filename, GetString(pretty));
	    };
    
	    GetRoot = function() { return root; };
    
	    Query = function(path) { // simplified
	        if (root == undefined) return undefined;
	        var parts = string_split(path, "/");
	        var current = root;
        
	        for (var i = 0; i < array_length(parts); i++) {
	            var part = parts[i];
	            if (part == "") continue;
            
	            // Handle attribute queries like "node@attribute"
	            var attr_pos = string_pos("@", part);
	            var tag_name = part;
	            var attr_name = undefined;
            
	            if (attr_pos > 0) {
	                tag_name = string_copy(part, 1, attr_pos - 1);
	                attr_name = string_copy(part, attr_pos + 1, string_length(part) - attr_pos);
	            }
            
	            var found = undefined;
	            if (current.children != undefined) {
	                for (var j = 0; j < array_length(current.children); j++) {
	                    if (current.children[j].tag == tag_name) {
	                        found = current.children[j];
	                        break;
	                    }
	                }
	            }
            
	            if (found == undefined) return undefined;
	            current = found;
            
	            if (attr_name != undefined) {
	                return current.GetAttribute(attr_name);
	            }
	        }
        
	        return current;
	    };
    
	    Free = function() {
	        if (root != undefined) FreeNode(root);
	        if (builder_stack != undefined) ds_stack_destroy_kismet(builder_stack);
	    };
    
	    function FreeNode(node) {
	        if (node == undefined) return;
	        if (node.children != undefined) {
	            for (var i = 0; i < array_length(node.children); i++) {
	                FreeNode(node.children[i]);
	            }
	        }
	        node.Free();
	    }
	}

	// XMLNode
	function XMLNode(_tag) constructor {
	    tag = _tag;
	    attributes = ds_map_create_kismet();
	    content = "";
	    cdata = "";
	    children = [];
	    parent = undefined;
    
	    SetAttribute = function(name, value) {
	        attributes[? name] = string(value);
	        return self;
	    };
    
	    GetAttribute = function(name) {
	        return ds_map_exists(attributes, name) ? attributes[? name] : undefined;
	    };
    
	    RemoveAttribute = function(name) {
	        if (ds_map_exists(attributes, name)) ds_map_delete(attributes, name);
	        return self;
	    };
    
	    HasAttribute = function(name) {
	        return ds_map_exists(attributes, name);
	    };
    
	    GetAttributes = function() {
		    var result = {};
		    var keys = ds_map_keys_to_array(attributes);
		    for (var i = 0; i < array_length(keys); i++) {
		        var key = keys[i];
		        // Use variable_struct_set for struct assignment
		        variable_struct_set(result, key, attributes[? key]);
		    }
		    return result;
		};
    
	    AddContent = function(text) {
	        content += text;
	        return self;
	    };
    
	    AddCDATA = function(text) {
	        cdata += text;
	        return self;
	    };
    
	    GetContent = function() {
	        return content;
	    };
    
	    GetCDATA = function() {
	        return cdata;
	    };
    
	    GetText = function() {
	        var text = content;
	        if (cdata != "") {
	            if (text != "") text += "\n";
	            text += cdata;
	        }
        
	        // Also collect text from children
	        if (children != undefined) {
	            for (var i = 0; i < array_length(children); i++) {
	                var child_text = children[i].GetText();
	                if (child_text != "") {
	                    if (text != "") text += "\n";
	                    text += child_text;
	                }
	            }
	        }
        
	        return text;
	    };
    
	    AddChild = function(node) {
	        array_push(children, node);
	        node.parent = self;
	        return self;
	    };
    
	    RemoveChild = function(node) {
	        for (var i = 0; i < array_length(children); i++) {
	            if (children[i] == node) {
	                array_delete(children, i, 1);
	                node.parent = undefined;
	                return true;
	            }
	        }
	        return false;
	    };
    
	    GetChildren = function(tag_name = undefined) {
	        if (tag_name == undefined) return children;
        
	        var result = [];
	        for (var i = 0; i < array_length(children); i++) {
	            if (children[i].tag == tag_name) {
	                array_push(result, children[i]);
	            }
	        }
	        return result;
	    };
    
	    GetFirstChild = function(tag_name = undefined) {
	        if (tag_name == undefined) {
	            return array_length(children) > 0 ? children[0] : undefined;
	        }
        
	        for (var i = 0; i < array_length(children); i++) {
	            if (children[i].tag == tag_name) {
	                return children[i];
	            }
	        }
	        return undefined;
	    };
    
	    ToString = function(indent_level = 0) {
	        var indent = indent_level >= 0 ? string_repeat("  ", indent_level) : "";
	        var result = indent + "<" + tag;
        
	        // Add attributes
	        var attr_keys = ds_map_keys_to_array(attributes);
	        for (var i = 0; i < array_length(attr_keys); i++) {
	            var key = attr_keys[i];
	            var value = attributes[? key];
	            // Escape quotes in attribute values
	            value = string_replace_all(value, "\"", "&quot;");
	            result += " " + key + "=\"" + value + "\"";
	        }
        
	        // Check if this is a self-closing tag
	        var has_content = content != "" || cdata != "" || array_length(children) > 0;
        
	        if (!has_content) {
	            result += " />";
	            if (indent_level >= 0) result += "\n";
	            return result;
	        }
        
	        result += ">";
        
	        // Add content
	        if (content != "") {
	            if (indent_level >= 0 && (cdata != "" || array_length(children) > 0)) result += "\n";
	            var content_indent = indent_level >= 0 ? indent + "  " : "";
	            var escaped_content = EscapeXML(content);
            
	            if (indent_level >= 0 && (cdata != "" || array_length(children) > 0)) {
	                result += content_indent + escaped_content + "\n";
	            } else {
	                result += escaped_content;
	            }
	        }
        
	        // Add CDATA
	        if (cdata != "") {
	            if (indent_level >= 0 && (content != "" || array_length(children) > 0)) result += indent + "  ";
	            result += "<![CDATA[" + cdata + "]]>";
	            if (indent_level >= 0 && array_length(children) > 0) result += "\n";
	        }
        
	        // Add children
	        for (var i = 0; i < array_length(children); i++) {
	            result += children[i].ToString(indent_level >= 0 ? indent_level + 1 : -1);
	        }
        
	        // Close tag
	        if (indent_level >= 0 && (content != "" || cdata != "" || array_length(children) > 0)) {
	            result += indent;
	        }
	        result += "</" + tag + ">";
	        if (indent_level >= 0) result += "\n";
        
	        return result;
	    };
    
	    Free = function() {
	        if (attributes != undefined) ds_map_destroy_kismet(attributes);
	        attributes = undefined;
        
	        if (children != undefined) {
	            for (var i = 0; i < array_length(children); i++) {
	                if (children[i] != undefined) children[i].Free();
	            }
	            children = undefined;
	        }
	    };
    
	    function EscapeXML(text) {
	        text = string_replace_all(text, "&", "&amp;");
	        text = string_replace_all(text, "<", "&lt;");
	        text = string_replace_all(text, ">", "&gt;");
	        text = string_replace_all(text, "\"", "&quot;");
	        text = string_replace_all(text, "'", "&apos;");
	        return text;
	    }
	}

	// XML Parser class
	function XMLParser() constructor {
	    position = 1;
	    xml_string = "";
	    length = 0;
    
	    Parse = function(xml) {
	        xml_string = xml;
	        length = string_length(xml_string);
	        position = 1;
        
	        try {
	            // Skip XML declaration
	            SkipWhitespace();
	            if (CheckString("<?xml")) {
	                ParseDeclaration();
	            }
            
	            SkipWhitespace();
	            var root = ParseNode();
            
	            if (root != undefined) {
	                return { success: true, root: root, error: "" };
	            } else {
	                return { success: false, root: undefined, error: "Failed to parse root node" };
	            }
	        } catch(e) {
	            return { success: false, root: undefined, error: string(e) };
	        }
	    };
    
	    function ParseNode() {
	        SkipWhitespace();
	        if (!CheckString("<")) {
	            return undefined;
	        }
        
	        position++; // Skip '<'
        
	        // comment
	        if (CheckString("!--")) {
	            ParseComment();
	            return ParseNode(); // Skip comment and continue
	        }
        
	        // processing instruction
	        if (CheckString("?")) {
	            ParsePI();
	            return ParseNode();
	        }
        
	        // tag name
	        var tag_name = ParseTagName();
	        if (tag_name == "") {
	            return undefined;
	        }
        
	        var node = new XMLNode(tag_name);
        
	        // attributes
	        SkipWhitespace();
	        while (!CheckString(">") && !CheckString("/>") && position <= length) {
	            var attr = ParseAttribute();
	            if (attr != undefined) {
	                node.SetAttribute(attr.name, attr.value);
	            }
	            SkipWhitespace();
	        }
        
	        // self-closing tag
	        if (CheckString("/>")) {
	            position += 2;
	            return node;
	        }
        
	        // Skip '>'
	        if (CheckString(">")) {
	            position++;
	        } else {
	            return undefined;
	        }
        
	        // content and children
	        while (position <= length) {
	            SkipWhitespace();
            
	            if (CheckString("</")) {
	                // Closing tag
	                var close_pos = position + 2;
	                var close_tag = ParseTagNameAt(close_pos);
	                if (close_tag == tag_name) {
	                    // Find the closing '>'
	                    while (position <= length && !CheckString(">")) {
	                        position++;
	                    }
	                    position++; // Skip '>'
	                    break;
	                } else {
	                    // Mismatched closing tag
	                    return undefined;
	                }
	            } else if (CheckString("<![CDATA[")) {
	                // CDATA section
	                position += 9; // Skip '<![CDATA['
	                var cdata_start = position;
	                while (position <= length - 3 && !CheckString("]]>")) {
	                    position++;
	                }
	                var cdata = string_copy(xml_string, cdata_start, position - cdata_start);
	                node.AddCDATA(cdata);
	                position += 3; // Skip ']]>'
	            } else if (CheckString("<!--")) {
	                // Comment
	                ParseComment();
	            } else if (CheckString("<")) {
	                // Child node
	                var child = ParseNode();
	                if (child != undefined) {
	                    node.AddChild(child);
	                }
	            } else {
	                // Text content
	                var text_start = position;
	                while (position <= length && !CheckString("<")) {
	                    position++;
	                }
	                var text = string_copy(xml_string, text_start, position - text_start);
	                if (string_trim(text) != "") {
	                    node.AddContent(UnescapeXML(text));
	                }
	            }
	        }
        
	        return node;
	    }
    
	    function ParseTagName() {
	        var start = position;
	        while (position <= length) {
	            var char = string_char_at(xml_string, position);
	            if ((char >= "a" && char <= "z") || (char >= "A" && char <= "Z") || 
	                (char >= "0" && char <= "9") || char == "_" || char == "-" || char == ":") {
	                position++;
	            } else {
	                break;
	            }
	        }
	        return string_copy(xml_string, start, position - start);
	    }
    
	    function ParseTagNameAt(pos) {
	        var old_pos = position;
	        position = pos;
	        var result = ParseTagName();
	        position = old_pos;
	        return result;
	    }
    
	    function ParseAttribute() {
	        var name = ParseTagName();
	        if (name == "") return undefined;
        
	        SkipWhitespace();
	        if (!CheckString("=")) {
	            return undefined;
	        }
	        position++; // Skip '='
	        SkipWhitespace();
        
	        var quote_char = string_char_at(xml_string, position);
	        if (quote_char != "\"" && quote_char != "'") {
	            return undefined;
	        }
	        position++; // Skip opening quote
        
	        var start = position;
	        while (position <= length && string_char_at(xml_string, position) != quote_char) {
	            position++;
	        }
        
	        var value = string_copy(xml_string, start, position - start);
	        position++; // Skip closing quote
        
	        value = UnescapeXML(value);
        
	        return { name: name, value: value };
	    }
    
	    function ParseDeclaration() {
	        while (position <= length - 2 && !CheckString("?>")) {
	            position++;
	        }
	        position += 2;
	    }
    
	    function ParseComment() {
	        while (position <= length - 3 && !CheckString("-->")) {
	            position++;
	        }
	        position += 3;
	    }
    
	    function ParsePI() {
	        while (position <= length - 2 && !CheckString("?>")) {
	            position++;
	        }
	        position += 2;
	    }
    
	    function SkipWhitespace() {
	        while (position <= length) {
	            var char = string_char_at(xml_string, position);
	            if (char == " " || char == "\t" || char == "\n" || char == "\r") {
	                position++;
	            } else {
	                break;
	            }
	        }
	    }
    
	    function CheckString(str) {
	        var str_len = string_length(str);
	        if (position + str_len - 1 > length) return false;
        
	        var check = string_copy(xml_string, position, str_len);
	        return check == str;
	    }
    
	    function UnescapeXML(text) {
	        text = string_replace_all(text, "&amp;", "&");
	        text = string_replace_all(text, "&lt;", "<");
	        text = string_replace_all(text, "&gt;", ">");
	        text = string_replace_all(text, "&quot;", "\"");
	        text = string_replace_all(text, "&apos;", "'");
	        return text;
	    }
	}

	//  Utility Functions
	function ExecuteSafe(fn, data = undefined, fallback = undefined) {
	    try { fn(data); } catch(e) { show_debug_message("KISMET.ExecuteSafe error: "+string(e)); if (fallback!=undefined) return fallback(); return undefined; }
	};
	
	function GetUnixDateTime(dateTarget) {
	    var dateStart = date_create_datetime(1970,1,1,0,0,0);
	    return date_compare_date(dateStart, dateTarget);
	};

	function WorldToUI(camera, x, y) {
	    var cam = camera.camera;
	    return [
	        (x - camera_get_view_x(cam)) / camera_get_view_width(cam) * display_get_gui_width(),
	        (y - camera_get_view_y(cam)) / camera_get_view_height(cam) * display_get_gui_height()
	    ];
	};

	//  Noise Functions
	function Hash(p) { var _x=p[0],_y=p[1]; return frac(sin(_x*127.1 + _y*311.7)*43758.5453); };
	function Dot(ax,ay,bx,by) { return ax*bx + ay*by; };
	function Frac(_x) { return _x - floor(_x); };
	function Clamp(_x, minVal, maxVal) { return max(minVal, min(_x, maxVal)); };
	function Mix(a,b,t) { return a + (b-a)*t; };
	function Smoothstep(edge0, edge1, _x) { var t = Clamp((_x-edge0)/(edge1-edge0),0.0,1.0); return t*t*(3.0-2.0*t); };
	function ValueNoise(p) {
	    var px=p[0], py=p[1];
	    var i = [floor(px), floor(py)];
	    var f = [Frac(px), Frac(py)];
	    f[0] = Smoothstep(0,1,f[0]); f[1] = Smoothstep(0,1,f[1]);
	    var a = Hash(i);
	    var b = Hash([i[0]+1, i[1]]);
	    var c = Hash([i[0], i[1]+1]);
	    var d = Hash([i[0]+1, i[1]+1]);
	    var ab = Mix(a,b,f[0]);
	    var cd = Mix(c,d,f[0]);
	    return Mix(ab,cd,f[1]);
	};
	function Fbm(p, octaves) {
	    var value=0.0, amp=0.5, freq=1.0;
	    for (var i=0;i<octaves;i++) { value += amp * ValueNoise([p[0]*freq, p[1]*freq]); amp*=0.5; freq*=2.0; }
	    return value;
	};
	function RidgeNoise(p, octaves) {
	    var value=0.0, amp=0.5, freq=1.0;
	    for (var i=0;i<octaves;i++) { var n = 1.0 - abs(ValueNoise([p[0]*freq, p[1]*freq])); n = n*n; value += n*amp; amp*=0.5; freq*=2.0; }
	    return value;
	};
	
    DefaultCommandManager = new CommandManager();
    
    DefaultCommandManager.RegisterAction(KISMET_COMMAND.GAME_QUIT, function(d) { game_end(); }, "system");
    DefaultCommandManager.RegisterAction(KISMET_COMMAND.ROOM_GOTO, function(d) { room_goto(d); }, "room");
    DefaultCommandManager.RegisterAction(KISMET_COMMAND.ROOM_RESTART, function(d) { room_restart(); }, "room");
    DefaultCommandManager.RegisterAction(KISMET_COMMAND.ROOM_PREVIOUS, function(d) { room_goto(room_previous(d)); }, "room");
    DefaultCommandManager.RegisterAction(KISMET_COMMAND.ROOM_NEXT, function(d) { room_goto(room_next(d)); }, "room");
    DefaultCommandManager.RegisterAction(KISMET_COMMAND.SYSTEM_SCREENSHOT, function(d) { screen_save("screenshot_" + string(GetUnixDateTime(date_current_datetime())) + ".png"); }, "system");
    DefaultCommandManager.RegisterAction(KISMET_COMMAND.SYSTEM_FULLSCREEN, function(d) { window_set_fullscreen(!window_get_fullscreen()); }, "system");
    DefaultCommandManager.RegisterAction(KISMET_COMMAND.GAME_TOGGLE_PAUSE, function(d) { 
        if (DefaultCommandManager.GetQueueSize() > 0) {
            DefaultCommandManager.Execute();
        }
    }, "game");
    
    Interface = new InterfaceAccess();
    DebugMode = false;
    Version = KISMET_VERSION;
    
    show_debug_message("KISMET Framework initialized (v" + Version + ")");
	
	function Cleanup() {
	    if (variable_global_exists("KISMET")) {
	        if (DebugMode) {
	            var final_stats = MemoryTracker.GetStats();
				show_debug_message("[KISMET] Final memory stats before cleanup: " + string(final_stats));
	        }
        
	        // Clean up leak detector
	        if (LeakDetector != undefined) {
	            LeakDetector.Free();
	            LeakDetector = undefined;
	        }
        
	        // Clean up command manager
	        if (DefaultCommandManager != undefined) {
	            DefaultCommandManager.Free();
	            DefaultCommandManager = undefined;
	        }
        
	        // Clean up interface
	        if (Interface != undefined) {
	            Interface.Free();
	            Interface = undefined;
	        }
        
	        // Clean up all tracked memory
	        if (MemoryTracker != undefined) {
	            MemoryTracker.CleanupAll();
	            MemoryTracker = undefined;
	        }
        
	        show_debug_message("KISMET Framework cleaned up successfully");
	    }
	}
}

