import 'dart:convert';
import 'dart:io';

import 'package:ftl/src/parser.dart';
import 'package:test/test.dart';

const List<String> _TEST_FILES = [
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
  for (String testFile in _TEST_FILES) {
    test('Testing parser with $testFile', () async {
      File ftlFile = File(testFile);
      expect(ftlFile.existsSync(), equals(true));

      String ftlString = await ftlFile.openRead().transform(utf8.decoder).join();
      parseFtl(ftlString);
    });
  }
}
