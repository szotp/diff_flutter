import 'dart:io';
import 'dart:math';

import 'package:diff/diff.dart';

final _r = Random();

void main() {
  bench('ints')
    ..setRandomInts(1000, 50)
    ..swap(50)
    ..run();

  bench('items')
    ..setRandomItems(1000)
    ..swap(50)
    ..run();

  bench('shuffle')
    ..setRandomInts(1000, 50)
    ..shuffle()
    ..run();

  exit(0);
  print('done');
}

Test bench(String name) => Test(name);

class Test {
  List source;
  List target;
  Duration duration;
  List<DiffItem> result;

  final String name;

  Test(this.name);

  void shuffle() {
    target.shuffle();
  }

  void setRandomInts(int length, int max) {
    source = List.generate(length, (i) => _r.nextInt(max));
    target = source.toList();
  }

  void setRandomItems(int length) {
    source = List.generate(
        length, (i) => Item(_r.nextInt(50), _r.nextInt(50).toString()));
    target = source.toList();
  }

  void swap(int mutations) {
    for (int i = 0; i < mutations; i++) {
      final index1 = _r.nextInt(target.length);
      final index2 = _r.nextInt(target.length);

      final temp = target[index1];
      target[index1] = target[index2];
      target[index2] = temp;
    }
  }

  void run() {
    final sw = Stopwatch()..start();
    result = source.diff(target);
    sw.stop();
    duration = sw.elapsed;

    final msec = sw.elapsedMicroseconds / 1000;
    final msecString = msec.toStringAsFixed(3).padLeft(10);

    print(
        '$msecString ms: $name, changes:${result.length}, length: ${source.length}');
  }
}

class Item {
  final int number;
  final String text;

  Item(this.number, this.text);

  @override
  int get hashCode => number.hashCode ^ text.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(other, this) ||
        (other is Item) && other.number == number && other.text == text;
  }
}
