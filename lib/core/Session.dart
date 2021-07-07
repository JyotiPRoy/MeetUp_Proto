

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Callback, when streams are added
typedef void StreamStateCallback(MediaStream stream);

class CallSession{

  CallSession({required this.callDoc}){
    // callDoc = FirebaseFirestore.instance.collection('calls').doc(sessionID);
    // sessionID = callDoc.id; // Since sessionID can be null (in case of calling)
    offerCandidates = callDoc.collection('offerCandidates');
    answerCandidates = callDoc.collection('answerCandidates');
  }

  // late String? sessionID;
  RTCPeerConnection? peerConnection;
  List<RTCIceCandidate> remoteCandidates = [];

  final DocumentReference<Map<String,dynamic>> callDoc;
  late CollectionReference<Map<String,dynamic>>? offerCandidates;
  late CollectionReference<Map<String,dynamic>>? answerCandidates;

  MediaStream? _localStream;
  List<MediaStream>? _remoteStreams;

  StreamStateCallback? onLocalStream;
  StreamStateCallback? onAddRemoteStream;
  StreamStateCallback? onRemoveRemoteStream;

  String get sdpSemantics => 'unified-plan';
  final rtcIceServers = <String, dynamic>{
    'iceServers' : [
      {
        'urls' : ['stun:stun1.l.google.com:19302', 'stun:stun2.l.google.com:19302'],
      },
    ],
  };
  final Map<String, dynamic> _config = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ]
  };

  void switchCamera() => Helper.switchCamera(_localStream!.getVideoTracks()[0]);

  void muteMic() {
    bool enabled = _localStream!.getAudioTracks()[0].enabled;
    _localStream!.getAudioTracks()[0].enabled = !enabled;
  }

  Future<MediaStream> createStream() async{
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth': '640',
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };
    MediaStream localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    onLocalStream!.call(localStream);
    return localStream;
  }

  Future<void> initialize({required bool isOffer}) async{
    peerConnection = await createPeerConnection({
      ...rtcIceServers,
      ...{'sdpSemantics' : sdpSemantics}
    }, _config);
    _localStream = await createStream();
    this.peerConnection!.onTrack = (event){
      if(event.track.kind == 'video'){
        onAddRemoteStream!.call(event.streams[0]);
      }
    };
    this.peerConnection!.onIceCandidate = (candidate) async{
      // ignore: unnecessary_null_comparison
      if(candidate == null){
        print('End!');
        return;
      }
      isOffer
          ? await offerCandidates!.add(candidate.toMap())
          : await answerCandidates!.add(candidate.toMap());
    };
    _localStream!.getTracks().forEach((track) {
      this.peerConnection!.addTrack(track, _localStream!);
    });
    this.peerConnection!.onIceConnectionState = (state){
      if(state == RTCIceConnectionState.RTCIceConnectionStateConnected){
        print('ICE STATE: CONNECTED!');
      }
    };
    this.peerConnection!.onConnectionState = (state){
      if(state == RTCPeerConnectionState.RTCPeerConnectionStateConnected){
        print('PEER CONN STATE: CONNECTED!');
      }
    };
    this.peerConnection!.onRemoveStream = (stream){
      onRemoveRemoteStream!.call(stream);
      _remoteStreams!.removeWhere((element) => element.id == stream.id);
    };
  }

  Future<void> makeCall() async{
    final offerDesc = await this.peerConnection!.createOffer();
    print('SDP: ${offerDesc.sdp}');
    this.peerConnection!.setLocalDescription(offerDesc);

    await callDoc.set(offerDesc.toMap());

    //Listen for an answer
    callDoc.snapshots().listen((snapshot) async {
      print('Listening for Answer!');
      var remoteDesc = await this.peerConnection!.getRemoteDescription();
      Map<String,dynamic>? data = snapshot.data();
      if(remoteDesc == null && data!['type'] != 'offer'){
        print('DATA: $data');
        print('Setting Remote Description!');
        final answerDesc = RTCSessionDescription(data['sdp'], data['type']);
        this.peerConnection!.setRemoteDescription(answerDesc);
      }
    });

    //Listening for answerCandidates
    answerCandidates!.snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        print('Answer Change: $change');
        if(change.type == DocumentChangeType.added){
          final candidate = RTCIceCandidate(
              change.doc['candidate'],
              change.doc['sdpMid'],
              change.doc['sdpMLineIndex']
          );
          this.peerConnection!.addCandidate(candidate);
        }
      });
    });
  }

  Future<void> answerCall() async{
    final callData = (await callDoc.get()).data();
    print('CALL DATA: $callData');
    await this.peerConnection!.setRemoteDescription(
        RTCSessionDescription(callData!['sdp'], callData['type'])
    );

    final answerDesc = await this.peerConnection!.createAnswer();
    await this.peerConnection!.setLocalDescription(answerDesc);

    await callDoc.update(answerDesc.toMap());

    offerCandidates!.snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        print('Offer Change: ${change.doc}');
        if(change.type == DocumentChangeType.added){
          final candidate = RTCIceCandidate(
              change.doc['candidate'],
              change.doc['sdpMid'],
              change.doc['sdpMLineIndex']
          );
          this.peerConnection!.addCandidate(candidate);
        }
      });
    });
  }

  void endCall(){
    _localStream!.dispose();
    _remoteStreams!.forEach((element) => element.dispose());
    this.peerConnection!.close();
  }
}