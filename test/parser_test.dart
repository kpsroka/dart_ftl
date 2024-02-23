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

import 'dart:convert';
import 'dart:io';

import 'package:ftl/src/parser.dart';
import 'package:test/test.dart';

const List<String> _testFiles = [
  'testdata/leading_dots.ftl',
  'testdata/reference_expressions.ftl',
  'testdata/term_parameters.ftl',
  'testdata/select_expressions.ftl',
  'testdata/sparse_entries.ftl',
  'testdata/comments.ftl',
  'testdata/eof_comment.ftl',
  'testdata/multiline_values.ftl',
  'testdata/crlf.ftl',
  'testdata/junk.ftl',
  'testdata/member_expressions.ftl',
  'testdata/select_indent.ftl',
  'testdata/astral.ftl',
  'testdata/eof_value.ftl',
  'testdata/any_char.ftl',
  'testdata/literal_expressions.ftl',
  'testdata/variables.ftl',
  'testdata/call_expressions.ftl',
  'testdata/eof_id_equals.ftl',
  'testdata/terms.ftl',
  'testdata/variant_keys.ftl',
  'testdata/eof_empty.ftl',
  'testdata/tab.ftl',
  'testdata/mixed_entries.ftl',
  'testdata/cr.ftl',
  'testdata/whitespace_in_value.ftl',
  'testdata/obsolete.ftl',
  'testdata/escaped_characters.ftl',
  'testdata/eof_id.ftl',
  'testdata/messages.ftl',
  'testdata/callee_expressions.ftl',
  'testdata/numbers.ftl',
  'testdata/eof_junk.ftl',
  'testdata/zero_length.ftl',
  'testdata/placeables.ftl',
];

void main() {
  for (String testFile in _testFiles) {
    test('Testing parser with $testFile', () async {
      File ftlFile = File(testFile);
      expect(ftlFile.existsSync(), equals(true));

      String ftlString = await ftlFile.openRead().transform(utf8.decoder).join();
      parseFtl(ftlString);
    });
  }
}
