import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ms_engage_proto/model/chat.dart';
import 'package:ms_engage_proto/model/user.dart';
import 'package:ms_engage_proto/store/session_data.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/widgets/chat_viewer.dart';
import 'package:ms_engage_proto/ui/widgets/input_field.dart';
import 'package:rxdart/rxdart.dart';

class ChatView extends StatefulWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {

  TextEditingController _searchController = TextEditingController();
  final viewController = BehaviorSubject<ChatRoom?>();

  @override
  void initState() {
    super.initState();
    viewController.add(null);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final divider = Divider(
      height: height * 0.06,
      color: AppStyle.darkBorderColor,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: width * 0.03, right: width * 0.03, top: 25),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: AppStyle.defaultBorderColor
              )
            )
          ),
          width: width * 0.3,
          height: height * 0.87,
          child: Column(
            children: [
              InputField(
                hintText: 'Search for a Contact',
                controller: _searchController,
                validator: (val){return null;},
                fieldName: '',
              ),
              divider,
              Expanded(
                child: SingleChildScrollView(
                  child: StreamBuilder<List<ChatRoom>>(
                    stream: SessionData.instance.chatRooms,
                    builder: (context, snapshot) {
                      if(snapshot.hasData && snapshot.data != null){
                        return Column(
                          children: snapshot.data!.map((chatRoom){
                            bool isSelected = false;
                            UserProfile user
                              = chatRoom.participants.where((user)
                                => user.userID != SessionData.instance.currentUser!.userID).first;
                           return Material(
                             color: AppStyle.primaryColor,
                             borderRadius: BorderRadius.circular(20),
                             clipBehavior: Clip.hardEdge,
                             child: InkWell(
                               onTap: (){
                                 viewController.add(chatRoom);
                               },
                               // splashColor: AppStyle.defaultSplash,
                               child: Padding(
                                 padding: const EdgeInsets.symmetric(horizontal: 16),
                                 child: Container(
                                   height: 75,
                                   child: Row(
                                     crossAxisAlignment: CrossAxisAlignment.center,
                                     children: [
                                       Container(
                                         clipBehavior: Clip.antiAlias,
                                         width: 50,
                                         height: 50,
                                         decoration: BoxDecoration(
                                           borderRadius: BorderRadius.all(Radius.circular(15)),
                                           border: Border.all(
                                             color: AppStyle.defaultBorderColor,
                                           ),
                                           color: AppStyle.secondaryColor,
                                         ),
                                         child: user.pfpUrl != null
                                            ? Image.network(
                                                user.pfpUrl!
                                              )
                                            : Container(),
                                       ),
                                       SizedBox(width: 16,),
                                       Text(
                                         user.userName,
                                         style: TextStyle(
                                           color: AppStyle.whiteAccent,
                                           fontSize: 16
                                         ),
                                       )
                                     ],
                                   ),
                                 ),
                               ),
                             ),
                           );
                          }
                          ).toList(),
                        );
                      }
                      return Center(
                        child: Container(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator(
                            color: AppStyle.whiteAccent,
                          ),
                        ),
                      );
                    }
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: width * 0.62,
          height: height * 0.87,
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.04, vertical: height * 0.03),
          child: ChatViewer(
            viewController: viewController,
            isSession: false,
          ),
        )
      ],
    );
  }
}
