import std.stdio;

import std.json;

import jinja;

JSONValue preparedData()
{
    JSONValue data;
    data["name"] = "hello";
    data["value"] = "Hello World from the compile time created function!";
    return data;
}

void main(string[] args)
{
    auto tmpl = `Hello {{ name1|default("\"ABCD\"") }}!`;
    JSONValue data;
    data["name"] = "World";
    Jinja view;
    writeln(view.render(tmpl, data));

    enum data1 = preparedData;
    enum funcTmpl = `
void {{ name }}()
{
    writeln("{{ value }}");
}
`;
    mixin(Jinja.renderString(funcTmpl, data1));
    // Call the function that is defined in the previous line
    hello;

    if (args.length == 3)
    {
        auto tmpl2 = args[1];
        auto data2 = parseJSON(args[2]);
        
        writeln(view.render(tmpl2, data2));
    }
}
