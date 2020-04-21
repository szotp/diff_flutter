import 'dart:collection';
import 'dart:typed_data';

// Original source: http://www.mathertel.de/Diff/ViewSrc.aspx

bool debugPrintDiffDuration = false;

/// shortest middle snake return date
class _ShortestMiddleSnake {
  int x, y;
}

class _DiffData extends UnmodifiableListView {
  Int8List modified;

  _DiffData(List data) : super(data) {
    modified = Int8List(data.length + 2);
  }
}

class DiffItem {
  final int startA;
  final int startB;
  final int deletedA;
  final int insertedB;

  DiffItem({this.startA, this.startB, this.deletedA, this.insertedB});

  @override
  String toString() {
    return 'DiffItem(startA: $startA, startB: $startB, deletedA: $deletedA, insertedB: $insertedB)';
  }
}

extension Diff<T> on List<T> {
  List<DiffItem> diff(List<T> target, {int Function(T) identity}) {
    Stopwatch watch;

    assert(() {
      if (debugPrintDiffDuration) {
        watch = Stopwatch();
        watch.start();
      }

      return true;
    }());

    final dataA = _DiffData(identity != null ? map(identity).toList() : this);
    final dataB =
        _DiffData(identity != null ? target.map(identity).toList() : target);

    final max = dataA.length + dataB.length + 1;
    final downVector = Int64List(2 * max + 2);
    final upVector = Int64List(2 * max + 2);

    longestCommonSubsequence(
        dataA, 0, dataA.length, dataB, 0, dataB.length, downVector, upVector);
    final result = createDiffs(dataA, dataB);

    assert(() {
      if (debugPrintDiffDuration) {
        watch.stop();
        // ignore: avoid_print
        print(
            'Diff with ${result.length} changes, ${target.length} items, took ${watch.elapsedMicroseconds} microseconds');
      }

      return true;
    }());

    return result;
  }
}

extension DiffItemExt on List<DiffItem> {
  void apply(
      {void Function(int index) delete,
      void Function(int index, int targetIndex) insert}) {
    int offset = 0;
    for (final item in this) {
      for (int i = 0; i < item.deletedA; i++) {
        delete(item.startA + offset);
      }

      for (int i = 0; i < item.insertedB; i++) {
        insert(item.startA + offset + i, item.startB + i);
      }

      offset -= item.deletedA;
      offset += item.insertedB;
    }
  }
}

/// This is the algorithm to find the Shortest Middle Snake (SMS).
_ShortestMiddleSnake findShortestMiddleSnake(
    _DiffData dataA,
    int lowerA,
    int upperA,
    _DiffData dataB,
    int lowerB,
    int upperB,
    Int64List downVector,
    Int64List upVector) {
  final ret = _ShortestMiddleSnake();
  final max = dataA.length + dataB.length + 1;

  final downK = lowerA - lowerB; // the k-line to start the forward search
  final upK = upperA - upperB; // the k-line to start the reverse search

  final delta = (upperA - lowerA) - (upperB - lowerB);
  final oddDelta = (delta & 1) != 0;

  // The vectors in the publication accepts negative indexes. the vectors implemented here are 0-based
  // and are access using a specific offset: UpOffset UpVector and DownOffset for DownVektor
  final downOffset = max - downK;
  final upOffset = max - upK;

  final maxD = ((upperA - lowerA + upperB - lowerB) ~/ 2) + 1;

  // Debug.Write(2, "SMS", String.Format("Search the box: A[{0}-{1}] to B[{2}-{3}]", LowerA, UpperA, LowerB, UpperB));

  // init vectors
  downVector[downOffset + downK + 1] = lowerA;
  upVector[upOffset + upK - 1] = upperA;

  for (int D = 0; D <= maxD; D++) {
    // Extend the forward path.
    for (int k = downK - D; k <= downK + D; k += 2) {
      // Debug.Write(0, "SMS", "extend forward path " + k.ToString());

      // find the only or better starting point
      int x, y;
      if (k == downK - D) {
        x = downVector[downOffset + k + 1]; // down
      } else {
        x = downVector[downOffset + k - 1] + 1; // a step to the right
        if ((k < downK + D) && (downVector[downOffset + k + 1] >= x)) {
          x = downVector[downOffset + k + 1];
        } // down
      }
      y = x - k;

      // find the end of the furthest reaching forward D-path in diagonal k.
      while ((x < upperA) && (y < upperB) && (dataA[x] == dataB[y])) {
        x++;
        y++;
      }
      downVector[downOffset + k] = x;

      // overlap ?
      if (oddDelta && (upK - D < k) && (k < upK + D)) {
        if (upVector[upOffset + k] <= downVector[downOffset + k]) {
          ret.x = downVector[downOffset + k];
          ret.y = downVector[downOffset + k] - k;
          // ret.u = UpVector[UpOffset + k];      // 2002.09.20: no need for 2 points
          // ret.v = UpVector[UpOffset + k] - k;
          return ret;
        } // if
      } // if

    } // for k

    // Extend the reverse path.
    for (int k = upK - D; k <= upK + D; k += 2) {
      // Debug.Write(0, "SMS", "extend reverse path " + k.ToString());

      // find the only or better starting point
      int x, y;
      if (k == upK + D) {
        x = upVector[upOffset + k - 1]; // up
      } else {
        x = upVector[upOffset + k + 1] - 1; // left
        if ((k > upK - D) && (upVector[upOffset + k - 1] < x)) {
          x = upVector[upOffset + k - 1];
        } // up
      } // if
      y = x - k;

      while ((x > lowerA) && (y > lowerB) && (dataA[x - 1] == dataB[y - 1])) {
        x--;
        y--; // diagonal
      }
      upVector[upOffset + k] = x;

      // overlap ?
      if (!oddDelta && (downK - D <= k) && (k <= downK + D)) {
        if (upVector[upOffset + k] <= downVector[downOffset + k]) {
          ret.x = downVector[downOffset + k];
          ret.y = downVector[downOffset + k] - k;
          // ret.u = UpVector[UpOffset + k];     // 2002.09.20: no need for 2 points
          // ret.v = UpVector[UpOffset + k] - k;
          return ret;
        } // if
      } // if

    } // for k

  } // for D

  throw "the algorithm should never come here.";
}

void longestCommonSubsequence(
    _DiffData dataA,
    int _lowerA,
    int _upperA,
    _DiffData dataB,
    int _lowerB,
    int _upperB,
    Int64List downVector,
    Int64List upVector) {
  int lowerA = _lowerA;
  int upperA = _upperA;
  int lowerB = _lowerB;
  int upperB = _upperB;

  // Fast walkthrough equal lines at the start
  while (lowerA < upperA && lowerB < upperB && dataA[lowerA] == dataB[lowerB]) {
    lowerA++;
    lowerB++;
  }

  // Fast walkthrough equal lines at the end
  while (lowerA < upperA &&
      lowerB < upperB &&
      dataA[upperA - 1] == dataB[upperB - 1]) {
    --upperA;
    --upperB;
  }

  if (lowerA == upperA) {
    // mark as inserted lines.
    while (lowerB < upperB) {
      dataB.modified[lowerB++] = 1;
    }
  } else if (lowerB == upperB) {
    // mark as deleted lines.
    while (lowerA < upperA) {
      dataA.modified[lowerA++] = 1;
    }
  } else {
    // Find the middle snakea and length of an optimal path for A and B
    final smsrd = findShortestMiddleSnake(
        dataA, lowerA, upperA, dataB, lowerB, upperB, downVector, upVector);
    // Debug.Write(2, "MiddleSnakeData", String.Format("{0},{1}", smsrd.x, smsrd.y));

    // The path is from LowerX to (x,y) and (x,y) to UpperX
    longestCommonSubsequence(
        dataA, lowerA, smsrd.x, dataB, lowerB, smsrd.y, downVector, upVector);
    longestCommonSubsequence(dataA, smsrd.x, upperA, dataB, smsrd.y, upperB,
        downVector, upVector); // 2002.09.20: no need for 2 points
  }
}

List<DiffItem> createDiffs(_DiffData dataA, _DiffData dataB) {
  final a = <DiffItem>[];

  int startA, startB;
  int lineA, lineB;

  lineA = 0;
  lineB = 0;
  while (lineA < dataA.length || lineB < dataB.length) {
    if ((lineA < dataA.length) &&
        (dataA.modified[lineA] == 0) &&
        (lineB < dataB.length) &&
        (dataB.modified[lineB] == 0)) {
      // equal lines
      lineA++;
      lineB++;
    } else {
      // maybe deleted and/or inserted lines
      startA = lineA;
      startB = lineB;

      while (lineA < dataA.length &&
          (lineB >= dataB.length || dataA.modified[lineA] == 1)) {
        lineA++;
      }

      while (lineB < dataB.length &&
          (lineA >= dataA.length || dataB.modified[lineB] == 1)) {
        lineB++;
      }

      if ((startA < lineA) || (startB < lineB)) {
        a.add(DiffItem(
          startA: startA,
          startB: startB,
          deletedA: lineA - startA,
          insertedB: lineB - startB,
        ));
      } // if
    } // if
  } // while

  return a;
}