module AST

data Program = program(list[Func] funcs);
data Func    = func(str name, list[str] formals, Exp body);

data Exp
  = nat(int n) | var(str name)
  | add(Exp a, Exp b) | sub(Exp a, Exp b)
  | mul(Exp a, Exp b) | div(Exp a, Exp b)
  | assign(Exp x, Exp e) | seq(Exp a, Exp b)
  | call(str name, list[Exp] args)
  | cond(Exp c, Exp t, Exp e)
  ;
