import 'package:flutter/material.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';

typedef String? InputValidator(String? val);

class InputField extends StatelessWidget {

  final TextEditingController controller;
  final InputValidator validator;
  final String fieldName;
  final RegExp? inputRegExp;
  final String? hintText;
  final bool obscureText;

  InputField({
    Key? key,
    required this.controller,
    required this.validator,
    required this.fieldName,
    this.inputRegExp,
    this.hintText,
    this.obscureText = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    BoxDecoration inputFieldDecor = BoxDecoration(
      color: AppStyle.secondaryColor,
      borderRadius: BorderRadius.all(Radius.circular(15)),
      border: Border.all(
        color: AppStyle.defaultBorderColor,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fieldName != ''
          ? Text(
              '  $fieldName',
              style: TextStyle(
                  color: AppStyle.whiteAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold
              ),
            )
          : Container(),
        SizedBox(
          height: fieldName != '' ? 8 : 0,
        ),
        Container(
          decoration: inputFieldDecor,
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 4),
            child: TextFormField(
              obscureText: obscureText,
              controller: controller,
              validator: (val){
                return validator.call(val);
              },
              style: TextStyle(
                  color: AppStyle.whiteAccent
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
        )
      ],
    );
  }
}