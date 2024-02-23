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

sealed class FtlVariantKeyCandidate {}

sealed class FtlInlinePlaceableCandidate {}

sealed class FtlInlineExpressionCandidate {}

sealed class FtlArgumentCandidate {}

final class FtlInlineExpression
    implements FtlInlinePlaceableCandidate, FtlArgumentCandidate {
  final FtlInlineExpressionCandidate expression;

  FtlInlineExpression({required this.expression});
}

final class FtlString {
  final String content;

  FtlString(this.content);
}

sealed class FtlLiteral {}

final class FtlStringLiteral extends FtlString
    implements FtlLiteral, FtlInlineExpressionCandidate {
  FtlStringLiteral(super.content);
}

final class FtlIdentifier extends FtlString
    implements FtlVariantKeyCandidate {
  FtlIdentifier(super.content);
}

sealed class FtlResourceCandidate {}

final class FtlBlankBlock extends FtlString
    implements FtlResourceCandidate {
  FtlBlankBlock(super.content);
}

final class FtlJunk extends FtlString implements FtlResourceCandidate {
  FtlJunk(super.content);
}

sealed class FtlPatternElementCandidate {}

final class FtlText extends FtlString
    implements FtlPatternElementCandidate {
  FtlText(super.content);
}

sealed class FtlEntry implements FtlResourceCandidate {}

final class FtlCommentLine extends FtlString implements FtlEntry {
  FtlCommentLine(super.content);
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

final class FtlAttributeAccessor {
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

final class FtlDefaultVariant {
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

final class FtlTerm implements FtlEntry {
  final FtlIdentifier identifier;
  final FtlPattern pattern;
  final List<FtlAttribute> attributes;

  FtlTerm({
    required this.identifier,
    required this.pattern,
    required this.attributes,
  });
}

final class FtlMessage implements FtlEntry {
  final FtlIdentifier identifier;
  final FtlPattern? pattern;
  final List<FtlAttribute> attributes;

  FtlMessage({
    required this.identifier,
    this.pattern,
    required this.attributes,
  });
}

final class FtlResource {
  final List<FtlResourceCandidate> resourceParts;

  FtlResource({required this.resourceParts});
}
