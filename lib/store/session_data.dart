import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:ms_engage_proto/model/chat.dart';
import 'package:ms_engage_proto/model/meeting_event.dart';
import 'package:ms_engage_proto/model/user.dart';
import 'package:ms_engage_proto/services/auth.dart';
import 'package:ms_engage_proto/utils/misc_utils.dart';
import 'package:rxdart/rxdart.dart';

part 'session_calendar_events.dart';
part 'session_chat_data.dart';

class SessionData with _SessionCalendarEvents, _SessionChatData{
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
  final _calendarEventsController = BehaviorSubject<Map<String,MeetingEvent>>();

  static final CollectionReference<Map<String,dynamic>> _userCollection
    = FirebaseFirestore.instance.collection('users');

  SessionData._(){
    currentUserStream.listen((user) {
      if(user != null){
        _init();
      }
    });
    uploadProgressController.stream.listen((frac) {
      print('UPLOAD FRAC: $frac');
    });
  }

  void _initStreams(){
    _pendingRequestController.add(_pendingRequests);
    _chatRoomController.add(_chatRooms);
    _contactsController.add(_contacts);
    _calendarEventsController.add(_calendarEvents);
    uploadProgressController.add(0.0);
  }

  Future<void> _init() async {
    _initStreams();
    pullAndRefreshCalendarEvents();
    pullAndRefreshPendingRequests();
    pullAndRefreshContacts();
    pullAndRefreshChatRooms();
  }

  static final SessionData _instance = SessionData._();
  static SessionData get instance => _instance;
  UserProfile? get currentUser => _currentUser;

  Stream<UserProfile?> get currentUserStream => _userStreamController.stream;
  Stream<List<PendingRequest>> get pendingRequests => _pendingRequestController.stream;
  Stream<List<ChatRoom>> get chatRooms => _chatRoomController.stream;
  Stream<List<UserProfile>> get contacts => _contactsController.stream.distinct();
  Stream<Map<String,MeetingEvent>> get calendarEvents => _calendarEventsController.stream;
  Stream<double> get uploadProgress => uploadProgressController.stream;

  void updateUser(UserProfile user){
    _currentUser = user;
    _userStreamController.add(_currentUser!);
  }

  // PART: Calendar/Meeting Events
  Future<void> addMeetingEvent(MeetingEvent event) async => await addCalendarEvents(event, _currentUser!.userID);
  Future<void> deleteMeetingEvent(MeetingEvent event) async => await deleteCalendarEvent(event, _currentUser!.userID);
  Future<void> editMeetingEvent(String oldEventID, MeetingEvent newEvent) async
        => editCalendarEvent(oldEventID, newEvent, _currentUser!.userID);

  void pullAndRefreshCalendarEvents(){
    final eventCollection = _userCollection.doc(_currentUser!.userID).collection('calendarEvents');
    eventCollection.snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        try{
          var data = change.doc.data();
          if(data == null) throw Exception('Null Doc Change received! @RefreshCal');
          switch(change.type){
            case DocumentChangeType.added: _calendarEvents[data['roomID']] = MeetingEvent.fromMap(data); break;
            case DocumentChangeType.modified: _calendarEvents[data['roomID']] = MeetingEvent.fromMap(data); break;
            case DocumentChangeType.removed: _calendarEvents.remove(data['roomID']); break;
            default: throw Exception('Invalid Document change type');
          }
          _calendarEventsController.add(_calendarEvents);
        }catch(e){
          print("Exception @RefreshCal: ${e.toString()}");
        }
      });
    });
  }

  // PART: Chat + Requests + Contacts
  Future<void> sendRequest(List<UserProfile> participants) async => _sendChatRequest(_currentUser!, participants);
  Future<void> acceptRequest(PendingRequest request) async => _acceptPendingRequest(_currentUser!, request);
  Future<void> createRoom(List<UserProfile> participants) async => _createChatRoom(participants);
  Future<void> sendChat(Chat chat, ChatRoom chatRoom, List<PlatformFile>? files) async => await _sendChat(chat, chatRoom, files);

  void pullAndRefreshContacts() {
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

  void pullAndRefreshPendingRequests() {
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

  void pullAndRefreshChatRooms() {
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