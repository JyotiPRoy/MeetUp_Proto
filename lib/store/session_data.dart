import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ms_engage_proto/model/meeting_event.dart';
import 'package:ms_engage_proto/model/user.dart';

part 'session_calendar_events.dart';

class SessionData with ChangeNotifier, _SessionCalendarEvents{
  UserProfile? _currentUser;
  Map<String,MeetingEvent>  _calendarEvents = <String,MeetingEvent>{};

  final _userStreamController = StreamController<UserProfile>.broadcast();

  static final CollectionReference<Map<String,dynamic>> _userCollection
    = FirebaseFirestore.instance.collection('users');

  SessionData._(){
    currentUserStream.listen((user) {
      if(user != null){
        _populateUserData();
      }
    });
  }

  Future<void> _populateUserData() async {
    await getAllMeetingEvents();
  }

  static final SessionData _instance = SessionData._();

  static SessionData get instance => _instance;
  UserProfile? get currentUser => _currentUser;
  Stream<UserProfile?> get currentUserStream => _userStreamController.stream;

  void updateUser(UserProfile user){
    _currentUser = user;
    _userStreamController.add(_currentUser!);
  }

  // PART: Calendar/Meeting Events
  Future<void> getAllMeetingEvents() async {
    _calendarEvents.addAll(await getAllCalendarEvents(_currentUser!.userID));
    refreshCalendarEvents(); // Added Listener
  }
  Future<void> addMeetingEvent(MeetingEvent event) async => await addCalendarEvents(event, _currentUser!.userID);
  Future<void> deleteMeetingEvent(MeetingEvent event) async => await deleteCalendarEvent(event, _currentUser!.userID);
  Future<void> editMeetingEvent(String oldEventID, MeetingEvent newEvent) async
        => editCalendarEvent(oldEventID, newEvent, _currentUser!.userID);

  /// Refreshes the local cache of MeetingEvents when data is received from Firestore db.
  /// We could have added the changes locally and then uploaded them to Firestore
  /// but since collaboration is an aspect, so we expect to receive meeting events
  /// which were not created by us, but our friend who added us to the meeting.
  /// But this also helps us as after events like add, delete and edit, we don't have
  /// to explicitly refresh the local store
  void refreshCalendarEvents(){
    final eventCollection = _userCollection.doc(_currentUser!.userID).collection('calendarEvents');
    eventCollection.snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        try{
          var data = change.doc.data();
          if(data == null) throw Exception('Null Doc Change received! @refreshCal');
          switch(change.type){
            // Since in a map in dart if key is not present, it's added
            // and if it's present, the value is modified
            case DocumentChangeType.added:
            case DocumentChangeType.modified: _calendarEvents[data['roomID']] = MeetingEvent.fromMap(data); break;
            case DocumentChangeType.removed: _calendarEvents.remove(data['roomID']); break;
            default: throw Exception('Invalid Document change type');
          }
        }catch(e){
          print("Exception @RefreshCal: ${e.toString()}");
        }
      });
    });
  }
}