// generated by codegen/codegen.py
import codeql.swift.elements.stmt.LabeledStmt
import codeql.swift.elements.stmt.StmtCondition

class LabeledConditionalStmtBase extends @labeled_conditional_stmt, LabeledStmt {
  StmtCondition getCondition() {
    exists(StmtCondition x |
      labeled_conditional_stmts(this, x) and
      result = x.resolve()
    )
  }
}
