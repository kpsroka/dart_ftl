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

library ftl;

import 'package:petitparser/petitparser.dart';

import './ast.dart';

Parser<FtlResource> _setUpParser() {
  Parser<FtlString> lineEnd = (string('\u000D\u000A') | string('\u000A'))
      .flatten()
      .map(FtlString.fromString);
  Parser<FtlString> blankInline =
      char('\u0020').plus().flatten().map(FtlString.fromString);
  Parser<FtlBlankBlock> blankBlock =
      (blankInline & lineEnd).plus().flatten().map(FtlString.fromString);
  Parser<FtlString> blank =
      (blankInline | lineEnd).plus().flatten().map(FtlString.fromString);

  Parser<FtlString> junkLine =
      (lineEnd.neg().star() & lineEnd).flatten().map(FtlString.fromString);
  Parser<FtlJunk> junk =
      (junkLine & ((letter() | char('#') | char('-')).not() & junkLine).star())
          .flatten()
          .map(FtlString.fromString);

  Parser<FtlString> specialTextChar =
      (char('{') | char('}')).flatten().map(FtlString.fromString);
  Parser<FtlString> textChar = ((specialTextChar.or(lineEnd)).not() & any())
      .flatten()
      .map(FtlString.fromString);
  Parser<FtlString> indentedChar =
      ((char('.').or(char('*')).or(char('['))).not() & textChar)
          .flatten()
          .map(FtlString.fromString);
  Parser<FtlString> specialQuotedChar =
      (char('"') | char('\\')).flatten().map(FtlString.fromString);
  Parser<FtlString> specialEscape =
      (char('\\') & specialQuotedChar).flatten().map(FtlString.fromString);
  Parser<FtlString> unicodeEscape4 =
      (string('\\u') & word().times(4)).flatten().map(FtlString.fromString);
  Parser<FtlString> unicodeEscape6 =
      (string('\\U') & word().times(6)).flatten().map(FtlString.fromString);
  Parser<FtlString> unicodeEscape =
      (unicodeEscape4 | unicodeEscape6).map((dynamic raw) => raw);
  Parser<FtlString> quotedChar =
      (textChar | specialEscape | unicodeEscape).map((dynamic raw) => raw);

  Parser<FtlText> inlineText =
      textChar.plus().flatten().map(FtlString.fromString);
  Parser<FtlText> blockText =
      (blankBlock & blankInline & indentedChar & inlineText.optional())
          .flatten()
          .map(FtlString.fromString);

  Parser<FtlString> commentChar =
      (lineEnd.not() & any()).flatten().map(FtlString.fromString);
  Parser<FtlCommentLine> commentLine =
      ((string('###') | string('##') | string('#')) &
              (char(' ') & commentChar.star()).optional() &
              lineEnd)
          .flatten()
          .map(FtlString.fromString);

  Parser<FtlIdentifier> identifier =
      (letter() & (word() | char('_') | char('-')).star())
          .flatten()
          .map(FtlString.fromString);
  Parser<FtlNumberLiteral> numberLiteral = ((char('-').optional()) &
          digit().plus() &
          (char('.') & digit().plus()).optional())
      .flatten()
      .map((String content) => FtlNumberLiteral(content));
  Parser<FtlStringLiteral> stringLiteral =
      (char('"') & quotedChar.star() & char('"'))
          .pick(1)
          .cast<String>()
          .map(FtlString.fromString);

  SettableParser<FtlSelectExpression> selectExpression = undefined();
  SettableParser<FtlInlineExpression> inlineExpression = undefined();

  Parser<FtlInlinePlaceable> inlinePlaceable = (char('{') &
          blank.optional() &
          (selectExpression | inlineExpression) &
          blank.optional() &
          char('}'))
      .pick(2)
      .map((raw) => FtlInlinePlaceable(placeable: raw));
  Parser<FtlBlockPlaceable> blockPlaceable =
      (blankBlock & blankInline.optional() & inlinePlaceable).pick(2).cast();

  Parser<FtlPatternElement> patternElement =
      (inlineText | blockText | inlinePlaceable | blockPlaceable)
          .map((raw) => FtlPatternElement(element: raw));
  Parser<FtlPattern> pattern = patternElement.plus().map(
      (List<FtlPatternElement> elements) =>
          FtlPattern(patternElements: elements));
  Parser<FtlAttribute> attribute = (lineEnd &
          blank.optional() &
          char('.') &
          identifier &
          blankInline.optional() &
          char('=') &
          blankInline.optional() &
          pattern)
      .map((List<dynamic> raw) =>
          FtlAttribute(identifier: raw[3], pattern: raw[7]));

  Parser<FtlNamedArgument> namedArgument = (identifier &
          (blank.optional() & char(':') & blank.optional()).flatten() &
          (stringLiteral | numberLiteral))
      .map((List<dynamic> parts) => FtlNamedArgument(parts[0], parts[2]));
  Parser<FtlArgument> argument = (namedArgument | inlineExpression)
      .map((raw) => FtlArgument(argument: raw));
  Parser<FtlArgumentList> argumentList =
      ((argument & blank.optional() & char(',') & blank.optional())
                  .pick(0)
                  .star() &
              argument.optional())
          .map((List raw) => FtlArgumentList(
              arguments: List.from([...raw[0], raw[1]]
                  .where((dynamic element) => element != null))));

  Parser<FtlCallArguments> callArguments =
      (char('(').trim(blank, blank) & argumentList & char(')').trim(blank))
          .pick(1)
          .map((dynamic args) => FtlCallArguments(arguments: args));
  Parser<FtlAttributeAccessor> attributeAccessor = (char('.') & identifier)
      .pick(1)
      .map((raw) => FtlAttributeAccessor(identifier: raw));
  Parser<FtlTermReference> termReference = (char('-') &
          identifier &
          attributeAccessor.optional() &
          callArguments.optional())
      .map((List<dynamic> raw) => FtlTermReference(
          identifier: raw[1],
          attributeAccessor: raw[2],
          callArguments: raw[3]));
  Parser<FtlMessageReference> messageReference =
      (identifier & attributeAccessor.optional()).map((List<dynamic> raw) =>
          FtlMessageReference(identifier: raw[0], attributeAccessor: raw[1]));
  Parser<FtlFunctionReference> functionReference = (identifier & callArguments)
      .map((List<dynamic> raw) =>
          FtlFunctionReference(identifier: raw[0], callArguments: raw[1]));
  Parser<FtlVariableReference> variableReference = (char('\$') & identifier)
      .pick(1)
      .map(
          (dynamic identifier) => FtlVariableReference(identifier: identifier));

  Parser<FtlVariantKey> variantKey = (char('[') &
          blank.optional() &
          (numberLiteral | identifier) &
          blank.optional() &
          char(']'))
      .pick(3)
      .map((dynamic key) => FtlVariantKey(key: key));
  Parser<FtlDefaultVariant> defaultVariant = (lineEnd &
          blank.optional() &
          char('*') &
          variantKey &
          blankInline.optional() &
          pattern)
      .map((List<dynamic> raw) =>
          FtlDefaultVariant(variantKey: raw[3], pattern: raw[5]));
  Parser<FtlVariant> variant = (lineEnd &
          blank.optional() &
          variantKey &
          blankInline.optional() &
          pattern)
      .map((List<dynamic> raw) =>
          FtlVariant(variantKey: raw[2], pattern: raw[4]));
  Parser<FtlVariantList> variantList =
      (variant.star() & defaultVariant & variant.star() & lineEnd).map(
          (List<dynamic> raw) =>
              FtlVariantList(defaultVariant: raw[1], variants: raw[2]));

  Parser<FtlTerm> term = (char('-') &
          identifier &
          char('=').trim(blank, blank) &
          pattern &
          attribute.star())
      .map((List<dynamic> raw) =>
          FtlTerm(identifier: raw[1], pattern: raw[3], attributes: raw[4]));
  Parser<FtlMessage> message = (identifier &
          char('=').trim(blankInline, blankInline) &
          ((pattern & attribute.star()) | attribute.plus()))
      .map((List<dynamic> raw) {
    assert(raw[2] is List && raw[2].isNotEmpty);
    if (raw[2][0] is FtlPattern) {
      return FtlMessage(
          identifier: raw[0],
          pattern: raw[2][0],
          attributes: List.castFrom((raw[2]).sublist(1)));
    } else {
      return FtlMessage(
          identifier: raw[0], attributes: raw[2] as List<FtlAttribute>);
    }
  });

  Parser<FtlEntry> entry =
      ((message & lineEnd).pick(0) | (term & lineEnd).pick(0) | commentLine)
          .map((raw) {
    if (raw is FtlMessage) return FtlEntry.forMessage(raw);
    if (raw is FtlTerm) return FtlEntry.forTerm(raw);
    if (raw is FtlCommentLine) return FtlEntry.forCommentLine(raw);
    assert(false, 'Unsupported type ${raw.runtimeType}: $raw');
    throw Exception('No fun');
  });

  selectExpression.set((inlineExpression &
          (blank.optional() & string('->') & blankInline.optional()).flatten() &
          variantList)
      .map((List<dynamic> raw) =>
          FtlSelectExpression(inlineExpression: raw[0], variantList: raw[2])));
  inlineExpression.set((stringLiteral |
          numberLiteral |
          functionReference |
          messageReference |
          termReference |
          variableReference |
          inlinePlaceable)
      .map((raw) => FtlInlineExpression(expression: raw)));

  Parser<FtlResource> resource = (entry | blankBlock | junk).star().map(
      (List<dynamic> raw) => FtlResource(resourceParts: List.castFrom(raw)));
  return resource;
}

Parser<FtlResource> _resourceParser = _setUpParser();

Result<FtlResource> parseFtl(String input) => _resourceParser.parse(input);
