library diff_flutter;

import 'package:flutter/widgets.dart';
import 'package:diff/diff.dart';

typedef DiffAnimatedTransitionFunc = Widget Function({
  Widget child,
  Animation<double> animation,
  bool delete,
});

class SliverDiffAnimatedList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final DiffAnimatedTransitionFunc transition;
  final Duration insertDuration;
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
      {Widget child, Animation<double> animation, bool delete}) {
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
                animation: animation,
                child: child,
                delete: true,
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
    _current = widget.items.toList();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedList(
      key: _key,
      initialItemCount: _initialItemCount,
      itemBuilder: (context, i, animation) {
        final child = widget.itemBuilder(context, _current[i], i);
        return widget.transition(
          animation: animation,
          child: child,
          delete: false,
        );
      },
    );
  }
}
