import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ms_engage_proto/core/user.dart';

class GlobalStore with ChangeNotifier{
  UserProfile? _currentUser;
  // ignore: close_sinks
  final _userStreamController = StreamController<UserProfile>();

  GlobalStore._();

  static final GlobalStore _instance = GlobalStore._();

  static GlobalStore get instance => _instance;
  UserProfile? get currentUser => _currentUser;

  void updateUser(UserProfile user){
    _currentUser = user;
    _userStreamController.sink.add(_currentUser!);
  }

}