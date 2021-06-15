import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

final rtcIceServers = <String, dynamic>{
  'iceServers' : [
    {
      'urls' : ['stun:stun1.l.google.com:19302', 'stun:stun2.l.google.com:19302'],
    },
  ],
  'iceCandidatePoolSize' : 10,
};

// final loopbackConstraints = <String, dynamic>{
//   'mandatory': {},
//   'optional': [
//     {'DtlsSrtpKeyAgreement': true},
//   ],
// };

// Since we don't need audio/video
final offerConstraints = <String, dynamic>{
  'mandatory': {
    'OfferToReceiveAudio': true,
    'OfferToReceiveVideo': true,
  },
  'optional': [],
};

class RTCCore{
  RTCPeerConnection? _rtcPeerConnection;
  String rtcCallID = '';
  MediaStream? localStream;
  MediaStream? remoteStream;

  RTCCore(){
    // do something
  }

  void makeCall(String roomID) async{
    if(_rtcPeerConnection == null) {
      _rtcPeerConnection = await createPeerConnection({
        ...rtcIceServers,
        ...{'sdpSemantics' : 'unified-plan'}
      });
    }
    final callDoc = FirebaseFirestore.instance.collection('calls').doc(roomID);
    final offerCandidates = callDoc.collection('offerCandidates');
    final answerCandidates = callDoc.collection('answerCandidates');

    print('${callDoc.id}');
    rtcCallID = callDoc.id;

    // get candidates for caller and save to db. Can do with transactions later
    _rtcPeerConnection!.onIceCandidate = (candidate) async {
      // ignore: unnecessary_null_comparison
      if(candidate == null){
        print('End!');
        return;
      }
      print('Writing offer candidates!');
      await offerCandidates.add(candidate.toMap());
    };

    final offerDesc = await _rtcPeerConnection!.createOffer(offerConstraints);
    print('SDP: ${offerDesc.sdp}');
    await _rtcPeerConnection!.setLocalDescription(offerDesc);

    await callDoc.set(offerDesc.toMap());

    //Listen for an answer
    callDoc.snapshots().listen((snapshot) async {
      print('Listening for Answer!');
      var remoteDesc = await _rtcPeerConnection!.getRemoteDescription();
      var data = snapshot.data();
      if(remoteDesc == null && data!['type'] != 'offer'){
        print('DATA: $data');
        print('Setting Remote Description!');
        final answerDesc = RTCSessionDescription(data['sdp'], data['type']);
        _rtcPeerConnection!.setRemoteDescription(answerDesc);
      }
    });

    //Listening for answerCandidates
    answerCandidates.snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        print('Answer Change: $change');
        if(change.type == DocumentChangeType.added){
          final candidate = RTCIceCandidate(
              change.doc['candidate'],
              change.doc['sdpMid'],
              change.doc['sdpMLineIndex']
          );
          _rtcPeerConnection!.addCandidate(candidate);
        }
      });
    });
  }

  void answerCall(String callID) async{
    if(_rtcPeerConnection == null){
      _rtcPeerConnection = await createPeerConnection({
        ...rtcIceServers,
        ...{'sdpSemantics' : 'unified-plan'}
      });
    }
    final callDoc = FirebaseFirestore.instance.collection('calls').doc(callID);
    final offerCandidates = callDoc.collection('offerCandidates');
    final answerCandidates = callDoc.collection('answerCandidates');

    // get candidates for answerer and add to db
    _rtcPeerConnection!.onIceCandidate = (candidate) async {
      // ignore: unnecessary_null_comparison
      if(candidate == null){
        print('Ice candidate complete!');
        return;
      }
      await answerCandidates.add(candidate.toMap());
    };

    final callData = (await callDoc.get()).data();
    print('CALL DATA: $callData');
    await _rtcPeerConnection!.setRemoteDescription(
        RTCSessionDescription(callData!['sdp'], callData['type'])
    );

    final answerDesc = await _rtcPeerConnection!.createAnswer();
    await _rtcPeerConnection!.setLocalDescription(answerDesc);

    await callDoc.update(answerDesc.toMap());

    offerCandidates.snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        print('Offer Change: ${change.doc}');
        if(change.type == DocumentChangeType.added){
          final candidate = RTCIceCandidate(
              change.doc['candidate'],
              change.doc['sdpMid'],
              change.doc['sdpMLineIndex']
          );
          _rtcPeerConnection!.addCandidate(candidate);
        }
      });
    });
  }

  void endCall() async{
    _rtcPeerConnection!.close();
    _rtcPeerConnection = null;
  }

  RTCPeerConnection get peerConnection => _rtcPeerConnection!;
}