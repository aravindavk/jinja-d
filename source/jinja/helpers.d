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
        foreach (size_t index, value; val)
        {
            newVal[index] = value.deepCopy;
        }
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

string interpolationParser(JinjaSettings settings, ParseTree parsedTmpl, ref JinjaData data)
{
    string expression;
    JinjaFilter[] filters;

    foreach(child; parsedTmpl.children)
    {
        if (child.name == "JinjaTemplate.Expression")
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
        expressionValue = _registeredFilters[filter.name](expressionValue, filter.args);
    }

    if (expressionValue.isNull)
    {
        if (settings.onMissingKey == MissingKey.empty)
            return "";
        else if (settings.onMissingKey == MissingKey.passThrough)
            return parsedTmpl.matches.join;
        else
            throw new JinjaException(expression ~ " not found in the data");
    }
    return expressionValue.str;
}

string setStatementParser(JinjaSettings settings, ParseTree parsedTmpl, ref JinjaData data)
{
    string variable;
    string expression;
    JinjaFilter[] filters;

    foreach(child; parsedTmpl.children)
    {
        if (child.name == "JinjaTemplate.Variable")
            variable = child.matches[0];
        else if (child.name == "JinjaTemplate.Expression")
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
        expressionValue = _registeredFilters[filter.name](expressionValue, filter.args);
    }

    data.set(variable, expressionValue);
    return "";
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
    default:
        return "";
    }
}


