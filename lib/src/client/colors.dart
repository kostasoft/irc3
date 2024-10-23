part of '../../client.dart';

/// IRC Message Colors
class Color {
  static Map<String, String> map = {
    'BLUE': '\u000312',
    'RESET': '\u000f',
    'NORMAL': '\u000f',
    'BOLD': '\u0002',
    'UNDERLINE': '\u001f',
    'REVERSE': '\u0016',
    'WHITE': '\u000300',
    'BLACK': '\u000301',
    'DARK_BLUE': '\u000302',
    'DARK_GREEN': '\u000303',
    'RED': '\u000304',
    'BROWN': '\u000305',
    'PURPLE': '\u000306',
    'OLIVE': '\u000307',
    'YELLOW': '\u000308',
    'GREEN': '\u000309',
    'TEAL': '\u000310',
    'CYAN': '\u000311',
    'MAGENTA': '\u000313',
    'DARK_GRAY': '\u000314',
    'LIGHT_GRAY': '\u000315',
    'ITALICS': '\u001d',
  };

  factory Color() => throw UnsupportedError("Sorry, Color can't be instantiated");

  /// Puts the Color String of [color] in front of [input] and ends with [endColor].
  static String wrap(String input, String color, [String endColor = 'reset']) =>
      '${forName(color)}${input}${forName(endColor)}';

  /// Gets a Color by the name of [input]. If no such color exists it returns null.
  static String? forName(String input) {
    var name = input.replaceAll(' ', '_').toUpperCase();
    return map[name];
  }

  /// Gets a Mapping of Color Names to Color Beginnings
  static Map<String, String> allColors() {
    var all = <String, String>{};
    map.forEach((key, value) {
      final name = key.replaceAll('_', ' ').toLowerCase();
      all[name] = value;
    });
    return all;
  }

  static String sanitize(String message) {
    var buffer = StringBuffer();
    for (var i = 0; i < message.length; i++) {
      if (i >= message.length) break;
      var c = message[i];
      if (c == '\u0003') {
        i += 2;
      } else if (c != '\u000f' &&
          c != '\u0016' &&
          c != '\u0002' &&
          c != '\u001d') {
        buffer.write(c);
      }
    }
    return buffer.toString();
  }
}
