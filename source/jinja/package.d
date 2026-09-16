module jinja;

import std.file;
import std.path;
import std.json;
import std.string;

import jinja.helpers;
import jinja.filters;
import jinja.parser;

struct Jinja
{
    JinjaSettings settings;
    string tmpl_;

    Jinja fromString(string input)
    {
        return templateFromString(input, onMissingKey: settings.onMissingKey);
    }

    Jinja fromFile(string path)
    {
        return templateFromFile(path, onMissingKey: settings.onMissingKey,
                                viewsDirectory: settings.viewsDirectory);
    }
}

void registerJinjaFilter(string name, FilterFunction func)
{
    _registeredFilters[name] = func;
}

string render(Args...)(ref Jinja view, JSONValue data = JSONValue())
{
    return render!(Args)(view, view.tmpl_, data);
}

string render(Args...)(ref Jinja view, string tmpl, JSONValue data = JSONValue())
{
    static if (Args.length > 0)
        data = dataFromArgs!(Args);

    auto parsedTmpl = JinjaTemplate(tmpl);
    version (ShowParsedTree)
    {
        import std.stdio;
        writeln(parsedTmpl);
    }
    JinjaData jd;
    jd.data = data;
    return parse(view.settings, parsedTmpl, jd);
}

string renderFile(Args...)(ref Jinja view, string fileName, JSONValue data = JSONValue())
{
    auto tmpl = readText(buildPath(view.settings.viewsDirectory, fileName));
    return render!(Args)(view, tmpl, data);
}

string renderString(Args...)(ref Jinja view, string tmpl, JSONValue data = JSONValue())
{
    return render!(Args)(view, tmpl, data);
}

Jinja templateFromString(string input, MissingKey onMissingKey = MissingKey.init)
{
    Jinja view;
    view.settings.onMissingKey = onMissingKey;
    view.tmpl_ = input;
    return view;
}

Jinja templateFromFile(string path, MissingKey onMissingKey = MissingKey.init, string viewsDirectory = defaultViewsDir)
{
    Jinja view;
    view.settings.onMissingKey = onMissingKey;
    view.settings.viewsDirectory = viewsDirectory; 
    view.tmpl_ = readText(buildPath(view.settings.viewsDirectory, path));
    return view;
}

string renderString(string input, JSONValue data = JSONValue(), MissingKey onMissingKey = MissingKey.init)
{
    Jinja tmpl;
    tmpl.settings.onMissingKey = onMissingKey;
    return tmpl.renderString(input, data);
}

string renderFile(string path, JSONValue data = JSONValue(), MissingKey onMissingKey = MissingKey.init, string viewsDirectory = defaultViewsDir)
{
    Jinja tmpl;
    tmpl.settings.onMissingKey = onMissingKey;
    tmpl.settings.viewsDirectory = viewsDirectory; 
    return tmpl.renderFile(path, data);
}

JSONValue dataFromArgs(Args...)()
{
    JSONValue data;
    static foreach (Arg; Args)
        data[__traits(identifier, Arg)] = Arg;

    return data;
}

string renderString(Args...)(string input, JSONValue data = JSONValue(), MissingKey onMissingKey = MissingKey.init)
{
    return renderString(input, dataFromArgs!(Args), onMissingKey: onMissingKey);
}

string renderFile(Args...)(string path, JSONValue data = JSONValue(), MissingKey onMissingKey = MissingKey.init, string viewsDirectory = defaultViewsDir)
{
    return renderFile(path, dataFromArgs!(Args), onMissingKey: onMissingKey, viewsDirectory: viewsDirectory);
}

unittest
{
    import std.exception;

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

    string name = "JINJA";
    JSONValue data1;
    data1["name"] = name;

    assert(renderString("Hello World!") == "Hello World!");
    assert(renderString("Hello World!{# This is comment #}") == "Hello World!");
    assert(renderString(tmpl1) == expect1, renderString(tmpl1));
    assert(renderString!(name)("Hello {{ name }}!") == "Hello JINJA!");
    assert(renderString("Hello {{ name }}!", data1) == "Hello JINJA!");

    // onMissingkey = EMPTY
    assert(renderString!(name)("Hello {{ name1 }}!") == "Hello !");
    assert(renderString!(name)("Hello {{ name1 }}!", onMissingKey: MissingKey.empty) == "Hello !");
    assert(renderString("Hello {{ name1 }}!", data1) == "Hello !");
    assert(renderString("Hello {{ name1 }}!", data1, onMissingKey: MissingKey.empty) == "Hello !");

    // onMissingkey = PASSTHROUGH
    assert(renderString!(name)("Hello {{ name1 }}!", onMissingKey: MissingKey.passThrough) == "Hello {{ name1 }}!");
    assert(renderString("Hello {{ name1 }}!", data1, onMissingKey: MissingKey.passThrough) == "Hello {{ name1 }}!");

    // onMissingkey == ERROR
    assertThrown!JinjaException(renderString!(name)("Hello {{ name1 }}!", onMissingKey: MissingKey.error));
    assertThrown!JinjaException(renderString("Hello {{ name1 }}!", data1, onMissingKey: MissingKey.error));

    Jinja view;
    assert(view.renderString("Hello World!") == "Hello World!");
    assert(view.renderString("Hello World!{# This is comment #}") == "Hello World!");
    assert(view.renderString(tmpl1) == expect1, renderString(tmpl1));
    assert(view.renderString!(name)("Hello {{ name }}!") == "Hello JINJA!");
    assert(view.renderString("Hello {{ name }}!", data1) == "Hello JINJA!");

    // onMissingkey = EMPTY
    assert(view.renderString!(name)("Hello {{ name1 }}!") == "Hello !");
    assert(view.renderString("Hello {{ name1 }}!", data1) == "Hello !");

    view.settings.onMissingKey = MissingKey.empty;
    assert(view.renderString!(name)("Hello {{ name1 }}!") == "Hello !");
    assert(view.renderString("Hello {{ name1 }}!", data1) == "Hello !");

    // onMissingkey = PASSTHROUGH
    view.settings.onMissingKey = MissingKey.passThrough;
    assert(view.renderString!(name)("Hello {{ name1 }}!") == "Hello {{ name1 }}!");
    assert(view.renderString("Hello {{ name1 }}!", data1) == "Hello {{ name1 }}!");

    // onMissingkey == ERROR
    view.settings.onMissingKey = MissingKey.error;
    assertThrown!JinjaException(view.renderString!(name)("Hello {{ name1 }}!"));
    assertThrown!JinjaException(view.renderString("Hello {{ name1 }}!", data1));

    // view.render tests
    Jinja view1;
    assert(view1.render("Hello World!") == "Hello World!");
    assert(view1.render("Hello World!{# This is comment #}") == "Hello World!");
    assert(view1.render(tmpl1) == expect1, renderString(tmpl1));
    assert(view1.render!(name)("Hello {{ name }}!") == "Hello JINJA!");
    assert(view1.render("Hello {{ name }}!", data1) == "Hello JINJA!");

    // onMissingkey = EMPTY
    assert(view1.render!(name)("Hello {{ name1 }}!") == "Hello !");
    assert(view1.render("Hello {{ name1 }}!", data1) == "Hello !");

    view1.settings.onMissingKey = MissingKey.empty;
    assert(view1.render!(name)("Hello {{ name1 }}!") == "Hello !");
    assert(view1.render("Hello {{ name1 }}!", data1) == "Hello !");

    // onMissingkey = PASSTHROUGH
    view1.settings.onMissingKey = MissingKey.passThrough;
    assert(view1.render!(name)("Hello {{ name1 }}!") == "Hello {{ name1 }}!");
    assert(view1.render("Hello {{ name1 }}!", data1) == "Hello {{ name1 }}!");

    // onMissingkey == ERROR
    view1.settings.onMissingKey = MissingKey.error;
    assertThrown!JinjaException(view1.render!(name)("Hello {{ name1 }}!"));
    assertThrown!JinjaException(view1.render("Hello {{ name1 }}!", data1));

    // templateFromString tests
    auto t1 = templateFromString("Hello World!");
    auto t2 = templateFromString("Hello {{ name }}!");
    auto t3 = templateFromString("Hello {{ name1 }}!");
    auto t4 = templateFromString("Hello {{ name1 }}!", onMissingKey: MissingKey.empty);
    auto t5 = templateFromString("Hello {{ name1 }}!", onMissingKey: MissingKey.passThrough);
    auto t6 = templateFromString("Hello {{ name1 }}!", onMissingKey: MissingKey.error);

    assert(t1.render == "Hello World!");
    assert(t2.render!(name) == "Hello JINJA!");
    assert(t2.render(data1) == "Hello JINJA!");

    // onMissingkey = EMPTY
    assert(t3.render!(name) == "Hello !");
    assert(t3.render(data1) == "Hello !");

    assert(t4.render!(name) == "Hello !");
    assert(t4.render(data1) == "Hello !");

    // onMissingkey = PASSTHROUGH
    assert(t5.render!(name) == "Hello {{ name1 }}!");
    assert(t5.render(data1) == "Hello {{ name1 }}!");

    // onMissingkey == ERROR
    assertThrown!JinjaException(t6.render!(name));
    assertThrown!JinjaException(t6.render(data1));

    // Using Filter -----------------------------
    auto tmpl3 = `Hello {{ name|capitalize }}!`;

    auto expect3 = `Hello Jinja!`;

    JSONValue data3;
    data3["name"] = "jinja";
    assert(renderString(tmpl3, data3) == expect3);

    // Unknown key, default value
    auto tmpl5 = `Hello {{ unknown|default(100) }}!`;
    auto expect5 = `Hello 100!`;

    JSONValue data5;
    assert(renderString(tmpl5, data5) == expect5, renderString(tmpl5, data5));

    auto tmpl4 = `Hello {{ unknown|default("ABCD") }}!`;
    auto expect4 = `Hello ABCD!`;
    JSONValue data4;
    assert(renderString(tmpl4, data4) == expect4, renderString(tmpl4, data4));

    // Set variable and filter ------------------------------------
    auto tmpl6 = `{% set name = "AAA"|capitalize %}Hello {{ name }}!`;
    auto expect6 = "Hello Aaa!";
    JSONValue data6;
    assert(renderString(tmpl6, data6) == expect6, renderString(tmpl6, data6));

    // If conditions -------------------------------------------------
    auto tmpl7 = `{% if name == "AAA" %}It is AAA{% elif name == "BBB" %}It is BBB{% else %}{% if check %}Nested AA{% else %}Nested Else{% endif %}{% endif %}`;
    auto expect7If = `It is AAA`;
    auto expect7Elif = `It is BBB`;
    auto expect7ElseIf = `Nested AA`;
    auto expect7ElseElse = `Nested Else`;
    JSONValue data7;
    data7["name"] = "AAA";
    assert(renderString(tmpl7, data7) == expect7If, renderString(tmpl7, data7));

    data7["name"] = "BBB";
    assert(renderString(tmpl7, data7) == expect7Elif, renderString(tmpl7, data7));

    data7["name"] = "CCC";
    data7["check"] = true;
    assert(renderString(tmpl7, data7) == expect7ElseIf, renderString(tmpl7, data7));

    data7["check"] = false;
    assert(renderString(tmpl7, data7) == expect7ElseElse, renderString(tmpl7, data7));

    // For loop ----------------------------------------------
    auto tmpl8 = `{% for name in names %}Hello {{ name|upper }}{% endfor %}`;
    auto expect8 = "Hello AHello BHello C";
    JSONValue data8;
    data8["names"] = JSONValue(["a", "b", "c"]);
    assert(renderString(tmpl8, data8) == expect8, renderString(tmpl8, data8));
}
