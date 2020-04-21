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
  final List<int> _items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                _items.add(DateTime.now().hashCode);
              });
            },
          )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverDiffAnimatedList<int>(
            items: _items,
            itemBuilder: (context, item, i) {
              return ListTile(
                title: Text(item.toString()),
                onTap: () {
                  setState(() {
                    assert(_items.indexOf(item) == i);
                    _items.removeAt(i);
                  });
                },
              );
            },
          )
        ],
      ),
    );
  }
}
