module jinja;

import std.file;
import std.path;
import std.json;
import std.string;

import pegged.grammar;
import jinja.parser;

enum MissingKey
{
    empty,
    passThrough,
    error
}

struct JinjaSettings
{
    string viewsDirectory = "views";
    MissingKey onMissingKey = MissingKey.passThrough;
}

class JinjaException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}

struct JinjaData
{
    JSONValue data;

    JSONValue get(string name, JSONValue scopeData = JSONValue())
    {
        auto _data = data;
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
        if (name in _data)
            return _data[name];

        // Null value
        return JSONValue();
    }
}

class Jinja
{
    JinjaSettings settings;

    this(JinjaSettings settings = JinjaSettings.init)
    {
        this.settings = settings;
    }

    private string parse(ParseTree parsedTmpl, JinjaData data)
    {
        import std.stdio;
        writeln(parsedTmpl);

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
            string expression;
            foreach(child; parsedTmpl.children)
            {
                if (child.name == "JinjaTemplate.Expression")
                    expression = child.matches[0];
            }
            auto expressionValue = data.get(expression);
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
}
