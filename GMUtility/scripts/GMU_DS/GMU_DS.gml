// Wrappers
function ds_map_create_gmu() {
    var _map = ds_map_create();
    return MemoryTracker.RegisterMap(_map);
};

function ds_list_create_gmu() {
    var _list = ds_list_create();
    return MemoryTracker.RegisterList(_list);
};

function ds_queue_create_gmu() {
    var _queue = ds_queue_create();
    return MemoryTracker.RegisterQueue(_queue);
};

function ds_stack_create_gmu() {
    var _stack = ds_stack_create();
    return MemoryTracker.RegisterStack(_stack);
};

function ds_grid_create_gmu(w, h) {
    var _grid = ds_grid_create(w, h);
    return MemoryTracker.RegisterGrid(_grid);
};

function ds_priority_create_gmu() {
    var _priority = ds_priority_create();
    return MemoryTracker.RegisterPriority(_priority);
};

function ds_map_destroy_gmu(id) {
    MemoryTracker.Unregister(id);
    ds_map_destroy(id);
};

function ds_list_destroy_gmu(id) {
    MemoryTracker.Unregister(id);
    ds_list_destroy(id);
};

function ds_queue_destroy_gmu(id) {
    MemoryTracker.Unregister(id);
    ds_queue_destroy(id);
};

function ds_stack_destroy_gmu(id) {
    MemoryTracker.Unregister(id);
   ds_stack_destroy(id);
};

function ds_grid_destroy_gmu(id) {
    MemoryTracker.Unregister(id);
    ds_grid_destroy(id);
};

function ds_priority_destroy_gmu(id) {
    MemoryTracker.Unregister(id);
    ds_priority_destroy(id);
};

//  Data Pack (XML)
function DataPack() constructor {
    root = undefined;
    current_node = undefined;

    building = false;
    builder_stack = ds_stack_create_gmu();

    function Clear() {
        if (root != undefined) FreeNode(root);
        root = undefined;
        current_node = undefined;
        ds_stack_clear(builder_stack);
        building = false;
        return self;
    };

    function NewDocument(root_tag = "root") {
        Clear();
        root = new XMLNode(root_tag);
        current_node = root;
        building = true;
        return self;
    };

    function PushTag(tag, attributes = undefined) {
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

    function AddContent(content) {
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

    function AddCDATA(content) {
        if (!building || current_node == undefined) return self;
        current_node.AddCDATA(content);
        return self;
    };

    function PopTag() {
        if (!building || ds_stack_empty(builder_stack)) {
            show_debug_message("[DataPack] Error: No tag to pop.");
            return self;
        }
        current_node = ds_stack_pop(builder_stack);
        return self;
    };

    function GetString(pretty = true) {
        if (root == undefined) return "";
        return root.ToString(pretty ? 0 : -1);
    };

    function Parse(xml_string) {
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

    function LoadFromFile(filename) {
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

    function SaveToFile(filename, pretty = true) {
        if (root == undefined) return false;
        return File.SaveString(filename, GetString(pretty));
    };

    function GetRoot() { return root; };

    function Query(path) { // simplified
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

    function Free() {
        if (root != undefined) FreeNode(root);
        if (builder_stack != undefined) ds_stack_destroy_gmu(builder_stack);
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
    attributes = ds_map_create_gmu();
    content = "";
    cdata = "";
    children = [];
    parent = undefined;

    function SetAttribute(name, value) {
        attributes[? name] = string(value);
        return self;
    };

    function GetAttribute(name) {
        return ds_map_exists(attributes, name) ? attributes[? name] : undefined;
    };

    function RemoveAttribute(name) {
        if (ds_map_exists(attributes, name)) ds_map_delete(attributes, name);
        return self;
    };

    function HasAttribute(name) {
        return ds_map_exists(attributes, name);
    };

    function GetAttributes() {
	    var result = {};
	    var keys = ds_map_keys_to_array(attributes);
	    for (var i = 0; i < array_length(keys); i++) {
	        var key = keys[i];
	        // Use variable_struct_set for struct assignment
	        variable_struct_set(result, key, attributes[? key]);
	    }
	    return result;
	};

    function AddContent(text) {
        content += text;
        return self;
    };

    function AddCDATA(text) {
        cdata += text;
        return self;
    };

    function GetContent() {
        return content;
    };

    function GetCDATA() {
        return cdata;
    };

    function GetText() {
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

    function AddChild(node) {
        array_push(children, node);
        node.parent = self;
        return self;
    };

    function RemoveChild(node) {
        for (var i = 0; i < array_length(children); i++) {
            if (children[i] == node) {
                array_delete(children, i, 1);
                node.parent = undefined;
                return true;
            }
        }
        return false;
    };

    function GetChildren(tag_name = undefined) {
        if (tag_name == undefined) return children;
    
        var result = [];
        for (var i = 0; i < array_length(children); i++) {
            if (children[i].tag == tag_name) {
                array_push(result, children[i]);
            }
        }
        return result;
    };

    function GetFirstChild(tag_name = undefined) {
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

    toString = function(indent_level = 0) {
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

    function Free() {
        if (attributes != undefined) ds_map_destroy_gmu(attributes);
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

    function Parse(xml) {
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

