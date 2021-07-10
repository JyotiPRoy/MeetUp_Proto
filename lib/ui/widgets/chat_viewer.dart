import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ms_engage_proto/model/chat.dart';
import 'package:ms_engage_proto/model/user.dart';
import 'package:ms_engage_proto/store/session_data.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/screens/viewmodel/chat_view_model.dart';
import 'package:ms_engage_proto/ui/widgets/attachment_tray.dart';
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
  bool _isSending = false;

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
    chatTextController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _sendChat(UserProfile currentUser, ChatRoom chatRoom) async {
    if (chatTextController.text.isNotEmpty || attachments.isNotEmpty) {
      await SessionData.instance.sendChat(
          Chat(
            senderID: currentUser.userID,
            message: chatTextController.text,
          ),
          chatRoom,
          attachments.isEmpty ? null : attachments);
      visibilityController.add(false);
      attachmentController.add([]);
      setState(() {
        chatTextController.text = '';
        _isSending = false;
      });
    }
  }

  void _pickAttachments() async {
    var pickerResult = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (pickerResult != null) {
      setState(() {
        attachments = pickerResult.files;
      });
    }
    attachmentController.add(attachments);
    await Future.delayed(const Duration(milliseconds: 50));
    visibilityController.add(true);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final divider = Divider(
      height: height * 0.02,
      color: AppStyle.darkBorderColor,
    );

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.04, vertical: height * 0.03),
      child: StreamBuilder<ChatRoom?>(
        stream: widget.viewController,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            UserProfile currentUser = SessionData.instance.currentUser!;
            UserProfile? other;
            if(snapshot.data is !SessionChat){
              other = snapshot.data!.participants
              .where((user) => user.userID != currentUser.userID)
              .first;
            }

            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    other == null ? SizedBox()
                   : Container(
                        height: 75,
                        width: 75,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          border:
                              Border.all(color: AppStyle.defaultBorderColor),
                          image: other.pfpUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(other.pfpUrl!),
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
                              )),
                    SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          other == null ? 'Chat'
                          : other.userName,
                          style: TextStyle(
                              color: AppStyle.whiteAccent,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        other == null ? SizedBox()
                        : Text(
                            other.email!,
                            style:
                              TextStyle(color: AppStyle.defaultUnselectedColor),
                        )
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                divider,
                SizedBox(
                  height: height * 0.02,
                ),
                Expanded(
                  child: StreamBuilder<List<Chat>>(
                    stream: chatStreamController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.length > 0) {
                        Future.delayed(
                            const Duration(milliseconds: 50),
                            () => scrollController.animateTo(
                                  scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.ease,
                                ));
                        return SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            children: snapshot.data!.map((chat) {
                              bool isCurrentUser =
                                  chat.senderID == currentUser.userID;
                              return Row(
                                mainAxisAlignment: isCurrentUser
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxWidth: width * 0.2, minWidth: 0),
                                    child: ChatCard(
                                      isCurrentUser: isCurrentUser,
                                      chat: chat,
                                      other:
                                        snapshot.data is !SessionChat
                                        ? null
                                        : other,
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

                        ),
                      );
                    },
                  ),
                ),
                AttachmentTray(
                  visibilityController: visibilityController,
                  attachmentController: attachmentController,
                ),
                divider,
                Container(
                  height: height * 0.08,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: chatTextController,
                          style: TextStyle(
                            color: AppStyle.whiteAccent,
                            fontSize: 14,
                          ),
                          maxLines: null,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Message ${other == null ? '' : other.userName}',
                            hintStyle: TextStyle(
                                color: AppStyle.defaultUnselectedColor,
                                fontSize: 14),
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
                              color: AppStyle.whiteAccent, fontSize: 16),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      DefaultButton(
                        onPress: () {
                          setState(() {
                            _isSending = true;
                          });
                          _sendChat(currentUser, snapshot.data!);
                        },
                        child: _isSending
                            ? StreamBuilder<double>(
                                stream: SessionData.instance.uploadProgress,
                                builder: (context, snapshot) {
                                  return Container(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: AppStyle.primaryColor,
                                      value: snapshot.data,
                                    ),
                                  );
                                },
                              )
                            : Text(
                                'Send',
                                style: TextStyle(
                                    color: AppStyle.whiteAccent, fontSize: 16),
                              ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 20),
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
