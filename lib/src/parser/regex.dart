part of '../../parser.dart';

/// Regular Expression based IRC Parser
class RegexIrcParser extends IrcParser {
  /// Basic Regular Expression for IRC Parsing.
  static final kLinePattern = RegExp(
      r'^(?:@([^\r\n ]*) +|())(?::([^\r\n ]+) +|())([^\r\n ]+)(?: +([^:\r\n ]+[^\r\n ]*(?: +[^:\r\n ]+[^\r\n ]*)*)|())?(?: +:([^\r\n]*)| +())?[\r\n]*$');

  @override
  Message convert(String line) {
    line = line.trimLeft();
    List<String> match;
    {
      var parsed = kLinePattern.firstMatch(line);

      if (parsed == null) {
        throw FormatException('Unable to parse line: $line');
      }

      match = List<String>.generate(parsed.groupCount + 1,
          (index) => parsed.group(index) ?? ''); // Ensure non-null values
    }

    var tagStuff = match[1];
    var hostmask = match[3];
    var command = match[5];
    var param = match[6];
    var msg = match[8];
    var parameters = param.isNotEmpty ? param.split(' ') : <String>[];
    var tags = <String, String>{};

    if (tagStuff.isNotEmpty) {
      tags = IrcParserSupport.parseTags(tagStuff);
    }

    return Message(
        line: line,
        hostmask: hostmask,
        command: command,
        message: msg,
        parameters: parameters,
        tags: tags);
  }
}
