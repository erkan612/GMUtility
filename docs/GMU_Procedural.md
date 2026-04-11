# GMU_Procedural

Procedural generation utilities for GameMaker. This module provides a comprehensive noise generation system (Perlin, Simplex, Worley, and fractal variants) and a flexible ID generation system (UUID, GUID, NanoID, and custom IDs).

## Table of Contents

- [Overview](#overview)
- [Global Instances](#global-instances)
- [Noise Generator](#noise-generator)
  - [Value Noise](#value-noise)
  - [Perlin Noise](#perlin-noise)
  - [Simplex Noise](#simplex-noise)
  - [Worley (Cellular) Noise](#worley-cellular-noise)
  - [Fractal Functions](#fractal-functions)
  - [Domain Warping](#domain-warping)
  - [Tileable Noise](#tileable-noise)
  - [Noise Map Generation](#noise-map-generation)
- [ID Generator](#id-generator)
  - [UUID v4](#uuid-v4)
  - [GUID](#guid)
  - [NanoID](#nanoid)
  - [Incremental IDs](#incremental-ids)
  - [Timestamped IDs](#timestamped-ids)
  - [Dated IDs](#dated-ids)
  - [Hash IDs](#hash-ids)
  - [Pattern-based IDs](#pattern-based-ids)
  - [Sequential Generator](#sequential-generator)
  - [Validation](#validation)
- [Complete Examples](#complete-examples)

---

## Overview

The GMU_Procedural module provides two independent systems:

### Noise Generator
- Multiple noise types: Value, Perlin, Simplex, Worley (Cellular)
- Fractal variants: fBm, Turbulence, Ridge, Billow
- Domain warping for organic patterns
- Tileable noise for seamless textures
- Noise map generation with customizable parameters

### ID Generator
- RFC 4122 compliant UUID v4
- Standard GUID format
- URL-friendly NanoID
- Incremental and timestamped IDs
- Hash-based deterministic IDs
- Pattern-based ID generation
- Validation utilities

---

## Global Instances

Global instances are automatically created via the `GMU_NAMESPACES_INIT` macro:

```gml
globalvar GenerateNoise;
GenerateNoise = new GenerateNoise();

globalvar IDGenerate;
IDGenerate = new IDGenerate();
```

---

## Noise Generator

### Value Noise

Smooth random noise using value interpolation.

#### ValueNoise2D(p, interpolation = "quintic", seed = 0)

Generates 2D value noise.

```gml
// Basic value noise
var value = GenerateNoise.ValueNoise2D([x * 0.01, y * 0.01]);

// With specific interpolation
var value = GenerateNoise.ValueNoise2D([x, y], "cubic");

// With seed
var value = GenerateNoise.ValueNoise2D([x, y], "quintic", 12345);
```

**Parameters:**
- `p` - Array `[x, y]` of coordinates
- `interpolation` - "linear", "cosine", "cubic", or "quintic" (default: "quintic")
- `seed` - Random seed (default: 0)

**Returns:** Float between 0.0 and 1.0.

---

#### ValueNoise3D(p, interpolation = "quintic", seed = 0)

Generates 3D value noise.

```gml
// 3D noise for animated effects
var value = GenerateNoise.ValueNoise3D([x, y, time]);
```

**Parameters:**
- `p` - Array `[x, y, z]` of coordinates
- `interpolation` - Interpolation type (default: "quintic")
- `seed` - Random seed (default: 0)

**Returns:** Float between 0.0 and 1.0.

---

#### ValueNoise(p)

Shortcut for 2D value noise with cubic interpolation.

```gml
var value = GenerateNoise.ValueNoise([x * 0.1, y * 0.1]);
```

**Returns:** Float between 0.0 and 1.0.

---

### Perlin Noise

Classic Perlin noise using gradient vectors.

#### PerlinNoise2D(p, seed = 0)

Generates 2D Perlin noise.

```gml
// Basic Perlin noise
var value = GenerateNoise.PerlinNoise2D([x * 0.01, y * 0.01]);

// With seed
var value = GenerateNoise.PerlinNoise2D([x, y], world_seed);
```

**Parameters:**
- `p` - Array `[x, y]` of coordinates
- `seed` - Random seed (default: 0)

**Returns:** Float between 0.0 and 1.0.

---

### Simplex Noise

Improved noise algorithm with lower computational complexity and fewer artifacts.

#### SimplexNoise2D(p, seed = 0)

Generates 2D Simplex noise.

```gml
// Simplex noise (better for terrain)
var value = GenerateNoise.SimplexNoise2D([x * 0.005, y * 0.005]);

// With seed
var value = GenerateNoise.SimplexNoise2D([x, y], terrain_seed);
```

**Parameters:**
- `p` - Array `[x, y]` of coordinates
- `seed` - Random seed (default: 0)

**Returns:** Float between 0.0 and 1.0.

---

### Worley (Cellular) Noise

Distance-based cellular noise useful for organic patterns.

#### WorleyNoise2D(p, mode = "f1", seed = 0)

Generates 2D Worley (cellular) noise.

```gml
// Standard Worley noise (F1 - distance to closest point)
var f1 = GenerateNoise.WorleyNoise2D([x * 0.01, y * 0.01], "f1");

// F2 - distance to second closest point
var f2 = GenerateNoise.WorleyNoise2D([x, y], "f2");

// Edge detection (F2 - F1)
var edges = GenerateNoise.WorleyNoise2D([x, y], "f2-f1");

// Combined
var combined = GenerateNoise.WorleyNoise2D([x, y], "f1*f2");

// Cell value (random value per cell)
var cell_val = GenerateNoise.WorleyNoise2D([x, y], "cell_value");
```

**Parameters:**
- `p` - Array `[x, y]` of coordinates
- `mode` - Noise mode (default: "f1")
  - `"f1"` - Distance to closest point
  - `"f2"` - Distance to second closest point
  - `"f2-f1"` - Difference (edge detection)
  - `"f1*f2"` - Product of distances
  - `"cell_value"` - Random value per cell
- `seed` - Random seed (default: 0)

**Returns:** Float between 0.0 and 1.0.

---

### Fractal Functions

Combine multiple octaves of noise for more detailed results.

#### Fbm(noiseFunc, p, octaves, persistence = 0.5, lacunarity = 2.0, scale = 1.0, seed = 0)

Fractional Brownian Motion - layers of noise with decreasing amplitude.

```gml
// fBm with Perlin noise
var value = GenerateNoise.Fbm(
    GenerateNoise.PerlinNoise2D,
    [x * 0.01, y * 0.01],
    6,      // octaves
    0.5,    // persistence
    2.0,    // lacunarity
    1.0,    // scale
    seed
);

// fBm with Simplex noise (better performance)
var terrain = GenerateNoise.Fbm(
    GenerateNoise.SimplexNoise2D,
    [x * 0.005, y * 0.005],
    4, 0.6, 2.0, 1.0, world_seed
);
```

**Parameters:**
- `noiseFunc` - Base noise function to use
- `p` - Array `[x, y]` of coordinates
- `octaves` - Number of noise layers
- `persistence` - Amplitude multiplier per octave (default: 0.5)
- `lacunarity` - Frequency multiplier per octave (default: 2.0)
- `scale` - Overall scale multiplier (default: 1.0)
- `seed` - Random seed (default: 0)

**Returns:** Float between 0.0 and 1.0.

---

#### Turbulence(noiseFunc, p, octaves, persistence = 0.5, lacunarity = 2.0, scale = 1.0, seed = 0)

Turbulence noise using absolute values for sharp ridges.

```gml
// Turbulence for cloud effects
var clouds = GenerateNoise.Turbulence(
    GenerateNoise.PerlinNoise2D,
    [x * 0.02, y * 0.02],
    4, 0.5, 2.0, 1.0, cloud_seed
);
```

**Parameters:** Same as Fbm.

**Returns:** Float between 0.0 and 1.0.

---

#### Ridge(noiseFunc, p, octaves, persistence = 0.5, lacunarity = 2.0, scale = 1.0, offset = 1.0, seed = 0)

Ridge noise for mountain-like features.

```gml
// Ridge noise for mountain ranges
var mountains = GenerateNoise.Ridge(
    GenerateNoise.SimplexNoise2D,
    [x * 0.008, y * 0.008],
    5, 0.55, 2.0, 1.0, 1.0, mountain_seed
);
```

**Parameters:** Same as Fbm, plus:
- `offset` - Ridge offset value (default: 1.0)

**Returns:** Float between 0.0 and 1.0.

---

#### Billow(noiseFunc, p, octaves, persistence = 0.5, lacunarity = 2.0, scale = 1.0, seed = 0)

Billow noise for cloud-like formations.

```gml
// Billow noise for fluffy clouds
var clouds = GenerateNoise.Billow(
    GenerateNoise.ValueNoise2D,
    [x * 0.015, y * 0.015],
    4, 0.5, 2.0, 1.0, sky_seed
);
```

**Parameters:** Same as Fbm.

**Returns:** Float between 0.0 and 1.0.

---

### Domain Warping

Distorts noise coordinates for more organic patterns.

#### DomainWarp(noiseFunc, p, strength = 1.0, seed = 0)

Applies domain warping to a noise function.

```gml
// Warped noise for organic terrain
var warped = GenerateNoise.DomainWarp(
    GenerateNoise.SimplexNoise2D,
    [x * 0.01, y * 0.01],
    0.5,    // warp strength
    seed
);

// Strong warping for alien landscapes
var alien = GenerateNoise.DomainWarp(
    GenerateNoise.Fbm,
    [x * 0.01, y * 0.01],
    1.5,    // stronger distortion
    seed
);
```

**Parameters:**
- `noiseFunc` - Base noise function
- `p` - Array `[x, y]` of coordinates
- `strength` - Warp intensity (default: 1.0)
- `seed` - Random seed (default: 0)

**Returns:** Float between 0.0 and 1.0.

---

### Tileable Noise

Creates seamlessly tileable noise patterns.

#### TileableNoise2D(p, period, noiseType = "perlin", seed = 0)

Generates tileable 2D noise.

```gml
// Create a 256x256 tileable texture
for (var _x = 0; _x < 256; _x++) {
    for (var _y = 0; _y < 256; _y++) {
        var value = GenerateNoise.TileableNoise2D(
            [_x, _y],
            256,        // period
            "perlin",
            seed
        );
        // Use value for texture
    }
}
```

**Parameters:**
- `p` - Array `[x, y]` of coordinates
- `period` - Tile period (size of repeat)
- `noiseType` - "value", "perlin", or "simplex" (default: "perlin")
- `seed` - Random seed (default: 0)

**Returns:** Float between 0.0 and 1.0.

---

### Noise Map Generation

#### GenerateMap(width, height, noiseType = "perlin", params = {})

Generates a 2D array of noise values.

```gml
// Simple noise map
var map = GenerateNoise.GenerateMap(100, 100, "perlin", {
    seed: 12345,
    scale: 0.1,
    octaves: 4
});

// fBm with Simplex noise
var terrain = GenerateNoise.GenerateMap(200, 200, "simplex", {
    seed: world_seed,
    scale: 0.05,
    octaves: 6,
    fractal: "fbm",
    persistence: 0.6,
    lacunarity: 2.0
});

// Ridge noise for mountains
var mountains = GenerateNoise.GenerateMap(150, 150, "perlin", {
    seed: 54321,
    scale: 0.08,
    octaves: 5,
    fractal: "ridge",
    persistence: 0.55
});

// Domain warped noise
var warped_map = GenerateNoise.GenerateMap(120, 120, "simplex", {
    seed: 999,
    scale: 0.06,
    octaves: 4,
    warp: true,
    warp_strength: 0.8
});

// Worley noise map
var cells = GenerateNoise.GenerateMap(100, 100, "worley", {
    seed: 777,
    scale: 0.04
});
```

**Parameters:**
- `width` - Map width
- `height` - Map height
- `noiseType` - "value", "perlin", "simplex", or "worley"
- `params` - Struct with options:
  - `seed` - Random seed
  - `scale` - Noise scale (default: 0.1)
  - `octaves` - Number of octaves (default: 4)
  - `fractal` - "fbm", "turbulence", "ridge", or undefined
  - `persistence` - Persistence for fractals
  - `lacunarity` - Lacunarity for fractals
  - `warp` - Enable domain warping
  - `warp_strength` - Warp intensity

**Returns:** 2D array `map[x][y]` of noise values (0.0 to 1.0).

---

#### SetSeed(seed)

Sets the permutation seed for all noise functions.

```gml
GenerateNoise.SetSeed(12345);
```

**Returns:** `self` for chaining.

---

### Utility Functions

```gml
// Hash function
var hash = GenerateNoise.Hash([x, y]);
var hash3d = GenerateNoise.Hash3([x, y, z]);

// Dot product
var dot = GenerateNoise.Dot(ax, ay, bx, by);

// Fractional part
var frac = GenerateNoise.Frac(3.7); // 0.7

// Clamp
var clamped = GenerateNoise.Clamp(value, 0, 1);

// Mix (lerp)
var mixed = GenerateNoise.Mix(a, b, 0.5);

// Smoothstep
var smooth = GenerateNoise.Smoothstep(0, 1, t);
```

---

## ID Generator

### UUID v4

RFC 4122 compliant UUID version 4.

#### UUID()

Generates a random UUID v4.

```gml
var id = IDGenerate.UUID();
// Returns: "550e8400-e29b-41d4-a716-446655440000"

// Use for database keys
player.id = IDGenerate.UUID();
save_data.id = IDGenerate.UUID();
```

**Returns:** String in UUID format `xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx`.

---

### GUID

Standard 32-character GUID.

#### GUID()

Generates a standard GUID.

```gml
var guid = IDGenerate.GUID();
// Returns: "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6"

// Alternative format (no hyphens)
var guid = IDGenerate.GUID();
```

**Returns:** String with 32 hex characters, formatted with hyphens.

---

### NanoID

URL-friendly, customizable ID generator.

#### NanoID(length = 21, alphabet = "default")

Generates a NanoID.

```gml
// Default NanoID (21 characters)
var id = IDGenerate.NanoID();
// Returns: "V1StGXR8_Z5jdHi6B-myT"

// Custom length
var short_id = IDGenerate.NanoID(10);

// Custom alphabet (numbers only)
var numeric_id = IDGenerate.NanoID(6, "0123456789");

// Custom alphabet (uppercase only)
var upper_id = IDGenerate.NanoID(8, "ABCDEFGHIJKLMNOPQRSTUVWXYZ");
```

**Parameters:**
- `length` - ID length (default: 21)
- `alphabet` - String of allowed characters (default: A-Z, a-z, 0-9, _, -)

**Returns:** Random string ID.

---

### Incremental IDs

Auto-incrementing ID generator.

#### Incremental(prefix = "", start = 0, padding = 0)

Creates an incremental ID generator function.

```gml
// Create generator
var next_id = IDGenerate.Incremental("player_", 0, 4);

// Generate IDs
var id1 = next_id(); // "player_0001"
var id2 = next_id(); // "player_0002"
var id3 = next_id(); // "player_0003"

// No padding
var simple_id = IDGenerate.Incremental("item_", 1, 0);
simple_id(); // "item_1"
simple_id(); // "item_2"

// No prefix
var counter = IDGenerate.Incremental("", 100);
counter(); // "101"
counter(); // "102"
```

**Parameters:**
- `prefix` - String prefix (default: "")
- `start` - Starting number (default: 0)
- `padding` - Zero padding width (default: 0)

**Returns:** Function that returns incremental IDs.

---

### Timestamped IDs

Time-based unique identifiers.

#### Timestamped(prefix = "", includeRandom = true, randomLength = 4)

Generates a timestamped ID.

```gml
// Full timestamped ID
var id = IDGenerate.Timestamped("log_");
// Returns: "log_1704067200_a3f2"

// Timestamp only
var time_id = IDGenerate.Timestamped("event_", false);
// Returns: "event_1704067200"

// Custom random length
var secure_id = IDGenerate.Timestamped("txn_", true, 8);
// Returns: "txn_1704067200_a3f2b9c1"
```

**Parameters:**
- `prefix` - String prefix (default: "")
- `includeRandom` - Add random suffix (default: true)
- `randomLength` - Length of random suffix (default: 4)

**Returns:** Timestamped ID string.

---

### Dated IDs

Human-readable date-based IDs.

#### Dated(prefix = "", format = "DDMMYYYY:HHmmSS")

Generates a date-formatted ID.

```gml
// Default format
var id = IDGenerate.Dated("save_");
// Returns: "save_11042026:143052"

// Custom format
var custom = IDGenerate.Dated("log_", "YYYY-MM-DD");
// Returns: "log_2026-04-11"

// Year-month only
var monthly = IDGenerate.Dated("report_", "YYYYMM");
// Returns: "report_202604"

// Time only
var time_id = IDGenerate.Dated("", "HH:mm:SS");
// Returns: "14:30:52"
```

**Parameters:**
- `prefix` - String prefix (default: "")
- `format` - Date format string with tokens:
  - `YYYY` - 4-digit year
  - `MM` - 2-digit month
  - `DD` - 2-digit day
  - `HH` - 2-digit hour (24h)
  - `mm` - 2-digit minute
  - `SS` - 2-digit second

**Returns:** Formatted date ID string.

---

### Hash IDs

Deterministic IDs from input strings.

#### ShortHash(input)

Generates a short hash from a string.

```gml
var hash = IDGenerate.ShortHash("Hello World");
// Returns: "1zcn9" (example)

// Use for consistent IDs from names
var enemy_id = IDGenerate.ShortHash(enemy_type + enemy_name);

// Cache keys
var cache_key = IDGenerate.ShortHash(json_stringify(data));
```

**Parameters:**
- `input` - String to hash

**Returns:** Base-36 hash string.

---

#### Hash(input, length = 8)

Generates a numeric hash from a string.

```gml
var num_hash = IDGenerate.Hash("player_name");
// Returns: "2847192347"

// Use for deterministic random seeds
random_set_seed(IDGenerate.Hash(level_name));
```

**Parameters:**
- `input` - String to hash
- `length` - Not used (kept for compatibility)

**Returns:** Numeric hash string.

---

### Pattern-based IDs

Generate IDs using template patterns.

#### Pattern(pattern, data = {})

Generates an ID from a pattern template.

```gml
// Basic pattern with built-in tokens
var id = IDGenerate.Pattern("{UUID}-{TIMESTAMP}");
// Returns: "550e8400-e29b-41d4-a716-446655440000-1704067200"

// Custom data
var player_id = IDGenerate.Pattern("{PREFIX}_{CLASS}_{NANOID}", {
    PREFIX: "CHR",
    CLASS: "WARRIOR"
});
// Returns: "CHR_WARRIOR_V1StGXR8_Z5jdHi6B-myT"

// Complex patterns
var item_id = IDGenerate.Pattern("{RARITY}-{TYPE}-{GUID}", {
    RARITY: "LEGENDARY",
    TYPE: "SWORD"
});
```

**Parameters:**
- `pattern` - Template string with `{TOKEN}` placeholders
- `data` - Struct with custom token values

**Built-in tokens:**
- `{UUID}` - Random UUID v4
- `{GUID}` - Random GUID
- `{NANOID}` - Random NanoID
- `{TIMESTAMP}` - Unix timestamp
- `{RANDOM}` - 8-character random hex string

**Returns:** Formatted ID string.

---

### Sequential Generator

Stateful sequential ID generator with namespaces.

#### Sequential()

Creates a sequential ID manager.

```gml
var seq = IDGenerate.Sequential();

// Generate IDs in different namespaces
var player_id = seq.next("players", "P", 4);    // "P0001"
var enemy_id = seq.next("enemies", "E", 3);     // "E001"
var item_id = seq.next("items", "ITEM_", 0);    // "ITEM_1"

// Get current count
var count = seq.get("players"); // 1

// Reset a namespace
seq.reset("players");

// Clean up
seq.free();
```

**Returns:** Sequential manager struct with methods:
- `next(namespace, prefix, padding)` - Generate next ID
- `reset(namespace)` - Reset counter
- `get(namespace)` - Get current count
- `free()` - Clean up

---

### Validation

Validate ID formats.

#### IsValidUUID(id)

Checks if a string is a valid UUID v4.

```gml
if (IDGenerate.IsValidUUID(some_id)) {
    // Valid UUID
}

// Examples
IDGenerate.IsValidUUID("550e8400-e29b-41d4-a716-446655440000"); // true
IDGenerate.IsValidUUID("invalid"); // false
```

**Returns:** `true` if valid UUID v4 format.

---

#### IsValidGUID(id)

Checks if a string is a valid GUID format.

```gml
if (IDGenerate.IsValidGUID(some_id)) {
    // Valid GUID
}
```

**Returns:** `true` if valid GUID format (32 hex chars with hyphens).

---

### Utility Functions

```gml
// Generate random hex string
var hex = IDGenerate.GenerateHexString(8); // "a3f2b9c1"

// Format a UUID string
var formatted = IDGenerate.FormatUUID("a1b2c3d4e5f6", [4, 6]);
```

---

## Complete Examples

### Example 1: Procedural Terrain Generation

```gml
function GenerateTerrainMap(width, height, seed) {
    GenerateNoise.SetSeed(seed);
    
    var map = GenerateNoise.GenerateMap(width, height, "simplex", {
        seed: seed,
        scale: 0.008,
        octaves: 6,
        fractal: "fbm",
        persistence: 0.5,
        lacunarity: 2.0
    });
    
    // Convert noise values to terrain types
    for (var x = 0; x < width; x++) {
        for (var y = 0; y < height; y++) {
            var value = map[x][y];
            
            if (value < 0.3) {
                // Water
                tilemap_set(tilemap, TILE_WATER, x, y);
            } else if (value < 0.4) {
                // Sand
                tilemap_set(tilemap, TILE_SAND, x, y);
            } else if (value < 0.6) {
                // Grass
                tilemap_set(tilemap, TILE_GRASS, x, y);
            } else if (value < 0.8) {
                // Forest
                tilemap_set(tilemap, TILE_FOREST, x, y);
            } else {
                // Mountain
                tilemap_set(tilemap, TILE_MOUNTAIN, x, y);
            }
        }
    }
    
    return map;
}

// Add mountain details using Ridge noise
function AddMountainDetails(width, height, seed) {
    var ridge_map = GenerateNoise.GenerateMap(width, height, "perlin", {
        seed: seed + 1000,
        scale: 0.015,
        octaves: 4,
        fractal: "ridge",
        persistence: 0.6
    });
    
    // Add peaks where ridge noise is high
    for (var x = 0; x < width; x++) {
        for (var y = 0; y < height; y++) {
            if (ridge_map[x][y] > 0.7) {
                // Add mountain peak details
                AddMountainPeak(x, y);
            }
        }
    }
}

// Generate cave system using Worley noise
function GenerateCaves(width, height, seed) {
    var cave_map = GenerateNoise.GenerateMap(width, height, "worley", {
        seed: seed + 2000,
        scale: 0.03
    });
    
    // Use edge detection mode for cave walls
    for (var x = 0; x < width; x++) {
        for (var y = 0; y < height; y++) {
            var edge = GenerateNoise.WorleyNoise2D(
                [x * 0.03, y * 0.03],
                "f2-f1",
                seed + 2000
            );
            
            if (edge > 0.3) {
                // Cave wall
                tilemap_set(tilemap, TILE_CAVE_WALL, x, y);
            } else {
                // Cave floor
                tilemap_set(tilemap, TILE_CAVE_FLOOR, x, y);
            }
        }
    }
}
```

### Example 2: Cloud and Weather Effects

```gml
function GenerateCloudTexture(width, height, seed) {
    var cloud_map = GenerateNoise.GenerateMap(width, height, "perlin", {
        seed: seed,
        scale: 0.02,
        octaves: 4,
        fractal: "billow",
        persistence: 0.5
    });
    
    // Create surface from noise
    var surf = surface_create(width, height);
    surface_set_target(surf);
    
    for (var x = 0; x < width; x++) {
        for (var y = 0; y < height; y++) {
            var alpha = cloud_map[x][y];
            draw_set_color(make_color_rgb(255, 255, 255));
            draw_set_alpha(alpha);
            draw_point(x, y);
        }
    }
    
    draw_set_alpha(1);
    surface_reset_target();
    
    return surf;
}

// Animated clouds using 3D noise
function UpdateCloudOffset(time) {
    for (var x = 0; x < cloud_width; x++) {
        for (var y = 0; y < cloud_height; y++) {
            var value = GenerateNoise.ValueNoise3D([
                x * 0.02,
                y * 0.02,
                time * 0.01
            ], "quintic", cloud_seed);
            
            cloud_alpha[x][y] = value;
        }
    }
}
```

### Example 3: Entity ID Management

```gml
function EntityManager() constructor {
    id_generator = IDGenerate.Sequential();
    entities = ds_map_create_gmu();
    
    function CreateEntity(type, data) {
        var id = id_generator.next(type, string_upper(type) + "_", 6);
        
        var entity = {
            id: id,
            type: type,
            uuid: IDGenerate.UUID(),
            created: IDGenerate.Timestamped(),
            data: data
        };
        
        entities[? id] = entity;
        return entity;
    }
    
    function GetEntity(id) {
        return entities[? id];
    }
    
    function SaveEntities() {
        var save_data = {
            timestamp: IDGenerate.Dated("", "YYYY-MM-DD_HH-mm-SS"),
            entities: {}
        };
        
        var keys = ds_map_keys_to_array(entities);
        for (var i = 0; i < array_length(keys); i++) {
            save_data.entities[$ keys[i]] = entities[? keys[i]];
        }
        
        var filename = $"save_{save_data.timestamp}.json";
        File.SaveJSON(filename, save_data);
    }
    
    function Free() {
        id_generator.free();
        ds_map_destroy_gmu(entities);
    }
}

// Usage
var entities = new EntityManager();

var player = entities.CreateEntity("player", { name: "Hero", hp: 100 });
var enemy1 = entities.CreateEntity("enemy", { name: "Goblin", hp: 30 });
var enemy2 = entities.CreateEntity("enemy", { name: "Orc", hp: 80 });

show_debug_message(player.id);      // "PLAYER_000001"
show_debug_message(player.uuid);    // "550e8400-e29b-41d4-a716-446655440000"
show_debug_message(player.created); // "player_1704067200_a3f2"
```

### Example 4: Deterministic World Generation

```gml
function WorldGenerator(world_seed) {
    // Set consistent seed for reproducibility
    GenerateNoise.SetSeed(world_seed);
    
    function GenerateBiome(x, y) {
        // Use multiple noise layers for biome determination
        var temperature = GenerateNoise.Fbm(
            GenerateNoise.SimplexNoise2D,
            [x * 0.001, y * 0.001],
            3, 0.5, 2.0, 1.0, world_seed
        );
        
        var moisture = GenerateNoise.Fbm(
            GenerateNoise.PerlinNoise2D,
            [x * 0.001 + 100, y * 0.001 + 100],
            3, 0.5, 2.0, 1.0, world_seed + 1
        );
        
        var elevation = GenerateNoise.Ridge(
            GenerateNoise.SimplexNoise2D,
            [x * 0.0008, y * 0.0008],
            4, 0.6, 2.0, 1.0, 1.0, world_seed + 2
        );
        
        // Determine biome from parameters
        if (elevation > 0.7) {
            return temperature > 0.5 ? BIOME_VOLCANIC : BIOME_MOUNTAIN;
        } else if (elevation > 0.4) {
            if (moisture > 0.6) return BIOME_FOREST;
            if (temperature > 0.7) return BIOME_DESERT;
            return BIOME_PLAINS;
        } else {
            if (temperature < 0.2) return BIOME_TUNDRA;
            return BIOME_GRASSLAND;
        }
    }
    
    function GenerateRiver(x, y) {
        // Use domain warping for organic river paths
        var river_value = GenerateNoise.DomainWarp(
            GenerateNoise.SimplexNoise2D,
            [x * 0.002, y * 0.002],
            0.8,
            world_seed + 3
        );
        
        return river_value > 0.55 && river_value < 0.65;
    }
    
    function GenerateResources(x, y, biome) {
        // Deterministic resource placement using hash
        var cell_seed = IDGenerate.Hash($"{x},{y},{biome}");
        random_set_seed(real(cell_seed));
        
        var resources = [];
        
        if (biome == BIOME_FOREST) {
            if (random(100) < 30) {
                array_push(resources, "wood");
            }
            if (random(100) < 10) {
                array_push(resources, "herbs");
            }
        } else if (biome == BIOME_MOUNTAIN) {
            if (random(100) < 25) {
                array_push(resources, "stone");
            }
            if (random(100) < 5) {
                array_push(resources, "iron");
            }
        }
        
        return resources;
    }
    
    return {
        GenerateBiome: GenerateBiome,
        GenerateRiver: GenerateRiver,
        GenerateResources: GenerateResources
    };
}

// Create consistent world
var world_gen = new WorldGenerator(12345);
var biome = world_gen.GenerateBiome(500, 300);
var is_river = world_gen.GenerateRiver(500, 300);
var resources = world_gen.GenerateResources(500, 300, biome);
```

### Example 5: Item and Loot ID System

```gml
function LootSystem() constructor {
    var seq = IDGenerate.Sequential();
    
    function GenerateItemID(rarity, type) {
        return IDGenerate.Pattern("{RARITY}_{TYPE}_{NANOID}", {
            RARITY: string_upper(rarity),
            TYPE: string_upper(type)
        });
    }
    
    function GenerateLootDrop(enemy_type, level) {
        var drop_id = IDGenerate.UUID();
        var items = [];
        
        // Deterministic drop based on enemy and level
        var drop_seed = IDGenerate.Hash($"{enemy_type}_{level}_{drop_id}");
        random_set_seed(real(drop_seed));
        
        var item_count = irandom_range(1, 3);
        for (var i = 0; i < item_count; i++) {
            var rarity = DetermineRarity(level);
            var type = DetermineItemType(enemy_type);
            
            array_push(items, {
                instance_id: seq.next("item_instances", "ITEM_", 8),
                template_id: GenerateItemID(rarity, type),
                drop_uuid: drop_id,
                timestamp: IDGenerate.Dated("", "YYYY-MM-DD HH:mm:SS")
            });
        }
        
        return {
            drop_id: drop_id,
            items: items,
            source: enemy_type
        };
    }
    
    function DetermineRarity(level) {
        var roll = random(100);
        var luck_bonus = level * 2;
        
        if (roll < 1 + luck_bonus) return "legendary";
        if (roll < 5 + luck_bonus) return "epic";
        if (roll < 15 + luck_bonus) return "rare";
        if (roll < 35 + luck_bonus) return "uncommon";
        return "common";
    }
    
    function DetermineItemType(enemy_type) {
        var types = {
            "goblin": ["dagger", "leather", "coin"],
            "skeleton": ["bone", "sword", "shield"],
            "dragon": ["scale", "claw", "fire_essence"]
        };
        
        var available = types[$ enemy_type] ?? ["scrap"];
        return available[irandom(array_length(available) - 1)];
    }
    
    function Free() {
        seq.free();
    }
}
```
