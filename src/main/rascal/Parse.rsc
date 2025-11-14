module Parse
import Syntax;
import ParseTree;

public Program parse(str s) = parse(#Program, s);
public Program parse(loc l) = parse(#Program, l);
