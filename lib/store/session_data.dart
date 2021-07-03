import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ms_engage_proto/model/chat.dart';
import 'package:ms_engage_proto/model/meeting_event.dart';
import 'package:ms_engage_proto/model/user.dart';
import 'package:ms_engage_proto/services/auth.dart';
import 'package:ms_engage_proto/utils/misc_utils.dart';
import 'package:rxdart/rxdart.dart';

part 'session_calendar_events.dart';
part 'session_chat_data.dart';

class SessionData
    with ChangeNotifier, _SessionCalendarEvents, _SessionChatData{
  UserProfile? _currentUser;
  /// String roomID (also ID of the event on Firestore) & MeetingEvent is the event object
  Map<String,MeetingEvent>  _calendarEvents = <String,MeetingEvent>{};
  /// List of ChatRooms
  List<ChatRoom> _chatRooms = <ChatRoom>[];
  /// List of Friends/Contacts
  List<UserProfile> _contacts = [];
  /// Pending Friend Requests
  List<PendingRequest> _pendingRequests = <PendingRequest>[];


  final Auth _auth = Auth();
  final _userStreamController = BehaviorSubject<UserProfile>();
  final _pendingRequestController = BehaviorSubject<List<PendingRequest>>();
  final _chatRoomController = BehaviorSubject<List<ChatRoom>>();
  final _contactsController = BehaviorSubject<List<UserProfile>>();

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
    // await getAllMeetingEvents();
    await getPendingRequests();
    await getContacts();
    await getChatRooms();
  }

  static final SessionData _instance = SessionData._();

  static SessionData get instance => _instance;
  UserProfile? get currentUser => _currentUser;
  Stream<UserProfile?> get currentUserStream => _userStreamController.stream;
  Stream<List<PendingRequest>> get pendingRequests => _pendingRequestController.stream;
  Stream<List<ChatRoom>> get chatRooms => _chatRoomController.stream;
  Stream<List<UserProfile>> get contacts => _contactsController.stream.distinct();

  void updateUser(UserProfile user){
    _currentUser = user;
    _userStreamController.add(_currentUser!);
  }

  // PART: Calendar/Meeting Events
  Future<void> getAllMeetingEvents() async {
    // _calendarEvents.addAll(await getAllCalendarEvents(_currentUser!.userID));
    
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
          if(data == null) throw Exception('Null Doc Change received! @RefreshCal');
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


  Future<void> sendRequest(List<UserProfile> participants) async => _sendChatRequest(_currentUser!, participants);
  Future<void> acceptRequest(PendingRequest request) async => _acceptPendingRequest(_currentUser!, request);
  Future<void> getContacts() async {
    // _contacts = await _getAllContacts(_currentUser!.userID);
    _contactsController.add(_contacts);
    refreshContacts();
  }
  Future<void> getPendingRequests() async {
    // print("GETTING PENDING REQUEST!");
    // _pendingRequests = await _getAllPendingRequest(_currentUser!.userID);
    // print('PENDING REQUEST LENGTH: ${_pendingRequests.length}');
    // _pendingRequestController.add(_pendingRequests);
    refreshPendingRequests();
  }
  Future<void> getChatRooms() async {
    // _chatRooms = await _getAllChatRooms(_currentUser!.userID);
    // _chatRoomController.add(_chatRooms);
    refreshChatRooms();
  }
  Future<void> createRoom(List<UserProfile> participants) async => _createChatRoom(participants);
  Future<void> sendChat(Chat chat, ChatRoom chatRoom) async => await _sendChat(chat, chatRoom);

  void refreshContacts() {
    final contactsCollection = _userCollection.doc(_currentUser!.userID).collection('contacts');
    contactsCollection.snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) async {
        bool wasModified = false;
        try{
          var data = change.doc.data();
          if(data == null) throw Exception('Null Doc Change received! @RefreshContacts');
          switch(change.type){
            case DocumentChangeType.added:{
              UserProfile? user = await _auth.getProfileFromFirebase(data['userID']);
              if(user != null){
                _contacts.add(user);
                wasModified = true;
              }else print('NULL USER VALUE, @RefreshContacts');
              break;
            }
            case DocumentChangeType.modified: break; //This case is invalid in this case
            case DocumentChangeType.removed: {
              _contacts.removeWhere((user) => user.userID == data['userID']);
              wasModified = true;
              break;
            }
            default: throw Exception('Invalid Document change type');
          }
          if(wasModified){
            _contactsController.add(_contacts);
          }
        }catch(e){
          print('Exception @RefreshContacts: ${e.toString()}');
        }
      });
    });
  }

  void refreshPendingRequests() {
    final requestCollection = _userCollection.doc(_currentUser!.userID).collection('pendingRequests');
    requestCollection.snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) async {
        bool wasModified = false;
        try{
          var data = change.doc.data();
          if(data == null) throw Exception('Null Doc Change received! @RefreshContacts');
          switch(change.type){
            case DocumentChangeType.added: {
              print("JUST CHECKING HERE!");
              _pendingRequests.add(await PendingRequest.fromMap(data));
              wasModified = true;
              break;
            }
            case DocumentChangeType.modified: break; //This case is invalid in this case
            case DocumentChangeType.removed: {
              _pendingRequests.removeWhere((request) => request.chatRoomID == data['chatRoomID']);
              wasModified = true;
              break;
            }
          }
          if(wasModified){
            _pendingRequestController.add(_pendingRequests);
          }
        }catch(e){
          print('Exception at refreshing PendingRequests: ${e.toString()}');
        }
      });
    });
  }

  void refreshChatRooms() {
    final chatRoomCollection = _userCollection.doc(_currentUser!.userID).collection('chatRooms');
    chatRoomCollection.snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) async {
        bool wasModified = false;
        try{
          var data = change.doc.data();
          if(data == null) throw Exception('Null Doc Change received! @RefreshContacts');
          switch(change.type){
            case DocumentChangeType.added: {
              _chatRooms.add(await ChatRoom.fromMap(data));
              wasModified = true;
              break;
            }
            case DocumentChangeType.modified: break; //This case is invalid in this case
            case DocumentChangeType.removed: {
              _chatRooms.removeWhere((room) => room.roomID == data['roomID']);
              wasModified = true;
              break;
            }
          }
          if(wasModified){
            _chatRoomController.add(_chatRooms);
          }
        }catch(e){
          print('Exception at Refresh ChatRoom!');
        }
      });
    });
  }


}