import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:ms_engage_proto/model/chat.dart';
import 'package:ms_engage_proto/model/user.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:http/http.dart' as http;
import 'package:ms_engage_proto/ui/modals/attachment_viewer.dart';
import 'package:ms_engage_proto/utils/download_attachment_web.dart';

class ChatCard extends StatelessWidget {
  final bool isCurrentUser;
  final Chat chat;
  final UserProfile? other;
  const ChatCard({
    Key? key,
    required this.isCurrentUser,
    required this.chat,
    this.other,
  }) : super(key: key);

  void showMultiAttachmentDialog(
      BuildContext context, List<ChatAttachment> attachments) async {
    Dialog dialog = Dialog(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: AppStyle.primaryColor,
      child: MultiAttachmentViewer(
        attachments: attachments,
      ),
    );
    await showDialog<Dialog>(
      context: context,
      builder: (context) => dialog,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isCurrentUser
              ? AppStyle.primaryButtonColor
              : AppStyle.secondaryColor,
          border: isCurrentUser
              ? null
              : Border.all(color: AppStyle.defaultBorderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          other != null
          ? Container(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              isCurrentUser ? 'You' : other!.userName,
              style: TextStyle(
                color: AppStyle.whiteAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold
              ),
            ),
          )
          : SizedBox(),
          chat.attachments != null && chat.attachments!.isNotEmpty
              ? chat.attachments!.length > 1
                  ? Column(
                    children: [
                      MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => showMultiAttachmentDialog(
                                context, chat.attachments!),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppStyle.whiteAccent.withOpacity(0.3),
                              ),
                              child: Text(
                                '${chat.attachments!.length} attachments.',
                                style: TextStyle(
                                  color: AppStyle.whiteAccent,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  )
                  : SingleAttachmentViewer(
                      attachment: chat.attachments!.first,
                      attachmentType: AttachmentTypeExtension.fromString(
                          lookupMimeType(chat.attachments!.first.fileName)!),
                    )
              : SizedBox(),
          Container(
            child: Text(
              chat.message!,
              style: TextStyle(color: AppStyle.whiteAccent, fontSize: 16),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

class SingleAttachmentViewer extends StatefulWidget {
  final ChatAttachment attachment;
  final AttachmentType attachmentType;
  const SingleAttachmentViewer(
      {Key? key, required this.attachment, required this.attachmentType})
      : super(key: key);

  @override
  _SingleAttachmentViewerState createState() => _SingleAttachmentViewerState();
}

class _SingleAttachmentViewerState extends State<SingleAttachmentViewer> {
  bool isImage = false;

  @override
  void initState() {
    super.initState();
    isImage = widget.attachmentType == AttachmentType.Image;
  }

  void _downloadImage() async {
    // var anchorElement = AnchorElement(href: url);
    // anchorElement.setAttribute('download', '${widget.attachment.fileName}');
    // anchorElement.click();
    // var downloadFunc = DownloadAttachmentWeb();
    // downloadFunc.download(widget.attachment);
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Container();
    switch (widget.attachmentType) {
      case AttachmentType.Image:
        {
          break;
        }
      case AttachmentType.Video:
        {
          break;
        }
      case AttachmentType.File:
        {
          child = Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                widget.attachmentType.icon,
                color: AppStyle.whiteAccent,
              ),
              SizedBox(
                width: 10,
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 200
                ),
                child: Text(
                  widget.attachment.fileName,
                  style: TextStyle(fontSize: 16, color: AppStyle.whiteAccent),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          );
        }
    }

    return Column(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: isImage ? () => _downloadImage() : null,
            child: Container(
              height: isImage ? 150 : null,
              width: isImage ? 266 : null,
              padding: isImage
                  ? null
                  : EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppStyle.whiteAccent.withOpacity(0.3),
                image: isImage
                    ? DecorationImage(
                        image: NetworkImage(
                          widget.attachment.downloadUrl,
                        ),
                      )
                    : null,
              ),
              child: child,
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
