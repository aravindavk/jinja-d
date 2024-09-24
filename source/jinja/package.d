module jinja;

import std.file;
import std.path;
import std.json;
import std.string;
import std.typecons;

import pegged.grammar;

import jinja.parser;
import jinja.filters;

enum MissingKey
{
    empty,
    passThrough,
    error
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

    JinjaData updated(JSONValue extraData)
    {
        auto _data = data.deepCopy;
        foreach(k, v; extraData.object)
            _data[k] = v;

        return JinjaData(_data);
    }
}

alias Filter = Tuple!(string, "name", string[], "args");

class Jinja
{
    JinjaSettings settings;

    this(JinjaSettings settings = JinjaSettings.init)
    {
        this.settings = settings;
    }

    private string interpolationParser(ParseTree parsedTmpl, JinjaData data)
    {
        string expression;
        Filter[] filters;

        foreach(child; parsedTmpl.children)
        {
            if (child.name == "JinjaTemplate.Expression")
                expression = child.matches[0];
            else if (child.name == "JinjaTemplate.Filter")
            {
                // Example of a Filter with Args
                // +-JinjaTemplate.Filter[16, 33]["|", "default", "(", "\"ABCD\"", ")"]
                //   |  +-JinjaTemplate.FilterStart[16, 17]["|"]
                //   |  +-JinjaTemplate.FilterName[17, 24]["default"]
                //   |  +-JinjaTemplate.FilterArgs[24, 32]["(", "\"ABCD\"", ")"]
                //     |     +-JinjaTemplate.OpenParen[24, 25]["("]
                //     |     +-JinjaTemplate.FilterArg[25, 31]["\"ABCD\""]
                //     |     +-JinjaTemplate.CloseParen[31, 32][")"]
                Filter f;
                // children[1] is FilterName
                foreach(filterChild; child.children)
                {
                    if (filterChild.name == "JinjaTemplate.FilterName")
                        f.name = filterChild.matches[0];
                    else if (filterChild.name == "JinjaTemplate.FilterArgs")
                    {
                        foreach(argChild; filterChild.children)
                        {
                            if (argChild.name == "JinjaTemplate.FilterArg")
                                f.args ~= argChild.matches[0];
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

    private string parse(ParseTree parsedTmpl, JinjaData data)
    {
        switch(parsedTmpl.name)
        {
        case "JinjaTemplate":
            return parse(parsedTmpl.children[0], data);
        case "JinjaTemplate.Template":
            string result = "";
            foreach(child; parsedTmpl.children)
                result ~= parse(child, data);
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
            return interpolationParser(parsedTmpl, data);
        default:
            return "";
        }
    }

    string render(string tmpl, JSONValue data = JSONValue())
    {
        auto parsedTmpl = JinjaTemplate(tmpl);
        return parse(parsedTmpl, JinjaData(data));
    }

    string renderFile(string fileName, JSONValue data = JSONValue())
    {
        auto tmpl = readText(buildPath(settings.viewsDirectory, fileName));
        return render(tmpl, data);
    }
}

unittest
{
    auto view = new Jinja;
    assert(view.render("Hello World!") == "Hello World!", view.render("Hello World!"));
    assert(view.render("Hello World!{# This is comment #}") == "Hello World!");
    auto tmpl1 = `Hello World!
{% raw %}
{# this is comment #}
{{ name }}
{% endraw %}
After Raw.
`;

    auto expect1 = `Hello World!
{# this is comment #}
{{ name }}
After Raw.
`;

    assert(view.render(tmpl1) == expect1, view.render(tmpl1));

    auto tmpl2 = `Hello {{ name }}!`;

    auto expect2 = `Hello World!`;

    JSONValue data2;
    data2["name"] = "World";
    assert(view.render(tmpl2, data2) == expect2, view.render(tmpl2, data2));

    auto tmpl3 = `Hello {{ name|capitalize }}!`;

    auto expect3 = `Hello World!`;

    JSONValue data3;
    data3["name"] = "world";
    assert(view.render(tmpl3, data3) == expect3, view.render(tmpl3, data3));

    auto tmpl4 = `Hello {{ unknown|default("ABCD") }}!`;

    auto expect4 = `Hello ABCD!`;

    JSONValue data4;
    assert(view.render(tmpl4, data4) == expect4, view.render(tmpl4, data4));
}
