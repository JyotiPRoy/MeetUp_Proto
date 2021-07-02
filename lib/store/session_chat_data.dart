part of 'session_data.dart';

mixin _SessionChatData {
  static final CollectionReference<Map<String, dynamic>> _userCollection =
      FirebaseFirestore.instance.collection('users');
  final _userNameCollection =
      FirebaseFirestore.instance.collection('userName-ID');
  static const String chatRoomsCollection = 'chatRooms';
  static const String pendingRequestsCollection = 'pendingRequests';
  static const contactsCollection = 'contacts';

  Future<void> _createChatRoom(List<UserProfile> participants) async {
    String roomID = MiscUtils.generateSecureRandomString(12);
    ChatRoom res = ChatRoom(roomID: roomID, participants: participants);
    for (UserProfile user in participants) {
      await _userCollection
          .doc(user.userID)
          .collection(chatRoomsCollection)
          .doc(roomID)
          .set(res.toMap());
    }
  }

  // Friend Request
  Future<void> _sendChatRequest(
      UserProfile sender, List<UserProfile> receivers) async {
    List<UserProfile> participants = [
      //Sender has to be the first in the list as it will be used to display group host/admin later
      sender,
      ...receivers,
    ];
    String chatRoomID = MiscUtils.generateSecureRandomString(12);
    PendingRequest request =
        PendingRequest(chatRoomID: chatRoomID, participants: participants);
    for (UserProfile rec in receivers) {
      await _userCollection
          .doc(rec.userID)
          .collection(pendingRequestsCollection)
          .doc(chatRoomID)
          .set(request.toMap());
    }
  }

  Future<void> _acceptPendingRequest(UserProfile accepter, PendingRequest request) async {
    for(UserProfile user in request.participants){
      var userDoc =  _userCollection.doc(user.userID);
      await userDoc.collection(chatRoomsCollection).doc(request.chatRoomID).set(request.toChatRoomMap());
      for(UserProfile user2 in request.participants){
        if(user.userID != user2.userID){
          userDoc.collection(contactsCollection).doc(user2.userID).set({'userID' : user2.userID});
        }
      }
    }
    await _userCollection
        .doc(accepter.userID).collection(pendingRequestsCollection).doc(request.chatRoomID).delete();
  }

  Future<List<UserProfile>> _getAllContacts(String userID) async {
    List<UserProfile> contacts = [];
    Auth _auth = Auth();
    var snapshot = await _userCollection.doc(userID).collection(contactsCollection).get();
    for (QueryDocumentSnapshot<Map<String, dynamic>> element in snapshot.docs) {
      UserProfile? contact =
          await _auth.getProfileFromFirebase(element.data()['userID']);
      if (contact != null) {
        contacts.add(contact);
      } else
        print('Received Null UserProfile from Firebase! @GetAllContacts');
    }
    return contacts;
  }

  Future<List<PendingRequest>> _getAllPendingRequest(String userID) async {
    List<PendingRequest> requests = [];
    var snapshot = await _userCollection.doc(userID).collection(pendingRequestsCollection).get();
    for(QueryDocumentSnapshot<Map<String,dynamic>> docSnap in snapshot.docs){
      requests.add(await PendingRequest.fromMap(docSnap.data()));
    }
    return requests;
  }

  Future<List<ChatRoom>> _getAllChatRooms(String userID) async {
    List<ChatRoom> chatRooms = [];
    var snapshot = await _userCollection.doc(userID).collection(chatRoomsCollection).get();
    for(QueryDocumentSnapshot<Map<String,dynamic>> docSnap in snapshot.docs){
      chatRooms.add(await ChatRoom.fromMap(docSnap.data()));
    }
    return chatRooms;
  }

}
