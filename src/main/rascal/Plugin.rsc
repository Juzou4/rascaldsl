module Plugin

import IO;
import ParseTree;
import util::Reflective;
import util::IDEServices;
import util::LanguageServer;
import Relation;
import Syntax;
import Checker;

PathConfig pcfg = getProjectPathConfig(|project://rascaldsl|);
Language tdslLang = language(pcfg, "ALU", "alu", "Plugin", "contribs");

Summary aluSummarizer(loc l, start[Program] input) {
  tm   = aluTModelFromTree(input);
  defs = getUseDef(tm);  // todavía no manejamos def/use

  return summary(
    l,
    messages   = { <m.at, m> | m <- getMessages(tm), !(m is info) },
    definitions = defs
  );
}

set[LanguageService] contribs() = {
parser(start[Program] (str program, loc src) {
return parse(#start[Program], program, src);
}),
    summarizer(aluSummarizer)
};

void main() {
registerLanguage(tdslLang);
}
