import 'package:flutter/material.dart';
import '../controller.dart';

class WhileBlock extends StatelessWidget {
  WhileBlock(
      {this.children = const [], required this.add, required this.actions});
  final List<Widget> children;
  final List<Widget> actions;
  final void Function(String? key, BlockType type) add;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.2),
          border: Border.all(
            width: 2,
            color: Colors.amber,
          )),
      constraints: BoxConstraints(minHeight: 40, minWidth: 100),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'while',
                  style: TextStyle(color: Colors.black87),
                ),
                SizedBox(
                  width: 55,
                ),
                ...actions
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          )
        ],
      ),
    );
  }
}
