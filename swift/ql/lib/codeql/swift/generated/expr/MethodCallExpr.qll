// generated by codegen/codegen.py
import codeql.swift.elements.expr.ApplyExpr
import codeql.swift.elements.expr.Expr

class MethodCallExprBase extends @method_call_expr, ApplyExpr {
  override string getAPrimaryQlClass() { result = "MethodCallExpr" }

  Expr getQualifier() {
    exists(Expr x |
      method_call_exprs(this, x) and
      result = x.resolve()
    )
  }
}
