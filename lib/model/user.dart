
import 'dart:convert';

class UserProfile{
  final String userID;
  String userName;
  String? pfpUrl;
  String? email;
  bool shareEmail;
  bool optOutOfSearch;

  UserProfile({
    required this.userID,
    required this.userName,
    this.pfpUrl,
    this.email,
    this.shareEmail = false,
    this.optOutOfSearch = false
  }){
    _createUser();
  }

  Map<String,dynamic> toMap(){
    return {
      'userID' : this.userID,
      'userName' : this.userName,
      'pfpUrl' : this.pfpUrl,
      'email' : this.email,
      'shareEmail' : this.shareEmail,
      'optOutOfSearch' : this.optOutOfSearch
    };
  }

  UserProfile.fromMap(Map map)
  : userID = map['userID'],
    userName = map['userName'],
    pfpUrl = map['pfpUrl'] == null || map['pfpUrl'] == ''
        ? null : map['pfpUrl'],
    email = map['email'],
    shareEmail = map['shareEmail'],
    optOutOfSearch = map['optOutOfSearch'];

  UserProfile copyWith({
    String? userID,
    String? userName,
    String? pfpUrl,
    String? email,
    List<String>? chatRooms,
    List<String>? pendingRequests,
    bool? shareEmail,
    bool? optOutOfSearch
  }){
    return UserProfile(
      userID: userID ?? this.userID,
      userName: userName ?? this.userName,
      pfpUrl: pfpUrl ?? this.pfpUrl,
      email: email ?? this.email,
      shareEmail: shareEmail ?? this.shareEmail,
      optOutOfSearch: optOutOfSearch ?? this.optOutOfSearch,
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