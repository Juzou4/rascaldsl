module Checker

import Syntax;
import ParseTree;
extend analysis::typepal::TypePal;

// Tipos abstractos que usaremos en el lenguaje ALU

data AType
  = intType()
  | realType()
  | boolType()
  | charType()
  | stringType()
  ;

str prettyAType(intType()) = "Int";
str prettyAType(realType()) = "Real";
str prettyAType(boolType()) = "Bool";
str prettyAType(charType()) = "Char";
str prettyAType(stringType()) = "String";

// pasar de Syntax::Type a nuestro AType
AType typeFromSyntax(Type t) {
  switch (t) {
    case intType(): return intType();
    case boolType(): return boolType();
    case charType(): return charType();
    case stringType(): return stringType();
  }
  return AType();
}

// Collect: tipos base (literales y paréntesis)

// enteros naturales
void collect(current: (Exp) `<Natural _>`, Collector c) {
  c.fact(current, intType());
}

// reales
void collect(current: (Exp) `<RealLiteral _>`, Collector c) {
  c.fact(current, realType());
}

// strings
void collect(current: (Exp) `<Str _>`, Collector c) {
  c.fact(current, stringType());
}

// booleanos
void collect(current: (Exp) `<BoolLiteral _>`, Collector c) {
  c.fact(current, boolType());
}

// caracteres
void collect(current: (Exp) `<CharLiteral _>`, Collector c) {
  c.fact(current, charType());
}

// paréntesis: ( e )
void collect(current: (Exp) `( <Exp e> )`, Collector c) {
  c.fact(current, e);
  collect(e, c);
}

public TModel aluTModelFromTree(Tree pt) {
  // si viene como start[Program], nos quedamos con el .top
  if (pt has top) {
    pt = pt.top;
  }
  // versión simple: usa la config por defecto de TypePal
  return collectAndSolve(pt);
}

// Operadores aritméticos básicos

void collect(current: (Exp) `<Exp e1> + <Exp e2>`, Collector c) {
  c.calculate("add", current, [e1, e2],
    AType (Solver s) {
      switch (<s.getType(e1), s.getType(e2)>) {
        case <intType(),  intType()>:  return intType();
        case <realType(), realType()>: return realType();
        case <intType(),  realType()>: return realType();
        case <realType(), intType()>:  return realType();
        default:
          s.report(error(current, "`+` no está definido para %t y %t", e1, e2));
      }
    });
  collect(e1, e2, c);
}

void collect(current: (Exp) `<Exp e1> - <Exp e2>`, Collector c) {
  c.calculate("sub", current, [e1, e2],
    AType (Solver s) {
      switch (<s.getType(e1), s.getType(e2)>) {
        case <intType(),  intType()>:  return intType();
        case <realType(), realType()>: return realType();
        case <intType(),  realType()>: return realType();
        case <realType(), intType()>:  return realType();
        default:
          s.report(error(current, "`-` no está definido para %t y %t", e1, e2));
      }
    });
  collect(e1, e2, c);
}

void collect(current: (Exp) `<Exp e1> * <Exp e2>`, Collector c) {
  c.calculate("mul", current, [e1, e2],
    AType (Solver s) {
      switch (<s.getType(e1), s.getType(e2)>) {
        case <intType(),  intType()>:  return intType();
        case <realType(), realType()>: return realType();
        case <intType(),  realType()>: return realType();
        case <realType(), intType()>:  return realType();
        default:
          s.report(error(current, "`*` no está definido para %t y %t", e1, e2));
      }
    });
  collect(e1, e2, c);
}

void collect(current: (Exp) `<Exp e1> / <Exp e2>`, Collector c) {
  c.calculate("div", current, [e1, e2],
    AType (Solver s) {
      switch (<s.getType(e1), s.getType(e2)>) {
        case <intType(),  intType()>:  return intType();
        case <realType(), realType()>: return realType();
        case <intType(),  realType()>: return realType();
        case <realType(), intType()>:  return realType();
        default:
          s.report(error(current, "`/` no está definido para %t y %t", e1, e2));
      }
    });
  collect(e1, e2, c);
}

// -------------------------------------------------------
// 5. Comparación ==  (devuelve Bool)
// -------------------------------------------------------

void collect(current: (Exp) `<Exp e1> "==" <Exp e2>`, Collector c) {
  c.calculate("eq", current, [e1, e2],
    AType (Solver s) {
      s.requireEqual(
        e1, e2,
        error(current, "Tipos incompatibles en `==`: %t y %t", e1, e2)
      );
      return boolType();
    });
  collect(e1, e2, c);
}

// -------------------------------------------------------
// 6. Anotación: e :: Tipo
// -------------------------------------------------------

void collect(current: (Exp) `<Exp e> "::" <Type t>`, Collector c) {
  AType expected = typeFromSyntax(t);

  c.calculate("annotation", current, [e],
    AType (Solver s) {
      s.requireEqual(
        e, expected,
        error(current,
          "La anotación de tipo espera %t pero la expresión tiene tipo %t",
          expected, e
        )
      );
      return expected;
    });

  collect(e, c);
}

// -------------------------------------------------------
// 7. Casos “neutros” para no romper nada
//    (solo siguen recorriendo el árbol)
// -------------------------------------------------------

// variables solas (por ahora no hacemos def/use, solo seguimos)
void collect(current: (Exp) `<Identifier _>`, Collector c) {
  ; // sin tipo fijo todavía
}

// cualquier otra forma de Exp que no toquemos todavía
void collect(current: (Exp) `<Exp e1> ; <Exp e2>`, Collector c) {
  collect(e1, e2, c);
}

// -------------------------------------------------------
// 8. Función auxiliar para crear el TModel
// -------------------------------------------------------

public TModel aluTModelFromTree(Tree pt) {
  if (pt has top) {
    pt = pt.top;
  }
  return collectAndSolve(pt);
}
