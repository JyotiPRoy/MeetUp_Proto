import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ms_engage_proto/provider/pexel_img_provider.dart';
import 'package:ms_engage_proto/store/session_data.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:timer_builder/timer_builder.dart';

bool _timeColon = true;

class DateTimeDisplay extends StatelessWidget {
  const DateTimeDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Container(
      height: height * 0.28,
      width: width * 0.48,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: FutureBuilder<String?>(
                future: PexelImageProvider.getImageUrl(SessionData.instance.pexelPageNum),
                builder: (context, snapshot) {
                  if(snapshot.hasData && snapshot.data != null){
                    return Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: AppStyle.defaultBorderColor,
                          ),
                          image: DecorationImage(
                              image: NetworkImage(snapshot.data!),
                              fit: BoxFit.cover
                          )
                      ),
                    );
                  }
                  return Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: AppStyle.defaultBorderColor,
                        ),
                        color: AppStyle.secondaryColor
                    ),
                  );
                }
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                  sigmaX: 3,
                  sigmaY: 3
              ),
              child: Container(
                color: AppStyle.secondaryColor.withOpacity(0.4),
              ),
            ),
          ),
          TimerBuilder.periodic(
            const Duration(minutes: 1),
            builder: (context){
              return Positioned.fill(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${DateTime.now().hour.toString().padLeft(2, '0')}'
                            + ' : ' +
                            '${DateTime.now().minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                            color: AppStyle.whiteAccent,
                            fontSize: 48,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        '${weekDays[DateTime.now().weekday - 1]}, ' /// For some reason index starts at 1 -_-
                            ' ${DateTime.now().day.toString()}'
                            ' ${months[DateTime.now().month - 1]} ${DateTime.now().year}',
                        style: TextStyle(
                            color: AppStyle.whiteAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            right: 15,
            top: 15,
            child: Container(
              height: 20,
              width: 20,
              child: Icon(
                Icons.refresh,
                color: AppStyle.whiteAccent.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Better use this approach than downloading another package
/// cuz "Surprise" dart DateTime doesn't output month names -_-
List<String> months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];

List<String> weekDays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday'
];