module Syntax

lexical Ident   = [a-zA-Z][a-zA-Z0-9_]* !>> [a-zA-Z0-9_];
lexical Natural = [0-9]+ !>> [0-9];

keyword KW_COND = "cond";
keyword KW_DO = "do";
keyword KW_DATA      = "data";
keyword KW_ELSIF      = "elsif";
keyword KW_END      = "end";
keyword KW_FOR      = "for";
keyword KW_FROM      = "from";
keyword KW_THEN     = "then";
keyword KW_FUNCTION = "function";
keyword KW_ELSE     = "else";
keyword KW_IF       = "if";
keyword KW_IN         = "in";
keyword KW_ITERATOR       = "iterator";
keyword KW_SEQUENCE       = "sequence";
keyword KW_STRUCT       = "struct";
keyword KW_TO       = "to";
keyword KW_TUPLE       = "tuple";
keyword KW_TYPE       = "type";
keyword KW_WITH       = "with";
keyword KW_WITH       = "yielding";
keyword KW_YIELDING       = "positive";
keyword KW_NEGATIVE       = "negative";
keyword KW_OR       = "or";


lexical LAYOUT = [\t-\n\r\ ];
layout  LAYOUTLIST = LAYOUT*;

start syntax Program = program: Exp;

syntax Func
// forma con bloque
  = func: Ident name "=" KW_FUNCTION "(" {Ident ","}* ")" "do" Exp KW_END
  // forma corta en una línea
  | func: Ident name "=" KW_FUNCTION "(" {Ident ","}* ")" "="  Exp KW_END
  ;

syntax Exp
  = bracket "(" Exp ")"
  | var: Ident
  | nat: Natural
  | call: Ident "(" {Exp ","}* ")"
  > left  mul: Exp "*" Exp
  > left  div: Exp "/" Exp
  > left  add: Exp "+" Exp
  > left  sub: Exp "-" Exp
  > right assign: Exp ":=" Exp
  > right seq: Exp ";" Exp
  > left gt: Exp "\>" Exp
  > left lt: Exp "\<" Exp
  > left loe: Exp "\<=" Exp
  > left goe: "\>=" Exp
  > left different: Exp "\<\>" Exp
  > left eq: Exp "=" Exp
  > left or: Exp KW_OR Exp
  > left p: Exp ":" Exp
  | cond: KW_IF Exp KW_THEN Exp KW_ELSE Exp KW_END
  ;

