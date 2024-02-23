//  Copyright 2019 Krzysztof Sroka

//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//      http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

class FtlString
    implements
        FtlJunk,
        FtlIdentifier,
        FtlStringLiteral,
        FtlText,
        FtlCommentLine,
        FtlBlankBlock {
  final String content;

  FtlString._(this.content);

  static FtlString fromString(String content) {
    return FtlString._(content);
  }
}

class FtlText implements _FtlPatternElementCandidate {}

class FtlJunk implements FtlResourceCandidate {}

class FtlBlankBlock implements FtlResourceCandidate {}

class FtlCommentLine {}

class FtlIdentifier implements _FtlVariantKeyCandidate {}

class FtlStringLiteral implements _FtlInlineExpressionCandidate {}

class FtlNumberLiteral extends FtlString
    implements _FtlInlineExpressionCandidate, _FtlVariantKeyCandidate {
  final num value;

  FtlNumberLiteral(super.content)
      : value = num.parse(content),
        super._();
}

class FtlAttribute {
  final FtlIdentifier identifier;
  final FtlPattern pattern;

  FtlAttribute({required this.identifier, required this.pattern});
}

class FtlAttributeAccessor {
  final FtlIdentifier identifier;

  FtlAttributeAccessor({required this.identifier});
}

class FtlNamedArgument implements _FtlArgumentCandidate {
  final FtlIdentifier identifier;

  // Either FtlNumberLiteral or FtlStringLiteral.
  final dynamic literal;

  FtlNamedArgument(this.identifier, this.literal)
      : assert(literal is FtlNumberLiteral || literal is FtlStringLiteral);
}

class _FtlArgumentCandidate {}

class FtlArgument {
  final _FtlArgumentCandidate argument;

  FtlArgument({required this.argument});
}

class _FtlVariantKeyCandidate {}

class FtlVariantKey {
  final _FtlVariantKeyCandidate key;

  FtlVariantKey({required this.key});
}

class FtlVariant {
  final FtlVariantKey variantKey;
  final FtlPattern pattern;

  FtlVariant({required this.variantKey, required this.pattern});
}

class FtlDefaultVariant {
  final FtlVariantKey variantKey;
  final FtlPattern pattern;

  FtlDefaultVariant({required this.variantKey, required this.pattern});
}

class FtlVariantList {
  final FtlDefaultVariant defaultVariant;
  final List<FtlVariant> variants;

  FtlVariantList({required this.defaultVariant, required this.variants});
}

class _FtlInlinePlaceableCandidate {}

class FtlInlinePlaceable
    implements _FtlPatternElementCandidate, _FtlInlineExpressionCandidate {
  final _FtlInlinePlaceableCandidate placeable;

  FtlInlinePlaceable({required this.placeable});
}

class FtlBlockPlaceable implements _FtlInlinePlaceableCandidate {}

class _FtlInlineExpressionCandidate {}

class FtlInlineExpression
    implements _FtlInlinePlaceableCandidate, _FtlArgumentCandidate {
  final _FtlInlineExpressionCandidate expression;

  FtlInlineExpression({required this.expression});
}

class _FtlPatternElementCandidate {}

class FtlPatternElement {
  final _FtlPatternElementCandidate element;

  FtlPatternElement({required this.element});
}

class FtlPattern {
  final List<FtlPatternElement> patternElements;

  FtlPattern({required this.patternElements});
}

class FtlSelectExpression implements _FtlInlinePlaceableCandidate {
  FtlInlineExpression inlineExpression;
  FtlVariantList variantList;

  FtlSelectExpression(
      {required this.inlineExpression, required this.variantList});
}

class FtlArgumentList {
  final List<FtlArgument> arguments;

  FtlArgumentList({required this.arguments});
}

class FtlCallArguments {
  final FtlArgumentList arguments;

  FtlCallArguments({required this.arguments});
}

class FtlTermReference implements _FtlInlineExpressionCandidate {
  final FtlIdentifier identifier;
  final FtlAttributeAccessor attributeAccessor;
  final FtlCallArguments callArguments;

  FtlTermReference(
      {required this.identifier,
      required this.attributeAccessor,
      required this.callArguments});
}

class FtlMessageReference implements _FtlInlineExpressionCandidate {
  final FtlIdentifier identifier;
  final FtlAttributeAccessor attributeAccessor;

  FtlMessageReference(
      {required this.identifier, required this.attributeAccessor});
}

class FtlFunctionReference implements _FtlInlineExpressionCandidate {
  final FtlIdentifier identifier;
  final FtlCallArguments callArguments;

  FtlFunctionReference({required this.identifier, required this.callArguments});
}

class FtlVariableReference implements _FtlInlineExpressionCandidate {
  final FtlIdentifier identifier;

  FtlVariableReference({required this.identifier});
}

class FtlTerm {
  final FtlIdentifier identifier;
  final FtlPattern pattern;
  final List<FtlAttribute> attributes;

  FtlTerm(
      {required this.identifier,
      required this.pattern,
      required this.attributes});
}

class FtlMessage {
  final FtlIdentifier identifier;
  final FtlPattern? pattern;
  final List<FtlAttribute> attributes;

  FtlMessage(
      {required this.identifier, this.pattern, required this.attributes});
}

class FtlEntry implements FtlResourceCandidate {
  final FtlMessage? message;
  final FtlTerm? term;
  final FtlCommentLine? commentLine;

  FtlEntry({this.message, this.term, this.commentLine});

  factory FtlEntry.forMessage(FtlMessage message) => FtlEntry(message: message);
  factory FtlEntry.forTerm(FtlTerm term) => FtlEntry(term: term);
  factory FtlEntry.forCommentLine(FtlCommentLine commentLine) =>
      FtlEntry(commentLine: commentLine);
}

class FtlResourceCandidate {}

class FtlResource {
  final List<FtlResourceCandidate> resourceParts;

  FtlResource({required this.resourceParts});
}
