import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ms_engage_proto/model/chat.dart';
import 'package:ms_engage_proto/model/user.dart';
import 'package:ms_engage_proto/store/session_data.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/screens/viewmodel/chat_view_model.dart';
import 'package:ms_engage_proto/ui/widgets/chat_card.dart';
import 'package:ms_engage_proto/ui/widgets/default_button.dart';

class ChatViewer extends StatefulWidget {
  final Stream<ChatRoom?> viewController;
  const ChatViewer({
    Key? key,
    required this.viewController,
  }) : super(key: key);

  @override
  _ChatViewerState createState() => _ChatViewerState();
}

class _ChatViewerState extends ChatViewModel<ChatViewer> {

  TextEditingController _chatTextController = TextEditingController();
  List<PlatformFile> attachments = [];

  @override
  void initState() {
    super.initState();
    widget.viewController.listen((chatRoom) {
      chats = <Chat>[];
      init(chatRoom);
    });
  }

  @override
  void dispose() {
    _chatTextController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _sendChat(UserProfile currentUser, ChatRoom chatRoom){
    if(_chatTextController.text.isNotEmpty){
      SessionData.instance.sendChat(Chat(
        senderID: currentUser.userID,
        message: _chatTextController.text,
      ), chatRoom,
        attachments.isEmpty ? null : attachments
      );
      setState(() {
        _chatTextController.text = '';
      });
    }
  }

  void _pickAttachments() async {
    var pickerResult = await FilePicker.platform.pickFiles();
    if(pickerResult != null){
      setState(() {
        attachments = pickerResult.files;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final divider = Divider(
      height: height * 0.06,
      color: AppStyle.darkBorderColor,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.03),
      child: StreamBuilder<ChatRoom?>(
        stream: widget.viewController,
        builder: (context, snapshot){
          if(snapshot.hasData && snapshot.data != null){
            // TODO: Apply better solution later
            UserProfile currentUser = SessionData.instance.currentUser!;
            UserProfile other
                = snapshot.data!.participants.where((user)
                  => user.userID !=currentUser.userID).first;
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 75,
                      width: 75,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        border: Border.all(
                            color: AppStyle.defaultBorderColor
                        ),
                        image: other.pfpUrl != null
                            ? DecorationImage(
                                image: NetworkImage(
                                 other.pfpUrl!
                                ),
                              )
                            : null,
                      ),
                      child: other.pfpUrl != null
                        ? Container()
                        : Center(
                            child: Icon(
                              FontAwesomeIcons.user,
                              color: AppStyle.defaultUnselectedColor,
                            ),
                          )
                    ),
                    SizedBox(width: 20,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          other.userName,
                          style: TextStyle(
                            color: AppStyle.whiteAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 4,),
                        Text(
                          other.email!,
                          style: TextStyle(
                            color: AppStyle.defaultUnselectedColor
                          ),
                        )
                      ],
                    )
                  ],
                ),
                divider,
                Expanded(
                  child: StreamBuilder<List<Chat>>(
                    stream: chatStreamController.stream,
                    builder: (context, snapshot){
                      if(snapshot.hasData && snapshot.data!.length > 0){
                        Future.delayed(const Duration(milliseconds: 50), ()
                        =>scrollController.animateTo(
                          scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.ease,
                        ));
                        return SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            children: snapshot.data!.map((chat) {
                              bool isCurrentUser = chat.senderID == currentUser.userID;
                              return Row(
                                mainAxisAlignment: isCurrentUser
                                    ? MainAxisAlignment.end : MainAxisAlignment.start,
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: width * 0.2,
                                      minWidth: 0
                                    ),
                                    child: ChatCard(
                                      isCurrentUser: isCurrentUser,
                                      chat: chat,
                                      other: other,
                                    ),
                                  )
                                ],
                              );
                            }).toList(),
                          ),
                        );
                      }
                      return Center(
                        child: Container(
                          // TODO: Add Something
                        ),
                      );
                    },
                  ),
                ),
                divider,
                Container(
                  height: height * 0.08,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatTextController,
                          style: TextStyle(
                            color: AppStyle.whiteAccent,
                            fontSize: 14,
                          ),
                          maxLines: null,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Message ${other.userName}',
                            hintStyle: TextStyle(
                              color: AppStyle.defaultUnselectedColor,
                              fontSize: 14
                            ),

                          ),
                        ),
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      DefaultButton(
                        onPress: () async => _pickAttachments(),
                        child: Text(
                          'attach',
                          style: TextStyle(
                              color: AppStyle.whiteAccent,
                              fontSize: 16
                          ),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      DefaultButton(
                        onPress: () => _sendChat(currentUser, snapshot.data!),
                        child: Text(
                          'Send',
                          style: TextStyle(
                            color: AppStyle.whiteAccent,
                            fontSize: 16
                          ),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      )
                    ],
                  ),
                )
              ],
            );
          }
          return Center(
            child: Container(
              //TODO: Add something similar to when ContactsViewer has null data
            ),
          );
        },
      ),
    );
  }
}
