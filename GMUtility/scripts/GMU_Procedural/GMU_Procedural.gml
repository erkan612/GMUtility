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