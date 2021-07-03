
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:ms_engage_proto/model/chat.dart';
import 'package:ms_engage_proto/store/session_data.dart';
import 'package:rxdart/rxdart.dart';

abstract class ChatViewModel<T extends StatefulWidget> extends State<T> {
  final sessionData = SessionData.instance;
  final chatRoomCollection = FirebaseFirestore.instance.collection('chatRooms');
  List<Chat> chats = <Chat>[];
  final BehaviorSubject<List<Chat>> chatStreamController = BehaviorSubject<List<Chat>>();
  final scrollController = ScrollController();

  void init(ChatRoom? chatRoom){
    if(chatRoom != null){
      chatStreamController.add(chats);
      pullAndRefreshChats(chatRoom);
    }
  }

  void pullAndRefreshChats(ChatRoom chatRoom){
    var snapshot = chatRoomCollection.doc(chatRoom.roomID).collection('chats').snapshots();
    snapshot.listen((snap) {
      snap.docChanges.forEach((change) {
        bool wasModified = false;
        var data = change.doc.data();
        if(data == null) throw Exception('Null Chat Data');
        switch(change.type){
          case DocumentChangeType.added: {
            chats.add(Chat.fromMap(data));
            wasModified = true;
            break;
          }
          case DocumentChangeType.modified: break;
          case DocumentChangeType.removed: {
            // TODO: May implement this feature later if time permits;
            break;
          }
        }
        if(wasModified){
          chatStreamController.add(chats);
        }
      });
    });
  }

}