import 'package:flutter/material.dart';
import 'package:ms_engage_proto/model/chat.dart';
import 'package:ms_engage_proto/model/user.dart';
import 'package:ms_engage_proto/store/session_data.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/widgets/input_field.dart';

class ChatView extends StatefulWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {

  TextEditingController _searchController = TextEditingController();

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
                            UserProfile user = chatRoom.participants[1];
                           return Container(
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
          color: Colors.red,
        )
      ],
    );
  }
}
