module runparser;

import antlr.runtime.ANTLRStringStream;
import antlr.runtime.ANTLRFileStream;
import antlr.runtime.CharStream;
import antlr.runtime.CommonTokenStream;
import antlr.runtime.tree.CommonTree;

import ConfigurationFileLexer, ConfigurationFileParser;

import std.array;
import std.conv;
import std.stdio;
import std.string;
import std.variant;

Variant astToValue(CommonTree value, const ConfigurationFileLexer lexer) {
  Variant dict;

  switch (value.token.getType()) {
    case lexer.BOOLEAN:
      assert(value.getChildCount == 0);
      auto lc_value = value.token.getText().toLower();
      assert(lc_value == "true" || lc_value == "false");
      dict = lc_value == "true" ? true : false;
      break;
    case lexer.INTEGER:
    case lexer.INTEGER64:
    case lexer.HEX:
    case lexer.HEX64:
      // TODO: parse
      assert(value.getChildCount == 0);
      dict = value.token.getText();
      break;
    case lexer.FLOAT:
      assert(value.getChildCount == 0);
      dict = std.conv.to!double(value.token.getText());
      break;
    case lexer.String:
      assert(value.getChildCount >= 1);
      string str;
      for (int i = 0; i < value.getChildCount(); i++) {
        auto str_node = cast(CommonTree)value.getChild(i);
        assert(str_node.token.getType() == lexer.STRING);
        // TODO: un-escape properly
        str ~= str_node.getText()[1..$-1];
      }
      dict = str;
      break;
    case lexer.Array:
    case lexer.List:
      // TODO: make array and list different types?
      if (value.getChildCount == 0) {
        dict = new Variant[0];
        break;
      }
      assert(value.getChildCount == 1);
      auto vl_node = cast(CommonTree)value.getChild(0);
      auto vl = new Variant[vl_node.getChildCount()];
      for (int i = 0; i < vl_node.getChildCount(); i++) {
        auto val_node = cast(CommonTree)vl_node.getChild(i);
        vl[i] = astToValue(val_node, lexer);
      }
      dict = vl;
      break;
    case lexer.Group:
    case lexer.Configuration:
      Variant[string] group;
      for (int i = 0; i < value.getChildCount(); i++) {
        auto kv = cast(CommonTree)value.getChild(i);
        assert(kv.getType() == lexer.KeyValue);
        assert(kv.getChildCount() == 2);
        auto key_node = cast(CommonTree)kv.getChild(0);
        assert(key_node.getType() == lexer.NAME);
        assert(key_node.getChildCount() == 0);
        auto val_node = cast(CommonTree)kv.getChild(1);
        group[key_node.token.getText()] = astToValue(val_node, lexer);
      }
      dict = group;
      break;
    default:
      assert(false);
      break;
  }
  return dict;
}

Variant config_read_stream(CharStream ins) {
  auto lexer = new ConfigurationFileLexer(ins);
  auto tokens = new CommonTokenStream(lexer);
  auto parser = new ConfigurationFileParser(tokens);
  auto res = parser.configuration();
  return astToValue(cast(CommonTree)res.getTree(), lexer);
}

Variant config_read_file(const string filename) {
  return config_read_stream(new ANTLRFileStream(filename));
}

Variant config_read_string(const string str) {
  return config_read_stream(new ANTLRStringStream(str));
}

int config_lookup_int(const Variant config, const string path) {
  // TODO: parse on config init
  return to!int(config_lookup(config, path).get!(string));
}

long config_lookup_int64(const Variant config, const string path) {
  // TODO: parse on config init
  auto long_str = config_lookup(config, path).get!(string);
  for (auto i = 0; i < 2; ++i) {
    if (long_str[$-1] == 'L') {
      long_str = long_str[0..$-1];
    }
  }
  return to!long(long_str);
}

double config_lookup_float(const Variant config, const string path) {
  return config_lookup(config, path).get!(double);
}

bool config_lookup_bool(const Variant config, const string path) {
  return config_lookup(config, path).get!(bool);
}

string config_lookup_string(const Variant config, const string path) {
  return config_lookup(config, path).get!(string);
}

Variant config_lookup(const Variant config, const string path) {
  auto path_nodes = path.split('.');
  Variant result = config;
  foreach (string path_node; path_nodes) {
    result = result[path_node];
  }
  return result;
}

int config_setting_get_int(const Variant setting) {
  Variant setting_copy = setting;
  return to!int(setting_copy.get!(string));
}

long config_setting_get_int64(const Variant setting) {
  Variant setting_copy = setting;
  auto long_str = setting_copy.get!(string);
  for (auto i = 0; i < 2; ++i) {
    if (long_str[$-1] == 'L') {
      long_str = long_str[0..$-1];
    }
  }
  return to!long(long_str);
}

double config_setting_get_float(const Variant setting) {
  Variant setting_copy = setting;
  return setting_copy.get!(double);
}

bool config_setting_get_bool(const Variant setting) {
  Variant setting_copy = setting;
  return setting_copy.get!(bool);
}

string config_setting_get_string(const Variant setting) {
  Variant setting_copy = setting;
  return setting_copy.get!(string);
}

int config_setting_lookup_int(const Variant setting, const string name) {
  return config_lookup_int(setting, name);
}

long config_setting_lookup_int64(const Variant setting, const string name) {
  return config_lookup_int64(setting, name);
}

double config_setting_lookup_float(const Variant setting, const string name) {
  return config_lookup_float(setting, name);
}

bool config_setting_lookup_bool(const Variant setting, const string name) {
  return config_lookup_bool(setting, name);
}

string config_setting_lookup_string(const Variant setting, const string name) {
  return config_lookup_string(setting, name);
}

Variant config_setting_get_member(const Variant setting, const string name) {
  return config_lookup(setting, name);
}

Variant config_setting_get_elem(const Variant setting, uint index) {
  Variant setting_copy = setting;
  return setting_copy[index];
}

int config_setting_get_int_elem(const Variant setting, uint index) {
  return config_setting_get_int(config_setting_get_elem(setting, index));
}

long config_setting_get_int64_elem(const Variant setting, uint index) {
  return config_setting_get_int64(config_setting_get_elem(setting, index));
}

double config_setting_get_float_elem(const Variant setting, uint index) {
  return config_setting_get_float(config_setting_get_elem(setting, index));
}

bool config_setting_get_bool_elem(const Variant setting, uint index) {
  return config_setting_get_bool(config_setting_get_elem(setting, index));
}

string config_setting_get_string_elem(const Variant setting, uint index) {
  return config_setting_get_string(config_setting_get_elem(setting, index));
}

ulong config_setting_length(const Variant setting) {
  Variant setting_copy = setting;
  return setting_copy.length;
}

bool config_setting_is_group(const Variant config) {
  return config.type == typeid(Variant[string]);
}

void main(string[] args) {
  auto config = config_read_file(args[1]);
  writeln(config_lookup(config, "application.window.size.h"));
  writeln(config_setting_get_member(
    config_lookup(config, "application.window.size"), "h"));
  writeln(config_lookup_int(config, "misc.port"));
  writeln(config_lookup_int64(config, "misc.bigint"));
  writeln(config_lookup_float(config, "misc.pi"));
  writeln(config_lookup_bool(config, "misc.enabled"));
  writeln(config_lookup_string(config, "misc.unicode"));
  writeln(config_setting_is_group(config_lookup(config, "application")));
  writeln(config_setting_is_group(config_lookup(config, "application.window")));
  writeln(config_setting_is_group(
    config_lookup(config, "application.window.title")));
  auto lst = config_lookup(config, "list");
  writeln(config_setting_length(lst));
  writeln(config_setting_get_elem(lst, 1));
  auto books = config_lookup(config, "books");
  writeln(config_setting_get_string(config_setting_get_elem(books, 0)));
  writeln(config_setting_get_int(config_lookup(config,
    "application.a")));
  writeln(config_setting_get_int64(config_lookup(config,
    "misc.bigint")));
  writeln(config_setting_get_float(config_lookup(config,
    "misc.pi")));
  writeln(config_setting_get_bool(config_lookup(config,
    "application.group1.flag")));
  writeln(config_setting_lookup_int(config_lookup(config, "misc"), "port"));
  writeln(config_setting_lookup_int64(config_lookup(config, "misc"), "bigint"));
  writeln(config_setting_lookup_float(config_lookup(config, "misc"), "pi"));
  writeln(config_setting_lookup_bool(config_lookup(config, "misc"), "enabled"));
  writeln(config_setting_lookup_string(config_lookup(config, "misc"), "unicode"));
  writeln(config_setting_get_string_elem(config_lookup(config, "application.group1.states"), 1));
}
