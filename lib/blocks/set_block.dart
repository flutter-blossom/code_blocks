import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_model/flutter_widget_model.dart';
import '../controller.dart';

class SetBlock extends StatelessWidget {
  SetBlock({
    this.children = const [],
    required this.root,
    required this.data,
    required this.onUpdate,
    required this.actions,
    required this.propertySelectWidget,
  });

  final List<Widget> children;
  final List<Widget> actions;
  final WidgetModel root;
  final Map<String, dynamic> data;
  final void Function(Map<String, dynamic>) onUpdate;
  final Widget propertySelectWidget;
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
      child: Wrap(
        // crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...actions,
                Text(
                  'set',
                  style: TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                propertySelectWidget,
                if (data['key'] != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      EnumToString.convertToString(
                          root.properties[data['key']]?.type ?? ''),
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
              ],
            ),
          ),
          Wrap(
            children: children,
          )
        ],
      ),
    );
  }
}
