module Checker
import Syntax;

extend analysis::typepal::TypePal;
import ParseTree;
import String;

// Tipos abstractos que usaremos en el lenguaje ALU

data AType
  = intType()
  | realType()
  | boolType()
  | charType()
  | stringType()
  | floatType()
  ;

str prettyAType(intType())    = "Int";
str prettyAType(realType())   = "Real";
str prettyAType(boolType())   = "Bool";
str prettyAType(charType())   = "Char";
str prettyAType(stringType()) = "String";
str prettyAType(floatType()) = "Float";

//traducir sintaxis::tipo a Atype para las anotaciones de :: que buscamos
  AType typeFromSyntax(Type t) {
    switch (t) {
      case intType(): return intType();
      case boolType(): return boolType();
      case charType(): return charType();
      case stringType(): return stringType();
      case floatType(): return floatType();
    }
  }

  public TModel aluTModelFromTree(Tree pt) {
    if (pt has top) {
      pt = pt.top;
    }
    return collectAndSolve(pt);
  }

  //reglas 
  // nat: Natural
void collect(current: Exp nat(Natural _), Collector c) {
  c.fact(current, intType());
}

// nreal: RealLiteral
void collect(current: Exp nreal(RealLiteral _), Collector c) {
  c.fact(current, realType());
}

// string: Str
void collect(current: Exp string(Str _), Collector c) {
  c.fact(current, stringType());
}

// boolLit: BoolLiteral
void collect(current: Exp boolLit(BoolLiteral _), Collector c) {
  c.fact(current, boolType());
}

// charLit: CharLiteral
void collect(current: Exp charLit(CharLiteral _), Collector c) {
  c.fact(current, charType());
}

// floatLit: FloatLiteral
void collect(current: Exp floatLit(FloatLiteral _), Collector c) {
  c.fact(current, floatType());
}

// paren: "(" Exp ")"
void collect(current: Exp paren(Exp e), Collector c) {
  // el tipo de (e) es el mismo tipo de e
  c.fact(current, e);
  collect(e, c);
}



void collect(current: Exp add(Exp e1, Exp e2), Collector c) {
  c.calculate("add", current, [e1, e2],
    AType (Solver s) {
      AType t1 = s.getType(e1);
      AType t2 = s.getType(e2);

      switch (<t1, t2>) {
        case <intType(),  intType()>:  return intType();
        case <realType(), realType()>: return realType();
        case <stringType(),  stringType()>: return stringType();
        case <charType(), charType()>:  return charType();
        case <floatType(), floatType()>: return floatType();
        default: {
          s.report(error(current,
            "`+` no está definido para tipos %t y %t", e1, e2));
        }
      }
    });
  collect(e1, c);
  collect(e2, c);
}

// Anotación de tipo: annotated: Exp "::" Type
void collect(current: Exp annotated(Exp e, Type t), Collector c) {
  AType expected = typeFromSyntax(t);

  c.calculate("annotation", current, [e],
    AType (Solver s) {
      s.requireEqual(
        e,
        expected,
        error(current,
          "La anotación de tipo espera %t pero la expresión tiene tipo %t",
          expected, e
        )
      );
      return expected;
    });

  collect(e, c);
}

// 7. Casos “neutros” para seguir recorriendo el árbol
// secuencia: p: Exp ":" Exp  (si quieres otros, los vas añadiendo)
void collect(current: Exp p(Exp e1, Exp e2), Collector c) {
  collect(e1, c);
  collect(e2, c);
}

// por ahora: las variables las dejamos sin tipo fijo
void collect(current: Exp var(Identifier _), Collector c) {
  ; // aquí luego puedes meter def/use de variables
}


