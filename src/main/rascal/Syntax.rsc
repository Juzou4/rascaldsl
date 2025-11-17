module Syntax

lexical String = "\"" ![\"]* "\"";
syntax Str = String;

lexical Real = [0-9]+ "." [0-9]+;
syntax RealLiteral = Real;

lexical Identifier = [a-zA-Z][a-zA-Z0-9_]* !>> [a-zA-Z0-9_];
lexical Natural = [0-9]+ !>> [0-9];

lexical LAYOUT = [\t-\n\r\ ]+;
layout  LAYOUTLIST = LAYOUT* !>> [\t-\n\r\ ];

// -------- KEYWORDS --------
keyword KW_COND = "cond";
keyword KW_DO = "do";
keyword KW_DATA = "data";
keyword KW_ELSIF = "elsif";
keyword KW_END = "end";
keyword KW_FOR = "for";
keyword KW_FROM = "from";
keyword KW_THEN = "then";
keyword KW_FUNCTION = "function";
keyword KW_ELSE = "else";
keyword KW_IF = "if";
keyword KW_IN = "in";
keyword KW_ITERATOR = "iterator";
keyword KW_SEQUENCE = "sequence";
keyword KW_STRUCT = "struct";
keyword KW_TO = "to";
keyword KW_TUPLE = "tuple";
keyword KW_TYPE = "type";
keyword KW_WITH = "with";
keyword KW_YIELDING = "yielding";
keyword KW_POSITIVE = "positive";
keyword KW_NEGATIVE = "negative";
keyword KW_OR = "or";


start syntax Program = program: Module+;

syntax Module
  = dataModule: DataAbstraction
  | funcModule: Func
  ;

syntax Block
  = block: Stmt+
  ;

syntax Func
// forma con bloque
  = func: Identifier name "=" KW_FUNCTION "(" {Identifier {"," Identifier }* }* ")" KW_DO Block KW_END
  // forma corta en una línea
  | func: Identifier name "=" KW_FUNCTION "(" {Identifier {"," Identifier}*}* ")" "="  Exp KW_END
  ;

syntax StructDecl
  = structDecl:
  Identifier "=" KW_STRUCT "(" {Identifier {"," Identifier }* }* ")";

syntax DataAbstraction
  = dataAbs:
  Identifier "=" KW_DATA KW_WITH {Identifier {"," Identifier }* }+
  StructDecl
  Func+
  KW_END Identifier
  ;

syntax CondBranch
  = branch: Exp "-\>" Exp
  ;

syntax CondBlock
  = block: CondBranch+
  ;

syntax FieldAssign
  = fieldAssign: Identifier ":" Exp;


syntax Stmt
  = assign: Identifier "=" Exp
  | exprtStmt: Exp
  | funcDef: Func
  | forRange: KW_FOR Identifier KW_FROM Exp KW_TO Exp KW_DO Block KW_END
  | ForIn: KW_FOR Identifier KW_IN Exp KW_DO Block KW_END
  | ifStmt: KW_IF Exp KW_THEN Block KW_ELSE Block KW_END
  ;
syntax Exp

  = tupla: "(" Exp "," Exp ")"
  | sequence: "(" {Exp {"," Exp}*}+ ")"
  | paren: "(" Exp ")"
  | var: Identifier
  | nat: Natural
  | string: Str
  | nreal: RealLiteral
  | call: Identifier "(" {Exp {"," Exp}* }* ")"
  | dataCall: Identifier "$" "(" {FieldAssign {"," FieldAssign}* }* ")"
  // Operadores aritmeticos
  > left  mul: Exp "*" Exp
  > left  div: Exp "/" Exp
  > left  add: Exp "+" Exp
  > left  sub: Exp "-" Exp

  // Comparaciones
  > left gt: Exp "\>" Exp
  > left lt: Exp "\<" Exp
  > left loe: Exp "\<=" Exp
  > left goe: Exp "\>=" Exp
  > left different: Exp "\<\>" Exp
  > left eq: Exp "=" Exp

  // Logicos
  > left or: Exp KW_OR Exp

  // Secuencias
  > right assign: Exp ":=" Exp
  > right seq: Exp ";" Exp
  > left p: Exp ":" Exp
  > left dot: Exp "." Identifier

  // rango
  > non-assoc range: KW_FROM Exp KW_TO Exp

  // iterador
  > non-assoc iter: KW_ITERATOR "(" Exp ")" KW_YIELDING "(" Exp ")"

  // expresion condicional
  > non-assoc condExpr: KW_COND Exp KW_DO CondBlock KW_END
  ;
