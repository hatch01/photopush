/// Basic fractional indexing implementation for local ordering.
/// In a real production app, this would use a robust base62/fractional indexing algorithm.
/// For now, we'll use a simple string append strategy to ensure inserts between elements.
class OrderKey {
  static String generateFirst() => 'A';
  
  static String generateNext(String previous) {
    return '${previous}a'; // Very naive approach for MVP, normally we'd increment the char
  }
}
