
import 'dart:convert';
import 'dart:io';

import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';
import 'package:ms_engage_proto/model/user.dart';
import 'package:ms_engage_proto/store/algolia_helper.dart';

class Auth{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _userCollection = FirebaseFirestore.instance.collection('users');
  // final _userName_ID_Map = FirebaseFirestore.instance.collection('userName-ID');
  final _pfpStorageReference = FirebaseStorage.instance.ref('user_pfps');
  Algolia _algolia = AlgoliaHelper.algolia;

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
      final pfpFile = _pfpStorageReference.child('${userID}_pfp.${pfp.extension}');
      // Uploading the pfp got from local storage as a List of bytes
      // Not providing any metadata for the image as of now
      await pfpFile.putData(pfp.bytes!, SettableMetadata(contentType: lookupMimeType(pfp.name)));
      // Getting the download url
      location = await pfpFile.getDownloadURL();
      // Setting pfpUrl = location, so we can use that anywhere in the app with
      // NetworkImage widget
    }
    UserProfile newUser = fromLanding.copyWith(
        userID: userID,
        pfpUrl: location
    );
    // Uploading User details to Firestore 'users' collection and adding
    await _userCollection.doc(userID).set(newUser.toMap());
    /// Algolia indexing is now being taken care of by GCP Cloud Functions
    /// I have deployed on Firebase.
    /// await _algolia.instance.index('users').addObject(newUser.toMap());
    return newUser;
  }

  Future<UserProfile?> getProfileFromFirebase(String userID) async {
    try{
      UserProfile? userProfile;
      var snapshot = await _userCollection.get();
      for(QueryDocumentSnapshot<Map<String,dynamic>> doc in snapshot.docs){
        if(doc.id == userID){
          userProfile = UserProfile.fromMap(doc.data());
        }
      }
      return userProfile;
    }catch(e){
      print('EXCP: ${e.toString()}');
      return null;
    }
  }

  Future<UserProfile?> signInWithEmail(String email, String password) async {
    // try{
    //
    // }catch(e){
    //   print('EXCP @signUp: ${e.toString()}');
    //   return null;
    // }
    UserCredential res = await _auth.signInWithEmailAndPassword(
        email: email, password: password
    );
    User user;
    if(res.user != null){
      user = res.user!; // Even after null checking I'm being forced to use ! operator. -_-
    }else throw Exception('Received null user!');
    return getProfileFromFirebase(user.uid);
  }

  Future<UserProfile?> signUpWithEmail(
      String email,
      String password,
      UserProfile fromLanding,
      PlatformFile? pfp
    ) async {
    // try{
    //
    // }catch(e){
    //   print('EXCP @signup: ${e.toString()}');
    //   return null;
    // }
    UserCredential res = await _auth.createUserWithEmailAndPassword(
        email: email, password: password
    );
    User user;
    if(res.user != null){
      user = res.user!;
    }else throw Exception('Received null user at signup!');
    return await _createNewUser(user.uid, fromLanding, pfp);
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