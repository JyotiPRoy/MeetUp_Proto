import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:ms_engage_proto/model/chat.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/widgets/chat_card.dart';
import 'package:ms_engage_proto/ui/widgets/default_button.dart';

class MultiAttachmentViewer extends StatelessWidget {
  final List<ChatAttachment> attachments;

  const MultiAttachmentViewer({
    Key? key,
    required this.attachments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final divider = Divider(
      height: height * 0.02,
      color: AppStyle.darkBorderColor,
    );

    return Container(
      padding: EdgeInsets.all(16),
      height: height * 0.3,
      width: width * 0.2,
      decoration: BoxDecoration(
        color: AppStyle.primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            '${attachments.length} attachments',
            style: TextStyle(
              color: AppStyle.whiteAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          divider,
          Expanded(
            child: ListView(
              children: attachments
                  .map(
                    (attachment) => SingleAttachmentViewer(
                      attachment: attachment,
                      attachmentType: AttachmentTypeExtension.fromString(''),
                    ),
                  )
                  .toList(),
            ),
          ),
          divider,
          Container(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DefaultButton(
                    onPress: (){},
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          color: AppStyle.whiteAccent
                      ),
                    ),
                    buttonColor: AppStyle.secondaryColor,
                    buttonBorder: BorderSide(
                      color: AppStyle.defaultBorderColor,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  ),
                  SizedBox(width: 16,),
                  DefaultButton(
                    onPress: (){},
                    child: Text(
                      'Download All',
                      style: TextStyle(
                        color: AppStyle.whiteAccent
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  )
                ],
            ),
          )
        ],
      ),
    );
  }
}
