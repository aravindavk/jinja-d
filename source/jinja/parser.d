module jinja.parser;

import pegged.grammar;
import pegged.examples.strings;
import pegged.examples.numbers;

enum jinjaTemplateGrammer = `
JinjaTemplate:
  Template           <- (Text / Comment)+
  Text               <~ (!(OpenInterpolation / OpenStatement / OpenComment) .)+
  Comment            <- OpenComment (!CloseComment .)+ CloseComment
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
    assert(tmpl.toString == `JinjaTemplate[0, 12]["Hello World!"]
 +-JinjaTemplate.Template[0, 12]["Hello World!"]
    +-JinjaTemplate.Text[0, 12]["Hello World!"]
`);
}
