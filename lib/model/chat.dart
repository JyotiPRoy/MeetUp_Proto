import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ms_engage_proto/model/user.dart';
import 'package:ms_engage_proto/services/auth.dart';

class ChatAttachment{
  final String path;  // TODO: Determine whether it should be Uri or String
  final String fileName; // File Name with extension. Mime type can be determined from this
  ChatAttachment({
    required this.path,
    required this.fileName
  });

  ChatAttachment.fromMap(Map map)
  : path = map['path']!,
    fileName = map['fileName']!;

  Map<String,String> toMap(){
    return <String,String>{
      'path' : this.path,
      'fileName' : this.fileName
    };
  }
}

/// Represents a Chat. A chat on the Firestore db is a map of <String,String>
/// with a userID, a message and a list of file attachments. Each chat is stored
/// as a document under the collection: sessionChat in Firestore db.
/// The attachments are stored in the Firebase storage and the link is stored
/// under attachments in the Chat doc.
class Chat{
  final String senderID;
  String? message;
  List<ChatAttachment>? attachments;

  Chat({
    required this.senderID,
    this.message,
    this.attachments,
  });
        // assert(message != null && attachments!.length != 0);

  Map<String,String> toMap(){
    Map<String,String> res = {};
    res['senderID'] = this.senderID;
    res['message'] = this.message ?? '';
    res['attachments'] = this.attachments != null
        ? jsonEncode(this.attachments!.map((e) => e.toMap()).toList())
        : jsonEncode(null);
    return res;
  }

  static Chat fromMap(Map map){
    Chat res = Chat(
      senderID: map['senderID']!,
      message: map['message'],
    );
    if(map['attachments'] != 'null'){
      List<ChatAttachment> attachments = <ChatAttachment>[];
      List temp = jsonDecode(map['attachments']!).map((e)
      => ChatAttachment.fromMap(e)).toList();
      temp.forEach((element) => attachments.add(element));
      // All this had to be done to please the Dart Type-Police (Since the return from jsonDecode is JSArray<dynamic>) -_-
      res.attachments = attachments;
    }
    return res;
  }
}

class ChatRoom {
  String roomID;
  List<UserProfile> participants;

  ChatRoom({
    required this.roomID,
    required this.participants
  });

  static Future<ChatRoom> fromMap(Map map) async {
    Auth auth = Auth();
    List<UserProfile> _participants = [];
    for(String participantID in map['participants']){
      UserProfile? user = await auth.getProfileFromFirebase(participantID);
      if(user != null){
        _participants.add(user);
      }else throw Exception('Null User @ChatRoom -> fromMap()');
    }
    return ChatRoom(roomID: map['roomID'], participants: _participants);
  }

  factory ChatRoom.fromPendingRequest(PendingRequest request)
  => ChatRoom(
      roomID: request.chatRoomID,
      participants: request.participants
    );

  Map<String,dynamic> toMap()
   => {
      'roomID' : this.roomID,
      'participants' : this.participants.map((user) => user.userID).toList(),
   };
}

class PendingRequest {
  String chatRoomID; // This will be the ID of the ChatRoom once the request is accepted
  List<UserProfile> participants;

  PendingRequest({
    required this.chatRoomID,
    required this.participants
  });

  static Future<PendingRequest> fromMap(Map map) async {
    Auth auth = Auth();
    List<UserProfile> _participants = [];
    for(String participantID in map['participants']){
      UserProfile? user = await auth.getProfileFromFirebase(participantID);
      if(user != null){
        _participants.add(user);
      }else throw Exception('Null User @PendingRequest -> fromMap()');
    }
    return PendingRequest(chatRoomID: map['chatRoomID'], participants: _participants);
  }

  Map<String,dynamic> toMap()
  => {
    'chatRoomID' : this.chatRoomID,
    'participants' : this.participants.map((user) => user.userID).toList()
  };

  Map<String,dynamic> toChatRoomMap()
  => {
    'roomID' : this.chatRoomID,
    'participants' : this.participants.map((user) => user.userID).toList()
  };

}