import 'package:better_print/better_print.dart';
import 'package:code_blocks/blocks/set_block.dart';
import 'package:code_blocks/blocks/set_state_block.dart';
import 'package:code_blocks/code_blocks.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';

import 'blocks/add_block.dart';
import 'blocks/divide_block.dart';
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
    required this.onReplace,
    required this.onUpdate,
    required this.onDelete,
    this.maxHeight,
    this.backgroundColor = Colors.transparent,
  });
  final Color backgroundColor;
  final BlockController controller;
  final double? maxHeight;
  final void Function(String? key, BlockType type) onAdd;
  final void Function(String? key, Block block) onReplace;
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
    final selectWidget = DropdownButton<String>(
      isDense: true,
      value: block.data['key'],
      onTap: () {},
      onChanged: (value) {
        block.data['key'] = value;
        block.data['root'] = controller.root.key;
        block.data['type'] =
            EnumToString.convertToString(controller.root.properties[value]!.type);
        onUpdate(block.key, block.copyWith(data: block.data));
      },
      items: controller.root.properties.entries
          .skip(1)
          .map((e) => DropdownMenuItem<String>(
                value: e.key,
                child: RichText(
                  text: TextSpan(
                      text: e.key,
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: ' ' + e.value.type.toString().split('.')[1],
                          style: TextStyle(color: Colors.black.withOpacity(0.5)),
                        )
                      ]),
                ),
                onTap: () {},
              ))
          .toList(),
    );
    switch (block.type) {
      case BlockType.SetState:
        result = SetStateBlock(
          add: onAdd,
          children: block.children.map((e) => _getBlock(e, parent: block)).toList(),
          actions: [ActionButton(onDelete: () => onDelete(block.key))],
        );
        break;
      case BlockType.Set:
        result = SetBlock(
          onUpdate: (data) {
            onUpdate(block.key, block.copyWith(data: data));
          },
          propertySelectWidget: selectWidget,
          data: block.data,
          root: controller.root,
          children: block.children.map((e) => _getBlock(e, parent: block)).toList(),
          actions: [ActionButton(onDelete: () => onDelete(block.key))],
        );
        break;
      case BlockType.Return:
        result = ReturnBlock(
          add: onAdd,
          children: block.children.map((e) => _getBlock(e, parent: block)).toList(),
          actions: [ActionButton(onDelete: () => onDelete(block.key))],
        );
        break;
      case BlockType.Add:
        result = AddBlock(
          onUpdate: (data) {
            onUpdate(block.key, block.copyWith(data: data));
          },
          propertySelectWidget: selectWidget,
          data: block.data,
          root: controller.root,
          children: block.children.map((e) => _getBlock(e, parent: block)).toList(),
          actions: [ActionButton(onDelete: () => onDelete(block.key))],
        );
        break;
      case BlockType.For:
        result = ForBlock(
          add: onAdd,
          children: block.children.map((e) => _getBlock(e, parent: block)).toList(),
          actions: [ActionButton(onDelete: () => onDelete(block.key))],
        );
        break;
      case BlockType.While:
        result = WhileBlock(
          add: onAdd,
          children: block.children.map((e) => _getBlock(e, parent: block)).toList(),
          actions: [ActionButton(onDelete: () => onDelete(block.key))],
        );
        break;
      case BlockType.Subtract:
        result = SubtractBlock(
          add: onAdd,
          children: block.children.map((e) => _getBlock(e, parent: block)).toList(),
          actions: [ActionButton(onDelete: () => onDelete(block.key))],
        );
        break;
      case BlockType.Multiply:
        result = MultiplyBlock(
          add: onAdd,
          children: block.children.map((e) => _getBlock(e, parent: block)).toList(),
          actions: [ActionButton(onDelete: () => onDelete(block.key))],
        );
        break;
      case BlockType.Divide:
        result = DivideBlock(
          add: onAdd,
          children: block.children.map((e) => _getBlock(e, parent: block)).toList(),
          actions: [ActionButton(onDelete: () => onDelete(block.key))],
        );
        break;
      case BlockType.If:
        result = IfBlock(
          add: onAdd,
          children: block.children.map((e) => _getBlock(e, parent: block)).toList(),
          actions: [ActionButton(onDelete: () => onDelete(block.key))],
        );
        break;
      case BlockType.Else:
        result = ElseBlock(
          add: onAdd,
          children: block.children.map((e) => _getBlock(e, parent: block)).toList(),
          actions: [ActionButton(onDelete: () => onDelete(block.key))],
        );
        break;
      case BlockType.Error:
        result = Container(
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.2),
            border: Border.all(
              width: 2,
              color: Colors.amber,
            ),
          ),
          width: 60,
          height: 40,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Error'),
                GestureDetector(
                    onTap: () => onDelete(block.key),
                    child: Icon(
                      Icons.delete,
                      size: 16,
                    ))
              ],
            ),
          ),
        );
        // TODO: Handle this case.
        break;
    }
    // ignore: unnecessary_null_comparison
    return result != null
        ? DragTarget<Block>(
            onWillAccept: (b) {
              return b is Block && b.key != block.key;
            },
            onAccept: (b) {
              onDelete(b.key);
              onReplace(block.key, b);
            },
            builder: (context, List<Block?> candidateData1, List<dynamic> rejectedData) =>
                DragTarget<BlockType>(
              onWillAccept: (b) {
                var result = b is BlockType;
                if (b is BlockType) {
                  if (b == BlockType.Set)
                    result =
                        block.type != BlockType.Set && block.type != BlockType.Return;
                  if (b == BlockType.Return)
                    result =
                        block.type != BlockType.Return && block.type != BlockType.Set;
                  if (b == BlockType.Else)
                    result = block.children.length > 0 &&
                        block.children.last.type == BlockType.If;
                }
                return result;
              },
              onAccept: (type) {
                onAdd(block.key, type);
              },
              builder: (context, List<BlockType?> candidateData2,
                      List<dynamic> rejectedData) =>
                  Opacity(
                opacity: candidateData1.isNotEmpty || candidateData2.isNotEmpty ? 0.5 : 1,
                child: Draggable(
                  data: block,
                  feedback: Material(child: result),
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Transform.scale(
                        alignment: Alignment.topLeft,
                        scale: candidateData1.isNotEmpty || candidateData2.isNotEmpty
                            ? 1.02
                            : 1.0,
                        child: result),
                  ),
                  childWhenDragging: SizedBox(),
                ),
              ),
            ),
          )
        : SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: this.backgroundColor,
      constraints: BoxConstraints(maxHeight: maxHeight ?? double.infinity),
      child: Row(
        children: [
          Container(
            height: double.infinity,
            width: 80,
            color: Colors.grey.withOpacity(0.2),
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
                                    style: TextStyle(color: Colors.black45)),
                              )),
                              child: _getBox(Text(
                                EnumToString.convertToString(e),
                                style: TextStyle(color: Colors.black.withOpacity(0.7)),
                              ))),
                        ))
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: DragTarget<Block>(
                onAccept: (Block b) {
                  onDelete(b.key);
                  onReplace(null, b);
                },
                onWillAccept: (b) =>
                    b is Block &&
                    !controller.children.any((e) => e.type == BlockType.Return),
                builder:
                    (context, List<Block?> candidateData1, List<dynamic> rejectedData) =>
                        DragTarget<BlockType>(
                  onAccept: (BlockType type) {
                    onAdd(null, type);
                  },
                  onWillAccept: (val) =>
                      val is BlockType &&
                      !controller.children.any((e) => e.type == BlockType.Return),
                  builder: (context, List<BlockType?> candidateData2,
                          List<dynamic> rejectedData) =>
                      SingleChildScrollView(
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height - 110,
                      ),
                      color: candidateData1.isNotEmpty || candidateData2.isNotEmpty
                          ? Colors.grey.withOpacity(0.02)
                          : null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: controller.children
                            .map(
                              (e) => Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _getBlock(e),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
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
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: InkWell(
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
      ),
    );
  }
}
