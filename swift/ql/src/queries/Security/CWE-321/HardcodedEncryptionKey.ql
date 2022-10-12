/**
 * @name Hard-coded encryption key
 * @description Using hardcoded keys for encryption is not secure, because potential attacker can easiy guess them.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.1
 * @precision high
 * @id swift/hardcoded-key
 * @tags security
 *       external/cwe/cwe-321
 */

import swift
import codeql.swift.dataflow.DataFlow
import DataFlow::PathGraph

/**
 * An `Expr` that is used to initialize a key.
 */
abstract class KeySource extends Expr { }

/**
 * A literal byte array is a key source.
 */
class ByteArrayLiteralSource extends KeySource {
  ByteArrayLiteralSource() { this = any(ArrayExpr arr | arr.getType().toString() = "Array<UInt8>") }
}

/**
 * A string literal is a key source.
 */
class StringLiteralSource extends KeySource {
  StringLiteralSource() { this instanceof StringLiteralExpr }
}

/**
 * A class for all ways to set a key.
 */
class EncryptionKeySink extends Expr {
  EncryptionKeySink() {
    // `key` arg in `init` is a sink
    exists(ClassDecl c, AbstractFunctionDecl f, CallExpr call |
      c.getName() = ["AES", "HMAC", "ChaCha20", "CBCMAC", "CMAC", "Poly1305", "Blowfish", "Rabbit"] and
      c.getAMember() = f and
      f.getName().matches("init(key:%") and
      call.getStaticTarget() = f and
      call.getArgument(0).getExpr() = this
    )
  }
}

/**
 * A dataflow configuration from the key source to expressions that use
 * it to initialize a cipher.
 */
class HardcodedKeyConfig extends DataFlow::Configuration {
  HardcodedKeyConfig() { this = "HardcodedKeyConfig" }

  override predicate isSource(DataFlow::Node node) { node.asExpr() instanceof KeySource }

  override predicate isSink(DataFlow::Node node) { node.asExpr() instanceof EncryptionKeySink }
}

// The query itself
from HardcodedKeyConfig config, DataFlow::PathNode sourceNode, DataFlow::PathNode sinkNode
where config.hasFlowPath(sourceNode, sinkNode)
select sinkNode.getNode(), sourceNode, sinkNode,
  "The key '" + sinkNode.getNode().toString() +
    "' has been initialized with hard-coded values from $@.", sourceNode,
  sourceNode.getNode().toString()
