# diff_flutter

Automatically animates list using a diff alghoritm.

## Example

Use your favorite state management to modify contents of a list, and then simply provide copies of that list to the widget.

```dart
SliverDiffAnimatedList<int>(
  items: _items.toList(),
  itemBuilder: (context, item, i) {
    return ListTile(
      title: Text(item.toString()),
    );
  },
)
```

## Customizations

Widget provides few optional parameters to customize the animation:

```dart
SliverDiffAnimatedList<int>(
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
```

## Alghoritm

This package uses algorithm published in "An O(ND) Difference Algorithm and its Variations" by Eugene Myers. Code was ported from C# available at http://www.mathertel.de/Diff/.