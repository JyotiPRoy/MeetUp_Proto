import 'dart:convert';

class MeetingEvent {
  final String roomID; // Also serves as the ID for this event of Firestore db
  final String hostID;
  final String title;
  final DateTime start;
  final DateTime? end;
  final String? details;
  final List<String>? participants;
  final bool allowAnon;
  
  MeetingEvent({
    required this.roomID,
    required this.hostID,
    required this.title,
    required this.start,
    this.end,
    this.details,
    this.participants,
    this.allowAnon = false,
  });
  
  factory MeetingEvent.fromMap(Map map)
    => MeetingEvent(
      roomID: map['roomID'],
      hostID: map['hostID'],
      title: map['title'],
      start: DateTime.parse(map['start']),
      end: map['end'] != ''
            ? DateTime.parse(map['end'])
            : null,
      details: map['details'] != ''
              ? map['details'] : null,
      participants: map['participants'] != ''
              ? List<String>.from(map['participants'])
              : null,
      allowAnon: map['allowAnon']
    );

  Map<String,dynamic> toMap()
  => {
    'roomID' : this.roomID,
    'hostID' : this.hostID,
    'title' : this.title,
    'start' : this.start.toIso8601String(),
    'end' : this.end != null
        ? this.end!.toIso8601String() : '',
    'details' : this.details ?? '',
    'participants' : this.participants != null
        ? jsonEncode(this.participants) : '',
    'allowAnon' : this.allowAnon
  };
  
}