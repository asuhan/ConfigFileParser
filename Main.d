module runparser;

import antlr.runtime.ANTLRStringStream;
import antlr.runtime.ANTLRFileStream;
import antlr.runtime.CommonTokenStream;

import ConfigurationFileLexer, ConfigurationFileParser;

import std.stdio;
import antlr.runtime.tree.CommonTree;
import std.array;
import std.string;
import std.variant;

Variant astToValue(CommonTree value, ConfigurationFileLexer lexer) {
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

void main(string[] args) {
  ANTLRStringStream ins;
  assert(args.length > 1);
  ins = new ANTLRFileStream(args[1]);
  auto lexer = new ConfigurationFileLexer(ins);
  CommonTokenStream tokens = new CommonTokenStream(lexer);
  auto parser = new ConfigurationFileParser(tokens);
  auto res = parser.configuration();
  writeln(astToValue(cast(CommonTree)res.getTree(), lexer));
}
