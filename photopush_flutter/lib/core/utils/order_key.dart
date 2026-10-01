/// Fractional / sequential indexing implementation for local ordering.
/// Ensures that lexicographical sorting matches chronological / user-specified order.
class OrderKey {
  static String generateFirst() => '000000';

  static String generateNext(String previous) {
    final parsed = int.tryParse(previous);
    if (parsed != null) {
      return (parsed + 1).toString().padLeft(6, '0');
    }
    return '${previous}a';
  }

  static String keyFromIndex(int index) => index.toString().padLeft(6, '0');
}
