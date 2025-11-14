module Eval
import AST;
import List;

alias PEnv = map[str, Func];
alias VEnv = map[str, int];

public int run(str main, list[int] args, Program prog) {
  PEnv penv = ( f.name : f | f <- prog.funcs );  // <— clave
  Func f = penv[main];
  return eval(applyArgs(f, args), penv, ());
}

Exp applyArgs(Func f, list[int] args) {
  map[str,int] m = ( f.formals[i] : args[i] | i <- index(f.formals) );
  return substVars(f.body, m);
}

Exp substVars(Exp e, map[str,int] m)
  = visit(e) { case var(str x) => m[x]? ? nat(m[x]) : var(x) };

int eval(nat(int n), PEnv _, VEnv __) = n;
int eval(add(Exp a, Exp b), PEnv p, VEnv v) = eval(a,p,v) + eval(b,p,v);
int eval(sub(Exp a, Exp b), PEnv p, VEnv v) = eval(a,p,v) - eval(b,p,v);
int eval(mul(Exp a, Exp b), PEnv p, VEnv v) = eval(a,p,v) * eval(b,p,v);
int eval(div(Exp a, Exp b), PEnv p, VEnv v) = eval(a,p,v) / eval(b,p,v);
int eval(seq(Exp a, Exp b), PEnv p, VEnv v) { eval(a,p,v); return eval(b,p,v); }
int eval(assign(var(str _x), Exp e), PEnv p, VEnv v) = eval(e,p,v);
int eval(call(str name, list[Exp] args), PEnv p, VEnv v) {
  Func f = p[name]; list[int] vs = [ eval(a,p,v) | a <- args ];
  return eval(applyArgs(f, vs), p, v);
}
int eval(cond(Exp c, Exp t, Exp e), PEnv p, VEnv v)
  = (eval(c,p,v) != 0) ? eval(t,p,v) : eval(e,p,v);
