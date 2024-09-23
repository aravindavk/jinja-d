module jinja.parser;

import pegged.grammar;
import pegged.examples.strings;
import pegged.examples.numbers;

enum jinjaTemplateGrammer = `
JinjaTemplate:
  Template           <- Text+
  Text               <- (!OpenInterpolation !OpenStatement !OpenComment .)+
  OpenInterpolation  <- "{{"
  CloseInterpolation <- "}}"
  OpenStatement      <- "{%"
  CloseStatement     <- "%}"
  OpenComment        <- "{#"
  CloseComment       <- "#}"
`;

mixin(grammar(jinjaTemplateGrammer));

unittest
{
    auto tmpl = JinjaTemplate("Hello World!");
    assert(tmpl.toString == `JinjaTemplate[0, 12]["H", "e", "l", "l", "o", " ", "W", "o", "r", "l", "d", "!"]
 +-JinjaTemplate.Template[0, 12]["H", "e", "l", "l", "o", " ", "W", "o", "r", "l", "d", "!"]
    +-JinjaTemplate.Text[0, 12]["H", "e", "l", "l", "o", " ", "W", "o", "r", "l", "d", "!"]
`);
}
