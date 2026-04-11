
// Noise Generator
function GenerateNoise() constructor {
    GRAD_2D = [
        [ 1, 1], [-1, 1], [ 1,-1], [-1,-1],
        [ 1, 0], [-1, 0], [ 0, 1], [ 0,-1]
    ];
    
    PERMUTATION_SIZE = 256;
    PERMUTATION_MASK = 255;
    
    SIMPLEX_SKEW_2D = 0.3660254037844386;   // (sqrt(3)-1)/2
    SIMPLEX_UNSKEW_2D = 0.211324865405187;  // (3-sqrt(3))/6
    
    perm = [];
    perm_mod12 = [];
    
    // init
    function InitPermutation(seed = 0) {
        var p = array_create(PERMUTATION_SIZE);
        for (var i = 0; i < PERMUTATION_SIZE; i++) {
            p[i] = i;
        }
        
        if (seed != 0) {
            random_set_seed(seed);
        }
        for (var i = PERMUTATION_SIZE - 1; i > 0; i--) {
            var j = irandom_range(0, i);
            var temp = p[i];
            p[i] = p[j];
            p[j] = temp;
        }
        
        for (var i = 0; i < 512; i++) {
            perm[i] = p[i & PERMUTATION_MASK];
            perm_mod12[i] = perm[i] mod 12;
        }
        
        return self;
    } InitPermutation(random_get_seed());
    
    // core
    function Hash2(p, seed = 0) {
        var _x = p[0], _y = p[1];
        var n = _x * 374761393 + _y * 668265263 + seed * 1013904223;
        n = (n ^ (n >> 13)) * 1274126177;
        return ((n ^ (n >> 15)) & 0x7fffffff) / 2147483647.0;
    };
    
    function Hash3(p, seed = 0) {
        var _x = p[0], _y = p[1], _z = p[2];
        var n = _x * 374761393 + _y * 668265263 + _z * 915682241 + seed * 1013904223;
        n = (n ^ (n >> 13)) * 1274126177;
        return ((n ^ (n >> 15)) & 0x7fffffff) / 2147483647.0;
    };
    
	// value noise
    function Quintic(t) { // smootherstep
        return t * t * t * (t * (t * 6 - 15) + 10);
    };
    
    function Cubic(t) {
        return t * t * (3 - 2 * t);
    };
    
    function ValueNoise2D(p, interpolation = "quintic", seed = 0) {
        var _x = p[0], _y = p[1];
        var ix = floor(_x), iy = floor(_y);
        var fx = _x - ix, fy = _y - iy;
        
        var sx, sy;
        if (interpolation == "quintic") {
            sx = Quintic(fx); sy = Quintic(fy);
        } else if (interpolation == "cubic") {
            sx = Cubic(fx); sy = Cubic(fy);
        } else if (interpolation == "cosine") {
            sx = (1 - cos(fx * pi)) * 0.5;
            sy = (1 - cos(fy * pi)) * 0.5;
        } else {
            sx = fx; sy = fy; // linear
        }
        
        var a = Hash2([ix, iy], seed);
        var b = Hash2([ix+1, iy], seed);
        var c = Hash2([ix, iy+1], seed);
        var d = Hash2([ix+1, iy+1], seed);
        
        var ab = lerp(a, b, sx);
        var cd = lerp(c, d, sx);
        return lerp(ab, cd, sy);
    };
    
    function ValueNoise3D(p, interpolation = "quintic", seed = 0) {
        var _x = p[0], _y = p[1], _z = p[2];
        var ix = floor(_x), iy = floor(_y), iz = floor(_z);
        var fx = _x - ix, fy = _y - iy, fz = _z - iz;
        
        var sx = Quintic(fx), sy = Quintic(fy), sz = Quintic(fz);
        
        var a = Hash3([ix, iy, iz], seed);
        var b = Hash3([ix+1, iy, iz], seed);
        var c = Hash3([ix, iy+1, iz], seed);
        var d = Hash3([ix+1, iy+1, iz], seed);
        var e = Hash3([ix, iy, iz+1], seed);
        var f = Hash3([ix+1, iy, iz+1], seed);
        var g = Hash3([ix, iy+1, iz+1], seed);
        var h = Hash3([ix+1, iy+1, iz+1], seed);
        
        var ab = lerp(a, b, sx);
        var cd = lerp(c, d, sx);
        var ef = lerp(e, f, sx);
        var gh = lerp(g, h, sx);
        
        var abcd = lerp(ab, cd, sy);
        var efgh = lerp(ef, gh, sy);
        
        return lerp(abcd, efgh, sz);
    };
    
    function Grad2D(hash, x, y) {
        var g = GRAD_2D[hash & 7];
        return g[0] * x + g[1] * y;
    };
    
    function PerlinNoise2D(p, seed = 0) {
        var _x = p[0], _y = p[1];
        var ix = floor(_x), iy = floor(_y);
        var fx = _x - ix, fy = _y - iy;
        
        var sx = Quintic(fx), sy = Quintic(fy);
        
        var aa = perm[(ix + perm[iy & PERMUTATION_MASK]) & PERMUTATION_MASK];
        var ab = perm[(ix + perm[(iy+1) & PERMUTATION_MASK]) & PERMUTATION_MASK];
        var ba = perm[((ix+1) + perm[iy & PERMUTATION_MASK]) & PERMUTATION_MASK];
        var bb = perm[((ix+1) + perm[(iy+1) & PERMUTATION_MASK]) & PERMUTATION_MASK];
        
        var g00 = Grad2D(perm_mod12[aa], fx, fy);
        var g10 = Grad2D(perm_mod12[ba], fx-1, fy);
        var g01 = Grad2D(perm_mod12[ab], fx, fy-1);
        var g11 = Grad2D(perm_mod12[bb], fx-1, fy-1);
        
        var x1 = lerp(g00, g10, sx);
        var x2 = lerp(g01, g11, sx);
        var value = lerp(x1, x2, sy);
        
        return (value + 1) * 0.5;
    };
    
    function SimplexNoise2D(p, seed = 0) {
        var _x = p[0], _y = p[1];
        
        var s = (_x + _y) * SIMPLEX_SKEW_2D;
        var ix = floor(_x + s), iy = floor(_y + s);
        var t = (ix + iy) * SIMPLEX_UNSKEW_2D;
        
        var x0 = _x - (ix - t);
        var y0 = _y - (iy - t);
        
        var i1, j1;
        if (x0 > y0) {
            i1 = 1; j1 = 0;
        } else {
            i1 = 0; j1 = 1;
        }
        
        var x1 = x0 - i1 + SIMPLEX_UNSKEW_2D;
        var y1 = y0 - j1 + SIMPLEX_UNSKEW_2D;
        var x2 = x0 - 1 + 2 * SIMPLEX_UNSKEW_2D;
        var y2 = y0 - 1 + 2 * SIMPLEX_UNSKEW_2D;
        
        var ii = ix & PERMUTATION_MASK;
        var jj = iy & PERMUTATION_MASK;
        var gi0 = perm_mod12[ii + perm[jj]];
        var gi1 = perm_mod12[ii + i1 + perm[jj + j1]];
        var gi2 = perm_mod12[ii + 1 + perm[jj + 1]];
        
        var t0 = 0.5 - x0*x0 - y0*y0;
        var n0 = (t0 < 0) ? 0 : t0*t0 * Grad2D(gi0, x0, y0);
        
        var t1 = 0.5 - x1*x1 - y1*y1;
        var n1 = (t1 < 0) ? 0 : t1*t1 * Grad2D(gi1, x1, y1);
        
        var t2 = 0.5 - x2*x2 - y2*y2;
        var n2 = (t2 < 0) ? 0 : t2*t2 * Grad2D(gi2, x2, y2);
        
        // scale and map to 0-1
        return (70 * (n0 + n1 + n2) + 1) * 0.5;
    };
    
    function WorleyNoise2D(p, mode = "f1", seed = 0) {
        var _x = p[0], _y = p[1];
        var ix = floor(_x), iy = floor(_y);
        var fx = _x - ix, fy = _y - iy;
        
        var f1 = 999999, f2 = 999999; // F1 = closest, F2 = second closest
        var dx1 = 0, dy1 = 0;
        
        for (var dy = -1; dy <= 1; dy++) {
            for (var dx = -1; dx <= 1; dx++) {
                var nx = ix + dx, ny = iy + dy;
                var pointX = nx + Hash2([nx, ny], seed);
                var pointY = ny + Hash2([nx, ny], seed + 1);
                
                var distX = fx - (dx + pointX - nx);
                var distY = fy - (dy + pointY - ny);
                var dist = sqrt(distX*distX + distY*distY);
                
                if (dist < f1) {
                    f2 = f1;
                    f1 = dist;
                    dx1 = distX;
                    dy1 = distY;
                } else if (dist < f2) {
                    f2 = dist;
                }
            }
        }
        
        switch(mode) {
            case "f1": return f1 / 1.5;            // normalized distance
            case "f2": return f2 / 1.5;            // second closest
            case "f2-f1": return (f2 - f1) / 1.5;  // edge detection
            case "f1*f2": return (f1 * f2) / 2.0;  // combined
            case "cell_value": return Hash2([ix + dx1, iy + dy1], seed);
            default: return f1 / 1.5;
        }
    };
    
    // fractal funcs
    function Fbm(noiseFunc, p, octaves, persistence = 0.5, lacunarity = 2.0, scale = 1.0, seed = 0) {
        var value = 0;
        var amplitude = 1.0;
        var frequency = 1.0;
        var maxValue = 0;
        
        for (var i = 0; i < octaves; i++) {
            var nx = p[0] * frequency * scale;
            var ny = p[1] * frequency * scale;
            value += noiseFunc([nx, ny], seed + i) * amplitude;
            maxValue += amplitude;
            amplitude *= persistence;
            frequency *= lacunarity;
        }
        
        return value / maxValue; // normalize to 0-1
    };
    
    function Turbulence(noiseFunc, p, octaves, persistence = 0.5, lacunarity = 2.0, scale = 1.0, seed = 0) {
        var value = 0;
        var amplitude = 1.0;
        var frequency = 1.0;
        var maxValue = 0;
        
        for (var i = 0; i < octaves; i++) {
            var nx = p[0] * frequency * scale;
            var ny = p[1] * frequency * scale;
            value += abs(noiseFunc([nx, ny], seed + i) * 2 - 1) * amplitude;
            maxValue += amplitude;
            amplitude *= persistence;
            frequency *= lacunarity;
        }
        
        return value / maxValue;
    };
    
    function Ridge(noiseFunc, p, octaves, persistence = 0.5, lacunarity = 2.0, scale = 1.0, offset = 1.0, seed = 0) {
        var value = 0;
        var amplitude = 1.0;
        var frequency = 1.0;
        var maxValue = 0;
        
        for (var i = 0; i < octaves; i++) {
            var nx = p[0] * frequency * scale;
            var ny = p[1] * frequency * scale;
            var n = noiseFunc([nx, ny], seed + i);
            n = abs(n * 2 - 1);  // to 0-1 range
            n = offset - n;
            n = n * n;
            value += n * amplitude;
            maxValue += amplitude;
            amplitude *= persistence;
            frequency *= lacunarity;
        }
        
        return value / maxValue;
    };
    
    function DomainWarp(noiseFunc, p, strength = 1.0, seed = 0) {
        var qx = Fbm(noiseFunc, [p[0], p[1]], 3, 0.5, 2.0, 1.0, seed);
        var qy = Fbm(noiseFunc, [p[0] + 5.2, p[1] + 1.3], 3, 0.5, 2.0, 1.0, seed + 10);
        
        var rx = p[0] + strength * (qx * 2 - 1);
        var ry = p[1] + strength * (qy * 2 - 1);
        
        return noiseFunc([rx, ry], seed + 20);
    };
    
    function Billow(noiseFunc, p, octaves, persistence = 0.5, lacunarity = 2.0, scale = 1.0, seed = 0) { // cloud-like
        var value = 0;
        var amplitude = 1.0;
        var frequency = 1.0;
        var maxValue = 0;
        
        for (var i = 0; i < octaves; i++) {
            var nx = p[0] * frequency * scale;
            var ny = p[1] * frequency * scale;
            var n = noiseFunc([nx, ny], seed + i);
            n = abs(n * 2 - 1) * 2 - 1;  // sharper peaks
            value += n * amplitude;
            maxValue += amplitude;
            amplitude *= persistence;
            frequency *= lacunarity;
        }
        
        return (value / maxValue + 1) * 0.5;
    };
    
	// utility stuff
    function GenerateMap(width, height, noiseType = "perlin", params = {}) {
        var map = ds_grid_create_gmu(width, height);
        var seed = params[$ "seed"] ?? 0;
        var scale = params[$ "scale"] ?? 0.1;
        var octaves = params[$ "octaves"] ?? 4;
        
        var noiseFunc;
        switch(noiseType) {
            case "value": noiseFunc = method(self, ValueNoise2D); break;
            case "perlin": noiseFunc = method(self, PerlinNoise2D); break;
            case "simplex": noiseFunc = method(self, SimplexNoise2D); break;
            case "worley": noiseFunc = method(self, WorleyNoise2D); break;
            default: noiseFunc = method(self, PerlinNoise2D);
        }
        
        for (var _y = 0; _y < height; _y++) {
            for (var _x = 0; _x < width; _x++) {
                var nx = _x * scale, ny = _y * scale;
                var value;
                
                if (params[$ "fractal"] == "fbm") {
                    value = Fbm(noiseFunc, [nx, ny], octaves, params[$ "persistence"] ?? 0.5, 
                               params[$ "lacunarity"] ?? 2.0, 1.0, seed);
                } else if (params[$ "fractal"] == "turbulence") {
                    value = Turbulence(noiseFunc, [nx, ny], octaves, params[$ "persistence"] ?? 0.5,
                                      params[$ "lacunarity"] ?? 2.0, 1.0, seed);
                } else if (params[$ "fractal"] == "ridge") {
                    value = Ridge(noiseFunc, [nx, ny], octaves, params[$ "persistence"] ?? 0.5,
                                 params[$ "lacunarity"] ?? 2.0, 1.0, 1.0, seed);
                } else if (params[$ "warp"]) {
                    value = DomainWarp(noiseFunc, [nx, ny], params[$ "warp_strength"] ?? 1.0, seed);
                } else {
                    value = noiseFunc([nx, ny], seed);
                }
                
                ds_grid_set(map, _x, _y, value);
            }
        }
        
        return map;
    };
    
    function TileableNoise2D(p, period, noiseType = "perlin", seed = 0) {
        var _x = p[0], _y = p[1];
        var px = _x / period, py = _y / period;
        
        var v1 = ValueNoise2D([px, py], "quintic", seed);
        var v2 = ValueNoise2D([px + period, py], "quintic", seed);
        var v3 = ValueNoise2D([px, py + period], "quintic", seed);
        var v4 = ValueNoise2D([px + period, py + period], "quintic", seed);
        
        var blendX = (_x / period) - floor(_x / period);
        var blendY = (_y / period) - floor(_y / period);
        
        var top = lerp(v1, v2, blendX);
        var bottom = lerp(v3, v4, blendX);
        
        return lerp(top, bottom, blendY);
    };
    
    function SetSeed(seed) {
        InitPermutation(seed);
        random_set_seed(seed);
        return self;
    };
    
    function ValueNoise(p) {
        return ValueNoise2D(p, "cubic");
    };
    
    function Hash(p) {
        return Hash2(p);
    };
    
    function Dot(ax, ay, bx, by) { return ax*bx + ay*by; };
    function Frac(_x) { return _x - floor(_x); };
    function Clamp(_x, minVal, maxVal) { return clamp(_x, minVal, maxVal); };
    function Mix(a, b, t) { return lerp(a, b, t); };
    function Smoothstep(edge0, edge1, _x) { 
        var t = clamp((_x - edge0) / (edge1 - edge0), 0.0, 1.0); 
        return t * t * (3.0 - 2.0 * t); 
    };
};

//  ID Generator
function IDGenerate() constructor {
    HEX_CHARS = "0123456789abcdef";
    HEX_LENGTH = 16;
    UUID_V4_POS = 12;  // version 4
    UUID_VAR_POS = 16;  // variant
    
    _guid_template = [8, 4, 4, 4, 12];  // segment lengths for formatting
    
    function GUID() { // standard GUID (32 hex chars)
        var guid = GenerateHexString(32);
        return FormatUUID(guid, [8, 12, 16, 20]);
    };
    
    function UUID() { // RFC 4122 compliant UUID v4
        var uuid = array_create(32);
        
        for (var i = 0; i < 32; i++) {
            uuid[i] = RandomHex();
        }
        
        uuid[UUID_V4_POS] = "4";
        
        var variant = choose(8, 9, 10, 11);  // 8,9,A,B in hex
        uuid[UUID_VAR_POS] = string_char_at(HEX_CHARS, variant + 1);
        
        var uuidString = "";
        for (var i = 0; i < 32; i++) {
            uuidString += uuid[i];
        }
        
        return FormatUUID(uuidString, [8, 12, 16, 20]);
    };
    
    function NanoID(length = 21, alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz-") { // URL friendly and customizable
        var _id = "";
        var alphabetLength = string_length(alphabet);
        
        for (var i = 0; i < length; i++) {
            _id += string_char_at(alphabet, irandom_range(1, alphabetLength));
        }
        return _id;
    };
    
    function Incremental(prefix = "", start = 0, padding = 0) {
        var counter = start;
        return function() {
            counter++;
            var num = string(counter);
            if (padding > 0) {
                while (string_length(num) < padding) {
                    num = "0" + num;
                }
            }
            return prefix + num;
        };
    };
    
    function Timestamped(prefix = "", includeRandom = true, randomLength = 4) {
        var timestamp = string(GetUnixDateTime(date_current_datetime()));
        if (includeRandom) {
            timestamp += "_" + GenerateHexString(randomLength);
        }
        return prefix + timestamp;
    };
    
    function Dated(prefix = "", format = "DDMMYYYY:HHmmSS") {
        var date = date_current_datetime();
        var year = string(date_get_year(date));
        var month = string(date_get_month(date));
        var day = string(date_get_day(date));
        var hour = string(date_get_hour(date));
        var minute = string(date_get_minute(date));
        var second = string(date_get_second(date));
        
        if (string_length(month) < 2) month = "0" + month;
        if (string_length(day) < 2) day = "0" + day;
        if (string_length(hour) < 2) hour = "0" + hour;
        if (string_length(minute) < 2) minute = "0" + minute;
        if (string_length(second) < 2) second = "0" + second;
        
        var result = format;
        result = string_replace_all(result, "YYYY", year);
        result = string_replace_all(result, "MM", month);
        result = string_replace_all(result, "DD", day);
        result = string_replace_all(result, "HH", hour);
        result = string_replace_all(result, "mm", minute);
        result = string_replace_all(result, "SS", second);
        
        return prefix + result;
    };
    
    function ShortHash(input) { // deterministic
        var hash = 0;
        var length = string_length(input);
        
        for (var i = 1; i <= length; i++) {
            hash = ((hash << 5) + hash) + ord(string_char_at(input, i)); // hash * 33 + c
        }
        
        var result = "";
        var num = abs(hash);
        var chars = "0123456789abcdefghijklmnopqrstuvwxyz";
        
        while (num > 0) {
            result = string_char_at(chars, (num mod 36) + 1) + result;
            num = num div 36;
        }
        
        return result != "" ? result : "0";
    };
    
    function Hash(input, length = 8) { // simplified and SHA-1 style
        var h1 = 0x67452301;
        var h2 = 0xEFCDAB89;
        var h3 = 0x98BADCFE;
        var h4 = 0x10325476;
        var h5 = 0xC3D2E1F0;
        
        var inputLength = string_length(input);
        for (var i = 1; i <= inputLength; i++) {
            var c = ord(string_char_at(input, i));
            h1 = ((h1 << 5) | (h1 >> 27)) + c;
            h2 = ((h2 << 5) | (h2 >> 27)) + c;
            h3 = ((h3 << 5) | (h3 >> 27)) + c;
            h4 = ((h4 << 5) | (h4 >> 27)) + c;
            h5 = ((h5 << 5) | (h5 >> 27)) + c;
        }
        
        var combined = (h1 ^ h2 ^ h3 ^ h4 ^ h5) & 0xFFFFFFFF;
        return string_format(combined, 1, 0);
    };
    
    function Sequential() {
        var counters = ds_map_create_gmu();
        
        return {
			counters: counters,
			
            next: function(namespace = "default", prefix = "", padding = 0) {
                if (!ds_map_exists(counters, namespace)) {
                    counters[? namespace] = 0;
                }
                
                counters[? namespace]++;
                var num = string(counters[? namespace]);
                
                if (padding > 0) {
                    while (string_length(num) < padding) {
                        num = "0" + num;
                    }
                }
                
                return prefix + num;
            },
            
            reset: function(namespace = "default") {
                counters[? namespace] = 0;
            },
            
            get: function(namespace = "default") {
                return counters[? namespace] ?? 0;
            },
            
            free: function() {
                ds_map_destroy_gmu(counters);
            }
        };
    };
    
    function Pattern(pattern, data = {}) {
        var result = pattern;
        
        result = string_replace_all(result, "{UUID}", UUID());
        result = string_replace_all(result, "{GUID}", GUID());
        result = string_replace_all(result, "{NANOID}", NanoID());
        result = string_replace_all(result, "{TIMESTAMP}", string(GetUnixDateTime(date_current_datetime())));
        result = string_replace_all(result, "{RANDOM}", GenerateHexString(8));
        
        var keys = variable_struct_get_names(data);
        for (var i = 0; i < array_length(keys); i++) {
            var key = keys[i];
            result = string_replace_all(result, "{" + key + "}", string(data[$ key]));
        }
        
        return result;
    };
    
    // validation methods
    function IsValidUUID(id) {
        var pattern = "^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$";
        return string_regex_match(id, pattern);
    };
    
    function IsValidGUID(id) {
        var pattern = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$";
        return string_regex_match(id, pattern);
    };
    
    // helper methods
    function RandomHex() {
        return string_char_at(HEX_CHARS, irandom_range(1, HEX_LENGTH));
    };
    
    function GenerateHexString(length) {
        var result = "";
        for (var i = 0; i < length; i++) {
            result += RandomHex();
        }
        return result;
    };
    
    function FormatUUID(hexString, positions) {
        var formatted = hexString;
        var offset = 0;
        
        for (var i = 0; i < array_length(positions); i++) {
            formatted = string_insert("-", formatted, positions[i] + offset + 1);
            offset++;
        }
        return formatted;
    };
};