
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ms_engage_proto/core/user.dart';

class Auth{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _userCollection = FirebaseFirestore.instance.collection('users');
  final _storageReference = FirebaseStorage.instance.ref('user_pfps');

  User? currentUser(){
    return _auth.currentUser;
  }

  Future<UserProfile?> _createNewUser(
      String userID,
      UserProfile fromLanding,
      PlatformFile? pfp
    ) async {
    // try{
    //
    // }catch(e){
    //   print('EXCP @createNewUser : ${e.toString()}');
    //   return null;
    // }
    String location = '';

    if(pfp != null){
      final pfpFile = _storageReference.child('${userID}_pfp.${pfp.extension}');
      // Uploading the pfp got from local storage as a List of bytes
      // Not providing any metadata for the image as of now
      await pfpFile.putData(pfp.bytes!, SettableMetadata(contentType: 'image'));
      // Getting the download url
      location = await pfpFile.getDownloadURL();
      // Setting pfpUrl = location, so we can use that anywhere in the app with
      // NetworkImage widget
    }
    UserProfile newUser = fromLanding.copyWith(
        userID: userID,
        pfpUrl: location
    );
    // Uploading User details to Firestore 'users' collection
    await _userCollection.doc(userID).set(newUser.toMap());
    return newUser;
  }

  Future<UserProfile?> getProfileFromFirebase(User user) async {
    try{
      UserProfile? userProfile;
      var snapshot = await _userCollection.get();
      for(QueryDocumentSnapshot<Map<String,dynamic>> doc in snapshot.docs){
        if(doc.id == user.uid){
          userProfile = UserProfile.fromMap(doc.data());
        }
      }
      print('USER: ${jsonEncode(userProfile!.toMap())}');
      return userProfile;
    }catch(e){
      print('EXCP: ${e.toString()}');
      return null;
    }
  }

  Future<UserProfile?> signInWithEmail(String email, String password) async {
    try{
      UserCredential res = await _auth.signInWithEmailAndPassword(
          email: email, password: password
      );
      User user;
      if(res.user != null){
        user = res.user!; // Even after null checking I'm being forced to use ! operator. -_-
      }else throw Exception('Received null user!');
      return getProfileFromFirebase(user);
    }catch(e){
      print('EXCP @signUp: ${e.toString()}');
      return null;
    }
  }

  Future<UserProfile?> signUpWithEmail(
      String email,
      String password,
      UserProfile fromLanding,
      PlatformFile? pfp
    ) async {
    try{
      UserCredential res = await _auth.createUserWithEmailAndPassword(
          email: email, password: password
      );
      User user;
      if(res.user != null){
        user = res.user!;
      }else throw Exception('Received null user at signup!');
      return await _createNewUser(user.uid, fromLanding, pfp);
    }catch(e){
      print('EXCP @signup: ${e.toString()}');
      return null;
    }
  }

  Future resetPassword(String email) async {
    try{
      return _auth.sendPasswordResetEmail(email: email);
    }catch(e){
      print('EXCP: ${e.toString()}');
      return null;
    }
  }

  Future<void> signOut() async{
    try{
      await _auth.signOut();
      // TODO: Remove User from Global User Field
    }catch(e){
      print('EXCP: ${e.toString()}');
      return null;
    }
  }
}