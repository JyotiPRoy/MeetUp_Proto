import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/widgets/default_button.dart';

class TabsButtonGroup extends StatelessWidget {
  final List<TabButton> children;

  const TabsButtonGroup({
    required this.children,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: Row(
        children: children,
      ),
    );
  }
}

class TabButton extends StatefulWidget {
  final StreamController<int> selectionController;
  final String title;
  final int index;

  const TabButton({
    required this.selectionController,
    required this.title,
    required this.index,
    Key? key,
  }) : super(key: key);

  @override
  _TabButtonState createState() => _TabButtonState();
}

class _TabButtonState extends State<TabButton> {

  bool _isSelected = false;

  @override
  void initState() {
    super.initState();
    widget.selectionController.stream.listen((selectedIndex) {
      setState(() {
        _isSelected = widget.index == selectedIndex;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: (){
          widget.selectionController.add(widget.index);
        },
        child: AnimatedContainer(
          margin: EdgeInsets.symmetric(horizontal: 4),
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          duration: const Duration(milliseconds: 200),
          child: Text(
            widget.title,
            style: TextStyle(
              color: _isSelected
                  ? AppStyle.whiteAccent 
                  : AppStyle.defaultUnselectedColor,
              fontWeight: FontWeight.bold
            ),
          ),
          decoration: BoxDecoration(
            color: _isSelected
                ? AppStyle.defaultUnselectedColor.withOpacity(0.5)
                : Colors.transparent,
            border: _isSelected
                ? Border.all(
                    color: AppStyle.defaultBorderColor
                  )
                : null,
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
        ),
      ),
    );
  }
}
