
import 'package:flutter/cupertino.dart';
import 'package:ms_engage_proto/services/auth.dart';

class CoreServicesProvider extends InheritedWidget{

  CoreServicesProvider({
    required this.auth,
    required Widget child
  }) : super(child: child);

  final Auth auth;
  // TODO: Add rest here

  static CoreServicesProvider of(BuildContext context) => (context.dependOnInheritedWidgetOfExactType<CoreServicesProvider>()!);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;

}