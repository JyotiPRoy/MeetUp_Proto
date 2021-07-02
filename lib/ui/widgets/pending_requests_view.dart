import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ms_engage_proto/model/chat.dart';
import 'package:ms_engage_proto/model/user.dart';
import 'package:ms_engage_proto/store/session_data.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';

class PendingRequestsView extends StatefulWidget {
  const PendingRequestsView({Key? key}) : super(key: key);

  @override
  _PendingRequestsViewState createState() => _PendingRequestsViewState();
}

class _PendingRequestsViewState extends State<PendingRequestsView> {
  OverlayEntry? overlayEntry;
  final LayerLink layerLink = LayerLink();
  Stream<List<PendingRequest>> pendingRequests
    = SessionData.instance.pendingRequests;
  bool _hasPendingRequests = false;
  bool _isShowing = false;
  List<PendingRequest> _initialData = [];

  @override
  void initState() {
    super.initState();
    pendingRequests.listen((requests) {
      setState(() {
        _hasPendingRequests = requests.length != 0;
        _initialData = requests;
      });
    });
  }

  OverlayEntry _createOverlay() {
    var radius = Radius.circular(15);

    return OverlayEntry(
      builder: (context)
        => Positioned(
          width: 300,
          height: 200,
          child: CompositedTransformFollower(
            link: layerLink,
            offset: Offset(-150, 52),
            child: Material(
              color: AppStyle.secondaryColor,
              borderRadius: BorderRadius.only(bottomLeft: radius, bottomRight: radius),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  child: StreamBuilder<List<PendingRequest>>(
                    initialData: _initialData,
                    stream: SessionData.instance.pendingRequests,
                    builder: (context, snapshot){
                      print('IS SNAPSHOT NULL: ${snapshot.data == null}');
                      if(snapshot.hasData && snapshot.data != null){
                        return ListView(
                          children: snapshot.data!.map((pendingRequest)
                              {
                                UserProfile user = pendingRequest.participants[0];
                                return Container(
                                  child: Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color:
                                                    AppStyle.defaultBorderColor),
                                            color: AppStyle.secondaryColor,
                                            image: user.pfpUrl != null
                                                ? DecorationImage(
                                                    image: NetworkImage(user.pfpUrl!)
                                                  )
                                                : null,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Text(
                                        user.userName,
                                        style: TextStyle(
                                          color: AppStyle.whiteAccent,
                                          fontSize: 16
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },).toList(),
                        );
                      }
                      return Center(
                        child: Container(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            color: AppStyle.whiteAccent,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
    );
  }

  void _toggleOverlay() {
    overlayEntry = _createOverlay();
    if(!_isShowing){
      // .insert(overlayEntry!);
      WidgetsBinding.instance!.addPostFrameCallback((_) => Overlay.of(context)!.insert(overlayEntry!));
      _isShowing = true;
    }else{
      _isShowing = false;
      overlayEntry!.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: layerLink,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _toggleOverlay(),
          child: Container(
            height: 50,
            width: 50,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                      clipBehavior: Clip.antiAlias,
                      // width: 50,
                      // height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        border: Border.all(
                          color: AppStyle.defaultBorderColor,
                        ),
                        color: AppStyle.secondaryColor,
                      ),
                      child: Icon(
                        FontAwesomeIcons.bell,
                        color: AppStyle.defaultUnselectedColor,
                      )
                  ),
                ),
                Positioned(
                  left: 27,
                  top: 16,
                  child: Visibility(
                    visible: _hasPendingRequests,
                    child: Container(
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: AppStyle.defaultErrorColor,
                        shape: BoxShape.circle
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
