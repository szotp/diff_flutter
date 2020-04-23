library diff_flutter;

import 'package:flutter/widgets.dart';
import 'package:diff/diff.dart';

typedef DiffAnimatedTransitionFunc = Widget Function(
  Widget child,
  Animation<double> animation,
  bool delete,
);

class SliverDiffAnimatedList<T> extends StatefulWidget {
  /// Passed items must not be modified afterwards.
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;

  /// Provides animation for insert/delete. SizeTransition+FadeTransition by default.
  final DiffAnimatedTransitionFunc transition;

  /// Default: 300 msec
  final Duration insertDuration;

  /// Default: 300 msec
  final Duration removeDuration;

  const SliverDiffAnimatedList({
    Key key,
    @required this.items,
    @required this.itemBuilder,
    this.transition = buildSizeTransition,
    this.insertDuration = const Duration(milliseconds: 300),
    this.removeDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  _SliverDiffAnimatedListState<T> createState() =>
      _SliverDiffAnimatedListState<T>();

  static Widget buildSizeTransition(
    Widget child,
    Animation<double> animation,
    bool isDelete,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

class _SliverDiffAnimatedListState<T> extends State<SliverDiffAnimatedList<T>> {
  int _initialItemCount;
  final _key = GlobalKey<SliverAnimatedListState>();
  List<T> _current;

  @override
  void initState() {
    super.initState();

    _saveCurrent();
    _initialItemCount = _current.length;
  }

  @override
  void didUpdateWidget(SliverDiffAnimatedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.items == widget.items) {
      return;
    }

    int offset = 0;

    _current.diff(widget.items).apply(
      delete: (i) {
        final item = _current[i + offset];
        offset--;
        return _key.currentState.removeItem(
          i,
          (context, animation) {
            final child = widget.itemBuilder(context, item, i);
            return IgnorePointer(
              ignoring: true,
              child: widget.transition(
                child,
                animation,
                true,
              ),
            );
          },
          duration: widget.removeDuration,
        );
      },
      insert: (i, ti) {
        offset++;
        return _key.currentState.insertItem(i, duration: widget.insertDuration);
      },
    );
    _saveCurrent();
  }

  void _saveCurrent() {
    _current = widget.items;
  }

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedList(
      key: _key,
      initialItemCount: _initialItemCount,
      itemBuilder: (context, i, animation) {
        final child = widget.itemBuilder(context, _current[i], i);
        return widget.transition(
          child,
          animation,
          false,
        );
      },
    );
  }
}
