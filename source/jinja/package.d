module jinja;

import std.file;
import std.path;
import std.json;
import std.string;

import jinja.helpers;
import jinja.filters;
import jinja.parser;

class Jinja
{
    JinjaSettings settings;

    this(JinjaSettings settings = JinjaSettings.init)
    {
        this.settings = settings;
    }
    
    string render(string tmpl, JSONValue data = JSONValue())
    {
        auto parsedTmpl = JinjaTemplate(tmpl);
        version (ShowParsedTree)
        {
            import std.stdio;
            writeln(parsedTmpl);
        }
        return parse(settings, parsedTmpl, JinjaData(data));
    }

    string renderFile(string fileName, JSONValue data = JSONValue())
    {
        auto tmpl = readText(buildPath(settings.viewsDirectory, fileName));
        return render(tmpl, data);
    }

    static void registerFilter(string name, FilterFunction func)
    {
        _registeredFilters[name] = func;
    }

    static renderString(string tmpl, JSONValue data = JSONValue())
    {
        auto parsedTmpl = JinjaTemplate(tmpl);
        JinjaSettings settings_;
        return parse(settings_, parsedTmpl, JinjaData(data));
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

    auto tmpl5 = `Hello {{ unknown|default(100) }}!`;

    auto expect5 = `Hello 100!`;

    JSONValue data5;
    auto view2 = new Jinja;
    assert(view2.render(tmpl5, data5) == expect5, view2.render(tmpl5, data5));

    auto tmpl4 = `Hello {{ unknown|default("ABCD") }}!`;
    auto expect4 = `Hello ABCD!`;
    JSONValue data4;
    assert(view.render(tmpl4, data4) == expect4, view.render(tmpl4, data4));
}
