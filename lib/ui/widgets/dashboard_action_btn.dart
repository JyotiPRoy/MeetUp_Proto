import 'package:flutter/material.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';

class DashboardActionButton extends StatelessWidget {
  final Color? color;
  final String title;
  final String subtext;
  final IconData icon;
  final VoidCallback onTap;

  DashboardActionButton({
    Key? key,
    this.color,
    required this.onTap,
    required this.title,
    required this.subtext,
    required this.icon
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width * 0.13,
          height: height * 0.28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: color ?? AppStyle.primaryButtonColor,
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppStyle.whiteAccent.withOpacity(0.3),
                      border: Border.all(
                        color: AppStyle.defaultBorderColor,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  child: Icon(
                    icon,
                    color: AppStyle.whiteAccent,
                    size: 32,
                  ),
                ),
                Expanded(
                  child: SizedBox(),
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: AppStyle.whiteAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  subtext,
                  style: TextStyle(
                    color: AppStyle.whiteAccent.withOpacity(0.6),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
