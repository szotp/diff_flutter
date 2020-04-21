import 'dart:math';

import 'package:flutter/material.dart';
import 'package:diff_flutter/diff_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: ExamplePage(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  @override
  _ExamplePageState createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final _random = Random();
  final List<int> _items = [];

  void _addItem() {
    setState(() {
      _items.add(DateTime.now().hashCode);
    });
  }

  void _removeItem() {
    setState(() {
      _items.removeAt(_random.nextInt(_items.length));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addItem,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _removeItem,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverDiffAnimatedList<int>(
            items: _items.toList(),
            itemBuilder: (context, item, i) {
              return ListTile(
                title: Text(item.toString()),
              );
            },
          )
        ],
      ),
    );
  }

  Widget buildAdvanced() {
    return SliverDiffAnimatedList<int>(
      items: _items.toList(),
      itemBuilder: (context, item, i) {
        return ListTile(
          title: Text(item.toString()),
        );
      },
      // use default animation with custom curve
      transition: (child, animation, isDelete) =>
          SliverDiffAnimatedList.buildSizeTransition(
        child,
        CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        isDelete,
      ),
      insertDuration: const Duration(milliseconds: 500),
      removeDuration: const Duration(milliseconds: 200),
    );
  }
}
