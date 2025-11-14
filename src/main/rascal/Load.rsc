module Load

import Syntax;
import AST;
import Parse;
import ParseTree;

AST::Program implode(Syntax::Program p)
  = implode(#AST::Program, p);

public AST::Program load(str s) = implode(parse(s));
public AST::Program load(loc l) = implode(parse(l));
