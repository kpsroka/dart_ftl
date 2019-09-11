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

library dart_ftl;

import 'package:petitparser/petitparser.dart';

Parser _line_end = (string('\u000D\u000A') | string('\u000A') | endOfInput()).flatten();
Parser _blank_inline = char('\u0020').plus().flatten();
Parser _blank_block = (_blank_inline & _line_end).plus().flatten();
Parser _blank = (_blank_inline | _line_end).plus().flatten();

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

Parser _select_expression = undefined();
Parser _inline_expression = undefined();

Parser _inline_placeable = char('{') & _blank.optional('') & (_select_expression | _inline_expression) & _blank.optional('') & char('}');
Parser _block_placeable = _blank_block & _blank_inline.optional() & _inline_placeable;


parseFtl(String input) {


}
