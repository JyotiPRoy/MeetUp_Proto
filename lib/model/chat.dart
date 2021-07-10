import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ms_engage_proto/model/user.dart';
import 'package:ms_engage_proto/services/auth.dart';

// Creating this enum for convenience
enum AttachmentType {Image, Video, File}

extension AttachmentTypeExtension on AttachmentType {

  static AttachmentType fromString(String type) {
    AttachmentType val;
    if(type.contains('image')){
     val = AttachmentType.Image;
    }else if(type.contains('video')){
      val = AttachmentType.Video;
    }else val = AttachmentType.File;
    return val;
  }

  IconData get icon {
    switch(this){
      case AttachmentType.Image: return FontAwesomeIcons.fileImage;
      case AttachmentType.Video: return FontAwesomeIcons.fileVideo;
      case AttachmentType.File: return FontAwesomeIcons.fileAlt;
    }
  }

}

class ChatAttachment{
  final String downloadUrl;  // File can be downloaded from Firebase with this url
  final String fileName; // File Name with extension. Mime type can be determined from this
  ChatAttachment({
    required this.downloadUrl,
    required this.fileName
  });

  ChatAttachment.fromMap(Map map)
  : downloadUrl = map['downloadUrl']!,
    fileName = map['fileName']!;

  Map<String,String> toMap(){
    return <String,String>{
      'downloadUrl' : this.downloadUrl,
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
  String? replyTo;
  List<ChatAttachment>? attachments;

  Chat({
    required this.senderID,
    this.message,
    this.replyTo,
    this.attachments,
  });
        // assert(message != null && attachments!.length != 0);

  Map<String,String> toMap(){
    Map<String,String> res = {};
    res['senderID'] = this.senderID;
    res['message'] = this.message ?? '';
    res['replyTo'] = this.replyTo ?? '';
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

/// This class stores the data required to setup and run a ChatRoom
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

/// SessionChat is the chat during an ongoing call
class SessionChat extends ChatRoom{
  String? title;
  DateTime dateTime;

  SessionChat({
    required String roomID,
    required List<UserProfile> participants,
    required this.dateTime,
    this.title
  }) : super(roomID: roomID, participants: participants);

  static Future<SessionChat> fromMap(Map map) async {
    Auth auth = Auth();
    List<UserProfile> _participants = [];
    for(String participantID in map['participants']){
      UserProfile? user = await auth.getProfileFromFirebase(participantID);
      if(user != null){
        _participants.add(user);
      }else throw Exception('Null User @ChatRoom -> fromMap()');
    }
    return SessionChat(
        roomID: map['roomID'],
        participants: _participants,
        dateTime: DateTime.parse(map['dateTime']),
        title: map['title']
    );
  }

  @override
  Map<String,dynamic> toMap()
  => {
    'roomID' : this.roomID,
    'participants' : this.participants.map((user) => user.userID).toList(),
    'dateTime' : this.dateTime.toIso8601String(),
    'title' : this.title
  };
}


/// A Friend Request
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