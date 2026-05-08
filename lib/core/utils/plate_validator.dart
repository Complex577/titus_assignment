class PlateValidator {
  PlateValidator._();

  // Ordered from most-specific to least-specific so stricter patterns win first
  static final List<RegExp> _patterns = [
    // Indian: KA01AB1234, MH04CD5678
    RegExp(r'^[A-Z]{2}\d{2}[A-Z]{1,3}\d{4}$'),
    // UK: AB12CDE
    RegExp(r'^[A-Z]{2}\d{2}[A-Z]{3}$'),
    // US / generic: ABC1234, 1ABC234, 1234ABC
    RegExp(r'^[A-Z]{1,3}\d{3,4}[A-Z]{0,2}$'),
    RegExp(r'^\d{1,4}[A-Z]{2,3}\d{0,4}$'),
    // European short: AB1234, A1234B
    RegExp(r'^[A-Z]{1,2}\d{3,5}$'),
    RegExp(r'^[A-Z]{1}\d{4}[A-Z]{1,2}$'),
    // Generic: 4–10 pure alphanumeric
    RegExp(r'^[A-Z0-9]{4,10}$'),
  ];

  /// Returns true if [text] (after stripping spaces/hyphens) matches a known plate format.
  static bool isValidPlate(String text) {
    final cleaned = _clean(text);
    if (cleaned.length < 4 || cleaned.length > 12) return false;
    return _patterns.any((p) => p.hasMatch(cleaned));
  }

  /// Upper-cases and trims the text.
  static String normalize(String text) =>
      text.toUpperCase().replaceAll(RegExp(r'\s+'), ' ').trim();

  /// From a list of candidate strings, returns the best plate match.
  static String extractBest(List<String> candidates) {
    if (candidates.isEmpty) return '';

    final normalized = candidates
        .map(normalize)
        .where((candidate) => _clean(candidate).isNotEmpty)
        .toSet()
        .toList();

    normalized.sort((a, b) => scoreCandidate(b).compareTo(scoreCandidate(a)));
    return normalized.first;
  }

  /// Gives fuller mixed letter/number plates a better score than short partial hits.
  static int scoreCandidate(String text) {
    final cleaned = _clean(text);
    if (cleaned.isEmpty) return 0;

    final hasLetters = RegExp(r'[A-Z]').hasMatch(cleaned);
    final hasDigits = RegExp(r'\d').hasMatch(cleaned);
    final isValid = isValidPlate(text);
    final compactLength = cleaned.length;

    var score = compactLength;
    if (hasLetters) score += 6;
    if (hasDigits) score += 6;
    if (hasLetters && hasDigits) score += 10;
    if (isValid) score += 20;

    return score;
  }

  static String _clean(String text) =>
      text.toUpperCase().replaceAll(RegExp(r'[\s\-_.]'), '');
}
