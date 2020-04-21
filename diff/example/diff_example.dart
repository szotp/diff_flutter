import 'package:diff/diff.dart';

void main() {
  final a = [1, 2, 3];
  final b = [1, 4, 2];
  final diff = a.diff(b);

  diff.apply(
    delete: (i) => a.removeAt(i),
    insert: (i, ib) => a.insert(i, b[i]),
  );

  // ignore: avoid_print
  print(a);
  assert(b.toString() == a.toString());
}
