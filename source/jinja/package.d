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
        JinjaData jd;
        jd.data = data;
        return parse(settings, parsedTmpl, jd);
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
        JinjaData jd;
        jd.data = data;
        return parse(settings_, parsedTmpl, jd);
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

    auto tmpl6 = `{% set name = "AAA"|capitalize %}Hello {{ name }}!`;
    auto expect6 = "Hello Aaa!";
    JSONValue data6;
    assert(view.render(tmpl6, data6) == expect6, view.render(tmpl6, data6));

    auto tmpl7 = `{% if name == "AAA" %}It is AAA{% elif name == "BBB" %}It is BBB{% else %}{% if check %}Nested AA{% else %}Nested Else{% endif %}{% endif %}`;
    auto expect7If = `It is AAA`;
    auto expect7Elif = `It is BBB`;
    auto expect7ElseIf = `Nested AA`;
    auto expect7ElseElse = `Nested Else`;
    JSONValue data7;
    data7["name"] = "AAA";
    assert(view.render(tmpl7, data7) == expect7If, view.render(tmpl7, data7));

    data7["name"] = "BBB";
    assert(view.render(tmpl7, data7) == expect7Elif, view.render(tmpl7, data7));

    data7["name"] = "CCC";
    data7["check"] = true;
    assert(view.render(tmpl7, data7) == expect7ElseIf, view.render(tmpl7, data7));

    data7["check"] = false;
    assert(view.render(tmpl7, data7) == expect7ElseElse, view.render(tmpl7, data7));
}
