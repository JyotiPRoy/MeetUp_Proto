import 'package:flutter/material.dart';
import 'package:ms_engage_proto/model/meeting_event.dart';
import 'package:ms_engage_proto/store/session_data.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/widgets/default_button.dart';
import 'package:ms_engage_proto/utils/misc_utils.dart';
import 'package:table_calendar/table_calendar.dart';

class AddMeetingEventDialog extends StatefulWidget {
  final MeetingEvent? toEdit;

  const AddMeetingEventDialog({
    Key? key,
    this.toEdit
  }) : super(key: key);

  @override
  _AddMeetingEventDialogState createState() => _AddMeetingEventDialogState();
}

class _AddMeetingEventDialogState extends State<AddMeetingEventDialog> {
  int _pageNumber = 0;
  PageController _pageController = PageController();

  GlobalKey<__EventDetailsState> details = GlobalKey<__EventDetailsState>();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.all(25),
      height: height * 0.8,
      width: width * 0.4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Scaffold(
        backgroundColor: AppStyle.primaryColor,
        appBar: AppBar(
          title: Text(
            _pageNumber == 0 ? 'Schedule Meeting' : 'Add Participants',
            style: TextStyle(
              color: AppStyle.whiteAccent,
              fontSize: 18,
            ),
          ),
          centerTitle: false,
          titleSpacing: 0,
          elevation: 0,
          backgroundColor: AppStyle.primaryColor,
          leading: IconButton(
            onPressed: () {
              // TODO: when pageNumber = 0, Nav.pop else pageNumber -= 1
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: DefaultButton(
                onPress: () {},
                child: Text(
                  'Cancel',
                  style: TextStyle(
                      color: AppStyle.defaultUnselectedColor, fontSize: 14),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                buttonColor: AppStyle.secondaryColor,
                buttonBorder: BorderSide(color: AppStyle.defaultBorderColor),
                borderRadius: 12,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: DefaultButton(
                onPress: () {
                  MeetingEvent? event = details.currentState!.validateAndCreateEvent();
                  Navigator.of(context, rootNavigator: true).pop();
                  if(event != null){
                    SessionData.instance.addMeetingEvent(event);
                  }
                },
                child: Text(
                  'Create',
                  style: TextStyle(color: AppStyle.whiteAccent, fontSize: 14),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                borderRadius: 12,
              ),
            ),
          ],
        ),
        body: PageView(
          children: [
            _EventDetails(
              key: details,
              toEdit: widget.toEdit,
            )
          ],
        ),
      ),
    );
  }
}

class _EventDetails extends StatefulWidget {
  final MeetingEvent? toEdit;

  const _EventDetails({
    Key? key,
    this.toEdit
  }) : super(key: key);

  @override
  __EventDetailsState createState() => __EventDetailsState();
}

class __EventDetailsState extends State<_EventDetails> {
  final titleController = TextEditingController();
  final detailsController = TextEditingController();
  DateTime date = DateTime.now();
  DateTime start = DateTime.now();
  DateTime? end;
  bool allowAnon = false;
  String? meetingID;

  String _titleHintText = 'Add a Title';
  TextStyle _titleHintStyle = TextStyle(
    color: AppStyle.defaultUnselectedColor,
    fontSize: 18,
  );

  @override
  initState(){
    super.initState();
    if(widget.toEdit != null){
      MeetingEvent event = widget.toEdit!;
      titleController.text = event.title;
      detailsController.text = event.details ?? '';
      date = event.start;
      start = event.start;
      end = event.end;
      allowAnon = event.allowAnon;
      meetingID = event.roomID;
    }
  }

  MeetingEvent? validateAndCreateEvent() {
    if(titleController.text.isEmpty){
      setState(() {
        _titleHintText = 'Title cannot be empty!';
        _titleHintStyle = _titleHintStyle.copyWith(
          color: AppStyle.defaultErrorColor
        );
      });
      return null;
    }
    validateTime();
    return MeetingEvent(
      roomID: meetingID!,
      hostID: SessionData.instance.currentUser!.userID,
      title: titleController.text,
      start: start,
      end: end,
      details: detailsController.text,
      allowAnon: allowAnon
    );
  }

  String _getSecureRndString(){
    if(meetingID == null){
      meetingID = MiscUtils.generateSecureRandomString(12);
    }
    return meetingID!;
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '- : -';
    } else
      return (dateTime.hour > 10
              ? dateTime.hour.toString()
              : dateTime.hour.toString().padLeft(2, '0')) +
          ' : ' +
          (dateTime.minute > 10
              ? dateTime.minute.toString()
              : dateTime.minute.toString().padLeft(2, '0'));
  }

  Color _getCheckBoxColor(Set<MaterialState> states) {
    if(states.contains(MaterialState.hovered) && !states.contains(MaterialState.selected)){
      return AppStyle.whiteAccent.withOpacity(0.7);
    }else if(states.contains(MaterialState.selected) && states.contains(MaterialState.hovered))
      return AppStyle.primaryButtonColor;
    if(states.contains(MaterialState.selected))
      return AppStyle.primaryButtonColor;
    else return AppStyle.defaultUnselectedColor;  //Pardon the bad code :(
  }

  Future<TimeOfDay?> _getTime(BuildContext buildContext) async{
    return showTimePicker(
      initialTime: TimeOfDay.now(),
      context: buildContext
    );
  }

  void validateTime(){
    if(end != null){
      if(start.difference(end!) == Duration.zero){
        // TODO: Show toast that start cannot be = end
      }
      end = DateTime.utc(date.year, date.month, date.day, end!.hour, end!.minute);
    }
    start = DateTime.utc(date.year, date.month, date.day, start.hour, start.minute);
    print('Start: ${start.toIso8601String()}');
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final divider = Divider(
      height: height * 0.03,
      color: AppStyle.darkBorderColor,
    );
    final subHeadingStyle =
        TextStyle(color: AppStyle.defaultUnselectedColor, fontSize: 14);
    final timePickerDecor = BoxDecoration(
      color: AppStyle.secondaryColor,
      border: Border.all(
        color: AppStyle.defaultBorderColor,
      ),
      borderRadius: BorderRadius.all(Radius.circular(15)),
    );

    return Container(
      child: Column(
        children: [
          divider,
          Container(
            padding: EdgeInsets.symmetric(horizontal: width * 0.015),
            width: double.infinity,
            height: height * 0.04,
            child: TextField(
              style: TextStyle(color: AppStyle.whiteAccent, fontSize: 18),
              controller: titleController,
              decoration: InputDecoration(
                hintText: _titleHintText,
                hintStyle: _titleHintStyle,
                border: InputBorder.none,
              ),
            ),
          ),
          divider,
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          right: BorderSide(color: AppStyle.darkBorderColor))),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          'Select Date',
                          style: subHeadingStyle,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TableCalendar(
                        focusedDay: date,
                        firstDay: DateTime.now(),
                        lastDay: DateTime.utc(2030, 1, 1),
                        calendarStyle: AppStyle.calendarStyle,
                        headerStyle: AppStyle.calendarHeaderStyle,
                        selectedDayPredicate: (day) {
                          return isSameDay(date, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            date = selectedDay;
                            print('SELECTED DAY: ${date.toIso8601String()}');
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 30, right: 30, top: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Meeting Time',
                        style: subHeadingStyle,
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        children: [
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () async {
                                final now = DateTime.now();
                                final time = await _getTime(context);
                                if(time != null){
                                  setState(() {
                                    start = DateTime.utc(now.year, now.minute, now.day, time.hour, time.minute);
                                  });
                                }else throw Exception('Null Time');
                              },
                              child: Container(
                                width: 120,
                                height: 50,
                                decoration: timePickerDecor,
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatTime(start),
                                      style: subHeadingStyle.copyWith(
                                          color: AppStyle.whiteAccent
                                              .withOpacity(0.7)),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down_outlined,
                                      color: AppStyle.defaultUnselectedColor,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(child: SizedBox()),
                          Text(
                            'to',
                            style: subHeadingStyle,
                          ),
                          Expanded(child: SizedBox()),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () async {
                                final now = DateTime.now();
                                final time = await _getTime(context);
                                if(time != null){
                                  var temp = DateTime.utc(now.year, now.minute, now.day, time.hour, time.minute);
                                  if(temp.difference(start).inMinutes < 0){
                                    // TODO: Toast, that end cannot be < start
                                  }else setState(() {
                                    end = temp;
                                  });
                                }else throw Exception('Null Time');
                              },
                              child: Container(
                                width: 120,
                                height: 50,
                                decoration: timePickerDecor,
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatTime(end),
                                      style: subHeadingStyle.copyWith(
                                          color: AppStyle.whiteAccent
                                              .withOpacity(0.7)),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down_outlined,
                                      color: AppStyle.defaultUnselectedColor,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      divider,
                      SizedBox(
                        height: 16.5,
                      ),
                      Text(
                        'Details',
                        style: subHeadingStyle,
                      ),
                      TextField(
                        style: subHeadingStyle.copyWith(
                          fontSize: 14,
                          color: AppStyle.whiteAccent
                        ),
                        controller: detailsController,
                        maxLines: 11,
                        decoration: InputDecoration(
                          hintText: 'Add Meeting details here',
                          hintStyle: subHeadingStyle.copyWith(
                            fontSize: 14
                          ),
                          border: InputBorder.none,
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          divider,
          // SizedBox(
          //   height: 15,
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      'Meeting ID:',
                      style: subHeadingStyle,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      meetingID ?? _getSecureRndString(),
                      style: TextStyle(
                          color:AppStyle.whiteAccent,
                          fontSize: 24,
                          fontWeight: FontWeight.bold
                      ),
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30,),
                child: Column(
                  children: [
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          checkColor: AppStyle.whiteAccent,
                          fillColor: MaterialStateProperty.resolveWith(_getCheckBoxColor),
                          value: allowAnon,
                          onChanged: (val){
                            setState(() {
                              allowAnon = val ?? false;
                            });
                          },
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Text(
                          'Allow anonymous participants?',
                          style: subHeadingStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
