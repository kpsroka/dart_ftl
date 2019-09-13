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

abstract class _FtlString {
  final String content;

  _FtlString(this.content) : assert(content != null);
}

class FtlJunk extends _FtlString {
  FtlJunk(String content) : super(content);
}

class FtlIdentifier extends _FtlString {
  FtlIdentifier(String content) : super(content);
}

class FtlStringLiteral extends _FtlString {
  FtlStringLiteral(String content) : super(content);
}

class FtlNumberLiteral extends _FtlString {
  final int value;

  FtlNumberLiteral(String content)
      : this.value = int.parse(content),
        super(content);
}

class FtlAttributeAccessor extends _FtlString {
  FtlAttributeAccessor(String content) : super(content);
}

class FtlNamedArgument {
  final FtlIdentifier identifier;

  // Either FtlNumberLiteral or FtlStringLiteral.
  final dynamic literal;

  FtlNamedArgument(this.identifier, this.literal)
      : assert(identifier != null),
        assert(literal is FtlNumberLiteral || literal is FtlStringLiteral);
}

class FtlVariantKey {
  // Either FtlNumberLiteral or FtlIdentifier.
  final dynamic key;

  FtlVariantKey(this.key)
      : assert(key is FtlNumberLiteral || key is FtlIdentifier);
}
