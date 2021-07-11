
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:ms_engage_proto/core/Session.dart';
import 'package:ms_engage_proto/store/session_data.dart';

typedef void StreamStateCallback(MediaStream stream,String id);

class GroupSession{

  GroupSession({
    required this.groupSessionID,
    required this.onAddRemote,
    required this.onAddLocal,
    required this.onRemoveRemote,
    required this.onError,
  }) : _peersCollection = FirebaseFirestore.instance.
          collection('videoRooms').doc(groupSessionID).collection('peers');

  final String groupSessionID;
  final _currentUser = SessionData.instance.currentUser!;

  Map<String,CallSession> peerSessions = {};

  RTCVideoRenderer? localRenderer;
  final StreamStateCallback onAddRemote, onRemoveRemote, onAddLocal;
  final ErrorCallback onError;

  CollectionReference<Map<String, dynamic>> _peersCollection;

  void _setStreamStateCallbacks(CallSession session, String id){
    session.onAddRemoteStream = (stream) => onAddRemote.call(stream,id);
    session.onLocalStream = (stream) => onAddLocal.call(stream,id);
    session.onRemoveRemoteStream = (stream) => onRemoveRemote.call(stream,id);
  }

  void joinCall() async {
    var snapshot = await _peersCollection.get();
    if(snapshot.docs.isNotEmpty){
      for(QueryDocumentSnapshot docSnap in snapshot.docs){
       if(docSnap.id != _currentUser.userID){
         var callDoc = docSnap.reference
             .collection('connections').doc(_currentUser.userID);
         final callSession = CallSession(callDoc: callDoc, onError: onError);
         peerSessions[docSnap.id] = callSession;
         _setStreamStateCallbacks(peerSessions[docSnap.id]!, docSnap.id);
         await peerSessions[docSnap.id]!.initialize(isOffer: true);
         peerSessions[docSnap.id]!.makeCall();
       }
      }
    }
    await _peersCollection.doc(_currentUser.userID).set(
        {'userID' : _currentUser.userID}
    );
    watchForPeer();
  }

  void leaveCall(){

  }

  void watchForPeer(){
    var selfDoc = _peersCollection
        .doc(_currentUser.userID).collection('connections');
    selfDoc.snapshots().listen((colSnap) {
      colSnap.docChanges.forEach((change) async {
        var data = change.doc.data();
        var id = change.doc.id;
        if(id != _currentUser.userID && !peerSessions.keys.contains(id)){
          if(data == null) throw Exception('Null Data @PeerWatcher');
          switch(change.type){
            case DocumentChangeType.added: {
              final callSession = CallSession(
                callDoc: change.doc.reference,
                onError: onError,
              );
              peerSessions[id] = callSession;
              _setStreamStateCallbacks(peerSessions[id]!, id);
              //await Future.delayed(Duration(seconds: 2)); // Sorry :(
              await peerSessions[id]!.initialize(isOffer: false);
              await peerSessions[id]!.answerCall();
              break;
            }
            case DocumentChangeType.modified:{
              break;
            }
            case DocumentChangeType.removed: {
              peerSessions[id]!.endCall();
              // TODO: Maybe even remove the Renderer/VideoView
              break;
            }
          }
        }
      });
    });
  }
}