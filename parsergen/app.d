import std.file;

import pegged.grammar;

int main()
{
    auto header = "import pegged.examples.strings;\nimport pegged.examples.numbers;";
    auto jinjaGrammer = readText("parsergen/jinja.pegged");
    asModule("jinja.parser", "source/jinja/parser", jinjaGrammer, header);
    return 0;
}
