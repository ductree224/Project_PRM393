import 'package:flutter/foundation.dart';

class MultiSelectController<T> extends ChangeNotifier {
  final Set<T> _selected = <T>{};
  bool _selectionMode = false;

  bool get isSelectionMode => _selectionMode;
  int get selectedCount => _selected.length;
  Set<T> get selectedItems => Set<T>.unmodifiable(_selected);

  bool isSelected(T item) => _selected.contains(item);

  void enterSelectionMode([T? item]) {
    _selectionMode = true;
    if (item != null) {
      _selected.add(item);
    }
    notifyListeners();
  }

  void toggle(T item) {
    _selectionMode = true;
    if (_selected.contains(item)) {
      _selected.remove(item);
    } else {
      _selected.add(item);
    }

    if (_selected.isEmpty) {
      _selectionMode = false;
    }
    notifyListeners();
  }

  void selectAll(Iterable<T> items) {
    _selectionMode = true;
    _selected
      ..clear()
      ..addAll(items);
    notifyListeners();
  }

  void clear() {
    _selected.clear();
    _selectionMode = false;
    notifyListeners();
  }
}
