import 'package:diff/diff.dart';
import 'package:test/test.dart';

void main() {
  group('diff', () {
    test('simple', () {
      final a = [1, 2, 3];
      final b = [2, 3, 5];

      final diff = a.diff(b);
      diff.apply(
        insert: (i, bi) => a.insert(i, b[bi]),
        delete: (i) => a.removeAt(i),
      );

      assert(a.toString() == b.toString());
    });
  });
}
