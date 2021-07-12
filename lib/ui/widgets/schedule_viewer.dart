import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ms_engage_proto/model/meeting_event.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/widgets/default_button.dart';
import 'package:ms_engage_proto/utils/ui_utils.dart';

class ScheduleViewer extends StatelessWidget {
  final MeetingEvent event;
  ScheduleViewer({
    Key? key,
    required this.event
  }) : super(key: key);

  final _standardSpacing = SizedBox(
    width: 16,
  );

  final _buttonTextStyle = TextStyle(
      color: AppStyle.whiteAccent.withOpacity(0.7),
      fontSize: 18,
      fontWeight: FontWeight.bold
  );

  DefaultButton _secondaryButtons({String? title, Widget? icon, EdgeInsetsGeometry? padding})
  => DefaultButton(
      onPress: (){},
      child: title != null
              ?Text(
                title,
                style: _buttonTextStyle,
              ) : icon!,
      padding: padding ?? EdgeInsets.symmetric(horizontal: 35, vertical: 30),
      buttonColor: AppStyle.secondaryColor,
      buttonBorder: BorderSide(
        color: AppStyle.defaultBorderColor
      ),
    );

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final subtextColor = AppStyle.defaultUnselectedColor;
    final divider = Divider(
      height: height * 0.08,
      color: AppStyle.darkBorderColor,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.title,
          style: TextStyle(
            color: AppStyle.whiteAccent,
            fontSize: 32,
            fontWeight: FontWeight.bold
          ),
        ),
        SizedBox(
          height: 16,
        ),
        Row(
          children: [
            Icon(
              Icons.access_time,
              color: subtextColor,
              size: 18,
            ),
            SizedBox(
              width: 16,
            ),
            Text(
              '${event.start.hour}:${event.start.minute} - ' +
                  '${(event.end != null ? event.end!.hour : '')}'
                      ':${(event.end != null ? event.end!.minute : '')}',
              style: TextStyle(color: subtextColor, fontSize: 16),
            ),
            SizedBox(
              width: 16,
            ),
            Text(
              '|',
              style: TextStyle(
                color: subtextColor,
                fontSize: 16
              ),
            ),
            SizedBox(
              width: 16,
            ),
            Text(
              'Starts in ${UIUtils.formatTime(dateTime: event.start)}',
              style: TextStyle(color: subtextColor, fontSize: 16),
            )
          ],
        ),
        divider,
        Row(
          children: [
            DefaultButton(
              onPress: (){},
              child: Text(
                'Start',
                style: _buttonTextStyle.copyWith(
                  color: AppStyle.whiteAccent
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            ),
            _standardSpacing,
            _secondaryButtons(title: 'Copy Invitation'),
            _standardSpacing,
            _secondaryButtons(title: 'Join Lobby'),
            _standardSpacing,
            _secondaryButtons(icon: Icon(
              Icons.edit,
              color: AppStyle.whiteAccent.withOpacity(0.7),
            )),
            _standardSpacing,
            _secondaryButtons(
              icon: Icon(
                Icons.delete_outline_outlined,
                color: AppStyle.whiteAccent.withOpacity(0.7),
                size: 30,
              ),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 27)
            )
          ],
        ),
        SizedBox(
          height: height * 0.03,
        ),
        Divider(
          color: AppStyle.darkBorderColor,
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: height * 0.02),
          width: double.infinity,
          height: 80,
          child: SingleChildScrollView(
            child: Text(
              event.details ?? 'Add some details about this meeting',
              style: TextStyle(
                color: AppStyle.defaultUnselectedColor,
                fontSize: event.details != null ? 18 : 20,
              ),
            ),
          ),
        ),
        Divider(
          color: AppStyle.darkBorderColor,
        ),
        SizedBox(
          height: height * 0.03,
        ),
        Container(
          width: double.infinity,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Meeting ID:',
                  style: TextStyle(
                    color: AppStyle.defaultUnselectedColor,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  event.roomID,
                  style: TextStyle(
                    color: AppStyle.whiteAccent,
                    fontSize: 30,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            ),
          ),
        ),
        divider,
        Row(
          children: [
            Icon(
              FontAwesomeIcons.userFriends,
              color: AppStyle.defaultUnselectedColor,
            ),
            SizedBox(
              width: 20,
            ),
            Text(
              'Participants',
              style: TextStyle(
                color: AppStyle.defaultUnselectedColor,
                fontSize: 18,
              ),
            )
          ],
        ),
      ],
    );
  }
}
