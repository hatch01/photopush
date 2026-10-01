import 'package:flutter_test/flutter_test.dart';
import 'package:photopush_flutter/core/utils/order_key.dart';

void main() {
  group('OrderKey utility tests', () {
    test('generateFirst returns base initial key', () {
      final first = OrderKey.generateFirst();
      expect(first, equals('000000'));
    });

    test('generateNext increments sequentially with padding', () {
      final first = OrderKey.generateFirst();
      final second = OrderKey.generateNext(first);
      final third = OrderKey.generateNext(second);

      expect(second, equals('000001'));
      expect(third, equals('000002'));
    });

    test('keyFromIndex preserves lexicographical order for first 1000 items', () {
      final keys = List.generate(1000, (i) => OrderKey.keyFromIndex(i));
      final sortedKeys = List.of(keys)..sort();

      expect(keys, equals(sortedKeys));
    });

    test('Lexicographical comparison strictly respects integer index ordering', () {
      final key0 = OrderKey.keyFromIndex(0);
      final key1 = OrderKey.keyFromIndex(1);
      final key99 = OrderKey.keyFromIndex(99);
      final key100 = OrderKey.keyFromIndex(100);

      expect(key0.compareTo(key1), lessThan(0));
      expect(key1.compareTo(key99), lessThan(0));
      expect(key99.compareTo(key100), lessThan(0));
    });
  });
}
