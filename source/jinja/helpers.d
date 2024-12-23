module jinja.helpers;

debug {import std.stdio;}

import std.json;
import std.string;

import pegged.grammar;

import jinja.filters;

enum MissingKey
{
    empty,
    passThrough,
    error
}

struct JinjaFilter
{
    string name;
    string[] args;
}

struct JinjaSettings
{
    string viewsDirectory = "views";
    MissingKey onMissingKey = MissingKey.empty;
}

class JinjaException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}

JSONValue deepCopy(ref JSONValue val)
{
    JSONValue newVal;
    switch(val.type)
    {
    case JSONType.string:
        newVal = JSONValue(val.str.idup);
        break;
    case JSONType.object:
        foreach (string key, value; val)
        {
            newVal[key] = value.deepCopy;
        }
        break;
    case JSONType.array:
        newVal = JSONValue.emptyArray;
        foreach (size_t index, value; val)
            newVal.array ~= value.deepCopy;

        break;
    default:
        newVal = val;
    }
    return newVal;
}

struct JinjaData
{
    JSONValue data;

    JSONValue get(string name, JSONValue scopeData = JSONValue())
    {
        auto nameValue = sanitizeValue(name, true);
        if (!nameValue.isNull)
            return nameValue;

        JSONValue _data = data.deepCopy;

        // When extra data is passed that takes the precedence
        if (!scopeData.isNull)
        {
            foreach(k, v; scopeData.object)
                _data[k] = v;
        }

        // When name specified as key.name, color.name, font.size etc
        auto nameParts = name.split(".");
        if (nameParts.length > 1)
        {
            JSONValue v = (nameParts[0] in _data) ? _data[nameParts[0]] : JSONValue();
            foreach(np; nameParts[1..$])
            {
                if (np in v)
                    v = v[np];
                else
                    v = null;
            }
            return v;
        }

        // Regular key name lookup
        if (!_data.isNull)
        {
            if (name in _data)
                return _data[name];
        }
 
        // Null value
        return JSONValue();
    }

    void set(string key, JSONValue value)
    {
        data[key] = value;
    }

    JinjaData updated(JSONValue extraData)
    {
        auto _data = data.deepCopy;
        foreach(k, v; extraData.object)
            _data[k] = v;

        return JinjaData(_data);
    }
}

// TODO: Check the previous expression value and the operator to find the new value
JSONValue applyOperator(string operator, JSONValue value1, JSONValue value2)
{
    switch(operator)
    {
    case "==":
        return JSONValue(value1 == value2);
    default:
        return value2;
    }
}

JSONValue expressionParser(JinjaSettings settings, ParseTree parsedTmpl, ref JinjaData data, JSONValue prevExpressionValue = JSONValue())
{
    string expression;
    string operator;
    JinjaFilter[] filters;

    foreach(child; parsedTmpl.children)
    {
        if (child.name == "JinjaTemplate.ExpressionOperator")
            operator = child.matches[0];
        else if (child.name == "JinjaTemplate.ExpressionPart")
            expression = child.matches[0];
        else if (child.name == "JinjaTemplate.Filter")
        {
            JinjaFilter f;
            foreach(filterChild; child.children)
            {
                if (filterChild.name == "JinjaTemplate.FilterName")
                    f.name = filterChild.matches[0];
                else if (filterChild.name == "JinjaTemplate.FilterArgs")
                {
                    foreach(argChild; filterChild.children)
                    {
                        if (argChild.name == "JinjaTemplate.FilterArg")
                            f.args ~= argChild.matches.join;
                    }
                }
            }
            filters ~= f;
        }
    }

    auto expressionValue = data.get(expression);
    foreach(filter; filters)
    {
        // TODO: Handle filter exists and call error
        expressionValue = _registeredFilters[filter.name](expressionValue, filter.args);
    }

    return applyOperator(operator, prevExpressionValue, expressionValue);
}

string interpolationParser(JinjaSettings settings, ParseTree parsedTmpl, ref JinjaData data)
{
    JSONValue expressionValue;
    string fullExpression;
    JinjaFilter[] filters;

    foreach(child; parsedTmpl.children)
    {
        if (child.name == "JinjaTemplate.Expression")
        {
            fullExpression = child.matches.join;
            foreach(expChild; child.children)
            {
                if (expChild.name == "JinjaTemplate.ExpressionLhs")
                    expressionValue = expressionParser(settings, expChild, data);
                else if (expChild.name == "JinjaTemplate.ExpressionRhs")
                    expressionValue = expressionParser(settings, expChild, data, expressionValue);
            }
        }
    }

    if (expressionValue.isNull)
    {
        if (settings.onMissingKey == MissingKey.empty)
            return "";
        else if (settings.onMissingKey == MissingKey.passThrough)
            return parsedTmpl.matches.join;
        else
            throw new JinjaException(fullExpression ~ " not found in the data");
    }
    return expressionValue.str;
}

string setStatementParser(JinjaSettings settings, ParseTree parsedTmpl, ref JinjaData data)
{
    string variable;
    JSONValue expressionValue;
    JinjaFilter[] filters;

    foreach(child; parsedTmpl.children)
    {
        if (child.name == "JinjaTemplate.Variable")
            variable = child.matches[0];
        else if (child.name == "JinjaTemplate.Expression")
        {
            foreach(expChild; child.children)
            {
                if (expChild.name == "JinjaTemplate.ExpressionLhs")
                    expressionValue = expressionParser(settings, expChild, data);
            }
        }
    }

    data.set(variable, expressionValue);
    return "";
}

bool ifStatementParser(JinjaSettings settings, ParseTree parsedTmpl, ref JinjaData data)
{
    JSONValue expressionValue;
    foreach(ifChild; parsedTmpl.children)
    {
        if (ifChild.name == "JinjaTemplate.IfExpression")
        {
            foreach(expChild; ifChild.children)
            {
                if (expChild.name == "JinjaTemplate.Expression")
                {
                    foreach(exp; expChild.children)
                    {
                        if (exp.name == "JinjaTemplate.ExpressionLhs")
                            expressionValue = expressionParser(settings, exp, data);
                        else if (exp.name == "JinjaTemplate.ExpressionRhs")
                            expressionValue = expressionParser(settings, exp, data, expressionValue);
                    }   
                }
            }
        }
    }

    if (!expressionValue.isNull && expressionValue == JSONValue(true))
        return true;

    return false;
}

string elseStatementParser(JinjaSettings settings, ParseTree parsedTmpl, ref JinjaData data)
{
    foreach(elseChild; parsedTmpl.children)
    {
        if (elseChild.name == "JinjaTemplate.Template")
        {
            return parse(settings, elseChild, data);
        }
    }
    return "";
}

string ifElseStatementParser(JinjaSettings settings, ParseTree parsedTmpl, ref JinjaData data)
{
    auto conditionOk = false;

    foreach(child; parsedTmpl.children)
    {
        if (child.name == "JinjaTemplate.OpenIf")
        {
            conditionOk = ifStatementParser(settings, child, data);
        }
        else if (child.name == "JinjaTemplate.Template")
        {
            if (conditionOk)
                return parse(settings, child, data);
        }
        else if (child.name == "JinjaTemplate.ElifStatement" && !conditionOk)
        {
            foreach(elifChild; child.children)
            {
                if (elifChild.name == "JinjaTemplate.OpenElif")
                    conditionOk = ifStatementParser(settings, elifChild, data);
                else if (elifChild.name == "JinjaTemplate.Template")
                {
                    if (conditionOk)
                        return parse(settings, elifChild, data);
                }
            }
        }
        else if (child.name == "JinjaTemplate.ElseStatement" && !conditionOk)
        {
            return elseStatementParser(settings, child, data);
        }
    }

    return "";
}

string forStatementParser(JinjaSettings settings, ParseTree parsedTmpl, ref JinjaData data)
{
    JSONValue expressionValue;
    string variableName;
    string output;

    foreach(child; parsedTmpl.children)
    {
        if (child.name == "JinjaTemplate.OpenFor")
        {
            foreach(ofChild; child)
            {
                if (ofChild.name == "JinjaTemplate.Variable")
                    variableName = ofChild.matches[0];
                else if (ofChild.name == "JinjaTemplate.Expression")
                    foreach(expChild; ofChild.children)
                    {
                        if (expChild.name == "JinjaTemplate.ExpressionLhs")
                            expressionValue = expressionParser(settings, expChild, data);
                    }
            }
        }
        else if (child.name == "JinjaTemplate.Template")
        {
            // TODO: Handle if expressionValue is not an array
            foreach(loopData; expressionValue.array)
            {
                JSONValue d;
                d[variableName] = loopData;
                auto newData = data.updated(d);
                output ~= parse(settings, child, newData);
            }
        }
    }

    return output;
}

string parse(JinjaSettings settings, ParseTree parsedTmpl, ref JinjaData data)
{
    switch(parsedTmpl.name)
    {
    case "JinjaTemplate":
        return parse(settings, parsedTmpl.children[0], data);
    case "JinjaTemplate.Template":
        string result = "";
        foreach(child; parsedTmpl.children)
            result ~= parse(settings, child, data);
        return result;
    case "JinjaTemplate.Text":
        return parsedTmpl.matches[0];
    case "JinjaTemplate.Comment":
        return "";
    case "JinjaTemplate.RawStatement":
        foreach(child; parsedTmpl.children)
        {
            if (child.name == "JinjaTemplate.RawText")
                return child.matches[0];
        }
        return "";
    case "JinjaTemplate.Interpolation":
        return interpolationParser(settings, parsedTmpl, data);
    case "JinjaTemplate.SetStatement":
        return setStatementParser(settings, parsedTmpl, data);
    case "JinjaTemplate.IfStatement":
        return ifElseStatementParser(settings, parsedTmpl, data);
    case "JinjaTemplate.ForStatement":
        return forStatementParser(settings, parsedTmpl, data);
    default:
        return "";
    }
}
