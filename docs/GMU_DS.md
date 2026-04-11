# GMU_DS

Memory-safe data structure wrappers and XML handling utilities. This module provides tracked versions of GameMaker's built-in data structures and a complete XML parsing/building system.

## Table of Contents

- [Data Structure Wrappers](#data-structure-wrappers)
  - [ds_map_create_gmu](#ds_map_create_gmu)
  - [ds_list_create_gmu](#ds_list_create_gmu)
  - [ds_queue_create_gmu](#ds_queue_create_gmu)
  - [ds_stack_create_gmu](#ds_stack_create_gmu)
  - [ds_grid_create_gmu](#ds_grid_create_gmu)
  - [ds_priority_create_gmu](#ds_priority_create_gmu)
  - [Destroy Functions](#destroy-functions)
- [DataPack (XML System)](#datapack-xml-system)
  - [XMLNode](#xmlnode)
  - [XMLParser](#xmlparser)
  - [DataPack Builder](#datapack-builder)
  - [DataPack Parser](#datapack-parser)

---

## Data Structure Wrappers

All wrapped data structures are automatically registered with the `MemoryTracker` for leak detection and cleanup. Use these instead of the built-in `ds_*_create()` functions.

### ds_map_create_gmu

Creates a tracked ds_map.

```gml
var my_map = ds_map_create_gmu();
my_map[? "key"] = "value";
my_map[? "number"] = 42;
```

**Returns:** `ds_map` - Tracked map ID.

---

### ds_list_create_gmu

Creates a tracked ds_list.

```gml
var my_list = ds_list_create_gmu();
ds_list_add(my_list, "first");
ds_list_add(my_list, "second");
ds_list_add(my_list, "third");
```

**Returns:** `ds_list` - Tracked list ID.

---

### ds_queue_create_gmu

Creates a tracked ds_queue.

```gml
var my_queue = ds_queue_create_gmu();
ds_queue_enqueue(my_queue, "task1");
ds_queue_enqueue(my_queue, "task2");

var next = ds_queue_dequeue(my_queue); // "task1"
```

**Returns:** `ds_queue` - Tracked queue ID.

---

### ds_stack_create_gmu

Creates a tracked ds_stack.

```gml
var my_stack = ds_stack_create_gmu();
ds_stack_push(my_stack, "first");
ds_stack_push(my_stack, "second");

var top = ds_stack_pop(my_stack); // "second"
```

**Returns:** `ds_stack` - Tracked stack ID.

---

### ds_grid_create_gmu

Creates a tracked ds_grid.

```gml
var my_grid = ds_grid_create_gmu(10, 10);
ds_grid_set(my_grid, 0, 0, 100);
var value = ds_grid_get(my_grid, 0, 0); // 100
```

**Parameters:**
- `w` - Grid width
- `h` - Grid height

**Returns:** `ds_grid` - Tracked grid ID.

---

### ds_priority_create_gmu

Creates a tracked ds_priority queue.

```gml
var my_priority = ds_priority_create_gmu();
ds_priority_add(my_priority, "low", 10);
ds_priority_add(my_priority, "high", 100);
ds_priority_add(my_priority, "medium", 50);

var highest = ds_priority_delete_max(my_priority); // "high"
```

**Returns:** `ds_priority` - Tracked priority queue ID.

---

### Destroy Functions

Each wrapped type has a corresponding destroy function that also unregisters it from the `MemoryTracker`.

```gml
ds_map_destroy_gmu(my_map);
ds_list_destroy_gmu(my_list);
ds_queue_destroy_gmu(my_queue);
ds_stack_destroy_gmu(my_stack);
ds_grid_destroy_gmu(my_grid);
ds_priority_destroy_gmu(my_priority);
```

---

## DataPack (XML System)

The DataPack system provides a complete solution for building, parsing, and manipulating XML documents in GameMaker.

### XMLNode

The `XMLNode` struct represents a single node in an XML document.

#### Constructor

```gml
new XMLNode(tag)
```

**Parameters:**
- `tag` - The tag name for this node

```gml
var node = new XMLNode("player");
```

#### Methods

##### SetAttribute(name, value)

Sets an attribute on the node.

```gml
node.SetAttribute("id", "player1");
node.SetAttribute("health", 100);
node.SetAttribute("position", "100,200");
```

**Returns:** `self` for chaining.

##### GetAttribute(name)

Gets an attribute value.

```gml
var id = node.GetAttribute("id"); // "player1"
var missing = node.GetAttribute("missing"); // undefined
```

**Returns:** String value or `undefined` if not found.

##### RemoveAttribute(name)

Removes an attribute.

```gml
node.RemoveAttribute("health");
```

**Returns:** `self` for chaining.

##### HasAttribute(name)

Checks if an attribute exists.

```gml
if (node.HasAttribute("id")) {
    // Attribute exists
}
```

**Returns:** `true` if attribute exists, `false` otherwise.

##### GetAttributes()

Returns all attributes as a struct.

```gml
var attrs = node.GetAttributes();
show_debug_message($"ID: {attrs.id}, Health: {attrs.health}");
```

**Returns:** Struct with attribute key-value pairs.

##### AddContent(text)

Adds text content to the node.

```gml
node.AddContent("This is some text content.");
node.AddContent(" And more content.");
// Content becomes: "This is some text content. And more content."
```

**Returns:** `self` for chaining.

##### AddCDATA(text)

Adds CDATA content (unescaped character data).

```gml
node.AddCDATA("<script>alert('hello');</script>");
```

**Returns:** `self` for chaining.

##### GetContent()

Gets the node's text content (excluding CDATA).

```gml
var text = node.GetContent();
```

**Returns:** String content.

##### GetCDATA()

Gets the node's CDATA content.

```gml
var cdata = node.GetCDATA();
```

**Returns:** String CDATA content.

##### GetText()

Gets all text content including CDATA and child node text.

```gml
var all_text = node.GetText();
```

**Returns:** Combined text content.

##### AddChild(node)

Adds a child node.

```gml
var child = new XMLNode("item");
node.AddChild(child);
```

**Returns:** `self` for chaining.

##### RemoveChild(node)

Removes a child node.

```gml
node.RemoveChild(child);
```

**Returns:** `true` if removed, `false` if not found.

##### GetChildren(tag_name = undefined)

Gets child nodes, optionally filtered by tag name.

```gml
var all_children = node.GetChildren();
var items = node.GetChildren("item");
```

**Returns:** Array of child nodes.

##### GetFirstChild(tag_name = undefined)

Gets the first child node, optionally filtered by tag name.

```gml
var first_item = node.GetFirstChild("item");
```

**Returns:** First matching child node or `undefined`.

##### toString(indent_level = 0)

Converts the node to an XML string.

```gml
var xml_string = node.ToString(0);  // Pretty printed with indentation
var compact = node.ToString(-1);    // No indentation or newlines
```

**Returns:** XML string representation.

##### Free()

Cleans up the node and all children.

```gml
node.Free();
```

---

### XMLParser

The `XMLParser` struct parses XML strings into `XMLNode` trees.

#### Constructor

```gml
new XMLParser()
```

#### Methods

##### Parse(xml_string)

Parses an XML string and returns the root node.

```gml
var parser = new XMLParser();
var result = parser.Parse("<root><item>Hello</item></root>");

if (result.success) {
    var root = result.root;
    // Use root node
} else {
    show_debug_message($"Parse error: {result.error}");
}
```

**Returns:** Struct with properties:
- `success` - Boolean indicating if parsing succeeded
- `root` - Root XMLNode (if successful)
- `error` - Error message (if failed)

---

### DataPack Builder

The `DataPack` struct provides a builder pattern for creating XML documents.

#### Constructor

```gml
new DataPack()
```

#### Methods

##### NewDocument(root_tag = "root")

Starts building a new XML document.

```gml
var pack = new DataPack();
pack.NewDocument("game_data");
```

**Returns:** `self` for chaining.

##### PushTag(tag, attributes = undefined)

Adds a new child tag and makes it the current node.

```gml
pack.PushTag("player", { id: "p1", class: "warrior" });
pack.PushTag("stats");
pack.AddContent("Level 10");
pack.PopTag(); // Close stats
pack.PopTag(); // Close player
```

**Returns:** `self` for chaining.

##### AddContent(content)

Adds text content to the current node.

```gml
pack.PushTag("name");
pack.AddContent("Hero");
pack.PopTag();
```

**Returns:** `self` for chaining.

##### AddCDATA(content)

Adds CDATA content to the current node.

```gml
pack.PushTag("script");
pack.AddCDATA("function update() { /* code */ }");
pack.PopTag();
```

**Returns:** `self` for chaining.

##### PopTag()

Closes the current tag and moves back to its parent.

```gml
pack.PushTag("container");
pack.PushTag("item");
pack.PopTag(); // Back to container
pack.PopTag(); // Back to root
```

**Returns:** `self` for chaining.

##### GetString(pretty = true)

Gets the XML document as a string.

```gml
var xml = pack.GetString(true);  // Pretty printed
var compact = pack.GetString(false); // Compact
```

**Returns:** XML string.

##### Parse(xml_string)

Parses an XML string into the DataPack.

```gml
var pack = new DataPack();
var root = pack.Parse("<config><volume>0.8</volume></config>");

if (root != undefined) {
    var volume_node = root.GetFirstChild("volume");
    show_debug_message(volume_node.GetContent());
}
```

**Returns:** Root `XMLNode` or `undefined` on failure.

##### LoadFromFile(filename)

Loads and parses an XML file.

```gml
var pack = DataPack.LoadFromFile("config.xml");
if (pack != undefined) {
    var root = pack.GetRoot();
    // Process XML
}
```

**Returns:** `DataPack` instance or `undefined` on failure.

##### SaveToFile(filename, pretty = true)

Saves the XML document to a file.

```gml
pack.SaveToFile("save_data.xml", true);
```

**Returns:** `true` on success, `false` on failure.

##### GetRoot()

Gets the root node of the document.

```gml
var root = pack.GetRoot();
```

**Returns:** Root `XMLNode` or `undefined`.

##### Query(path)

Simple XPath-like query for finding nodes and attributes.

```gml
// Find a node
var player_node = pack.Query("game/players/player");

// Get an attribute
var player_id = pack.Query("game/players/player@id");
```

**Parameters:**
- `path` - Path string using `/` as separator, `@` for attributes

**Returns:** `XMLNode`, attribute string value, or `undefined`.

##### Clear()

Clears the current document.

```gml
pack.Clear();
```

**Returns:** `self` for chaining.

##### Free()

Cleans up the DataPack and all nodes.

```gml
pack.Free();
```

---

## Complete Examples

### Example 1: Building an XML Document

```gml
var pack = new DataPack();
pack.NewDocument("game_save");

// Add player data
pack.PushTag("player", { id: "hero", class: "mage" });
pack.PushTag("position");
pack.AddContent("100,200");
pack.PopTag();
pack.PushTag("stats");
pack.AddContent(json_stringify({ health: 85, mana: 120 }));
pack.PopTag();
pack.PopTag();

// Add inventory
pack.PushTag("inventory", { slots: "20" });
pack.PushTag("item", { id: "sword", quantity: "1" });
pack.PopTag();
pack.PushTag("item", { id: "potion", quantity: "5" });
pack.PopTag();
pack.PopTag();

// Get XML string
var xml_string = pack.GetString(true);
show_debug_message(xml_string);

// Save to file
pack.SaveToFile("save.xml");

// Clean up
pack.Free();
```

### Example 2: Parsing an XML Document

```gml
var xml_string = @'
<config>
    <graphics>
        <resolution width="1920" height="1080" />
        <fullscreen>true</fullscreen>
        <vsync>false</vsync>
    </graphics>
    <audio>
        <master>0.8</master>
        <sfx>0.7</sfx>
        <music>0.6</music>
    </audio>
</config>
';

var pack = new DataPack();
var root = pack.Parse(xml_string);

if (root != undefined) {
    // Get resolution attributes
    var width = pack.Query("config/graphics/resolution@width");
    var height = pack.Query("config/graphics/resolution@height");
    show_debug_message($"Resolution: {width}x{height}");
    
    // Get audio settings
    var master_vol = real(pack.Query("config/audio/master").GetContent());
    var sfx_vol = real(pack.Query("config/audio/sfx").GetContent());
    show_debug_message($"Master: {master_vol}, SFX: {sfx_vol}");
}

pack.Free();
```

### Example 3: Using Tracked Data Structures

```gml
// Create tracked structures
var player_inventory = ds_list_create_gmu();
var player_stats = ds_map_create_gmu();
var action_queue = ds_queue_create_gmu();

// Use them normally
ds_list_add(player_inventory, "sword", "shield", "potion");
player_stats[? "health"] = 100;
player_stats[? "level"] = 5;
ds_queue_enqueue(action_queue, "attack");
ds_queue_enqueue(action_queue, "defend");

// Check tracking stats
var stats = MemoryTracker.GetStats();
show_debug_message($"Currently tracking {stats.total} structures");

// Clean up individual structures
ds_list_destroy_gmu(player_inventory);
ds_map_destroy_gmu(player_stats);
ds_queue_destroy_gmu(action_queue);

// Or let MemoryTracker handle everything at game end
MemoryTracker.CleanupAll();
```

### Example 4: Building Config File

```gml
function BuildGameConfig() {
    var pack = new DataPack();
    pack.NewDocument("game_config");
    
    // Window settings
    pack.PushTag("window");
    pack.PushTag("title");
    pack.AddContent("My Awesome Game");
    pack.PopTag();
    pack.PushTag("size", { width: 1280, height: 720 });
    pack.PopTag();
    pack.PushTag("resizable");
    pack.AddContent("false");
    pack.PopTag();
    pack.PopTag();
    
    // Key bindings
    pack.PushTag("controls");
    
    pack.PushTag("action", { name: "move_up" });
    pack.PushTag("key");
    pack.AddContent("W");
    pack.PopTag();
    pack.PushTag("key");
    pack.AddContent("Up");
    pack.PopTag();
    pack.PopTag();
    
    pack.PushTag("action", { name: "jump" });
    pack.PushTag("key");
    pack.AddContent("Space");
    pack.PopTag();
    pack.PopTag();
    
    pack.PopTag(); // controls
    
    var xml = pack.GetString(true);
    pack.Free();
    
    return xml;
}

var config_xml = BuildGameConfig();
File.SaveString("config.xml", config_xml);
```
