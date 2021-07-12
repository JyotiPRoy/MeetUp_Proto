import 'dart:ui';

import 'package:flutter/material.dart';

final titleStyle = TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold);
final contentStyle = TextStyle(
  color: Colors.white,
  fontSize: 18,
);

class ErrorDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback okTapped;
  final VoidCallback cancelTapped;

  const ErrorDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.okTapped,
    required this.cancelTapped
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width * 0.22,
        maxHeight: height * 0.25
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 0,
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                child: Container(
                  height: height * 0.25,
                  width: width * 0.22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.grey[900]!.withOpacity(0.6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: height * 0.05,
                      ),
                      Text(
                        '$title',
                        style: titleStyle,
                        textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        '$content',
                        style: contentStyle,
                        textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                      Expanded(child: SizedBox(),),
                      _DialogActions(
                        okTapped: okTapped,
                        cancelTapped: cancelTapped,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -(height * 0.04),
            child: _CircularDialogHeader(),
          )
        ],
      ),
    );
  }
}

class _CircularDialogHeader extends StatelessWidget {

  final Icon? headerIcon;

  _CircularDialogHeader({this.headerIcon});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          height: 2 * (height * 0.04),
          width: 2 * (height * 0.04),
          decoration: BoxDecoration(
              color: Colors.grey[800]!.withOpacity(0.5),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[400]!, width: 4)),
          child: Center(
            child: headerIcon != null
                ? headerIcon
                : Icon(
              Icons.warning,
              color: Colors.yellow,
              size: 42,
            ),
          ),
        ),
      ),
    );
  }
}
class _DialogActions extends StatelessWidget {
  final GestureTapCallback okTapped;
  final GestureTapCallback cancelTapped;
  final List<String>? buttonLabels;

  _DialogActions({
    required this.okTapped,
    required this.cancelTapped,
    this.buttonLabels
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[900]!.withOpacity(0.4),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20)),
                      border: Border.all(
                          width: 0.5, color: Colors.grey[700]!)),
                  padding: EdgeInsets.all(16),
                  child: Center(
                      child: Text(
                        buttonLabels != null ? buttonLabels![0] : 'Cancel',
                        style: contentStyle,
                      )),
                ),
                Positioned.fill(
                  child: Material(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20)),
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: cancelTapped,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20)),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[900]!.withOpacity(0.4),
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(20)),
                      border: Border.all(
                          width: 0.5, color: Colors.grey[700]!)),
                  padding: EdgeInsets.all(16),
                  child: Center(
                      child: Text(
                        buttonLabels != null ? buttonLabels![1] : 'Ok',
                        style: contentStyle,
                      )),
                ),
                Positioned.fill(
                  child: Material(
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(20)),
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: okTapped,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(20)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
