import 'dart:typed_data';

// Original source: http://www.mathertel.de/Diff/ViewSrc.aspx

/// shortest middle snake return date
class _ShortestMiddleSnake {
  final int x, y;

  const _ShortestMiddleSnake(this.x, this.y);
}

class _DiffData {
  final Int32List dataA;
  final Int8List modifiedA;

  final Int32List dataB;
  final Int8List modifiedB;

  final Int32List upVector;
  final Int32List downVector;

  const _DiffData({
    this.modifiedA,
    this.dataA,
    this.modifiedB,
    this.dataB,
    this.upVector,
    this.downVector,
  });

  // ignore: prefer_constructors_over_static_methods
  static _DiffData create<T>(
      List<T> listA, List<T> listB, int Function(T) identity) {
    final max = listA.length + listB.length + 1;
    final downVector = Int32List(2 * max + 2);
    final upVector = Int32List(2 * max + 2);

    return _DiffData(
      dataA: makeList(listA, identity),
      dataB: makeList(listB, identity),
      modifiedA: Int8List(listA.length + 2),
      modifiedB: Int8List(listB.length + 2),
      upVector: upVector,
      downVector: downVector,
    );
  }

  List<DiffItem> calculate() {
    longestCommonSubsequence(0, dataA.length, 0, dataB.length);
    return createDiffs();
  }

  /// This is the algorithm to find the Shortest Middle Snake (SMS).
  _ShortestMiddleSnake findShortestMiddleSnake(
      int lowerA, int upperA, int lowerB, int upperB) {
    int rx;
    int ry;
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
            rx = downVector[downOffset + k];
            ry = downVector[downOffset + k] - k;
            // ret.u = UpVector[UpOffset + k];      // 2002.09.20: no need for 2 points
            // ret.v = UpVector[UpOffset + k] - k;
            return _ShortestMiddleSnake(rx, ry);
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
            rx = downVector[downOffset + k];
            ry = downVector[downOffset + k] - k;
            // ret.u = UpVector[UpOffset + k];     // 2002.09.20: no need for 2 points
            // ret.v = UpVector[UpOffset + k] - k;
            return _ShortestMiddleSnake(rx, ry);
          } // if
        } // if

      } // for k

    } // for D

    throw "the algorithm should never come here.";
  }

  void longestCommonSubsequence(
    int _lowerA,
    int _upperA,
    int _lowerB,
    int _upperB,
  ) {
    int lowerA = _lowerA;
    int upperA = _upperA;
    int lowerB = _lowerB;
    int upperB = _upperB;

    // Fast walkthrough equal lines at the start
    while (
        lowerA < upperA && lowerB < upperB && dataA[lowerA] == dataB[lowerB]) {
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
        modifiedA[lowerB++] = 1;
      }
    } else if (lowerB == upperB) {
      // mark as deleted lines.
      while (lowerA < upperA) {
        modifiedB[lowerA++] = 1;
      }
    } else {
      // Find the middle snakea and length of an optimal path for A and B
      final smsrd = findShortestMiddleSnake(lowerA, upperA, lowerB, upperB);
      // Debug.Write(2, "MiddleSnakeData", String.Format("{0},{1}", smsrd.x, smsrd.y));

      // The path is from LowerX to (x,y) and (x,y) to UpperX
      longestCommonSubsequence(lowerA, smsrd.x, lowerB, smsrd.y);
      longestCommonSubsequence(smsrd.x, upperA, smsrd.y, upperB);
      // 2002.09.20: no need for 2 points
    }
  }

  List<DiffItem> createDiffs() {
    final a = <DiffItem>[];

    int startA, startB;
    int lineA, lineB;

    lineA = 0;
    lineB = 0;
    while (lineA < dataA.length || lineB < dataB.length) {
      if ((lineA < dataA.length) &&
          (modifiedA[lineA] == 0) &&
          (lineB < dataB.length) &&
          (modifiedB[lineB] == 0)) {
        // equal lines
        lineA++;
        lineB++;
      } else {
        // maybe deleted and/or inserted lines
        startA = lineA;
        startB = lineB;

        while (lineA < dataA.length &&
            (lineB >= dataB.length || modifiedA[lineA] == 1)) {
          lineA++;
        }

        while (lineB < dataB.length &&
            (lineA >= dataA.length || modifiedB[lineB] == 1)) {
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
}

Int32List makeList<T>(List<T> list, int Function(T) identity) {
  final ints = Int32List(list.length);
  for (int i = 0; i < list.length; i++) {
    ints[i] = identity(list[i]);
  }

  return ints;
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

extension ListDiffExtension<T> on List<T> {
  static int _getHashcode(item) => item.hashCode;

  List<DiffItem> diff(List<T> target,
      [int Function(T) identity = _getHashcode]) {
    final data = _DiffData.create(this, target, identity);

    return data.calculate();
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
