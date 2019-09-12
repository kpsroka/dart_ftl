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

Parser _setUpParser() {
  Parser _line_end = (string('\u000D\u000A') | string('\u000A') | endOfInput()).flatten();
  Parser _blank_inline = char('\u0020').plus().flatten();
  Parser _blank_block = (_blank_inline & _line_end).plus().flatten();
  Parser _blank = (_blank_inline | _line_end).plus().flatten();

  Parser _junk_line = _line_end.not().star() & _line_end;
  Parser _junk = (_junk_line & ((letter() | char('#') | char('-')).not() & _junk_line).star()).flatten();

  Parser _special_text_char = char('{') | char('}');
  Parser _text_char = (_special_text_char.or(_line_end)).not() & any();
  Parser _indented_char = (char('.').or(char('*')).or(char('['))).not() & _text_char;
  Parser _special_quoted_char = (char('"') | char('\\'));
  Parser _special_escape = (char('\\') & _special_quoted_char).flatten();
  Parser _unicode_escape_4 = (string('\\u') & word().times(4)).flatten();
  Parser _unicode_escape_6 = (string('\\U') & word().times(6)).flatten();
  Parser _unicode_escape = _unicode_escape_4 | _unicode_escape_6;
  Parser _quoted_char = _text_char | _special_escape | _unicode_escape;

  Parser _inline_text = _text_char.plus().flatten();
  Parser _block_text = (_blank_block & _blank_inline & _indented_char & _inline_text.optional()).flatten();

  Parser _comment_char = _line_end.not() & any();
  Parser _comment_line = (string('###') | string('##') | string('#')) & (char(' ') & _comment_char.star()).optional([]) & _line_end;

  Parser _identifier = (letter() & (word() | char('_') | char('-')).star()).flatten();
  Parser _number_literal = ((char('-').optional('')) & digit().plus() & (char('.') & digit().plus()).optional([''])).flatten();
  Parser _string_literal = (char('"') & _quoted_char.star() & char('"')).flatten();

  SettableParser _select_expression = undefined();
  SettableParser _inline_expression = undefined();

  Parser _inline_placeable = char('{') & _blank.optional('') & (_select_expression | _inline_expression) & _blank.optional('') & char('}');
  Parser _block_placeable = _blank_block & _blank_inline.optional() & _inline_placeable;

  Parser _pattern_element = (_inline_text | _block_text | _inline_placeable | _block_placeable);
  Parser _pattern = _pattern_element.plus().flatten();
  Parser _attribute = _line_end & _blank.optional('') & char('.') & _identifier & _blank_inline.optional('') & char('=') & _blank_inline.optional('') & _pattern;

  Parser _named_argument = _identifier & _blank.optional('') & char(':') & _blank.optional('') & (_string_literal | _number_literal);
  Parser _argument = _named_argument | _inline_expression;
  Parser _argument_list = (_argument & _blank.optional('') & char(',') & _blank.optional('')).star() & _argument.optional('');
  Parser _call_arguments = char('(').trim(_blank, _blank) & _argument_list & char(')').trim(_blank);
  Parser _attribute_accessor = char('.') & _identifier;
  Parser _term_reference = char('-') & _identifier & _attribute_accessor.optional('') & _call_arguments.optional('');
  Parser _message_reference = _identifier & _attribute_accessor.optional('');
  Parser _function_reference = _identifier & _call_arguments;
  Parser _variable_reference = char('\$') & _identifier;

  Parser _variant_key = char('[') & _blank.optional('') & (_number_literal | _identifier) & _blank.optional('') & char(']');
  Parser _default_variant = (_line_end & _blank.optional('') & char('*') & _variant_key & _blank_inline.optional('') & _pattern).flatten();
  Parser _variant = (_line_end & _blank.optional('') & _variant_key & _blank_inline.optional('') & _pattern).flatten();
  Parser _variant_list = (_variant.star() & _default_variant & _variant.star() & _line_end).flatten();

  Parser _term = char('-') & _identifier & char('=').trim(_blank, _blank) & _pattern & _attribute.star();
  Parser _message = _identifier & char('=').trim(_blank_inline, _blank_inline) & ((_pattern & _attribute.star()) | _attribute.plus());
  Parser _entry = (_message & _line_end) | (_term & _line_end) | _comment_line;

  _select_expression.set(_inline_expression & _blank.optional('') & string('->') & _blank_inline.optional('') & _variant_list);
  _inline_expression.set(_string_literal | _number_literal | _function_reference | _message_reference | _term_reference | _variable_reference | _inline_placeable);

  Parser _resource = (_entry | _blank_block | _junk).star();
  return _resource;
}

Parser _resourceParser = _setUpParser();

Result parseFtl(String input) => _resourceParser.parse(input);
