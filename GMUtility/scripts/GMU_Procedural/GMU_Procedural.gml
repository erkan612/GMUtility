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
    function GUID() {
        var chars = "0123456789abcdef", guid = "";
        for (var i=0;i<32;i++) guid += string_char_at(chars, irandom_range(1,string_length(chars)));
        guid = string_insert("-", string_insert("-", string_insert("-", string_insert("-", guid,9),14),19),24);
        return guid;
    };
    function UUID() {
        var chars = "0123456789abcdef", s = array_create(32);
        for (var i=0;i<32;i++) s[i] = string_char_at(chars, irandom_range(1,string_length(chars)));
        s[12] = "4"; var variant = irandom_range(8,11); s[16] = string_char_at(chars, variant+1);
        var uuid = ""; for (var i=0;i<32;i++) uuid += s[i];
        uuid = string_insert("-", string_insert("-", string_insert("-", string_insert("-", uuid,9),14),19),24);
        return uuid;
    };
    function Incremental(prefix="", start=0) { var counter=start; return function(){ counter++; return prefix+string(counter); }; };
    function Timestamped(prefix="") { return prefix+string(GetUnixDateTime(date_current_datetime())); };
    function ShortHash(input) {
        var hash=0;
        for (var i=1;i<=string_length(input);i++) hash = (hash*31 + ord(string_char_at(input,i))) mod 1000000007;
        return string(abs(hash));
    };
};