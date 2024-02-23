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

interface class FtlPatternElementCandidate {}

interface class FtlResourceCandidate {}

interface class FtlJunk implements FtlResourceCandidate {}

interface class FtlBlankBlock implements FtlResourceCandidate {}

interface class FtlCommentLine {}

interface class FtlVariantKeyCandidate {}

final class FtlIdentifier implements FtlVariantKeyCandidate {}

interface class FtlInlinePlaceableCandidate {}

interface class FtlInlineExpressionCandidate {}

interface class FtlArgumentCandidate {}

final class FtlInlineExpression
    implements FtlInlinePlaceableCandidate, FtlArgumentCandidate {
  final FtlInlineExpressionCandidate expression;

  FtlInlineExpression({required this.expression});
}

interface class FtlLiteral {}

interface class FtlStringLiteral
    implements FtlLiteral, FtlInlineExpressionCandidate {}

interface class FtlText implements FtlPatternElementCandidate {}

final class FtlString
    implements
        FtlJunk,
        FtlIdentifier,
        FtlStringLiteral,
        FtlText,
        FtlCommentLine,
        FtlBlankBlock {
  final String content;

  FtlString(this.content);
}

final class FtlNumberLiteral extends FtlString
    implements
        FtlLiteral,
        FtlInlineExpressionCandidate,
        FtlVariantKeyCandidate {
  final num value;

  FtlNumberLiteral(super.content) : value = num.parse(content);
}

final class FtlAttribute {
  final FtlIdentifier identifier;
  final FtlPattern pattern;

  FtlAttribute({required this.identifier, required this.pattern});
}

class FtlAttributeAccessor {
  final FtlIdentifier identifier;

  FtlAttributeAccessor({required this.identifier});
}

final class FtlNamedArgument implements FtlArgumentCandidate {
  final FtlIdentifier identifier;
  final FtlLiteral literal;

  FtlNamedArgument(this.identifier, this.literal);
}

final class FtlArgument {
  final FtlArgumentCandidate argument;

  FtlArgument({required this.argument});
}

final class FtlVariantKey {
  final FtlVariantKeyCandidate key;

  FtlVariantKey({required this.key});
}

final class FtlVariant {
  final FtlVariantKey variantKey;
  final FtlPattern pattern;

  FtlVariant({required this.variantKey, required this.pattern});
}

class FtlDefaultVariant {
  final FtlVariantKey variantKey;
  final FtlPattern pattern;

  FtlDefaultVariant({required this.variantKey, required this.pattern});
}

final class FtlVariantList {
  final FtlDefaultVariant defaultVariant;
  final List<FtlVariant> variants;

  FtlVariantList({required this.defaultVariant, required this.variants});
}

final class FtlInlinePlaceable
    implements FtlPatternElementCandidate, FtlInlineExpressionCandidate {
  final FtlInlinePlaceableCandidate placeable;

  FtlInlinePlaceable({required this.placeable});
}

final class FtlBlockPlaceable implements FtlInlinePlaceableCandidate {}

final class FtlPatternElement {
  final FtlPatternElementCandidate element;

  FtlPatternElement({required this.element});
}

final class FtlPattern {
  final List<FtlPatternElement> patternElements;

  FtlPattern({required this.patternElements});
}

final class FtlSelectExpression implements FtlInlinePlaceableCandidate {
  FtlInlineExpression inlineExpression;
  FtlVariantList variantList;

  FtlSelectExpression({
    required this.inlineExpression,
    required this.variantList,
  });
}

final class FtlArgumentList {
  final List<FtlArgument> arguments;

  FtlArgumentList({required this.arguments});
}

final class FtlCallArguments {
  final FtlArgumentList arguments;

  FtlCallArguments({required this.arguments});
}

final class FtlTermReference implements FtlInlineExpressionCandidate {
  final FtlIdentifier identifier;
  final FtlAttributeAccessor? attributeAccessor;
  final FtlCallArguments? callArguments;

  FtlTermReference({
    required this.identifier,
    required this.attributeAccessor,
    required this.callArguments,
  });
}

final class FtlMessageReference implements FtlInlineExpressionCandidate {
  final FtlIdentifier identifier;
  final FtlAttributeAccessor? attributeAccessor;

  FtlMessageReference({
    required this.identifier,
    required this.attributeAccessor,
  });
}

final class FtlFunctionReference implements FtlInlineExpressionCandidate {
  final FtlIdentifier identifier;
  final FtlCallArguments callArguments;

  FtlFunctionReference({
    required this.identifier,
    required this.callArguments,
  });
}

final class FtlVariableReference implements FtlInlineExpressionCandidate {
  final FtlIdentifier identifier;

  FtlVariableReference({required this.identifier});
}

final class FtlTerm {
  final FtlIdentifier identifier;
  final FtlPattern pattern;
  final List<FtlAttribute> attributes;

  FtlTerm({
    required this.identifier,
    required this.pattern,
    required this.attributes,
  });
}

final class FtlMessage {
  final FtlIdentifier identifier;
  final FtlPattern? pattern;
  final List<FtlAttribute> attributes;

  FtlMessage({
    required this.identifier,
    this.pattern,
    required this.attributes,
  });
}

final class FtlEntry implements FtlResourceCandidate {
  final FtlMessage? message;
  final FtlTerm? term;
  final FtlCommentLine? commentLine;

  FtlEntry({
    this.message,
    this.term,
    this.commentLine,
  });

  factory FtlEntry.forMessage(FtlMessage message) => FtlEntry(message: message);
  factory FtlEntry.forTerm(FtlTerm term) => FtlEntry(term: term);
  factory FtlEntry.forCommentLine(FtlCommentLine commentLine) =>
      FtlEntry(commentLine: commentLine);
}

final class FtlResource {
  final List<FtlResourceCandidate> resourceParts;

  FtlResource({required this.resourceParts});
}
