import 'dart:io';
import 'dart:math';

import 'package:diff/diff.dart';

final _r = Random(0);

void main() {
  [1].diff([1]);

  bench('ints')
    ..setRandomInts(1000, 50)
    ..swap(50)
    ..run(false);

  bench('ints')
    ..setRandomInts(1000, 50)
    ..swap(50)
    ..run(true);

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

  void run([bool shouldPrint = true]) {
    const steps = 50;
    final timings = List<int>(steps);

    for (int i = 0; i < steps; i += 1) {
      final prev = result;

      final sw = Stopwatch();
      sw.start();
      result = source.diff(target);
      sw.stop();
      timings[i] = sw.elapsedMicroseconds;

      if (prev != null && prev.length != result.length) {
        throw 'error';
      }
    }

    final msec = trimmedAverage(timings) / 1000 / 5;
    final msecString = msec.toStringAsFixed(3).padLeft(10);

    if (shouldPrint) {
      print(
          '$msecString ms: $name, changes:${result.length}, length: ${source.length}');
    }
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

int trimmedAverage(List<int> list) {
  list.sort();

  int acc = 0;

  for (int i = 1; i < list.length - 2; i++) {
    acc += list[i];
  }

  return acc ~/ list.length - 2;
}
