module jinja.filters;

import std.string;
import std.json;

// If it is not variable (Literal string/number/bool/array/json)
// TODO: Handle Number, bool and other types
JSONValue sanitizeValue(string value, bool nullIfVariable = false)
{
    if (value.startsWith("\"") && value.endsWith("\""))
        return JSONValue(value.chompPrefix("\"").chomp("\""));

    if (nullIfVariable)
        return JSONValue();

    return JSONValue(value);
}

JSONValue filterCapitalize(JSONValue value, string[] args)
{
    return JSONValue(value.str.capitalize);
}

JSONValue filterUppercase(JSONValue value, string[] args)
{
    return JSONValue(value.str.toUpper);
}

JSONValue filterDefault(JSONValue value, string[] args)
{
    if (value.isNull)
        return args[0].sanitizeValue;

    return value;
}

alias FilterFunction = JSONValue function(JSONValue, string[]);

FilterFunction[string] _registeredFilters = [
    "capitalize": &filterCapitalize,
    "upper": &filterUppercase,
    "default": &filterDefault
];
