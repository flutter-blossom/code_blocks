import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_model/flutter_widget_model.dart';
import '../controller.dart';

class AddBlock extends StatelessWidget {
  AddBlock(
      {this.children = const [],
      required this.root,
      required this.data,
      required this.onUpdate,
      required this.actions});
  final List<Widget> children;
  final List<Widget> actions;
  final WidgetModel root;
  final Map<String, dynamic> data;
  final void Function(Map<String, dynamic>) onUpdate;
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
                  'add',
                  style: TextStyle(color: Colors.black87),
                ),
                SizedBox(
                  width: 55,
                ),
                ...actions
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: data['key'],
                  onTap: () {},
                  onChanged: (value) {
                    data['key'] = value;
                    data['root'] = root.key;
                    data['type'] = EnumToString.convertToString(
                        root.properties[value]!.type);
                    onUpdate(data);
                  },
                  items: root.properties.entries
                      .map((e) => DropdownMenuItem<String>(
                            value: e.key,
                            child: Text(
                              e.key,
                              style: TextStyle(color: Colors.black),
                            ),
                            onTap: () {},
                          ))
                      .toList(),
                ),
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
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
            child: AutoSizeTextField(
              onSubmitted: (value) {
                if (root.properties[data['key']]?.type == PropertyType.Int)
                  data['value'] = int.tryParse(value);
                else if (root.properties[data['key']]?.type ==
                    PropertyType.Double)
                  data['value'] = double.tryParse(value);
                else
                  data['value'] = value;
                onUpdate(data);
              },
              controller:
                  TextEditingController(text: (data['value'] ?? '').toString()),
              inputFormatters: [
                if (root.properties[data['key']]?.type == PropertyType.Int)
                  FilteringTextInputFormatter.digitsOnly,
                // if(root.properties[data['key']]?.type == PropertyType.double)
                // RegExInputFormatter.withRegex(
                //   '^\$|^(0|([1-9][0-9]{0,}))(\\.[0-9]{0,})?\$')
              ],
              textAlign: TextAlign.center,
              fullwidth: false,
              minWidth: 80,
              minFontSize: 16,
              style: TextStyle(
                color: Colors.black.withOpacity(0.9),
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(4.0),
                isDense: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
              ),
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
