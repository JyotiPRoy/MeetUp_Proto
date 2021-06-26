import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ms_engage_proto/model/meeting_event.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/widgets/default_button.dart';
import 'package:ms_engage_proto/utils/ui_utils.dart';

class MeetingCalendarEvent extends StatefulWidget {
  final MeetingEvent event;
  final StreamController<int>? groupController;
  final int? index;

  MeetingCalendarEvent({
    Key? key,
    required this.event,
    this.groupController,
    this.index,
  })  : assert(groupController != null ? index != null : index == null),
        super(key: key);

  @override
  _MeetingCalendarEventState createState() => _MeetingCalendarEventState();
}

class _MeetingCalendarEventState extends State<MeetingCalendarEvent> {
  bool _isSelected = false;
  bool _isParticipantListEmpty = true;

  @override
  void initState() {
    super.initState();
    _isParticipantListEmpty = widget.event.participants != null
        ? widget.event.participants!.isEmpty
        : widget.event.participants == null;
    if (widget.groupController != null) {
      widget.groupController!.stream.listen((event) {
        setState(() {
          _isSelected = event == widget.index;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    var subtextColor = _isSelected
        ? AppStyle.whiteAccent.withOpacity(0.7)
        : AppStyle.defaultUnselectedColor;

    return MouseRegion(
      cursor: widget.groupController != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: () {
          if (widget.groupController != null) {
            widget.groupController!.sink.add(widget.index!);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.all(height * 0.03),
          width: width * 0.21,
          height: height * 0.28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            border: Border.all(color: AppStyle.defaultBorderColor),
            color: _isSelected
                ? AppStyle.primaryButtonColor
                : AppStyle.secondaryColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.event.title,
                style: TextStyle(
                    color: AppStyle.whiteAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
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
                    width: 10,
                  ),
                  Text(
                    '${widget.event.start.hour}:${widget.event.start.minute} - ' +
                        '${(widget.event.end != null ? widget.event.end!.hour : '')}'
                            ':${(widget.event.end != null ? widget.event.end!.minute : '')}  |',
                    style: TextStyle(color: subtextColor, fontSize: 14),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Starts in ${UIUtils.formatTime(dateTime: widget.event.start)}',
                    style: TextStyle(color: subtextColor, fontSize: 14),
                  )
                ],
              ),
              Expanded(
                child: SizedBox(),
              ),
              Row(
                children: [
                  Text(
                    '${!_isParticipantListEmpty
                        ? widget.event.participants!.length.toString() + ' Participants' : 'No Participants'}',
                    style: TextStyle(color: AppStyle.whiteAccent, fontSize: 18),
                  ),
                  Expanded(
                    child: SizedBox(),
                  ),
                  widget.groupController == null
                      ? Row(
                          children: [
                            _isParticipantListEmpty
                                ? DefaultButton(
                                    onPress: () {},
                                    child: Text('Invite'),
                                    fixedSize: Size(75, 50),
                                  )
                                : SizedBox(),
                            SizedBox(
                              width: 10,
                            ),
                            DefaultButton(
                              onPress: () {},
                              child: Text('Start'),
                              fixedSize: Size(75, 50),
                            )
                          ],
                        )
                      : DefaultButton(
                          onPress: () {},
                          fixedSize: Size(50, 50),
                          buttonColor: Colors.transparent,
                          buttonBorder: BorderSide(
                            color: AppStyle.defaultBorderColor,
                          ),
                          child: Icon(
                            Icons.delete_outline_outlined,
                            color: subtextColor,
                          ),
                        ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
