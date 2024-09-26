/+ DO NOT EDIT BY HAND!
This module was automatically generated from the following grammar:

JinjaTemplate:
  Template           <- (Text / Comment / RawStatement / Interpolation / SetStatement)+
  Text               <- ~(!(OpenInterpolation / OpenStatement / OpenComment) .)+
  Comment            <- OpenComment (!CloseComment .)+ CloseComment
  RawStatement       <- OpenRaw RawText CloseRaw
  SetStatement       <  OpenStatement "set" Variable "=" Expression Filter* CloseStatement
  Variable           <  qualifiedIdentifier
  RawText            <~ blank* (!CloseRaw .)+ blank*
  OpenRaw            <  OpenStatement "raw" CloseStatement
  CloseRaw           <  OpenStatement "endraw" CloseStatement
  OpenInterpolation  <- "{{"
  CloseInterpolation <- "}}"
  OpenStatement      <- "{%"
  CloseStatement     <- "%}"
  OpenComment        <- "{#"
  CloseComment       <- "#}"
  OpenParen          <- "("
  CloseParen         <- ")"
  Interpolation      <  OpenInterpolation Expression Filter* CloseInterpolation
  Expression         <~ qualifiedIdentifier / Value
  Number             <  ~(Digit+)
  Digit              <  [0-9]
  Filter             <  FilterStart FilterName FilterArgs*
  FilterName         <  identifier
  FilterStart        <  "|"
  FilterArgSep       <  ","
  FilterArg          <  String / Number / identifier / (!FilterArgSep !CloseParen !blank .)+
  FilterArgs         <  OpenParen FilterArg (FilterArgSep FilterArg)* CloseParen
  Dict               <  '{' (Pair (',' Pair)*)? '}'
  Pair               <  String ':' Value
  Array              <  '[' (Value (',' Value)* )? ']'
  Value              <  String
                        / Number
                        / Dict
                        / Array
                        / True
                        / False
                        / Null
  True               <- "true"
  False              <- "false"
  Null               <- "null"


+/
module jinja.parser;

import pegged.examples.strings;
import pegged.examples.numbers;

public import pegged.peg;
import std.algorithm: startsWith;
import std.functional: toDelegate;

@safe struct GenericJinjaTemplate(TParseTree)
{
    import std.functional : toDelegate;
    import pegged.dynamic.grammar;
    static import pegged.peg;
    struct JinjaTemplate
    {
    enum name = "JinjaTemplate";
    static ParseTree delegate(ParseTree) @safe [string] before;
    static ParseTree delegate(ParseTree) @safe [string] after;
    static ParseTree delegate(ParseTree) @safe [string] rules;
    import std.typecons:Tuple, tuple;
    static TParseTree[Tuple!(string, size_t)] memo;
    static this() @trusted
    {
        rules["Template"] = toDelegate(&Template);
        rules["Text"] = toDelegate(&Text);
        rules["Comment"] = toDelegate(&Comment);
        rules["RawStatement"] = toDelegate(&RawStatement);
        rules["SetStatement"] = toDelegate(&SetStatement);
        rules["Variable"] = toDelegate(&Variable);
        rules["RawText"] = toDelegate(&RawText);
        rules["OpenRaw"] = toDelegate(&OpenRaw);
        rules["CloseRaw"] = toDelegate(&CloseRaw);
        rules["OpenInterpolation"] = toDelegate(&OpenInterpolation);
        rules["CloseInterpolation"] = toDelegate(&CloseInterpolation);
        rules["OpenStatement"] = toDelegate(&OpenStatement);
        rules["CloseStatement"] = toDelegate(&CloseStatement);
        rules["OpenComment"] = toDelegate(&OpenComment);
        rules["CloseComment"] = toDelegate(&CloseComment);
        rules["OpenParen"] = toDelegate(&OpenParen);
        rules["CloseParen"] = toDelegate(&CloseParen);
        rules["Interpolation"] = toDelegate(&Interpolation);
        rules["Expression"] = toDelegate(&Expression);
        rules["Number"] = toDelegate(&Number);
        rules["Digit"] = toDelegate(&Digit);
        rules["Filter"] = toDelegate(&Filter);
        rules["FilterName"] = toDelegate(&FilterName);
        rules["FilterStart"] = toDelegate(&FilterStart);
        rules["FilterArgSep"] = toDelegate(&FilterArgSep);
        rules["FilterArg"] = toDelegate(&FilterArg);
        rules["FilterArgs"] = toDelegate(&FilterArgs);
        rules["Dict"] = toDelegate(&Dict);
        rules["Pair"] = toDelegate(&Pair);
        rules["Array"] = toDelegate(&Array);
        rules["Value"] = toDelegate(&Value);
        rules["True"] = toDelegate(&True);
        rules["False"] = toDelegate(&False);
        rules["Null"] = toDelegate(&Null);
        rules["Spacing"] = toDelegate(&Spacing);
    }

    template hooked(alias r, string name)
    {
        static ParseTree hooked(ParseTree p) @safe
        {
            ParseTree result;

            if (name in before)
            {
                result = before[name](p);
                if (result.successful)
                    return result;
            }

            result = r(p);
            if (result.successful || name !in after)
                return result;

            result = after[name](p);
            return result;
        }

        static ParseTree hooked(string input) @safe
        {
            return hooked!(r, name)(ParseTree("",false,[],input));
        }
    }

    static void addRuleBefore(string parentRule, string ruleSyntax) @safe
    {
        // enum name is the current grammar name
        DynamicGrammar dg = pegged.dynamic.grammar.grammar(name ~ ": " ~ ruleSyntax, rules);
        foreach(ruleName,rule; dg.rules)
            if (ruleName != "Spacing") // Keep the local Spacing rule, do not overwrite it
                rules[ruleName] = rule;
        before[parentRule] = rules[dg.startingRule];
    }

    static void addRuleAfter(string parentRule, string ruleSyntax) @safe
    {
        // enum name is the current grammar named
        DynamicGrammar dg = pegged.dynamic.grammar.grammar(name ~ ": " ~ ruleSyntax, rules);
        foreach(ruleName,rule; dg.rules)
        {
            if (ruleName != "Spacing")
                rules[ruleName] = rule;
        }
        after[parentRule] = rules[dg.startingRule];
    }

    static bool isRule(string s) pure nothrow @nogc
    {
        import std.algorithm : startsWith;
        return s.startsWith("JinjaTemplate.");
    }
    mixin decimateTree;

    alias spacing Spacing;

    static TParseTree Template(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.oneOrMore!(pegged.peg.or!(Text, Comment, RawStatement, Interpolation, SetStatement)), "JinjaTemplate.Template")(p);
        }
        else
        {
            if (auto m = tuple(`Template`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.oneOrMore!(pegged.peg.or!(Text, Comment, RawStatement, Interpolation, SetStatement)), "JinjaTemplate.Template"), "Template")(p);
                memo[tuple(`Template`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Template(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.oneOrMore!(pegged.peg.or!(Text, Comment, RawStatement, Interpolation, SetStatement)), "JinjaTemplate.Template")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.oneOrMore!(pegged.peg.or!(Text, Comment, RawStatement, Interpolation, SetStatement)), "JinjaTemplate.Template"), "Template")(TParseTree("", false,[], s));
        }
    }
    static string Template(GetName g)
    {
        return "JinjaTemplate.Template";
    }

    static TParseTree Text(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.oneOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.or!(OpenInterpolation, OpenStatement, OpenComment)), pegged.peg.any))), "JinjaTemplate.Text")(p);
        }
        else
        {
            if (auto m = tuple(`Text`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.oneOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.or!(OpenInterpolation, OpenStatement, OpenComment)), pegged.peg.any))), "JinjaTemplate.Text"), "Text")(p);
                memo[tuple(`Text`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Text(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.oneOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.or!(OpenInterpolation, OpenStatement, OpenComment)), pegged.peg.any))), "JinjaTemplate.Text")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.oneOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.or!(OpenInterpolation, OpenStatement, OpenComment)), pegged.peg.any))), "JinjaTemplate.Text"), "Text")(TParseTree("", false,[], s));
        }
    }
    static string Text(GetName g)
    {
        return "JinjaTemplate.Text";
    }

    static TParseTree Comment(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(OpenComment, pegged.peg.oneOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(CloseComment), pegged.peg.any)), CloseComment), "JinjaTemplate.Comment")(p);
        }
        else
        {
            if (auto m = tuple(`Comment`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(OpenComment, pegged.peg.oneOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(CloseComment), pegged.peg.any)), CloseComment), "JinjaTemplate.Comment"), "Comment")(p);
                memo[tuple(`Comment`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Comment(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(OpenComment, pegged.peg.oneOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(CloseComment), pegged.peg.any)), CloseComment), "JinjaTemplate.Comment")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(OpenComment, pegged.peg.oneOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(CloseComment), pegged.peg.any)), CloseComment), "JinjaTemplate.Comment"), "Comment")(TParseTree("", false,[], s));
        }
    }
    static string Comment(GetName g)
    {
        return "JinjaTemplate.Comment";
    }

    static TParseTree RawStatement(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(OpenRaw, RawText, CloseRaw), "JinjaTemplate.RawStatement")(p);
        }
        else
        {
            if (auto m = tuple(`RawStatement`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(OpenRaw, RawText, CloseRaw), "JinjaTemplate.RawStatement"), "RawStatement")(p);
                memo[tuple(`RawStatement`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree RawStatement(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(OpenRaw, RawText, CloseRaw), "JinjaTemplate.RawStatement")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(OpenRaw, RawText, CloseRaw), "JinjaTemplate.RawStatement"), "RawStatement")(TParseTree("", false,[], s));
        }
    }
    static string RawStatement(GetName g)
    {
        return "JinjaTemplate.RawStatement";
    }

    static TParseTree SetStatement(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, OpenStatement, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("set"), Spacing), pegged.peg.wrapAround!(Spacing, Variable, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, Filter, Spacing)), pegged.peg.wrapAround!(Spacing, CloseStatement, Spacing)), "JinjaTemplate.SetStatement")(p);
        }
        else
        {
            if (auto m = tuple(`SetStatement`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, OpenStatement, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("set"), Spacing), pegged.peg.wrapAround!(Spacing, Variable, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, Filter, Spacing)), pegged.peg.wrapAround!(Spacing, CloseStatement, Spacing)), "JinjaTemplate.SetStatement"), "SetStatement")(p);
                memo[tuple(`SetStatement`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree SetStatement(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, OpenStatement, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("set"), Spacing), pegged.peg.wrapAround!(Spacing, Variable, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, Filter, Spacing)), pegged.peg.wrapAround!(Spacing, CloseStatement, Spacing)), "JinjaTemplate.SetStatement")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, OpenStatement, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("set"), Spacing), pegged.peg.wrapAround!(Spacing, Variable, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, Filter, Spacing)), pegged.peg.wrapAround!(Spacing, CloseStatement, Spacing)), "JinjaTemplate.SetStatement"), "SetStatement")(TParseTree("", false,[], s));
        }
    }
    static string SetStatement(GetName g)
    {
        return "JinjaTemplate.SetStatement";
    }

    static TParseTree Variable(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, qualifiedIdentifier, Spacing), "JinjaTemplate.Variable")(p);
        }
        else
        {
            if (auto m = tuple(`Variable`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, qualifiedIdentifier, Spacing), "JinjaTemplate.Variable"), "Variable")(p);
                memo[tuple(`Variable`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Variable(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, qualifiedIdentifier, Spacing), "JinjaTemplate.Variable")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, qualifiedIdentifier, Spacing), "JinjaTemplate.Variable"), "Variable")(TParseTree("", false,[], s));
        }
    }
    static string Variable(GetName g)
    {
        return "JinjaTemplate.Variable";
    }

    static TParseTree RawText(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.zeroOrMore!(blank), pegged.peg.oneOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(CloseRaw), pegged.peg.any)), pegged.peg.zeroOrMore!(blank))), "JinjaTemplate.RawText")(p);
        }
        else
        {
            if (auto m = tuple(`RawText`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.zeroOrMore!(blank), pegged.peg.oneOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(CloseRaw), pegged.peg.any)), pegged.peg.zeroOrMore!(blank))), "JinjaTemplate.RawText"), "RawText")(p);
                memo[tuple(`RawText`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree RawText(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.zeroOrMore!(blank), pegged.peg.oneOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(CloseRaw), pegged.peg.any)), pegged.peg.zeroOrMore!(blank))), "JinjaTemplate.RawText")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.zeroOrMore!(blank), pegged.peg.oneOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(CloseRaw), pegged.peg.any)), pegged.peg.zeroOrMore!(blank))), "JinjaTemplate.RawText"), "RawText")(TParseTree("", false,[], s));
        }
    }
    static string RawText(GetName g)
    {
        return "JinjaTemplate.RawText";
    }

    static TParseTree OpenRaw(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, OpenStatement, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("raw"), Spacing), pegged.peg.wrapAround!(Spacing, CloseStatement, Spacing)), "JinjaTemplate.OpenRaw")(p);
        }
        else
        {
            if (auto m = tuple(`OpenRaw`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, OpenStatement, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("raw"), Spacing), pegged.peg.wrapAround!(Spacing, CloseStatement, Spacing)), "JinjaTemplate.OpenRaw"), "OpenRaw")(p);
                memo[tuple(`OpenRaw`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree OpenRaw(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, OpenStatement, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("raw"), Spacing), pegged.peg.wrapAround!(Spacing, CloseStatement, Spacing)), "JinjaTemplate.OpenRaw")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, OpenStatement, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("raw"), Spacing), pegged.peg.wrapAround!(Spacing, CloseStatement, Spacing)), "JinjaTemplate.OpenRaw"), "OpenRaw")(TParseTree("", false,[], s));
        }
    }
    static string OpenRaw(GetName g)
    {
        return "JinjaTemplate.OpenRaw";
    }

    static TParseTree CloseRaw(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, OpenStatement, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("endraw"), Spacing), pegged.peg.wrapAround!(Spacing, CloseStatement, Spacing)), "JinjaTemplate.CloseRaw")(p);
        }
        else
        {
            if (auto m = tuple(`CloseRaw`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, OpenStatement, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("endraw"), Spacing), pegged.peg.wrapAround!(Spacing, CloseStatement, Spacing)), "JinjaTemplate.CloseRaw"), "CloseRaw")(p);
                memo[tuple(`CloseRaw`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree CloseRaw(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, OpenStatement, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("endraw"), Spacing), pegged.peg.wrapAround!(Spacing, CloseStatement, Spacing)), "JinjaTemplate.CloseRaw")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, OpenStatement, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("endraw"), Spacing), pegged.peg.wrapAround!(Spacing, CloseStatement, Spacing)), "JinjaTemplate.CloseRaw"), "CloseRaw")(TParseTree("", false,[], s));
        }
    }
    static string CloseRaw(GetName g)
    {
        return "JinjaTemplate.CloseRaw";
    }

    static TParseTree OpenInterpolation(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("{{"), "JinjaTemplate.OpenInterpolation")(p);
        }
        else
        {
            if (auto m = tuple(`OpenInterpolation`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.literal!("{{"), "JinjaTemplate.OpenInterpolation"), "OpenInterpolation")(p);
                memo[tuple(`OpenInterpolation`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree OpenInterpolation(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("{{"), "JinjaTemplate.OpenInterpolation")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.literal!("{{"), "JinjaTemplate.OpenInterpolation"), "OpenInterpolation")(TParseTree("", false,[], s));
        }
    }
    static string OpenInterpolation(GetName g)
    {
        return "JinjaTemplate.OpenInterpolation";
    }

    static TParseTree CloseInterpolation(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("}}"), "JinjaTemplate.CloseInterpolation")(p);
        }
        else
        {
            if (auto m = tuple(`CloseInterpolation`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.literal!("}}"), "JinjaTemplate.CloseInterpolation"), "CloseInterpolation")(p);
                memo[tuple(`CloseInterpolation`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree CloseInterpolation(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("}}"), "JinjaTemplate.CloseInterpolation")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.literal!("}}"), "JinjaTemplate.CloseInterpolation"), "CloseInterpolation")(TParseTree("", false,[], s));
        }
    }
    static string CloseInterpolation(GetName g)
    {
        return "JinjaTemplate.CloseInterpolation";
    }

    static TParseTree OpenStatement(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("{%"), "JinjaTemplate.OpenStatement")(p);
        }
        else
        {
            if (auto m = tuple(`OpenStatement`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.literal!("{%"), "JinjaTemplate.OpenStatement"), "OpenStatement")(p);
                memo[tuple(`OpenStatement`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree OpenStatement(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("{%"), "JinjaTemplate.OpenStatement")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.literal!("{%"), "JinjaTemplate.OpenStatement"), "OpenStatement")(TParseTree("", false,[], s));
        }
    }
    static string OpenStatement(GetName g)
    {
        return "JinjaTemplate.OpenStatement";
    }

    static TParseTree CloseStatement(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("%}"), "JinjaTemplate.CloseStatement")(p);
        }
        else
        {
            if (auto m = tuple(`CloseStatement`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.literal!("%}"), "JinjaTemplate.CloseStatement"), "CloseStatement")(p);
                memo[tuple(`CloseStatement`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree CloseStatement(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("%}"), "JinjaTemplate.CloseStatement")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.literal!("%}"), "JinjaTemplate.CloseStatement"), "CloseStatement")(TParseTree("", false,[], s));
        }
    }
    static string CloseStatement(GetName g)
    {
        return "JinjaTemplate.CloseStatement";
    }

    static TParseTree OpenComment(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("{#"), "JinjaTemplate.OpenComment")(p);
        }
        else
        {
            if (auto m = tuple(`OpenComment`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.literal!("{#"), "JinjaTemplate.OpenComment"), "OpenComment")(p);
                memo[tuple(`OpenComment`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree OpenComment(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("{#"), "JinjaTemplate.OpenComment")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.literal!("{#"), "JinjaTemplate.OpenComment"), "OpenComment")(TParseTree("", false,[], s));
        }
    }
    static string OpenComment(GetName g)
    {
        return "JinjaTemplate.OpenComment";
    }

    static TParseTree CloseComment(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("#}"), "JinjaTemplate.CloseComment")(p);
        }
        else
        {
            if (auto m = tuple(`CloseComment`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.literal!("#}"), "JinjaTemplate.CloseComment"), "CloseComment")(p);
                memo[tuple(`CloseComment`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree CloseComment(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("#}"), "JinjaTemplate.CloseComment")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.literal!("#}"), "JinjaTemplate.CloseComment"), "CloseComment")(TParseTree("", false,[], s));
        }
    }
    static string CloseComment(GetName g)
    {
        return "JinjaTemplate.CloseComment";
    }

    static TParseTree OpenParen(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("("), "JinjaTemplate.OpenParen")(p);
        }
        else
        {
            if (auto m = tuple(`OpenParen`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.literal!("("), "JinjaTemplate.OpenParen"), "OpenParen")(p);
                memo[tuple(`OpenParen`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree OpenParen(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("("), "JinjaTemplate.OpenParen")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.literal!("("), "JinjaTemplate.OpenParen"), "OpenParen")(TParseTree("", false,[], s));
        }
    }
    static string OpenParen(GetName g)
    {
        return "JinjaTemplate.OpenParen";
    }

    static TParseTree CloseParen(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!(")"), "JinjaTemplate.CloseParen")(p);
        }
        else
        {
            if (auto m = tuple(`CloseParen`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.literal!(")"), "JinjaTemplate.CloseParen"), "CloseParen")(p);
                memo[tuple(`CloseParen`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree CloseParen(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!(")"), "JinjaTemplate.CloseParen")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.literal!(")"), "JinjaTemplate.CloseParen"), "CloseParen")(TParseTree("", false,[], s));
        }
    }
    static string CloseParen(GetName g)
    {
        return "JinjaTemplate.CloseParen";
    }

    static TParseTree Interpolation(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, OpenInterpolation, Spacing), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, Filter, Spacing)), pegged.peg.wrapAround!(Spacing, CloseInterpolation, Spacing)), "JinjaTemplate.Interpolation")(p);
        }
        else
        {
            if (auto m = tuple(`Interpolation`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, OpenInterpolation, Spacing), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, Filter, Spacing)), pegged.peg.wrapAround!(Spacing, CloseInterpolation, Spacing)), "JinjaTemplate.Interpolation"), "Interpolation")(p);
                memo[tuple(`Interpolation`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Interpolation(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, OpenInterpolation, Spacing), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, Filter, Spacing)), pegged.peg.wrapAround!(Spacing, CloseInterpolation, Spacing)), "JinjaTemplate.Interpolation")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, OpenInterpolation, Spacing), pegged.peg.wrapAround!(Spacing, Expression, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, Filter, Spacing)), pegged.peg.wrapAround!(Spacing, CloseInterpolation, Spacing)), "JinjaTemplate.Interpolation"), "Interpolation")(TParseTree("", false,[], s));
        }
    }
    static string Interpolation(GetName g)
    {
        return "JinjaTemplate.Interpolation";
    }

    static TParseTree Expression(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(qualifiedIdentifier, Value)), "JinjaTemplate.Expression")(p);
        }
        else
        {
            if (auto m = tuple(`Expression`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(qualifiedIdentifier, Value)), "JinjaTemplate.Expression"), "Expression")(p);
                memo[tuple(`Expression`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Expression(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(qualifiedIdentifier, Value)), "JinjaTemplate.Expression")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(qualifiedIdentifier, Value)), "JinjaTemplate.Expression"), "Expression")(TParseTree("", false,[], s));
        }
    }
    static string Expression(GetName g)
    {
        return "JinjaTemplate.Expression";
    }

    static TParseTree Number(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.wrapAround!(Spacing, pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Digit, Spacing)), Spacing)), "JinjaTemplate.Number")(p);
        }
        else
        {
            if (auto m = tuple(`Number`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.wrapAround!(Spacing, pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Digit, Spacing)), Spacing)), "JinjaTemplate.Number"), "Number")(p);
                memo[tuple(`Number`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Number(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.wrapAround!(Spacing, pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Digit, Spacing)), Spacing)), "JinjaTemplate.Number")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.wrapAround!(Spacing, pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Digit, Spacing)), Spacing)), "JinjaTemplate.Number"), "Number")(TParseTree("", false,[], s));
        }
    }
    static string Number(GetName g)
    {
        return "JinjaTemplate.Number";
    }

    static TParseTree Digit(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.charRange!('0', '9'), Spacing), "JinjaTemplate.Digit")(p);
        }
        else
        {
            if (auto m = tuple(`Digit`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.charRange!('0', '9'), Spacing), "JinjaTemplate.Digit"), "Digit")(p);
                memo[tuple(`Digit`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Digit(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.charRange!('0', '9'), Spacing), "JinjaTemplate.Digit")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.charRange!('0', '9'), Spacing), "JinjaTemplate.Digit"), "Digit")(TParseTree("", false,[], s));
        }
    }
    static string Digit(GetName g)
    {
        return "JinjaTemplate.Digit";
    }

    static TParseTree Filter(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, FilterStart, Spacing), pegged.peg.wrapAround!(Spacing, FilterName, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, FilterArgs, Spacing))), "JinjaTemplate.Filter")(p);
        }
        else
        {
            if (auto m = tuple(`Filter`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, FilterStart, Spacing), pegged.peg.wrapAround!(Spacing, FilterName, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, FilterArgs, Spacing))), "JinjaTemplate.Filter"), "Filter")(p);
                memo[tuple(`Filter`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Filter(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, FilterStart, Spacing), pegged.peg.wrapAround!(Spacing, FilterName, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, FilterArgs, Spacing))), "JinjaTemplate.Filter")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, FilterStart, Spacing), pegged.peg.wrapAround!(Spacing, FilterName, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, FilterArgs, Spacing))), "JinjaTemplate.Filter"), "Filter")(TParseTree("", false,[], s));
        }
    }
    static string Filter(GetName g)
    {
        return "JinjaTemplate.Filter";
    }

    static TParseTree FilterName(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, identifier, Spacing), "JinjaTemplate.FilterName")(p);
        }
        else
        {
            if (auto m = tuple(`FilterName`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, identifier, Spacing), "JinjaTemplate.FilterName"), "FilterName")(p);
                memo[tuple(`FilterName`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree FilterName(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, identifier, Spacing), "JinjaTemplate.FilterName")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, identifier, Spacing), "JinjaTemplate.FilterName"), "FilterName")(TParseTree("", false,[], s));
        }
    }
    static string FilterName(GetName g)
    {
        return "JinjaTemplate.FilterName";
    }

    static TParseTree FilterStart(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("|"), Spacing), "JinjaTemplate.FilterStart")(p);
        }
        else
        {
            if (auto m = tuple(`FilterStart`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("|"), Spacing), "JinjaTemplate.FilterStart"), "FilterStart")(p);
                memo[tuple(`FilterStart`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree FilterStart(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("|"), Spacing), "JinjaTemplate.FilterStart")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("|"), Spacing), "JinjaTemplate.FilterStart"), "FilterStart")(TParseTree("", false,[], s));
        }
    }
    static string FilterStart(GetName g)
    {
        return "JinjaTemplate.FilterStart";
    }

    static TParseTree FilterArgSep(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), "JinjaTemplate.FilterArgSep")(p);
        }
        else
        {
            if (auto m = tuple(`FilterArgSep`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), "JinjaTemplate.FilterArgSep"), "FilterArgSep")(p);
                memo[tuple(`FilterArgSep`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree FilterArgSep(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), "JinjaTemplate.FilterArgSep")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), "JinjaTemplate.FilterArgSep"), "FilterArgSep")(TParseTree("", false,[], s));
        }
    }
    static string FilterArgSep(GetName g)
    {
        return "JinjaTemplate.FilterArgSep";
    }

    static TParseTree FilterArg(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, identifier, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.wrapAround!(Spacing, FilterArgSep, Spacing)), pegged.peg.negLookahead!(pegged.peg.wrapAround!(Spacing, CloseParen, Spacing)), pegged.peg.negLookahead!(pegged.peg.wrapAround!(Spacing, blank, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.any, Spacing)), Spacing))), "JinjaTemplate.FilterArg")(p);
        }
        else
        {
            if (auto m = tuple(`FilterArg`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, identifier, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.wrapAround!(Spacing, FilterArgSep, Spacing)), pegged.peg.negLookahead!(pegged.peg.wrapAround!(Spacing, CloseParen, Spacing)), pegged.peg.negLookahead!(pegged.peg.wrapAround!(Spacing, blank, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.any, Spacing)), Spacing))), "JinjaTemplate.FilterArg"), "FilterArg")(p);
                memo[tuple(`FilterArg`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree FilterArg(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, identifier, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.wrapAround!(Spacing, FilterArgSep, Spacing)), pegged.peg.negLookahead!(pegged.peg.wrapAround!(Spacing, CloseParen, Spacing)), pegged.peg.negLookahead!(pegged.peg.wrapAround!(Spacing, blank, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.any, Spacing)), Spacing))), "JinjaTemplate.FilterArg")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, identifier, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.wrapAround!(Spacing, FilterArgSep, Spacing)), pegged.peg.negLookahead!(pegged.peg.wrapAround!(Spacing, CloseParen, Spacing)), pegged.peg.negLookahead!(pegged.peg.wrapAround!(Spacing, blank, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.any, Spacing)), Spacing))), "JinjaTemplate.FilterArg"), "FilterArg")(TParseTree("", false,[], s));
        }
    }
    static string FilterArg(GetName g)
    {
        return "JinjaTemplate.FilterArg";
    }

    static TParseTree FilterArgs(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, OpenParen, Spacing), pegged.peg.wrapAround!(Spacing, FilterArg, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, FilterArgSep, Spacing), pegged.peg.wrapAround!(Spacing, FilterArg, Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, CloseParen, Spacing)), "JinjaTemplate.FilterArgs")(p);
        }
        else
        {
            if (auto m = tuple(`FilterArgs`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, OpenParen, Spacing), pegged.peg.wrapAround!(Spacing, FilterArg, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, FilterArgSep, Spacing), pegged.peg.wrapAround!(Spacing, FilterArg, Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, CloseParen, Spacing)), "JinjaTemplate.FilterArgs"), "FilterArgs")(p);
                memo[tuple(`FilterArgs`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree FilterArgs(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, OpenParen, Spacing), pegged.peg.wrapAround!(Spacing, FilterArg, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, FilterArgSep, Spacing), pegged.peg.wrapAround!(Spacing, FilterArg, Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, CloseParen, Spacing)), "JinjaTemplate.FilterArgs")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, OpenParen, Spacing), pegged.peg.wrapAround!(Spacing, FilterArg, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, FilterArgSep, Spacing), pegged.peg.wrapAround!(Spacing, FilterArg, Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, CloseParen, Spacing)), "JinjaTemplate.FilterArgs"), "FilterArgs")(TParseTree("", false,[], s));
        }
    }
    static string FilterArgs(GetName g)
    {
        return "JinjaTemplate.FilterArgs";
    }

    static TParseTree Dict(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("{"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Pair, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.wrapAround!(Spacing, Pair, Spacing)), Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}"), Spacing)), "JinjaTemplate.Dict")(p);
        }
        else
        {
            if (auto m = tuple(`Dict`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("{"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Pair, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.wrapAround!(Spacing, Pair, Spacing)), Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}"), Spacing)), "JinjaTemplate.Dict"), "Dict")(p);
                memo[tuple(`Dict`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Dict(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("{"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Pair, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.wrapAround!(Spacing, Pair, Spacing)), Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}"), Spacing)), "JinjaTemplate.Dict")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("{"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Pair, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.wrapAround!(Spacing, Pair, Spacing)), Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("}"), Spacing)), "JinjaTemplate.Dict"), "Dict")(TParseTree("", false,[], s));
        }
    }
    static string Dict(GetName g)
    {
        return "JinjaTemplate.Dict";
    }

    static TParseTree Pair(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":"), Spacing), pegged.peg.wrapAround!(Spacing, Value, Spacing)), "JinjaTemplate.Pair")(p);
        }
        else
        {
            if (auto m = tuple(`Pair`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":"), Spacing), pegged.peg.wrapAround!(Spacing, Value, Spacing)), "JinjaTemplate.Pair"), "Pair")(p);
                memo[tuple(`Pair`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Pair(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":"), Spacing), pegged.peg.wrapAround!(Spacing, Value, Spacing)), "JinjaTemplate.Pair")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":"), Spacing), pegged.peg.wrapAround!(Spacing, Value, Spacing)), "JinjaTemplate.Pair"), "Pair")(TParseTree("", false,[], s));
        }
    }
    static string Pair(GetName g)
    {
        return "JinjaTemplate.Pair";
    }

    static TParseTree Array(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("["), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Value, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.wrapAround!(Spacing, Value, Spacing)), Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("]"), Spacing)), "JinjaTemplate.Array")(p);
        }
        else
        {
            if (auto m = tuple(`Array`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("["), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Value, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.wrapAround!(Spacing, Value, Spacing)), Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("]"), Spacing)), "JinjaTemplate.Array"), "Array")(p);
                memo[tuple(`Array`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Array(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("["), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Value, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.wrapAround!(Spacing, Value, Spacing)), Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("]"), Spacing)), "JinjaTemplate.Array")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("["), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Value, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.wrapAround!(Spacing, Value, Spacing)), Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("]"), Spacing)), "JinjaTemplate.Array"), "Array")(TParseTree("", false,[], s));
        }
    }
    static string Array(GetName g)
    {
        return "JinjaTemplate.Array";
    }

    static TParseTree Value(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, Dict, Spacing), pegged.peg.wrapAround!(Spacing, Array, Spacing), pegged.peg.wrapAround!(Spacing, True, Spacing), pegged.peg.wrapAround!(Spacing, False, Spacing), pegged.peg.wrapAround!(Spacing, Null, Spacing)), "JinjaTemplate.Value")(p);
        }
        else
        {
            if (auto m = tuple(`Value`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, Dict, Spacing), pegged.peg.wrapAround!(Spacing, Array, Spacing), pegged.peg.wrapAround!(Spacing, True, Spacing), pegged.peg.wrapAround!(Spacing, False, Spacing), pegged.peg.wrapAround!(Spacing, Null, Spacing)), "JinjaTemplate.Value"), "Value")(p);
                memo[tuple(`Value`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Value(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, Dict, Spacing), pegged.peg.wrapAround!(Spacing, Array, Spacing), pegged.peg.wrapAround!(Spacing, True, Spacing), pegged.peg.wrapAround!(Spacing, False, Spacing), pegged.peg.wrapAround!(Spacing, Null, Spacing)), "JinjaTemplate.Value")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, Dict, Spacing), pegged.peg.wrapAround!(Spacing, Array, Spacing), pegged.peg.wrapAround!(Spacing, True, Spacing), pegged.peg.wrapAround!(Spacing, False, Spacing), pegged.peg.wrapAround!(Spacing, Null, Spacing)), "JinjaTemplate.Value"), "Value")(TParseTree("", false,[], s));
        }
    }
    static string Value(GetName g)
    {
        return "JinjaTemplate.Value";
    }

    static TParseTree True(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("true"), "JinjaTemplate.True")(p);
        }
        else
        {
            if (auto m = tuple(`True`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.literal!("true"), "JinjaTemplate.True"), "True")(p);
                memo[tuple(`True`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree True(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("true"), "JinjaTemplate.True")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.literal!("true"), "JinjaTemplate.True"), "True")(TParseTree("", false,[], s));
        }
    }
    static string True(GetName g)
    {
        return "JinjaTemplate.True";
    }

    static TParseTree False(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("false"), "JinjaTemplate.False")(p);
        }
        else
        {
            if (auto m = tuple(`False`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.literal!("false"), "JinjaTemplate.False"), "False")(p);
                memo[tuple(`False`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree False(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("false"), "JinjaTemplate.False")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.literal!("false"), "JinjaTemplate.False"), "False")(TParseTree("", false,[], s));
        }
    }
    static string False(GetName g)
    {
        return "JinjaTemplate.False";
    }

    static TParseTree Null(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("null"), "JinjaTemplate.Null")(p);
        }
        else
        {
            if (auto m = tuple(`Null`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.literal!("null"), "JinjaTemplate.Null"), "Null")(p);
                memo[tuple(`Null`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Null(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("null"), "JinjaTemplate.Null")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.literal!("null"), "JinjaTemplate.Null"), "Null")(TParseTree("", false,[], s));
        }
    }
    static string Null(GetName g)
    {
        return "JinjaTemplate.Null";
    }

    static TParseTree opCall(TParseTree p)
    {
        TParseTree result = decimateTree(Template(p));
        result.children = [result];
        result.name = "JinjaTemplate";
        return result;
    }

    static TParseTree opCall(string input)
    {
        if(__ctfe)
        {
            return JinjaTemplate(TParseTree(``, false, [], input, 0, 0));
        }
        else
        {
            forgetMemo();
            return JinjaTemplate(TParseTree(``, false, [], input, 0, 0));
        }
    }
    static string opCall(GetName g)
    {
        return "JinjaTemplate";
    }


    static void forgetMemo()
    {
        memo = null;
    }
    }
}

alias GenericJinjaTemplate!(ParseTree).JinjaTemplate JinjaTemplate;

