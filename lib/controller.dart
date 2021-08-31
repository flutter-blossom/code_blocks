import 'package:better_print/better_print.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter_widget_model/flutter_widget_model.dart';

enum InsertMode { prepend, append, insert, replace, changeParent }

enum BlockType {
  SetState,
  Set,
  Return,
  If,
  Else,
  For,
  While,
  Add,
  Subtract,
  Multiply,
  Divide,
  Error
}

class Block {
  Block(
      {required this.key,
      required this.type,
      required this.data,
      this.children = const []});
  final String key;
  final BlockType type;
  final List<Block> children;
  final Map<String, dynamic> data;
  bool get isParent => children.isNotEmpty;

  factory Block.fromMap(Map<String, dynamic> map) {
    return Block(
        key: map['key'],
        data: map['data'],
        type: EnumToString.fromString(BlockType.values, map['type']) ?? BlockType.Error,
        children: (map['children'] as List).map((e) => Block.fromMap(e)).toList());
  }

  Block copyWith(
          {String? key,
          BlockType? type,
          Map<String, dynamic>? data,
          List<Block>? children}) =>
      Block(
          key: key ?? this.key,
          data: data ?? this.data,
          type: type ?? this.type,
          children: children ?? this.children);

  Map<String, dynamic> get asMap => {
        'key': key,
        'type': EnumToString.convertToString(type),
        'data': data,
        'children': children.map((e) => e.asMap).toList(),
      };

  String toCode() {
    final _code = children.map((e) => e.toCode()).join('');
    final String? key = data['key'];
    switch (type) {
      case BlockType.SetState:
        return 'setState(() { \n' + _code + ';})';
      case BlockType.Set:
        return key != null && _code != '' ? key + '=' + _code : '';
      case BlockType.Add:
        return "${data['key']} + ${data['value']} $_code";
      default:
        return _code;
    }
  }
}

class BlockController {
  final List<Block> children;
  final void Function(BlockController controller) resolve;
  final WidgetModel root;
  BlockController({required this.children, required this.root, required this.resolve});

  Function get function => runFunction;

  BlockController loadMap({
    required List<Map<String, dynamic>> map,
  }) {
    final List<Block> children =
        map.map((Map<String, dynamic> item) => Block.fromMap(item)).toList();
    return BlockController(children: children, root: root, resolve: resolve);
  }

  runFunction() {
    resolve(this);
  }

  /// Deletes an existing node identified by specified key. This method
  /// returns a new list with the specified node removed.
  List<Block> deleteBlock(
    String key, {
    Block? parent,
    bool deleteChildren = false,
  }) {
    List<Block> _children = parent == null ? this.children : parent.children;
    List<Block> _filteredChildren = [];
    Iterator iter = _children.iterator;
    while (iter.moveNext()) {
      Block child = iter.current;
      if (child.key != key) {
        if (child.isParent) {
          _filteredChildren.add(child.copyWith(
            children: deleteBlock(key, parent: child, deleteChildren: deleteChildren),
          ));
        } else {
          _filteredChildren.add(child);
        }
      } else {
        if (!deleteChildren) {
          final children = getBlock(key)?.children;
          children?.forEach((child) {
            _filteredChildren.add(child.copyWith(
              children: deleteBlock(key, parent: child, deleteChildren: deleteChildren),
            ));
          });
        }
      }
    }
    return _filteredChildren;
  }

  List<Block> _addChildrenFrom(String key) {
    List<Block> _children = [];
    final children = getBlock(key)?.children;
    children?.forEach((child) {
      _children.add(child.copyWith(
        children: deleteBlock(key, parent: child),
      ));
    });
    return _children;
  }

  List<Block> addBlock(
    String key,
    Block newNode, {
    Block? parent,
    InsertMode mode: InsertMode.append,
    int? index,
    String? group,
  }) {
    List<Block> _children = parent == null ? this.children : parent.children;
    return _children.map((Block child) {
      if (child.key == key) {
        List<Block> _children = child.children.toList(growable: true);
        if (mode == InsertMode.prepend) {
          _children.insert(index ?? 0, newNode);
        } else if (mode == InsertMode.append) {
          _children.insert(index != null ? index + 1 : _children.length, newNode);
        } else if (mode == InsertMode.replace) {
          final children = _addChildrenFrom(_children[index ?? 0].key);
          _children.removeAt(index ?? 0);
          _children.insert(index ?? 0, newNode.copyWith(children: children));
        } else if (mode == InsertMode.changeParent) {
          final _child = _children[index ?? 0];
          _children.removeAt(index ?? 0);
          _children.insert(
            index ?? 0,
            newNode.copyWith(
              children: [_child],
            ),
          );
        } else {
          _children.add(newNode);
        }
        return child.copyWith(children: _children);
      } else {
        return child.copyWith(
          children: addBlock(
            key,
            newNode,
            parent: child,
            mode: mode,
            index: index,
            group: group,
          ),
        );
      }
    }).toList();
  }

  calculate(WidgetModelController controller, [Block? block, dynamic? value]) {
    final _children = block?.children ?? children;
    _children.forEach((e) {
      if (block == null) {
        block = getLastBlock(e);
      }
      if (block == null) return;
      final model =
          block!.data['root'] != null ? controller.getModel(block!.data['root']) : null;
      if (model != null) {
        final property = model.properties[block!.data['key']];
        if (property == null) return;
        property.modifiedValue ??= property.value;
        if (block!.type == BlockType.Add) {
          value = block!.data['value'] != null
              ? property.modifiedValue + block!.data['value']!
              : 0;
        } else if (block!.type == BlockType.Set) {
          if (property.type == PropertyType.Int) {
            property.modifiedValue = value;
          }
        }
      }
      final p = getParent(block!.key);
      if (p != null) calculate(controller, p, value);
    });
  }

  String toCode() {
    final code = children.map((e) {
      final c = e.toCode();
      return c == '' ? '' : c + ';';
    }).join();
    return '''(){
    $code 
}''';
  }

  Block? getParent(String key, {Block? parent}) {
    Block? _found;
    List<Block> _children = parent == null ? this.children : parent.children;
    Iterator iter = _children.iterator;
    while (iter.moveNext()) {
      Block child = iter.current;
      if (child.key == key) {
        _found = parent ?? null; //? fix
        break;
      } else {
        if (child.isParent) {
          _found = this.getParent(key, parent: child);
          if (_found != null) {
            break;
          }
        }
      }
    }
    return _found;
  }

  /// Updates an existing node identified by specified key. This method
  /// returns a new list with the updated node.
  List<Block> updateBlock(String key, Block newNode, {Block? parent}) {
    List<Block> _children = parent == null ? this.children : parent.children;
    return _children.map((Block child) {
      if (child.key == key) {
        return newNode;
      } else {
        if (child.isParent) {
          return child.copyWith(
            children: updateBlock(
              key,
              newNode,
              parent: child,
            ),
          );
        }
        return child;
      }
    }).toList();
  }

  /// Gets the block that has a key value equal to the specified key.
  Block? getLastBlock(Block block, {Block? parent}) {
    Block? _found;
    List<Block> _children = parent == null ? block.children : parent.children;
    Iterator iter = _children.iterator;
    while (iter.moveNext()) {
      Block child = iter.current;
      if (child.isParent)
        _found = this.getLastBlock(block, parent: child);
      else
        return _found = child;
    }
    return _found;
  }

  /// Gets the block that has a key value equal to the specified key.
  Block? getBlock(String key, {Block? parent}) {
    Block? _found;
    List<Block> _children = parent == null ? this.children : parent.children;
    Iterator iter = _children.iterator;
    while (iter.moveNext()) {
      Block child = iter.current;
      if (child.key == key) {
        _found = child;
        break;
      } else {
        if (child.isParent) {
          _found = this.getBlock(key, parent: child);
          if (_found != null) {
            break;
          }
        }
      }
    }
    return _found;
  }

  /// Map representation of this object
  List<Map<String, dynamic>> get asMap =>
      children.map((Block child) => child.asMap).toList();
}
