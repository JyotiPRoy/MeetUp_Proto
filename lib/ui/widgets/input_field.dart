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

  OutlineInputBorder _getInputBorder({Color? color})
    =>  OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
            width: 1.5,
            color: color ?? AppStyle.defaultBorderColor
        )
    );

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

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
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
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
              enabledBorder: _getInputBorder(),
              focusedBorder: _getInputBorder(
                color: AppStyle.whiteAccent.withOpacity(0.6)
              ),
              errorBorder: _getInputBorder(
                color: AppStyle.defaultErrorColor
              ),
              focusedErrorBorder: _getInputBorder(),
              fillColor: AppStyle.secondaryColor,
              border: InputBorder.none,
              hintText: hintText ?? '',
              hintStyle: TextStyle(
                color: AppStyle.defaultUnselectedColor
              )
            ),
          ),
        )
      ],
    );
  }
}