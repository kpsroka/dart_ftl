//  Copyright 2019-2024 Krzysztof Krasiński-Sroka

//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//      http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import 'package:built_collection/built_collection.dart';
import 'package:ftl/ftl.dart';
import 'package:ftl/src/ast.dart';

sealed class Evaluator<T> {
  Evaluator(this._node);

  final T _node;

  EvaluationContext evaluate(EvaluationContext context);
}

final class FtlResourceEvaluator extends Evaluator<FtlResource> {
  FtlResourceEvaluator(super.node);

  @override
  EvaluationContext evaluate(EvaluationContext context) {
    for (final part in _node.resourceParts) {
      switch (part) {
        case FtlJunk() || FtlBlankBlock():
          continue;
        case FtlEntry():
          context.mergeTerms(FtlEntryEvaluator(part).evaluate(context.clone()));
      }
    }

    return context;
  }
}

class FtlEntryEvaluator extends Evaluator<FtlEntry> {
  FtlEntryEvaluator(super.node);

  @override
  EvaluationContext evaluate(EvaluationContext context) {
    switch (_node) {
      case FtlTerm():
        return context
          ..mergeTerms(
            FtlTermEvaluator(_node).evaluate(context.clone()),
          );
      case FtlMessage():
        return context
          ..mergeTerms(
            FtlMessageEvaluator(_node).evaluate(context.clone()),
          );
      case FtlCommentLine(:final content):
        return context..commentAccumulator?.add(content);
    }
  }
}

class FtlTermEvaluator extends Evaluator<FtlTerm> {
  FtlTermEvaluator(super.node);

  @override
  EvaluationContext evaluate(EvaluationContext context) {
    final identifier = _node.identifier.content;

    // TODO: implement evaluate
    throw UnimplementedError();
  }
}

class FtlMessageEvaluator extends Evaluator<FtlMessage> {
  FtlMessageEvaluator(super.node);

  @override
  EvaluationContext evaluate(EvaluationContext context) {
    // TODO: implement evaluate
    throw UnimplementedError();
  }
}

class EvaluationContext {
  EvaluationContext(
    this.boundTerms, [
    this.commentAccumulator,
  ]);

  final MapBuilder<String, Term> boundTerms;

  final ListBuilder<String>? commentAccumulator;

  EvaluationContext clone() {
    return EvaluationContext(boundTerms, commentAccumulator);
  }

  void mergeTerms(EvaluationContext other) {
    for (final otherEntry in other.boundTerms.build().entries) {
      final key = otherEntry.key;
      boundTerms.putIfAbsent(key, () => otherEntry.value);
    }
  }

  void mergeComments(EvaluationContext other) {
    commentAccumulator?.addAll(other.commentAccumulator?.build() ?? const []);
  }
}

sealed class Term {}

class StringTerm extends Term {}

class FunctionTerm extends Term {}

class ConcatTerm extends Term {}
