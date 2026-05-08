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
    // Prefer a candidate that fully matches a plate pattern
    for (final c in candidates) {
      if (isValidPlate(c)) return normalize(c);
    }
    // Fall back to the longest candidate (most likely to be the plate)
    if (candidates.isEmpty) return '';
    final sorted = [...candidates]..sort((a, b) => b.length.compareTo(a.length));
    return normalize(sorted.first);
  }

  static String _clean(String text) =>
      text.toUpperCase().replaceAll(RegExp(r'[\s\-_.]'), '');
}
