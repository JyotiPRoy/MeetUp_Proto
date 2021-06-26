
import 'dart:convert';

class UserProfile{
  final String userID;
  String userName;
  String? pfpUrl;
  String? email;
  /// Contains list of chat-room IDs.
  List<String>? chatRooms;
  /// Pending Friend Requests. Contains a list of userIDs of users
  /// who have sent the friend requests.
  List<String>? pendingRequests;
  bool shareEmail;

  UserProfile({
    required this.userID,
    required this.userName,
    this.pfpUrl,
    this.email,
    this.chatRooms,
    this.pendingRequests,
    this.shareEmail = false,}){
    _createUser();
  }

  Map<String,dynamic> toMap(){
    return {
      'userID' : this.userID,
      'userName' : this.userName,
      'pfpUrl' : this.pfpUrl,
      'email' : this.email,
      'chatRooms' : this.chatRooms != null
                      ? jsonEncode(this.chatRooms)
                      : 'null',
      'pendingRequests' : this.pendingRequests != null
                            ? jsonEncode(this.pendingRequests)
                            : 'null',
      'shareEmail' : this.shareEmail
    };
  }

  UserProfile.fromMap(Map map)
  : userID = map['userID'],
    userName = map['userName'],
    pfpUrl = map['pfpUrl'],
    email = map['email'],
    chatRooms = map['chatRooms'] != 'null'
                  ? List<String>.from(jsonDecode(map['chatRooms']))
                  : null,
    pendingRequests = map['pendingRequests'] != 'null'
                        ? List<String>.from(jsonDecode(map['pendingRequests']))
                        : null,
    shareEmail = map['shareEmail'];

  UserProfile copyWith({
    String? userID,
    String? userName,
    String? pfpUrl,
    String? email,
    List<String>? chatRooms,
    List<String>? pendingRequests,
    bool? shareEmail
  }){
    return UserProfile(
      userID: userID ?? this.userID,
      userName: userName ?? this.userName,
      pfpUrl: pfpUrl ?? this.pfpUrl,
      email: email ?? this.email,
      chatRooms: chatRooms ?? this.chatRooms,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      shareEmail: shareEmail ?? this.shareEmail
    );
  }

  Future<void> uploadPFP(String path) async{
    // TODO: IMPLEMENT
  }

  Future<void> updateUserDetails(UserProfile newUser) async{
    // TODO: IMPLEMENT
  }

  Future<void> _createUser() async{
    // TODO: IMPLEMENT
  }

  Future<void> deleteUser() async{
    // TODO: IMPLEMENT
  }
}