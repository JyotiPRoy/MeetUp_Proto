import 'package:flutter/widgets.dart';
import 'package:ms_engage_proto/core/rtc_core.dart';

class RTCProvider extends InheritedWidget{
  final RTCCore core;

  RTCProvider({
    required this.core,
    required Widget child
  }) : super(child: child);

  static RTCProvider of(BuildContext context) => (context.dependOnInheritedWidgetOfExactType<RTCProvider>()!);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}