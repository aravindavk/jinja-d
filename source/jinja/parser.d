module jinja.parser;

import pegged.grammar;
import pegged.examples.strings;
import pegged.examples.numbers;

enum jinjaTemplateGrammer = `
JinjaTemplate:
  Template           <- (Text / Comment / RawStatement / Interpolation)+
  Text               <~ (!(OpenInterpolation / OpenStatement / OpenComment) .)+
  Comment            <- OpenComment (!CloseComment .)+ CloseComment
  RawStatement       <- OpenRaw RawText CloseRaw
  RawText            <~ blank* (!CloseRaw .)+ blank*
  OpenRaw            < OpenStatement "raw" CloseStatement
  CloseRaw           < OpenStatement "endraw" CloseStatement
  OpenInterpolation  <- "{{"
  CloseInterpolation <- "}}"
  OpenStatement      <- "{%"
  CloseStatement     <- "%}"
  OpenComment        <- "{#"
  CloseComment       <- "#}"
  OpenParen          <- "("
  CloseParen         <- ")"
  Interpolation      <  OpenInterpolation Expression Filter* CloseInterpolation
  Expression         <~ String / identifier / Number
  Number             <- [0-9]+
  Filter             <- FilterStart FilterName FilterArgs*
  FilterName         <- identifier
  FilterStart        <- "|"
  FilterArgSep       <- ","
  FilterArg          <- String / Number / identifier / (!FilterArgSep !CloseParen !blank .)+
  FilterArgs         <- OpenParen FilterArg (FilterArgSep FilterArg)* CloseParen
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

