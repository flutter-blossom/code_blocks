import 'package:better_print/better_print.dart';
import 'package:code_blocks/blocks/set_block.dart';
import 'package:code_blocks/code_blocks.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';

import 'blocks/add_block.dart';
import 'blocks/divide_block copy.dart';
import 'blocks/else_block.dart';
import 'blocks/for_block.dart';
import 'blocks/if_block.dart';
import 'blocks/multiply_block.dart';
import 'blocks/return_block.dart';
import 'blocks/subtract_block.dart';
import 'blocks/while_block.dart';

class BlockCanvas extends StatelessWidget {
  BlockCanvas({
    required this.controller,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
    this.maxHeight,
    this.backgroundColor = Colors.transparent,
  });
  final Color backgroundColor;
  final BlockController controller;
  final double? maxHeight;
  final void Function(String? key, BlockType type) onAdd;
  final void Function(String? key, Block type) onUpdate;
  final void Function(String key) onDelete;

  Widget _getBox(Widget child) {
    return Container(
      constraints: BoxConstraints(minHeight: 25, maxWidth: 60),
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: Colors.black26),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Center(child: child),
    );
  }

  Widget _getBlock(Block block, {Block? parent}) {
    Widget? result;
    switch (block.type) {
      case BlockType.Set:
        result = SetBlock(
          onUpdate: (data) {
            onUpdate(block.key, block.copyWith(data: data));
          },
          data: block.data,
          root: controller.root,
          children:
              block.children.map((e) => _getBlock(e, parent: block)).toList(),
          actions: [ActionButton(onDelete: () => onDelete(block.key))],
        );
        break;
      case BlockType.Return:
        result = ReturnBlock(
          add: onAdd,
          children:
              block.children.map((e) => _getBlock(e, parent: block)).toList(),
          actions: [ActionButton(onDelete: () => onDelete(block.key))],
        );
        break;
      case BlockType.Add:
        result = AddBlock(
          onUpdate: (data) {
            onUpdate(block.key, block.copyWith(data: data));
          },
          data: block.data,
          root: controller.root,
          children:
              block.children.map((e) => _getBlock(e, parent: block)).toList(),
          actions: [ActionButton(onDelete: () => onDelete(block.key))],
        );
        break;
      case BlockType.For:
        result = ForBlock(
          add: onAdd,
          children:
              block.children.map((e) => _getBlock(e, parent: block)).toList(),
          actions: [ActionButton(onDelete: () => onDelete(block.key))],
        );
        break;
      case BlockType.While:
        result = WhileBlock(
          add: onAdd,
          children:
              block.children.map((e) => _getBlock(e, parent: block)).toList(),
          actions: [ActionButton(onDelete: () => onDelete(block.key))],
        );
        break;
      case BlockType.Subtract:
        result = SubtractBlock(
          add: onAdd,
          children:
              block.children.map((e) => _getBlock(e, parent: block)).toList(),
          actions: [ActionButton(onDelete: () => onDelete(block.key))],
        );
        break;
      case BlockType.Multiply:
        result = MultiplyBlock(
          add: onAdd,
          children:
              block.children.map((e) => _getBlock(e, parent: block)).toList(),
          actions: [ActionButton(onDelete: () => onDelete(block.key))],
        );
        break;
      case BlockType.Divide:
        result = DivideBlock(
          add: onAdd,
          children:
              block.children.map((e) => _getBlock(e, parent: block)).toList(),
          actions: [ActionButton(onDelete: () => onDelete(block.key))],
        );
        break;
      case BlockType.If:
        result = IfBlock(
          add: onAdd,
          children:
              block.children.map((e) => _getBlock(e, parent: block)).toList(),
          actions: [ActionButton(onDelete: () => onDelete(block.key))],
        );
        break;
      case BlockType.Else:
        result = ElseBlock(
          add: onAdd,
          children:
              block.children.map((e) => _getBlock(e, parent: block)).toList(),
          actions: [ActionButton(onDelete: () => onDelete(block.key))],
        );
        break;
    }
    // ignore: unnecessary_null_comparison
    return result != null
        ? DragTarget<BlockType>(
            onWillAccept: (b) {
              if (b == BlockType.Set)
                return block.type != BlockType.Set &&
                    block.type != BlockType.Return;
              if (b == BlockType.Return)
                return block.type != BlockType.Return &&
                    block.type != BlockType.Set;
              if (b == BlockType.Else)
                return block.children.length > 0 &&
                    block.children.last.type == BlockType.If;
              return true;
            },
            onAccept: (BlockType type) {
              onAdd(block.key, type);
            },
            builder: (context, List<BlockType?> candidateData,
                    List<dynamic> rejectedData) =>
                Opacity(
              opacity: candidateData.isEmpty ? 1 : 0.5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: result,
              ),
            ),
          )
        : SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    var dragTarget = DragTarget<BlockType>(
      onAccept: (BlockType type) {
        onAdd(null, type);
      },
      builder: (context, List<BlockType?> candidateData,
              List<dynamic> rejectedData) =>
          Container(
        constraints: BoxConstraints(minWidth: 50),
        width: double.infinity,
        color: Colors.grey.withOpacity(candidateData.isNotEmpty ? 0.5 : 0.4),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(
            Icons.add,
            color: candidateData.isNotEmpty ? Colors.black54 : Colors.black26,
          ),
        ),
      ),
    );
    return Container(
      width: double.infinity,
      color: this.backgroundColor,
      constraints: BoxConstraints(maxHeight: maxHeight ?? double.infinity),
      child: Stack(
        children: [
          ListView(
            shrinkWrap: true,
            children: controller.children
                .map(
                  (e) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _getBlock(e),
                    ],
                  ),
                )
                .toList(),
          ),
          if (!controller.children.any((e) => e.type == BlockType.Return))
            if (controller.children.isNotEmpty)
              Align(
                alignment: Alignment.bottomLeft,
                child: dragTarget,
              )
            else
              Column(
                children: [
                  Expanded(
                    child: dragTarget,
                  ),
                ],
              ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Container(
                color: controller.children.isNotEmpty
                    ? Colors.grey.withOpacity(0.3)
                    : null,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: BlockType.values
                        .map((e) => Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Draggable(
                                  data: e,
                                  feedback: _getBox(Material(
                                    color: Colors.transparent,
                                    child: Text(EnumToString.convertToString(e),
                                        style:
                                            TextStyle(color: Colors.black45)),
                                  )),
                                  child: _getBox(Text(
                                    EnumToString.convertToString(e),
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.7)),
                                  ))),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ActionButton extends StatefulWidget {
  const ActionButton({
    Key? key,
    required this.onDelete,
  }) : super(key: key);

  final void Function() onDelete;

  @override
  _ActionButtonState createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _isOnHover = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onDelete,
      onHover: (val) {
        setState(() {
          _isOnHover = val;
        });
      },
      child: Icon(
        Icons.delete_forever,
        size: 15,
        color: _isOnHover ? Colors.black87 : Colors.black54,
      ),
    );
  }
}
