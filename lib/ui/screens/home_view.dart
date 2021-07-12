import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ms_engage_proto/model/meeting_event.dart';
import 'package:ms_engage_proto/store/session_data.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/modals/join_call.dart';
import 'package:ms_engage_proto/ui/modals/room_info.dart';
import 'package:ms_engage_proto/ui/screens/call_screen_web.dart';
import 'package:ms_engage_proto/ui/screens/group_call_screen.dart';
import 'package:ms_engage_proto/ui/widgets/dashboard_action_btn.dart';
import 'package:ms_engage_proto/ui/widgets/date_time_widget.dart';
import 'package:ms_engage_proto/ui/widgets/default_button.dart';
import 'package:ms_engage_proto/ui/widgets/meeting_calendar_event.dart';
import 'package:ms_engage_proto/utils/misc_utils.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Container(
          width: width * 0.38,
          height: height * 0.9,
          decoration: BoxDecoration(
              border: Border(
                  right: BorderSide(
                      color: AppStyle.darkBorderColor
                  )
              )
          ),
          padding: EdgeInsets.symmetric(vertical: height * 0.06, horizontal: width * 0.045),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: width * 0.17,
            ),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: height * 0.04,
                runSpacing: height * 0.04,
                children: [
                  DashboardActionButton(
                    title: 'New Meeting',
                    subtext: 'A New Peer to Peer Meeting',
                    icon: FontAwesomeIcons.video,
                    color: AppStyle.primaryHomeAction,
                    onTap: () {
                      String roomID = MiscUtils.generateSecureRandomString(12);
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (_)
                          => CallScreenWeb(host: true, roomID: roomID))
                      );
                    },
                  ),
                  DashboardActionButton(
                    title: 'Join Meeting',
                    subtext: 'Join a Peer to Peer Meeting',
                    icon: FontAwesomeIcons.solidPlusSquare,
                    onTap: () => _showJoinDialog(context, false),
                  ),
                  DashboardActionButton(
                    title: 'Create a Video Room',
                    subtext: 'Setup a group call',
                    icon: CupertinoIcons.person_add_solid,
                    onTap: () {
                      String roomID = MiscUtils.generateSecureRandomString(12);
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (_)
                          => GroupCallScreen(roomID: roomID))
                      );
                    },
                  ),
                  DashboardActionButton(
                    title: 'Join a Video Room',
                    subtext: 'Join a group video call',
                    icon: CupertinoIcons.person_2_fill,
                    onTap: () => _showJoinDialog(context, true),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: height * 0.03, left: width * 0.042, right: width * 0.03),
          child: Container(
            height: height * 0.8,
            width:  width * 0.48,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DateTimeDisplay(),
                SizedBox(
                  height: 50,
                ),
                Text(
                  "Scheduled Meetings",
                  style: TextStyle(
                      color: AppStyle.whiteAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                StreamBuilder<Map<String,MeetingEvent>>(
                  stream: SessionData.instance.calendarEvents,
                  builder: (context, snapshot) {
                    if(snapshot.hasData && snapshot.data != null){
                      if(snapshot.data!.isNotEmpty){
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: snapshot.data!.values.map(
                                (event) => Row(
                                  children: [
                                    MeetingCalendarEvent(
                                      event: event,
                                    ),
                                    SizedBox(width: 40,)
                                  ],
                                )
                            ).toList(),
                          ),
                        );
                      }
                      return Expanded(
                        child: Container(
                          // TODO: ADD GRAPHIC
                        ),
                      );
                    }
                    return Expanded(
                      child: Container(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppStyle.whiteAccent,
                          ),
                        ),
                      ),
                    );
                  }
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

void _showJoinDialog(BuildContext context, bool isGroup) async {
  Dialog startCall = Dialog(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    backgroundColor: AppStyle.primaryColor,
    child: JoinCallDialog(isGroupCall: isGroup,),
  );
  await showDialog<Dialog>(
    context: context,
    builder: (context) => startCall,
  );
}
