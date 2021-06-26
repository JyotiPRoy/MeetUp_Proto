import 'package:flutter/material.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';

class NavToggleButton extends StatefulWidget {
  final Icon child;
  final int index;
  final Stream<int> toggleController;
  final VoidCallback onTap;

  const NavToggleButton({
    Key? key,
    required this.child,
    required this.index,
    required this.toggleController,
    required this.onTap,
  }) : super(key: key);

  @override
  _NavToggleButtonState createState() => _NavToggleButtonState();
}

class _NavToggleButtonState extends State<NavToggleButton> {

  // Required since Icon class doesn't provide a default copy with func -_-
  Icon copyWith({
    required Icon icon,
    Color? color,
    double? size,
  }) => Icon(
    icon.icon,
    color: color ?? icon.color,
    size: size ?? icon.size,
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: widget.toggleController,
      builder: (context, snapshot) {
        print('CONN STATE: ${snapshot.connectionState}');
        if(snapshot.hasData){
          bool _isSelected = snapshot.data == widget.index;
          return InkWell(
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onTap: () => widget.onTap.call(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: _isSelected
                    ? AppStyle.secondaryColor : AppStyle.primaryColor,
                borderRadius: BorderRadius.all(Radius.circular(15)),
                border: _isSelected
                    ? Border.all(
                  color: AppStyle.defaultBorderColor,
                  width: 1.5,
                )
                    : null,
              ),
              child: Center(
                child: copyWith(
                  icon: widget.child,
                  color: _isSelected
                      ? AppStyle.whiteAccent
                      : AppStyle.defaultUnselectedColor,
                ),
              ),
            ),
          );
        }return Container();
      }
    );
  }
}
