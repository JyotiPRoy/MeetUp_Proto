
class UserProfile{
  final String userID;
  String userName;
  String? pfpUrl;
  String? email;
  bool shareEmail;

  UserProfile({
    required this.userID,
    required this.userName,
    this.pfpUrl,
    this.email,
    this.shareEmail = false,}){
    _createUser();
  }

  Map<String,dynamic> toMap(){
    return {
      'userID' : this.userID,
      'userName' : this.userName,
      'pfpUrl' : this.pfpUrl,
      'email' : this.email,
      'shareEmail' : this.shareEmail
    };
  }

  UserProfile.fromMap(Map map)
  : userID = map['userID'],
    userName = map['userName'],
    pfpUrl = map['pfpUrl'],
    email = map['email'],
    shareEmail = map['shareEmail'];

  UserProfile copyWith({
    String? userID,
    String? userName,
    String? pfpUrl,
    String? email,
    bool? shareEmail
  }){
    return UserProfile(
      userID: userID ?? this.userID,
      userName: userName ?? this.userName,
      pfpUrl: pfpUrl ?? this.pfpUrl,
      email: email ?? this.email,
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