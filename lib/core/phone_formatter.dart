class PhoneFormatter {
  static String digitsOnly(String input) => input.replaceAll(RegExp(r'[^0-9]'), '');

  // Formats Brazilian numbers like +55 (11) 99999-9999
  static String formatBr(String input) {
    final d = digitsOnly(input);
    // Ensure it includes country code; if not, assume it starts with 55 + 2-digit area
    String country = '';
    String rest = d;
    if (d.startsWith('55') && d.length >= 12) {
      country = '+55';
      rest = d.substring(2);
    }
    // After removing 55: AA + 8/9 digits
    if (rest.length < 10) {
      // Fallback: just return input
      return input;
    }
    final dd = rest.substring(0, 2);
    final body = rest.substring(2);
    final part1 = body.length == 9 ? body.substring(0, 5) : body.substring(0, 4);
    final part2 = body.length == 9 ? body.substring(5) : body.substring(4);
    final cc = country.isNotEmpty ? '$country ' : '';
    return '$cc($dd) $part1-$part2';
  }
}
