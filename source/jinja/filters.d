module jinja.filters;

import std.string;
import std.json;

string sanitizeString(string value)
{
    if (value.startsWith("\"") && value.endsWith("\""))
        return value.chompPrefix("\"").chomp("\"");

    return value;
}

JSONValue filterCapitalize(JSONValue value, string[] args)
{
    return JSONValue(value.str.capitalize);
}

JSONValue filterDefault(JSONValue value, string[] args)
{
    if (value.isNull)
        return JSONValue(args[0].sanitizeString);

    return value;
}

alias FilterFunction = JSONValue function(JSONValue, string[]);

FilterFunction[string] _registeredFilters = [
    "capitalize": &filterCapitalize,
    "default": &filterDefault
];
