module jinja;

import std.file;
import std.path;

import pegged.grammar;
import jinja.parser;

struct JinjaSettings
{
    string viewsDirectory = "views";
}

class Jinja
{
    JinjaSettings settings;

    this(JinjaSettings settings = JinjaSettings.init)
    {
        this.settings = settings;
    }

    private string parse(ParseTree parsedTmpl)
    {
        switch(parsedTmpl.name)
        {
        case "JinjaTemplate":
            return parse(parsedTmpl.children[0]);
        case "JinjaTemplate.Template":
            string result = "";
            foreach(child; parsedTmpl.children)
                result ~= parse(child);
            return result;
        case "JinjaTemplate.Text":
            return parsedTmpl.matches[0];
        case "JinjaTemplate.Comment":
            return "";
        default:
            return "";
        }
    }

    string render(string tmpl)
    {
        auto parsedTmpl = JinjaTemplate(tmpl);
        return parse(parsedTmpl);
    }

    string renderFile(string fileName)
    {
        auto tmpl = readText(buildPath(settings.viewsDirectory, fileName));
        return render(tmpl);
    }
}

unittest
{
    auto view = new Jinja;
    assert(view.render("Hello World!") == "Hello World!", view.render("Hello World!"));
    assert(view.render("Hello World!{# This is comment #}") == "Hello World!");
}
