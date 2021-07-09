
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
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
  TextEditingController chatTextController = TextEditingController();
  final visibilityController = StreamController<bool>.broadcast();
  final attachmentController = StreamController<List<PlatformFile>>.broadcast();
  bool _isVisible = false;

  List<PlatformFile> attachments = [];

  void toggleVisibility(){
    _isVisible = !_isVisible;
    visibilityController.add(_isVisible);
  }

  void init(ChatRoom? chatRoom){
    visibilityController.add(_isVisible);
    attachmentController.add(attachments);
    if(chatRoom != null){
      chatStreamController.add(chats);
      pullAndRefreshChats(chatRoom);
    }
    attachmentController.stream.listen((newAttachments) {
      if(newAttachments.length == 0){
        visibilityController.add(false);
      }
      setState(() {
        attachments = newAttachments;
      });
    });
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