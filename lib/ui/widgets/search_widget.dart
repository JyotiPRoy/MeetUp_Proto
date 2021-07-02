import 'dart:async';
import 'dart:collection';

import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:ms_engage_proto/model/user.dart';
import 'package:ms_engage_proto/services/auth.dart';
import 'package:ms_engage_proto/store/algolia_helper.dart';
import 'package:ms_engage_proto/store/session_data.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/widgets/default_button.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({Key? key}) : super(key: key);

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {

  TextEditingController _searchController = TextEditingController();
  final searchBarFocusNode = FocusNode();
  OverlayEntry? overlayEntry;
  final LayerLink layerLink = LayerLink();
  final Algolia _algolia = AlgoliaHelper.algolia;

  StreamController<UnmodifiableListView<AlgoliaObjectSnapshot>> _searchResults
      = StreamController<UnmodifiableListView<AlgoliaObjectSnapshot>>.broadcast();

  Future<void> _getResults(String key) async {
    var query = _algolia.instance.index('users').query(key);
    query.setAttributesForFaceting(['userName']);
    query.setFacets(['userName']);
    var querySnapshot = await query.getObjects();
    var results = querySnapshot.hits;
    _searchResults.add(UnmodifiableListView(results));
  }

  @override
  void initState() {
    super.initState();
    searchBarFocusNode.addListener(() {
      if(searchBarFocusNode.hasFocus){
        overlayEntry = _createOverlay();
        Overlay.of(context)!.insert(overlayEntry!);
      }else overlayEntry?.remove();
    });

    _searchController.addListener(() {
      // setState(() {
      //   _getResults(_searchController.text);
      // });
      if(_searchController.text.length >= 2){
        _getResults(_searchController.text);
      }
    });
  }

  void sendRequest(Map<String,dynamic> dataMap) async {
    Auth auth = Auth();
    UserProfile? receiver = await auth.getProfileFromFirebase(dataMap['userID']);
    if(receiver != null){
      SessionData.instance.sendRequest([
        receiver
      ]);
    }else print('Received null user from Firebase!');
  }

  @override
  void dispose() {
    _searchController.dispose();
    searchBarFocusNode.dispose();
    super.dispose();
  }

  OverlayEntry _createOverlay() {
    RenderBox renderBox = context.findRenderObject()! as RenderBox;
    var size = renderBox.size;
    var radius = Radius.circular(15);

    return OverlayEntry(
      builder: (context)
        => Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: layerLink,
            offset: Offset(0.0, size.height + 2),
            child: Material(
              color: AppStyle.secondaryColor,
              borderRadius: BorderRadius.only(bottomLeft: radius, bottomRight: radius),
              child: StreamBuilder<UnmodifiableListView<AlgoliaObjectSnapshot>>(
                stream: _searchResults.stream,
                builder: (context, snapshot) {
                  if(snapshot.hasData && snapshot.data != null){
                    var resultsBorder = BorderSide(
                      color: AppStyle.defaultBorderColor
                    );
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppStyle.secondaryColor,
                        borderRadius: BorderRadius.only(bottomLeft: radius, bottomRight: radius),
                      ),
                      width: size.width,
                      height: 80.0 * snapshot.data!.length,
                      child: ListView.builder(
                        itemCount: snapshot.data != null ? snapshot.data!.length : 0,
                        itemBuilder: (context, index){
                          bool requestSent = false;
                          var dataMap = snapshot.data![index].data;
                          return ListTile(
                            contentPadding: EdgeInsets.all(10),
                            leading: Container(
                              margin: EdgeInsets.only(right: 10),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppStyle.defaultBorderColor
                                ),
                                color: AppStyle.secondaryColor,
                                image: DecorationImage(
                                  image: NetworkImage(
                                    dataMap['pfpUrl']
                                  )
                                )
                              ),
                            ),
                            title: Text(
                              dataMap['userName'],
                              style: TextStyle(
                                color: AppStyle.whiteAccent,
                                fontSize: 16
                              ),
                            ),
                            trailing: IconButton(
                              color: AppStyle.primaryButtonColor,
                              icon: !requestSent
                                  ? Icon(Icons.add, color: AppStyle.whiteAccent,)
                                  : Icon(Icons.check, color: AppStyle.whiteAccent,),
                              onPressed: (){
                                sendRequest(dataMap);
                                setState(() {
                                  requestSent = true;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return Text('Loading...', style: TextStyle(color: AppStyle.whiteAccent),);
                }
              ),
            ),
          ),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return CompositedTransformTarget(
      link: layerLink,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        width: width * 0.2,
        decoration: BoxDecoration(
            color: AppStyle.secondaryColor,
            borderRadius: BorderRadius.all(Radius.circular(15)),
            border: Border.all(
                color: AppStyle.defaultBorderColor
            )
        ),
        child: TextField(
          focusNode: searchBarFocusNode,
          maxLines: 1,
          style: TextStyle(
            color: AppStyle.whiteAccent,
            fontSize: 18
          ),
          controller: _searchController,
          decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                color: AppStyle.defaultUnselectedColor,
                // size: 18,
              ),
              hintText: 'Search...',
              hintStyle: TextStyle(
                  color: AppStyle.defaultUnselectedColor,
                  fontSize: 18
              ),
              border: InputBorder.none
          ),
        ),
      ),
    );
  }
}
