import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String userID;
  String? message;
  List<ChatAttachment>? attachments;
  bool _sent = false;

  Chat({
    required this.userID,
    this.message,
    this.attachments,
  });
        // assert(message != null && attachments!.length != 0);

  Map<String,String> toMap(){
    Map<String,String> res = {};
    res['userID'] = this.userID;
    res['message'] = this.message ?? '';
    res['attachments'] = this.attachments != null
        ? jsonEncode(this.attachments!.map((e) => e.toMap()).toList())
        : jsonEncode(null);
    return res;
  }

  static Chat fromMap(Map map){
    Chat res = Chat(
      userID: map['userID']!,
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


class SessionChat{

  SessionChat({required this.sessionID}){
    _chatCollection =
        FirebaseFirestore.instance.collection('calls').doc(sessionID).collection('sessionChat');

  }

  final String sessionID;
  final List<Chat> _chats = <Chat>[];

   late CollectionReference<Map<String,dynamic>> _chatCollection;


}