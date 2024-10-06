///
/// IRC Parsing Support Library
///
///
///       var parser = new RegExIrcParser();
///      var message = parser.convert(":some.server PRIVMSG #SomeChannel :Some Message");
///      // Use Message Instance
///
/// IRC Parsers are implemented as a Converter<String, Message>. This enables powerful socket transforms.
///
/// All IRC Parsers should conform to the IRC Specification, and optionally conform to IRC v3 Specifications.
///
/// Currently, the only builtin parser is [RegexIrcParser].
///
/// # Creating a Custom Parser
///
///      class MyIrcParser extends IrcParser {
///        @override
///        Message convert(String input) {
///          // Parsing Logic
///        }
///      }
///
library;

import 'dart:convert' show Converter;

import 'package:glob/glob.dart';

part 'src/parser/base.dart';
part 'src/parser/message.dart';
part 'src/parser/regex.dart';
part 'src/parser/hostmask.dart';
