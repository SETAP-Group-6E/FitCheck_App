// Utility helpers for caption preview/truncation

String makePreview(String text, int limit) {
  if (text.length <= limit) return text;
  final cut = text.substring(0, limit);
  final matches = RegExp(r'[\s\n]').allMatches(cut).toList();
  if (matches.isNotEmpty) {
    final last = matches.last.start;
    if (last > 0) return cut.substring(0, last).trimRight();
  }
  return cut;
}
